package au.org.ala.volunteer

import groovy.sql.Sql

class UserController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def taskService
    def authService
    def userService
    def fieldSyncService
    def fieldService
    def dataSource
    def ROLE_ADMIN = grailsApplication.config.auth.admin_role
    def achievementService

    def index = {
        redirect(action: "list", params: params)
    }

    def logout = {
        session.invalidate()
        redirect(url:"${params.casUrl}?url=${params.appUrl}")
    }

    def myStats = {
      userService.registerCurrentUser()
      def currentUser = authService.username()
      def userInstance = User.findByUserId(currentUser)
      redirect(action: "show", id: userInstance.id, params: params )
    }

    def list = {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        if (!params.sort){
          // set default sort and order
          params.sort = params.sort ? params.sort : "transcribedCount"
          params.order = "desc"
        }
        def currentUser = authService.username()
        def results = userService.filteredUserList(params)
        results.list.each { user ->
            def count = taskService.getCountsForUserId(user.userId)?.get(0)
            log.debug(user.userId + " count: " + count)
            if (user.transcribedCount != count) {
                // Update incorrect transcribed count (from prev bug)
                user.transcribedCount = count.toInteger()
                if (!user.hasErrors() && user.save(flush:true)) {
                    log.info("Updating counts for " + user.displayName)
                } else {
                    log.error("Failed to update user: " + user.userId + " - " + user.hasErrors())
                }
            }
        }

        [userInstanceList: results.list, userInstanceTotal: results.count, currentUser: currentUser]
    }

    def project = {
        def projectInstance = Project.get(params.id)
        if (projectInstance) {
            params.max = Math.min(params.max ? params.int('max') : 10, 100)
            if(!params.sort){
              params.sort = params.sort ? params.sort : "displayName"
              params.order = "asc"
            }
            //def userList = User.list(params)
            def userList = []
            def userIds = taskService.getUserIdsAndCountsForProject(projectInstance, params)
            def userCount = taskService.getUserIdsAndCountsForProject(projectInstance, new HashMap<String, Object>()).size()
            userIds.each {
                // iterate over each user and assign to a role.
                def userId = it[0]
                def count = it[1]
                def user = User.findByUserId(userId)
                if (user) {
                    user.transcribedCount = count
                    userList.add(user)
                }
            }

//            userList.each { user ->
//                def count = taskService.getCountsForProjectAndUserId(projectInstance, user.userId)?.get(0)
//                log.debug(user.userId + " count: " + count)
//                if (user.transcribedCount != count) {
//                    // get counts for current project
//                    user.transcribedCount = count.toInteger() // temp set counts for just current project
//                }
//            }

            def currentUser = authService.username()
            render(view: "list", model:[userInstanceList: userList, userInstanceTotal: userCount, currentUser: currentUser, projectInstance: projectInstance])
        } else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        }
    }

    def create = {
        def userInstance = new User()
        userInstance.properties = params
        return [userInstance: userInstance]
    }

    def save = {
        def userInstance = new User(params)
        if (userInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'user.label', default: 'User'), userInstance.id])}"
            redirect(action: "show", id: userInstance.id)
        }
        else {
            render(view: "create", model: [userInstance: userInstance])
        }
    }

    def show = {
        // Getting the list of tasks for the user is a bit tricky because
        // we need to get the catalog number, if it exists, for each task.
        // The way this used to work was to get all the tasks, then extract all the
        // field values, and match them up, it this was fine, but it meant that
        // you couldn't sort by catalog number, but more importantly, you couldn't
        // search by catalog number, which is a user requested feature.

        // So instead this method performs a custom SQL query that performs the outer join
        // and can also handle the sort and pagination parameters

        def userInstance = User.get(params.id)
        def currentUser = authService.username()

        params.max = Math.min(params.max ? params.int('max') : 20, 50)
        params.offset = params.int('offset') ?: 0
        params.order = params.order ?: ""

        if (!params.sort) {
            params.sort = "lastEdit"
            params.order = "desc"
        }

        def project = Project.get(params.projectId)
        def sql = new Sql(dataSource: dataSource)

        String sort_clause = "t.id ${params.order}"
        String search_clause = ""

        if (project) {
            search_clause = " AND p.id = ${params.projectId}"
        }

        if (params.q) {
            String q = params.q?.toString()?.toLowerCase()
            search_clause += " AND (lower(t.external_identifier) like '%${q}%' OR lower(field.value) like '%${q}%' OR lower(p.featured_label) like '%${q}%' or lower(to_char(lastEdit, 'dd MON, yyyy HH24:MI.SS')) like '%${q}%')"
        }

        if (params.sort) {
            sort_clause = "${params.sort} IS NOT NULL, ${params.sort} ${params.order}"
        }

        String select = "SELECT t.id as id, t.external_identifier as externalIdentifier, t.fully_transcribed_by as fullyTranscribedBy, t.is_valid as isValid, field.value as catalogNumber, p.id as projectId, p.featured_label as project, field2.lastEdit as lastEdit"

        String fromWhere = """
            FROM Project p, Task t LEFT OUTER JOIN (select f.task_id, f.value from Field f where f.name = 'catalogNumber') as field on field.task_id = t.id
            LEFT OUTER JOIN (SELECT task_id, max(updated) as lastEdit from field f where f.transcribed_by_user_id = '${userInstance.userId}' group by f.task_id) as field2 on field2.task_id = t.id
            WHERE t.fully_transcribed_by = '${userInstance.userId}' and p.id = t.project_id ${search_clause}
        """

        String pageinationControl = """
            ORDER BY ${sort_clause}
            LIMIT ${params.int('max')}
            OFFSET ${params.int('offset')}
        """

        String query = "${select} ${fromWhere} ${pageinationControl}"
        String countQuery = "SELECT count(*) ${fromWhere}"

        def totalMatchingTasks = sql.firstRow(countQuery)[0]

        def viewList = []

        sql.eachRow(query) { row ->
                    def taskRow = [id: row.id, externalIdentifier:row.externalIdentifier, catalogNumber: row.catalogNumber, fullyTranscribedBy: row.fullyTranscribedBy, projectId: row.projectId, project:  row.project ]

                    taskRow.lastEdit = row.lastEdit

                    if (row.isValid == true) {
                        taskRow.status = "Validated"
                    } else if (row.isValid == false) {
                        taskRow.status = "Invalidated"
                    } else if (row.fullyTranscribedBy?.length() > 0) {
                        taskRow.status = "Transcribed"
                    } else {
                        taskRow.status = "Saved"
                    }
                    viewList.add(taskRow)
        }

        int totalTranscribedTasks
        def savedTasks
        def totalSavedTasks

        if (project) {
            savedTasks = taskService.getRecentlySavedTasksByProject(userInstance.getUserId(), project, params)
            totalSavedTasks = taskService.getRecentlySavedTasksByProject(userInstance.getUserId(), project, new HashMap<String, Object>()).size()
            totalTranscribedTasks = Task.countByFullyTranscribedByAndProject(userInstance.getUserId(), project)
        } else {
            savedTasks = taskService.getRecentlySavedTasks(userInstance.getUserId(), params)
            totalSavedTasks = taskService.getRecentlySavedTasks(userInstance.getUserId(), new HashMap<String, Object>()).size()
            totalTranscribedTasks = Task.countByFullyTranscribedBy(userInstance.getUserId())
        }

        def achievements = achievementService.calculateAchievements(userInstance)

        if (!userInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'user.label', default: 'User'), params.id])}"
            redirect(action: "list")
        } else {
            [   userInstance: userInstance, currentUser: currentUser, project: project,
                matchingTasks: viewList, totalMatchingTasks: totalMatchingTasks, totalTranscribedTasks: totalTranscribedTasks,
                savedTasks: savedTasks, totalSavedTasks: totalSavedTasks, achievements: achievements]
        }
    }

    def edit = {
        def currentUser = authService.username()
        def userInstance = User.get(params.id)
        if (currentUser != null && (authService.userInRole(ROLE_ADMIN) || currentUser == userInstance.userId)) {
            if (!userInstance) {
                flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'user.label', default: 'User'), params.id])}"
                redirect(action: "list")
            }
            else {
                return [userInstance: userInstance]
            }
        } else {
            flash.message = "You do not have permission to edit this user page (ROLE_ADMIN required)"
            redirect(action: "list")
        }
    }

    def update = {
        def userInstance = User.get(params.id)
        def currentUser = authService.username()
        if (userInstance && currentUser && (authService.userInRole(ROLE_ADMIN) || currentUser == userInstance.userId)) {
            if (params.version) {
                def version = params.version.toLong()
                if (userInstance.version > version) {
                    
                    userInstance.errors.rejectValue("version", "default.optimistic.locking.failure", [message(code: 'user.label', default: 'User')] as Object[], "Another user has updated this User while you were editing")
                    render(view: "edit", model: [userInstance: userInstance])
                    return
                }
            }
            userInstance.properties = params
            if (!userInstance.hasErrors() && userInstance.save(flush: true)) {
                flash.message = "${message(code: 'default.updated.message', args: [message(code: 'user.label', default: 'User'), userInstance.id])}"
                redirect(action: "show", id: userInstance.id)
            }
            else {
                render(view: "edit", model: [userInstance: userInstance])
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'user.label', default: 'User'), params.id])}"
            redirect(action: "list")
        }
    }

    def delete = {
        def userInstance = User.get(params.id)
        def currentUser = authService.username()
        if (userInstance && currentUser && authService.userInRole(ROLE_ADMIN)) {
            try {
                userInstance.delete(flush: true)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'user.label', default: 'User'), params.id])}"
                redirect(action: "list")
            }
            catch (org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "${message(code: 'default.not.deleted.message', args: [message(code: 'user.label', default: 'User'), params.id])}"
                redirect(action: "show", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'user.label', default: 'User'), params.id])}"
            redirect(action: "list")
        }
    }
}
