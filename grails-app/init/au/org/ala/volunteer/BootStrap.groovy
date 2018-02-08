package au.org.ala.volunteer

import au.org.ala.volunteer.sanitizer.SanitizedHtml
import au.org.ala.volunteer.sanitizer.ValueConverterListener
import com.google.common.io.Resources
import grails.converters.JSON
import grails.core.GrailsApplication
import groovy.sql.Sql
import org.apache.commons.lang.StringUtils
import org.grails.datastore.mapping.core.Datastore
import org.grails.web.json.JSONArray
import org.grails.web.json.JSONObject
import org.hibernate.FlushMode
import org.springframework.core.io.Resource
import org.springframework.web.context.support.ServletContextResource

class BootStrap {

    def logService
    def projectTypeService
    GrailsApplication grailsApplication
    def auditService
    def sessionFactory
    def authService
    def fullTextIndexService
    def dataSource
    def sanitizerService

    def init = { servletContext ->

        ensureFuzzyStrMatchExtension()

        dbMigrate()

        addSanitizer()

        defineMetaMethods()

        prepareFrontPage()

        preparePickLists()

        prepareValidationRules()

        prepareProjectTypes()

        fixTaskLastViews()

        prepareDefaultLabels()

        def internalRoles = [BVPRole.VALIDATOR, BVPRole.FORUM_MODERATOR, BVPRole.SITE_ADMIN]

        internalRoles.each { role ->
            ensureRoleExists(role)
        }

        // add system user
        if (!User.findByUserId('system')) {
            User u = new User(userId: 'system', email: ' support@ala.org.au', firstName: 'System', lastName: 'User', created: new Date())
            u.save(flush: true, failOnError: true)
        }

        fullTextIndexService.ping()

    }

    private void ensureFuzzyStrMatchExtension() {
        def sql = new Sql(dataSource)
        try {
            sql.execute("CREATE EXTENSION IF NOT EXISTS fuzzystrmatch")
        } catch (e) {
            log.error("Could not enable fuzzystrmatch PostgreSQL extension which is required by the application. Do you need to apt-get install postgresql-contrib or equivalent?", e)
        }

    }

    private void dbMigrate() {
        def sql = new Sql(dataSource)
        try {
            sql.execute("ALTER TABLE vp_user DROP COLUMN IF EXISTS display_name")
        } catch (e) {
            log.error("Could not remove vp_user.display_name", e)
        }
    }
    private addColumn(String table, String column, String columnType) {

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
        def builtIns = [[name:'specimens', label: "bootstrap.specimens", icon:'/public/images/2.0/iconLabels.png'], [name:'fieldnotes', label: 'bootstrap.field_notes', icon:'/public/images/2.0/iconNotes.png'], [name: 'cameratraps', label: 'bootstrap.camera_traps', icon: '/public/images/2.0/iconWild.png']]
        builtIns.each {
            def projectType = ProjectType.findByLabel(it.label)
            if (!projectType) {
                log.info("Creating project type ${it.name}")
                projectType = new ProjectType(name: it.name, label: it.label)
            }

//            InputStream inputStream = getClass().getResourceAsStream(it.icon)

            def iconFile = grailsApplication.mainContext.getResource("classpath:${it.icon}")
            if (iconFile) {
                projectTypeService.saveImageForProjectType(projectType, iconFile.inputStream)
            } else {
                log.warn("Couldn't load ${it.icon}")
            }
            projectType.save(failOnError: true, flush: true)

        }
    }

    private void prepareValidationRules() {
        log.info("Initialising validation rules")
        checkOrCreateRule('mandatory', '.+', "bootstrap.validation.this_field_is_mandatory", 'bootstrap.validation.this_field_is_mandatory.description', true)
        checkOrCreateRule('numeric', '^[-+]?[0-9]*\\.?[0-9]+$', 'bootstrap.validation.this_field_must_be_a_number', 'bootstrap.validation.this_field_must_be_a_number.description', false)
        checkOrCreateRule('integer', '^[-+]?[0-9]+$', 'bootstrap.validation.this_field_must_be_integer', 'bootstrap.validation.this_field_must_be_integer.description', false)
        checkOrCreateRule('positiveInteger', '^\\d+$', 'bootstrap.validation.this_field_must_be_a_positive_integer', 'bootstrap.validation.this_field_must_be_a_positive_integer.description', false)

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

    private void addSanitizer() {
        final ctx = grailsApplication.mainContext
        ctx.getBeansOfType(Datastore).values().each { Datastore d ->
            log.info "Adding listener for datastore: ${d}"
            ctx.addApplicationListener(ValueConverterListener.of(d, SanitizedHtml, String, sanitizerService.&sanitize))
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
                def csvText = grailsApplication.parentContext.getResource("classpath:resources/" + it + ".csv").inputStream.text
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
            if (newLabels) {
                log.debug("Adding ${newLabels.join('\n')}")
            }
//            if (newLabels) Label.saveAll(newLabels)
            if (newLabels) newLabels*.save()
        } else {
            log.debug("Skipping default labels")
        }
    }

}
