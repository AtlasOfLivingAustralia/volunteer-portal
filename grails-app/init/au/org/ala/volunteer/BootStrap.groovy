package au.org.ala.volunteer

import au.org.ala.volunteer.sanitizer.SanitizedHtml
import au.org.ala.volunteer.sanitizer.ValueConverterListener
import com.google.common.io.Resources
import grails.converters.JSON
import grails.core.GrailsApplication
import grails.gorm.transactions.Transactional
import groovy.sql.Sql
import groovy.util.logging.Slf4j
import org.apache.commons.lang.StringUtils
import org.grails.datastore.mapping.core.Datastore
import org.grails.web.json.JSONArray
import org.grails.web.json.JSONObject
import org.hibernate.FlushMode
import org.springframework.core.io.Resource
import org.springframework.web.context.support.ServletContextResource

import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.attribute.BasicFileAttributes

@Slf4j
class BootStrap {

    def projectTypeService
    def projectService
    GrailsApplication grailsApplication
    def auditService
    def sessionFactory
    def authService
    def fullTextIndexService
    def sanitizerService
    def tutorialService

    def init = { servletContext ->

        addSanitizer()

        defineMetaMethods()

        prepareFrontPage()

        prepareCustomLandingPage()

        preparePickLists()

        prepareValidationRules()

        prepareProjectTypes()

        fixTaskLastViews()

        prepareDefaultLabels()

        // For DigiVol 6.2.0 - Remove in following release.
//        migrateTutorials()

        // add system user
        if (!User.findByUserId('system')) {
            User u = new User(userId: 'system', email: ' support@ala.org.au', firstName: 'System', lastName: 'User')
        }

        def internalRoles = [BVPRole.VALIDATOR, BVPRole.FORUM_MODERATOR, BVPRole.INSTITUTION_ADMIN]

        internalRoles.each { role ->
            ensureRoleExists(role)
        }

        fullTextIndexService.ping()

    }

    /**
     * Migrates filesystem list of tutorials into new DB table for release 6.2.0
     * Disable this in next release.
     */
    private void migrateTutorials() {
        log.info("Initialising tutorial migration...")

        def tutorials = tutorialService.listTutorials()
        log.info("Found ${tutorials.size() ?: 0} files.")
        int totalMigrated = 0
        tutorials.each { tutorialFile ->
            log.debug("=> Tutorial: ${tutorialFile}")
            def tutorialChk = Tutorial.findByFilename(tutorialFile.name as String)

            // If no file already saved, create a new record.
            if (!tutorialChk) {
                log.debug("=> No db entry yet")
                Tutorial tutorial = new Tutorial(filename: tutorialFile.name, name: tutorialFile.name, isActive: true)
                def createdBy = null

                // Find any projects using this tutorial
                // - Get the institution
                // - Get the user who either created the project or institution (if any)
                def projectList = Project.findAllByTutorialLinksLike("%${tutorialFile.url}%", [sort: 'dateCreated', order: 'desc'])
                if (projectList) {
                    def institution = projectList.first()?.institution
                    if (institution) {
                        tutorial.institution = institution
                        createdBy = institution.createdBy
                        log.debug("=> Tutorial institution: ${institution}")
                    }

                    if (!createdBy) {
                        def project = projectList.find {
                            it.createdBy != null
                        }

                        createdBy = project.createdBy ?: null
                    }
                }

                log.debug("=> Tutorial createdBy: ${createdBy}")
                tutorial.createdBy = createdBy

                // Get the file's creation date.
                Path path = (tutorialFile.file as File).toPath()
                BasicFileAttributes attrs = Files.readAttributes(path, BasicFileAttributes)
                def createdDate = new Date(attrs.creationTime().toMillis())
                tutorial.dateCreated = createdDate ?: new Date()
                tutorial.save(flush: true, failOnError: true)
                log.debug("=> Tutorial dateCreated: ${tutorial.dateCreated} ")
                totalMigrated++
                log.debug("# Tutorial created: ${tutorial}")
            }
        }

        log.info("Tutorial migration completed; ${totalMigrated} files migrated.")
    }

    /**
     * This is to initialise the project sizes for release 6.1.0.
     * Disable this in next release.
     * DEPRECATED
     */
    private void initProjectSize() {
        log.info("Initialising project sizes...")

        def projectList = Project.findAllByArchived(false)
        int count = 0

        projectList.each { project ->
            if (project.sizeInBytes == 0L) {
                def size = projectService.projectSize(project).size as long
                if (size > 0) {
                    log.info("Project [${project.id}] ${project.name} calculated to be ${size} bytes.")
                }
            }
        }

        log.info("Completed Project Size initialisation for ${projectList.size()} projects.")
    }

    @Transactional
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
                        log.info("${count} tasks processed.")
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

    @Transactional
    private void prepareProjectTypes() {
        log.info("Checking project types...")
        def builtIns = [
                [name: ProjectType.PROJECT_TYPE_SPECIMEN,
                 label: 'Specimens',
                 icon: '/public/images/2.0/iconLabels.png'],
                [name: ProjectType.PROJECT_TYPE_FIELDNOTES,
                 label: 'Field notes',
                 icon: '/public/images/2.0/iconNotes.png'],
                [name: ProjectType.PROJECT_TYPE_CAMERATRAP,
                 label: 'Camera Traps',
                 icon: '/public/images/2.0/iconWild.png'],
                [name: ProjectType.PROJECT_TYPE_AUDIO,
                 label: 'Audio',
                 icon: '/public/images/2.0/iconWild.png']]
        builtIns.each {
            def projectType = ProjectType.findByName(it.name)
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
        checkOrCreateRule('mandatory', '.+', 'This field value is mandatory', "Mandatory fields must have a value supplied to them", true)
        checkOrCreateRule('numeric', '^[-+]?[0-9]*\\.?[0-9]+$', 'This field must be a number', "Field values must be numeric (floating point or otherwise)", false)
        checkOrCreateRule('integer', '^[-+]?[0-9]+$', 'This field must be a integer', "Field values must be integers", false)
        checkOrCreateRule('positiveInteger', '^\\d+$', 'This field must be a positive integer', "Field values must be positive integers", false)

    }

    @Transactional
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

    @Transactional
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

    @Transactional
    private void prepareFrontPage() {
        if (FrontPage.list()[0] == null) {
            def frontPage = new FrontPage()
            def projectList = Project.list()
            if (projectList.size() > 0) {
                frontPage.projectOfTheDay = projectList[0]
                frontPage.save(flush: true, failOnError: true)
            }
        }

        FrontPage.metaClass.'static'.getFeaturedProject = {->
            FrontPage.list()[0]?.featuredProject
        }
    }

    /*
      Must have at least 1 default custom landing page which is the wildlife spotter page
      This can be created or updated from existing wildlife spotter
     */
    @Transactional
    private void prepareCustomLandingPage() {
        LandingPage wildLifeSpotter = LandingPage.findByShortUrl ('wildlife-spotter')
        if (!wildLifeSpotter) {
            wildLifeSpotter = new LandingPage()
            wildLifeSpotter.title = 'Wildlife Spotter'
            wildLifeSpotter.shortUrl = 'wildlife-spotter'
            wildLifeSpotter.enabled = true
            ProjectType cameraTraps = ProjectType.findByName(ProjectType.PROJECT_TYPE_CAMERATRAP)
            wildLifeSpotter.projectType = cameraTraps
            wildLifeSpotter.bodyCopy = ''
            wildLifeSpotter.numberOfContributors = 10
            wildLifeSpotter.landingPageImage = null
            wildLifeSpotter.imageAttribution = null

            wildLifeSpotter.save(flush: true, failOnError: true)
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
        ArrayList.metaClass.toMap = {->
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

        String.metaClass.'intro' = { len -> return StringUtils.abbreviate(delegate.toString(), len as int) ?: '' }
        GString.metaClass.'intro' = { len -> return StringUtils.abbreviate(delegate.toString(), len as int) }

        String.metaClass.'toTitleCase' = { return WebUtils.makeTitleFromCamelCase(delegate.toString()) }
        GString.metaClass.'toTitleCase' = { return WebUtils.makeTitleFromCamelCase(delegate.toString()) }

    }

    @Transactional
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

    @Transactional
    private void prepareDefaultLabels() {
        log.info("Preparing default labels")
        final shouldInstall = grailsApplication.config.getProperty("bvp.labels.ensureDefault", Boolean, false)
        if (shouldInstall) {
            log.info("Installing default labels")
            final defaults = (JSONObject)JSON.parse(Resources.getResource('default-labels.json').newReader())

            // Check for categories then labels
            def now = new Date()
            defaults.keySet().each { k ->
                def blah = LabelCategory.findByName(k as String)
                if (!blah) {
                    // Create category
                    def zz = new Date()
                    //log.info("Date initialised: ${zz}")
                    def lc
                    LabelCategory.withNewTransaction {
                        lc = new LabelCategory(name: k)
                        lc.isDefault = true
                        lc.updatedDate = zz
                        lc.createdBy = 0L
                        lc.save(flush: true, failOnError: true)
                        lc.refresh()
                    }

                    //log.info("New category: ${lc}")

                    // Create new labels for new category
                    final labelList = (JSONArray)defaults[k]
                    labelList.each { val ->
                        def label = new Label(value: val)
                        label.isDefault = true
                        label.category = lc
                        label.updatedDate = zz
                        label.createdBy = 0L
                        //log.info("new label: ${label}")
                        label.save(flush: true, failOnError: true)
                    }
                } else {
                    blah.isDefault = true
                    blah.save(flush: true, failOnError: true)
                    final labelList = (JSONArray)defaults[k]
                    labelList.each { val ->
                        def label = Label.findByCategoryAndValue(blah, val as String)
                        if (!label) {
                            label = new Label(value: val)
                            label.isDefault = true
                            label.category = blah
                            label.updatedDate = now
                            label.createdBy = 0L
                            //log.info("new label: ${label}")
                            label.save(flush: true, failOnError: true)
                        } else {
                            label.isDefault = true
                            label.save(flush: true, failOnError: true)
                        }
                    }
                }
            }
        } else {
            log.debug("Skipping default labels")
        }
    }

}
