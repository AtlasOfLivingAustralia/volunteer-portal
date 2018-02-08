package au.org.ala.volunteer

import grails.converters.JSON
import groovy.xml.MarkupBuilder
import au.org.ala.cas.util.AuthenticationCookieUtils

class TaskCommentController {

    def authService, userService

    def index() {
    }

    def saveComment() {

        if (params.taskId && params.comment) {
            def username = AuthenticationCookieUtils.getUserName(request)
            if (username) {
                def user = User.findByUserId(username)
                def task = Task.get(params.int("taskId"))
                def taskComment = new TaskComment(user: user, task: task, date: new Date(), comment: params.comment)
                taskComment.save(flush: true)
                render([message: message(code: 'taskComment.ok')] as JSON)
                return
            }
        }

        render([message: message(code: 'taskComment.missing_required_parameter')] as JSON)
    }

    def deleteComment() {
        if (params.commentId) {
            def commentId = params.int("commentId")
            def comment = TaskComment.get(commentId);
            if (comment) {
                comment.delete(flush: true);
                render([message: message(code: 'taskComment.ok')] as JSON)
            } else {
                render([message: message(code: 'taskComment.failed_to_load_comment')] as JSON)
            }
        } else {
            render([message: message(code: 'taskComment.no_task_id_specified')] as JSON)
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
                span(message(code: 'taskComment.there_are_no_comments')) {

                }
            }

            for (TaskComment comment : comments) {
                def showDelete = false;
                use (groovy.time.TimeCategory) {
                    def userid = authService.userId ?: "unknown"
                    if ( comment.user.userId == userid && comment.date >= 15.minutes.ago) {
                        showDelete = true;
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
                        mkp.yieldUnescaped(comment.comment?.encodeAsHTML().replace('\n', '<br/>\n'))
                    }
                    if (showDelete) {
                        div(class:"task-comment-delete") {
                            button("Delete", class: "delete-task-button", onClick:"deleteTaskComment(event, ${comment.id})", title: message(code: 'taskComment.you_have_15_minutes'))
                        }
                    }
                }

            }

        }


        render w.toString();
    }
}
