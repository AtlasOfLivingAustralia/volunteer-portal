package au.org.ala.volunteer

import grails.orm.PagedResultList

class ForumService {

    static transactional = true

    PagedResultList getProjectForumTopics(Project project, Map params = null) {
        def c = ProjectForumTopic.createCriteria()
        def results = c.list(max:params?.max, offset: params?.offset) {
            eq("project", project)
            and {
                order("sticky")
                order("priority", "desc")
                order("dateCreated", "desc")
            }
            if (params?.max) {
                maxResults(params.max as Integer)
            }
            if (params?.offset) {
                firstResult(params.offset as Integer)
            }
        }
        return results as PagedResultList
    }

    PagedResultList getTopicMessages(ForumTopic topic, Map params = null) {
        def c = ForumMessage.createCriteria()
        def results = c.list(max:params?.max, offset: params?.offset) {
            eq("topic", topic)
            and {
                order("sticky")
                order("date", "desc")
            }
            if (params?.max) {
                maxResults(params.max as Integer)
            }
            if (params?.offset) {
                firstResult(params.offset as Integer)
            }
        }
        return results as PagedResultList
    }
}
