import au.org.ala.volunteer.*
import com.google.common.io.Resources
import grails.converters.JSON
import groovy.json.JsonSlurper
import groovy.sql.Sql
import org.apache.commons.lang.StringUtils
import org.apache.commons.lang3.time.StopWatch
import org.codehaus.groovy.grails.commons.ApplicationHolder
import org.codehaus.groovy.grails.web.json.JSONArray
import org.codehaus.groovy.grails.web.json.JSONObject
import org.hibernate.FlushMode

class BootStrap {

    def logService
    def projectTypeService
    def grailsApplication
    def auditService
    def sessionFactory
    def authService
    def dataSource
    def fullTextIndexService

    def init = { servletContext ->

        migrateUserIds();

        defineMetaMethods();

        prepareFrontPage();

        preparePickLists();

        prepareValidationRules();

        prepareProjectTypes();

        fixTaskLastViews();

        prepareDefaultLabels();

        // add system user
        if (!User.findByUserId('system')) {
            User u = new User(userId: 'system', email: ' support@ala.org.au', displayName: 'System User')
        }

        def internalRoles = [BVPRole.VALIDATOR, BVPRole.FORUM_MODERATOR, BVPRole.SITE_ADMIN]

        internalRoles.each { role ->
            ensureRoleExists(role)
        }

        fullTextIndexService.ping()

    }

    private void migrateUserIds() {
        final migrateProp = grailsApplication.config.bvp.users.migrateIds
        final migrate = migrateProp?.toBoolean()
        if (migrate) {
            final sw = new StopWatch()
            sw.start()
            final users = User.findAllByUserIdLike("%@%")
            sw.stop()
            log.warn("Took ${sw} to load users")
            sw.reset()
            sw.start()
            final missing = []
            final emailsAndIds = []
            users.each {
                if (it.email == 'system' || it.userId == 'system') {
                    it.userId = 'system'
                    it.email = 'support@ala.org.au'
                } else {
                    final userDetails = authService.getUserForEmailAddress(it.email)

                    if (userDetails) {
                        it.userId = userDetails.userId
                        emailsAndIds.add([id: it.userId, email: it.email])
                    } else {
                        missing.add(it.email)
                        log.warn("Missing user details for email address: ${it.email}!")
                    }
                }
            }
            sw.stop()
            log.warn("Took ${sw} to get user ids via auth service")
            sw.reset()
            sw.start()

            def test = checkMissing(Task,'lastViewedBy', missing)
            test += checkMissing(Task,'fullyTranscribedBy', missing)
            test += checkMissing(Task,'fullyValidatedBy', missing)
            test += checkMissing(NewsItem,'createdBy', missing)
            test += checkMissing(Field, 'transcribedByUserId', missing)
            test += checkMissing(ViewedTask, 'userId', missing)
            test += checkMissing(Template, 'author', missing)
            if (test > 0) {
                log.warn("a total of ${test} records still use email addresses")
            }
            sw.stop()
            log.warn("Took ${sw} to test for domain objects referencing missing ids")
            sw.reset()
            sw.start()

            User.saveAll(users)
            sessionFactory.currentSession.flush()
            sessionFactory.currentSession.clear()
            sw.stop()
            log.warn("Took ${sw} to save changes")
            sw.reset()
            sw.start()

            def sql
            try {
                sql = new Sql(dataSource)

                sql.withTransaction {
                    def results = sql.withBatch { stmt ->
                        stmt.addBatch("SET temp_buffers = '1GB';")
                        // DROP INDEXES
                        stmt.addBatch("DROP INDEX if exists field_name_index_superceeded_task_idx;")
                        stmt.addBatch("DROP INDEX if exists fieldnameidx;")
                        stmt.addBatch("DROP INDEX if exists fieldupdatedidx;")
                        // BATCH UPDATES
                        stmt.addBatch("UPDATE task AS t SET last_viewed_by = v.user_id FROM vp_user AS v WHERE t.last_viewed_by is not null AND t.last_viewed_by = v.email;")
                        stmt.addBatch("UPDATE task AS t SET fully_transcribed_by = v.user_id FROM vp_user AS v WHERE t.fully_transcribed_by is not null AND t.fully_transcribed_by = v.email;")
                        stmt.addBatch("UPDATE task AS t SET fully_validated_by = v.user_id FROM vp_user AS v WHERE t.fully_validated_by is not null AND t.fully_validated_by = v.email;")
                        stmt.addBatch("UPDATE news_item AS n SET created_by = v.user_id FROM vp_user AS v WHERE n.created_by is not null AND  n.created_by = v.email;")
                        stmt.addBatch("UPDATE field AS f SET transcribed_by_user_id = v.user_id FROM vp_user AS v WHERE f.transcribed_by_user_id is not null AND f.transcribed_by_user_id = v.email;")
                        stmt.addBatch("UPDATE viewed_task AS t SET user_id = v.user_id FROM vp_user AS v WHERE t.user_id is not null AND t.user_id = v.email;")
                        stmt.addBatch("UPDATE template AS t SET author = v.user_id FROM vp_user AS v WHERE t.author is not null AND t.author = v.email;")
                        // RE ADD INDEXES
                        stmt.addBatch("""CREATE INDEX field_name_index_superceeded_task_idx
                                        ON field
                                        USING btree
                                        (name COLLATE pg_catalog."default", record_idx, superceded, task_id);""")
                        stmt.addBatch("""CREATE INDEX fieldnameidx
                                        ON field
                                        USING btree
                                        (name COLLATE pg_catalog."default");""")
                        stmt.addBatch("""CREATE INDEX fieldupdatedidx
                                        ON field
                                        USING btree
                                        (updated);""")

                    }
                    log.warn("Batch results: ${Arrays.toString(results)}")
                }

            } finally {
                sql?.close()
            }

            sw.stop()
            log.warn("Took ${sw} to update domain objects id references")
            //sw.reset().start()
        }
    }

    private def checkMissing(c,m,emails) {
        if (emails) {
            final missing = c.executeQuery("select new map(${m} as x, count(id) as count) from ${c.simpleName} where ${m} in (:missing) group by ${m}", [missing: emails])
            missing.each { log.warn("${c.simpleName} ${m} has ${it.count} entries for ${it.x}") }
            final mc = missing*.count.sum() ?: 0
            log.warn("${c.simpleName} ${m} has ${mc} entries with unknown emails")
            return mc
        } else {
            return 0
        }
    }

    private void fixTaskLastViews() {
        log.info("Checking task last views...")

        def taskIds = Task.executeQuery("select t.id, count(vt.id) from Task t left outer join t.viewedTasks vt where t.lastViewed is null group by t.id having count(vt.id) > 0")

        if (taskIds) {
            log.info("Fixing last view for ${taskIds.size()} tasks...")
            sessionFactory.currentSession.setFlushMode(FlushMode.MANUAL)
            try {
                int count = 0
                taskIds.each { taskId ->

                    def task = Task.get(taskId)

                    if (!task) {
                        return
                    }

                    def lastView = auditService.getLastViewForTask(task)
                    if (lastView) {
                        task.lastViewed = lastView.lastView
                        task.lastViewedBy = lastView.userId
                    } else {
                        log.info("Problem fixing last view for task ${task.id} - no last view found.")
                    }
                    count++
                    if (count % 1000 == 0) {
                        println "${count} tasks processed."
                        sessionFactory.currentSession.flush()
                        sessionFactory.currentSession.clear()
                    }
                }
                log.info("${count} tasks processed (complete).")
            } finally {
                sessionFactory.currentSession.setFlushMode(FlushMode.AUTO)
            }
        } else {
            log.info("No tasks with inconsistent last view details.")
        }
    }

    private void prepareProjectTypes() {
        log.info("Checking project types...")
        def builtIns = [[name:'specimens', label:'Specimens', icon:'/images/icon_specimens.png'], [name:'fieldnotes', label: 'Field notes', icon:'/images/icon_fieldnotes.png']]
        builtIns.each {
            def projectType = ProjectType.findByName(it.name)
            if (!projectType) {
                log.info("Creating project type ${it.name}")
                projectType = new ProjectType(name: it.name, label: it.label)
            }

            File iconFile = grailsApplication.mainContext.getResource(it.icon)?.file
            if (iconFile) {
                projectTypeService.saveImageForProjectType(projectType, iconFile)
            }
            projectType.save(failOnError: true, flush: true)

        }
    }

    private void prepareValidationRules() {
        log.info("Initialising validation rules")
        checkOrCreateRule('mandatory', '.+', 'This field value is mandatory', "Mandatory fields must have a value supplied to them", true)
        checkOrCreateRule('numeric', '^[-+]?[0-9]*\\.?[0-9]+$', 'This field must be a number', "Field values must be numeric (floating point or otherwise)", false)
        checkOrCreateRule('integer', '^[-+]?[0-9]+$', 'This field must be a integer', "Field values must be integers", false)
        checkOrCreateRule('positiveInteger', '^\\d+$', 'This field must be a positive integer', "Field values must be positive integers", false)

    }

    private void checkOrCreateRule(String name, String expression, String message, String description, Boolean testEmptyValues = false) {
        def rule = ValidationRule.findByName(name)
        if (!rule) {
            log.info("Creating default validation rule '${name}'.")
            rule = new ValidationRule(name:name, regularExpression: expression, message: message, description: description, testEmptyValues: testEmptyValues)
            rule.save(failOnError: true)
        } else {
            log.info("Validation rule '${name}' exists.")
        }
    }

    def ensureRoleExists(String rolename) {
        def role = Role.findByNameIlike(rolename)
        if (!role) {
            role = new Role(name: rolename)
            role.save(flush: true, failOnError: true)
        }
        return role
    }

    def destroy = {
    }

    private void prepareFrontPage() {
        if (FrontPage.list()[0] == null) {
            def frontPage = new FrontPage()
            def projectList = Project.list()
            if (projectList.size() > 0) {
                frontPage.projectOfTheDay = projectList[0]
            }

            frontPage.save(flush: true, failOnError: true)
        }

        FrontPage.metaClass.'static'.getFeaturedProject = {->
            FrontPage.list()[0]?.featuredProject
        }
    }

    private void defineMetaMethods() {

        //add a utility method for creating a map from a arraylist
        java.util.ArrayList.metaClass.toMap = {->
            def myMap = [:]
            delegate.each { keyCount ->
                myMap.put keyCount[0], keyCount[1]
            }
            myMap
        }

        Map.metaClass.int = { String key ->
            def o = delegate[key]
            if (o instanceof Number) {
                return ((Number) o).intValue();
            }
            if (o != null) {
                try {
                    String string = o.toString();
                    if (string != null) {
                        return Integer.parseInt(string);
                    }
                }
                catch (NumberFormatException e) {}
            }
            return null;
        }

        String.metaClass.'intro' = { len -> return StringUtils.abbreviate(delegate, len) ?: '' }
        GString.metaClass.'intro' = { len -> return StringUtils.abbreviate(delegate.toString(), len) }

        String.metaClass.'toTitleCase' = { return WebUtils.makeTitleFromCamelCase(delegate.toString()) }
        GString.metaClass.'toTitleCase' = { return WebUtils.makeTitleFromCamelCase(delegate.toString()) }

    }

    private void preparePickLists() {
        // add some picklist values if not already loaded
        log.info "creating picklists..."
        def items = ["country", "stateProvince", "typeStatus", "institutionCode", "recordedBy", "verbatimLocality", "coordinateUncertaintyInMeters"]
        items.each {
            log.info("checking picklist: " + it)
            if (!Picklist.findByName(it)) {
                log.info("creating new picklist " + it)
                Picklist picklist = new Picklist(name: it).save(flush: true, failOnError: true)
                def csvText = ApplicationHolder.application.parentContext.getResource("classpath:resources/" + it + ".csv").inputStream.text
                csvText.eachCsvLine { tokens ->
                    def picklistItem = new PicklistItem()
                    picklistItem.picklist = picklist
                    picklistItem.value = tokens[0].trim()
                    // handle "value, key" CSV file format
                    if (tokens.size() > 1) {
                        picklistItem.key = tokens[1].trim()
                    }

                    picklistItem.save(flush: true, failOnError: true)
                }
            }
        }

    }

    private void prepareDefaultLabels() {
        log.info("Preparing default labels")
        final prop = grailsApplication.config.bvp.labels.ensureDefault
        final shouldInstall = prop.asBoolean()
        if (shouldInstall) {
            log.info("Installing default labels")
            final defaults = (JSONObject)JSON.parse(Resources.getResource('default-labels.json').newReader())
            //final defaultsSet = defaults.keySet().collectEntries { [(it): defaults[it].toSet() ] }
            final labels = Label.all // TODO scroll?
            final labelSet = labels.toSet()
            final newLabels = defaults.keySet().collect { k ->
                final a = (JSONArray)defaults[k]
                a.collect { new Label(category: k, value: it) }.findAll { !labelSet.contains(it) }
            }.flatten()
            log.info("Adding ${newLabels.size()} new labels")
            log.debug("Adding ${newLabels.join('\n')}")
            if (newLabels) Label.saveAll(newLabels)
        } else {
            log.debug("Skipping default labels")
        }
    }

}
