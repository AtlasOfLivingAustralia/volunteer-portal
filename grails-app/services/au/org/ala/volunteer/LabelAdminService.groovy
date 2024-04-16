package au.org.ala.volunteer

import grails.gorm.transactions.Transactional

@Transactional
class LabelAdminService {

    /**
     * Returns true if the label is in use by an entity.
     * @param label
     * @return true if the label is in use, false if not.
     */
    def isLabelInUse(Label label) {
        if (!label) {
            return false
        }

        if (label.projects?.size() > 0) return true
        if (label.landingPages?.size() > 0) return true
        // if (label.users?.size() > 0) return true

        false
    }

    /**
     * Retrieves the lists of entities that use the provided label.
     * @param label
     * @return a map containing individual lists for projects, landing pages and users.
     */
    def getLabelUsage(Label label) {
        def entityList = [:]
        def projectList = []
        label.projects.each {project ->
            projectList.add([id: project.id, name: project.name])
        }
        if (projectList.size() > 0) entityList.put("projects", projectList)

        def pageList = []
        label.landingPages.each {lPage ->
            pageList.add([id: lPage.id, name: lPage.title])
        }
        if (pageList.size() > 0) entityList.put("landingPages", pageList)

        // Todo Add users
        entityList
    }
}
