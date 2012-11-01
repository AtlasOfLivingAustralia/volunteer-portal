package au.org.ala.volunteer

class ForumController {

    def forumService
    def userService

    def index = { }

    def projectForum = {

        def projectId = params.int("projectId")
        if (projectId) {
            def projectInstance = Project.get(projectId)
            if (projectInstance) {
                def topics = forumService.getProjectForumTopics(projectInstance)
                return [projectInstance: projectInstance, topics: topics]
            }
        }

        flash.message = "Project with id ${params.projectId} could not be found!"
        redirect(controller: 'forum', action:'index')
    }

    def addProjectTopic = {
        def projectId = params.int("projectId")
        def projectInstance = Project.get(projectId)
        return [projectInstance: projectInstance]
    }

    def saveNewProjectTopic = {

        def projectId = params.int("projectId")
        if (projectId) {
            def projectInstance = Project.get(projectId)
            def title = params.title
            def text = params.text

            def messages = []

            if (!title) {
                messages << "You must enter a title for your forum topic"
            }

            if (!text) {
                messages << "You must enter a message for your forum topic"
            }

            if (messages) {
                def sb = new StringBuilder("The following errors occured:<ul>")
                messages.each {
                    sb << "<li>" + it + "</li>"
                }
                sb << "<ul>"

                flash.message = sb.toString()
                redirect(action: 'addProjectTopic', params: params)
            }

            def locked = false
            def sticky = false
            def priority = ForumTopicPriority.Normal

            if (userService.isForumModerator(projectInstance)) {
                locked = params.boolean("locked")
                sticky = params.boolean("sticky")
                priority = Enum.valueOf(ForumTopicPriority.class, params.priority as String)
            }

            println '*******************' + userService.currentUser

            def topic = new ProjectForumTopic(project: projectInstance, text: text, title: title, creator: userService.currentUser, dateCreated: new Date(), priority: priority, locked: locked, sticky: sticky)

            topic.save(flush: true, failOnError: true)

            redirect(action: 'projectForum', params: [projectId: projectInstance.id])
        }

    }

    def projectForumTopic = {
        def topic = ProjectForumTopic.get(params.id)
        [topic: topic, userInstance: userService.currentUser, projectInstance: topic.project]
    }

}
