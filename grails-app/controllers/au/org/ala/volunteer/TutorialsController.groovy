package au.org.ala.volunteer

import grails.gorm.transactions.Transactional
import org.springframework.web.multipart.MultipartFile
import org.springframework.web.multipart.MultipartHttpServletRequest

import java.util.regex.Matcher
import java.util.regex.Pattern

import static javax.servlet.http.HttpServletResponse.SC_FORBIDDEN

class TutorialsController {

    def tutorialService
    def userService

    public static final String SESSION_KEY_TUTORIAL_FILTER = "digivol_tutorial_filter"

    /**
     * Tutorial Index
     */
    def index() {
        def tutorialGroups = tutorialService.getTutorialGroups()
        def tutorialAdminCount = tutorialService.getAdminTutorials().size()

        [tutorialGroups: tutorialGroups, tutorialAdminCount: tutorialAdminCount]
    }

    /**
     * List of tutorials for an institution
     * @return
     */
    def groupList() {
        def institution = Institution.get(params.long('institution'))
        def admin = params.boolean("admin") == true
        log.debug("groupList: admin ${admin}")
        if (!institution && !admin) {
            flash.message = "Cannot find Institution with that ID"
            redirect (action: 'index')
            return
        }

        def tutorialList
        if (admin) tutorialList = Tutorial.findAllByInstitutionIsNullAndIsActive(true, [sort: 'name', order: 'asc'])
        else tutorialList = Tutorial.findAllByInstitutionAndIsActive(institution, true, [sort: 'name', order: 'asc'])
        [institution: institution, tutorialList: tutorialList]
    }

    /**
     * Tutorial Create
     */
    def create() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }
        def institutionList = getInstitutionList()

        [institutionList: institutionList]
    }

    /**
     * Tutorial Edit
     * @param tutorial the tutorial to edit
     */
    def edit(Tutorial tutorial) {
        if (!tutorial) {
            render(view: '/notFound')
            return
        }
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }

        def projectMatchList = []
        def migrate = params.boolean("migrate") == true
        if (migrate) {
            log.debug("Migrate flag is true, getting projects for migration")
            projectMatchList = tutorialService.findProjectsForMigration(tutorial)
        }

        render(view: 'edit', model: [tutorial: tutorial,
                                     tutorialUrl: tutorialService.getTutorialUrl(tutorial),
                                     institutionList: getInstitutionList(),
                                     projectMatchList: projectMatchList])
    }

    /**
     * Retrieves a list of institutions for the user. A Site Admin will return all.
     * @return the list of available institutions to the user.
     */
    private def getInstitutionList() {
        return (userService.isSiteAdmin() ? Institution.listApproved([sort: 'name', order: 'asc']) : userService.getAdminInstitutionList())
    }

    /**
     * Toggles a tutorials active status
     * @param tutorial the tutorial to modify
     */
    @Transactional
    def toggleTutorialStatus(Tutorial tutorial) {
        if (!tutorial) {
            render status: 404
            return
        }
        if (!userService.isInstitutionAdmin()) {
            response.sendError(SC_FORBIDDEN, "you don't have permission")
            return
        }
        if (!params.verifyId || params.verifyId as long != tutorial.id) {
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return
        }

        tutorial.isActive = (!tutorial.isActive)
        tutorial.save(flush: true, failOnError: true)
        flash.message = "The tutorial's status has been set to ${tutorial.isActive ? 'active' : 'inactive'}."
        redirect(uri: request?.getHeader("referer") ?: createLink(controller: 'tutorials', action: 'manage'))
    }

    /**
     * Updates a tutorial.
     * @param tutorial the tutorial to update
     */
    @Transactional
    def update(Tutorial tutorial) {
        if (!tutorial) {
            render(view: '/notFound')
            return
        }
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }

        if (request instanceof MultipartHttpServletRequest) {
            log.debug("Tutorial Controller => update multipart servlet request")
            MultipartFile f = ((MultipartHttpServletRequest) request).getFile('tutorialFile')

            if (tutorial.hasErrors()) {
                respond tutorial.errors, view: 'edit'
                return
            }

            def institution = Institution.get(params.long('institutionId'))
            if (institution) tutorial.institution = institution
            tutorial.updatedBy = userService.currentUser
            tutorial.name = params.get('name')
            tutorial.description = params.get('description')

            if (f && !f.empty) {
                log.debug("file: ${f}")
                def allowedMimeTypes = ['application/pdf']
                if (!allowedMimeTypes.contains(f.getContentType())) {
                    log.debug("Uploaded tutorial  is an invalid file type")
                    flash.message = "The file must be one of the following file types: ${allowedMimeTypes}"
                    redirect(action: 'edit', id: tutorial.id)
                    return
                }

                Pattern special = Pattern.compile(/[@#$%*=+|`'<>:;{}\\\\/]/);
                Matcher matcher = special.matcher(f.originalFilename)
                if (matcher.find()) {
                    log.debug("Invalid file name")
                    flash.message = "Filename includes illegal characters (one or more of the following: @,#,\$,%,^,*,=,<,>,{,},\\,/,|,',\",;,:,?)" +
                            ". <br />Please rename the file and try again."
                    redirect(action: 'edit', id: tutorial.id)
                    return
                }

                try {
                    // File was replaced. Remove existing file first.
                    tutorialService.deleteTutorial(tutorial.filename)
                    // Then save new file
                    File savedFile = tutorialService.uploadTutorialFile(f)

                    // Save the filename to the db before we can change it.
                    tutorial.filename = savedFile.name
                    tutorial.save(flush: true, failOnError: true)

                    // Rename new file to the structure using the tutorial details
                    tutorialService.migrateTutorialName(tutorial)

                    flash.message = "Tutorial uploaded and updated successfully"
                } catch (Exception ex) {
                    flash.message = "Failed to upload tutorial file: " + ex.message
                    log.error("Failed to upload tutorial file: " + ex.message, ex)
                }
            } else {
                // File wasn't updated, just the details
                flash.message = "Tutorial details updated successfully"
                tutorial.save(flush: true, failOnError: true)
            }

            if (params.migrate) {
                // Were there selected projects?
                def selectedProjects = params.list('projectLink')
                if (selectedProjects && selectedProjects.size() > 0) {
                    def projectList = []
                    selectedProjects.each { projectId ->
                        Project projectToAdd = Project.get(projectId as long)
                        if (projectToAdd) projectList.add(projectToAdd)
                    }
                    tutorialService.syncTutorialProjects(tutorial, projectList)
                }

                // Migrate tutorial name
                tutorialService.migrateTutorialName(tutorial)
            }
        }

        if (params.migrate) {
            redirect(action: 'manage', params: [migrate: true])
        } else {
            def filterParams = [:]
            filterParams.putAll(session[SESSION_KEY_TUTORIAL_FILTER] as Map)

            redirect(action: 'manage', params: session[SESSION_KEY_TUTORIAL_FILTER])
        }
    }

    /**
     * Deletes a tutorial
     * @param tutorial the tutorial to delete
     */
    @Transactional
    def delete(Tutorial tutorial) {
        if (!userService.isInstitutionAdmin()) {
            response.sendError(SC_FORBIDDEN, "you don't have permission")
            return
        }

        if (!tutorial) {
            response.sendError(SC_FORBIDDEN, "you don't have permission")
            return
        }

        // Find the file and delete it first.
        try {
            tutorialService.deleteTutorial(tutorial.filename)
        } catch (Exception ex) {
            flash.message = "Failed to delete tutorial file: " + ex.message
            log.error("Failed to delete tutorial file: " + ex.message, ex)
            redirect(action: 'manage', params: session[SESSION_KEY_TUTORIAL_FILTER])
        }

        // Delete the tutorial project records
        def projectList = tutorial.projects
        projectList.each {project ->
            tutorial.removeFromProjects(project)
        }
        tutorial.delete(flush: true, failOnError: true)

        flash.message = "Tutorial deleted successfully"
        redirect(action: 'manage', params: session[SESSION_KEY_TUTORIAL_FILTER])
    }

    /**
     * Saves a new tutorial file and record.
     */
    @Transactional
    def save() {
        if (!userService.isInstitutionAdmin()) {
            response.sendError(SC_FORBIDDEN, "you don't have permission")
            return
        }

        if (request instanceof MultipartHttpServletRequest) {
            log.debug("Tutorial Controller => save multipart servlet request")
            MultipartFile f = ((MultipartHttpServletRequest) request).getFile('tutorialFile')

            if (f) {
                def allowedMimeTypes = ['application/pdf']
                if (!allowedMimeTypes.contains(f.getContentType())) {
                    log.debug("Uploaded tutorial  is an invalid file type")
                    flash.message = "The file must be one of the following file types: ${allowedMimeTypes}"
                    redirect(action: 'create', params: params)
                    return
                }

                Pattern special = Pattern.compile(/[@#$%*=+|`'<>:;{}\\\\/]/);
                Matcher matcher = special.matcher(f.originalFilename)
                if (matcher.find()) {
                    log.debug("Invalid file name")
                    flash.message = "Filename includes illegal characters (one or more of the following: @,#,\$,%,^,*,=,<,>,{,},\\,/,|,',\",;,:,?)" +
                            ". <br />Please rename the file and try again."
                    redirect(action: 'create', params: params)
                    return
                }

                try {
                    Tutorial tutorial = new Tutorial()
                    tutorial.name = params.name
                    tutorial.description = params.description
                    tutorial.institution = Institution.get(params.long("institutionId"))
                    tutorial.isActive = true
                    tutorial.createdBy = userService.currentUser

                    File savedFile = tutorialService.uploadTutorialFile(f)
                    tutorial.filename = savedFile.name
                    tutorial.save(flush: true, failOnError: true)

                    // Rename file to the structure
                    def updatedName = tutorialService.generateTutorialFilename(tutorial)
                    if (updatedName) {
                        tutorialService.renameTutorial(tutorial.filename, updatedName)
                        tutorial.filename = updatedName
                        tutorial.save(flush: true, failOnError: true)
                    }

                    flash.message = "Tutorial uploaded successfully"
                } catch (Exception ex) {
                    flash.message = "Failed to upload tutorial file: " + ex.message
                    log.error("Failed to upload tutorial file: " + ex.message, ex)
                }
            }
        }

        redirect(action: 'manage')
    }

    /**
     * Management index
     */
    def manage() {
        if (!userService.isInstitutionAdmin()) {
            response.sendError(SC_FORBIDDEN, "you don't have permission")
            return
        }

        def migrate = params.boolean("migrate") == true
        def admin = params.boolean("admin") == true

        def institutionList = (userService.isSiteAdmin() ? Institution.listApproved([sort: 'name', order: 'asc']) :
                userService.getAdminInstitutionList())

        def statusFilterList = [[key: "active", value: "Active"],
                                [key: "inactive", value: "Inactive"],
                                [key: "hasProjects", value: "Linked to Expeditions"],
                                [key: "noProjects", value: "Not linked to Expeditions"]]

        params.sort = (params.sort ?: 'id')
        params.order = (params.order ?: 'asc')
        params.max = (params.max ?: 20)
        if (params.sort == 'status') {
            if (params.order == 'asc') params.sortFields = ['isActive', 'projects', 'id']
            else params.sortFields = ['projects', 'isActive', 'id']
        }

        def institutionFilter = []
        Institution institution = (params.institutionFilter ? Institution.get(params.long('institutionFilter')) : null)
        if (institution) {
            institutionFilter.add(institution)
            updateSessionFilter([institutionFilter: params.institutionFilter])
        } else {
            institutionFilter = institutionList
            removeSessionFilter("institutionFilter")
        }

        def statusFilter = (params.statusFilter ?: null)
        if (params.statusFilter) updateSessionFilter([statusFilter: params.statusFilter])
        else removeSessionFilter("statusFilter")

        if (params.q) updateSessionFilter([q: params.q])
        else removeSessionFilter("q")

        def tl = tutorialService.getTutorialsForManagement(institutionFilter, statusFilter, params, admin, migrate)
        def tutorialList = tl.tutorialList
        def tutorialListSize = tl.count
        params.remove('sortFields')

        render(view: 'manage', model: [tutorialList: tutorialList,
                                       tutorialListSize: tutorialListSize,
                                       institutionList: institutionList,
                                       statusFilterList: statusFilterList])
    }

    /**
     * Updates the session filter with the provided map
     * @param map the values to add to the session
     */
    private void updateSessionFilter(Map map) {
        if (!session[SESSION_KEY_TUTORIAL_FILTER]) {
            session[SESSION_KEY_TUTORIAL_FILTER] = [:]
        }
        (session[SESSION_KEY_TUTORIAL_FILTER] as Map).putAll(map)
    }

    /**
     * Clears the session filter.
     */
    private void clearSessionFilter() {
        session.removeAttribute(SESSION_KEY_TUTORIAL_FILTER)
    }

    /**
     * Removes a key from the session filter
     * @param key the key to remove
     */
    private void removeSessionFilter(String key) {
        if (!session[SESSION_KEY_TUTORIAL_FILTER]) return

        (session[SESSION_KEY_TUTORIAL_FILTER] as Map).remove(key)
    }
}
