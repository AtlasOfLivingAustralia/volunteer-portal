package au.org.ala.volunteer

import grails.converters.JSON
import groovy.time.TimeCategory
import groovy.xml.MarkupBuilder
import au.org.ala.cas.util.AuthenticationCookieUtils

class TaskCommentController {

    def authService, userService

    def saveComment() {
        if (params.taskId && params.comment) {
            def username = AuthenticationCookieUtils.getUserName(request)
            if (username) {
                def user = User.findByUserId(username)
                def task = Task.get(params.int("taskId"))
                def taskComment = new TaskComment(user: user, task: task, date: new Date(), comment: params.comment)
                taskComment.save(flush: true)
                render([message: 'ok'] as JSON)
                return
            }
        }

        render([message: 'failed! Missing a required parameter'] as JSON)
    }

    def deleteComment() {
        if (params.commentId) {
            def commentId = params.int("commentId")
            def comment = TaskComment.get(commentId)
            if (comment) {
                comment.delete(flush: true)
                render([message: 'ok'] as JSON)
            } else {
                render([message: 'Failed to load comment!'] as JSON)
            }
        } else {
            render([message: 'No task id specified!'] as JSON)
        }
    }

    def getCommentsAjax() {
        def w = new StringWriter()

        def task = Task.get(params.int("taskId"))

        def mb = new MarkupBuilder(w)
        def c = TaskComment.createCriteria()
        def comments = c {
            eq('task', task)
            order('date', 'asc')
        }

        mb.div {
            if (!comments) {
                span("There are no comments for this task.") {

                }
            }

            for (TaskComment comment : comments) {
                def showDelete = false
                use (TimeCategory) {
                    def userid = authService.userId ?: "unknown"
                    if ( comment.user.userId == userid && comment.date >= 15.minutes.ago) {
                        showDelete = true
                    }
                }

                def details = userService.detailsForUserId(comment.user.userId)

                div(class: "task-comment-container") {
                    div(class:"task-comment-header") {
                        div(class:"task-comment-username") {
                            mkp.yield(details.displayName)
                        }
                        div(class:"task-comment-date") {
                            mkp.yield(formatDate(date: comment.date, format:"d MMM yyyy HH:mm:ss"))
                        }
                        hr {}
                    }
                    div(class:"task-comment-text") {
                        mkp.yieldUnescaped(comment.comment?.encodeAsHTML()?.replace('\n', '<br/>\n'))
                    }
                    if (showDelete) {
                        div(class:"task-comment-delete") {
                            button("Delete", class: "delete-task-button", onClick:"deleteTaskComment(event, ${comment.id})", title:"You have 15 minutes from when you made this comment to delete it.")
                        }
                    }
                }
            }
        }

        render w.toString()
    }
}
