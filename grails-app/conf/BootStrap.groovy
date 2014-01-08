import au.org.ala.volunteer.*
import org.apache.commons.lang.StringUtils
import org.codehaus.groovy.grails.commons.ApplicationHolder

import java.util.regex.Pattern

class BootStrap {

    javax.sql.DataSource dataSource
    def logService

    def init = { servletContext ->

        defineMetaMethods();

        prepareFrontPage();

        preparePickLists();

        prepareTemplates();

        prepareValidationRules();

        prepareProjectTypes();

        // add system user
        if (!User.findByUserId('system')) {
            User u = new User(userId: 'system', displayName: 'System User')
        }

        def internalRoles = ["validator", "forum_moderator"]

        internalRoles.each { role ->
            ensureRoleExists(role)
        }

    }

    private void prepareProjectTypes() {
        def builtIns = [[name:'specimens', label:'Specimens', icon:'/images/icon_specimens.png'], [name:'fieldnotes', label: 'Field notes', icon:'/images/icon_fieldnotes.png']]
        builtIns.each {
            def existing = ProjectType.findByName(it.name)
            if (!existing) {

            }
        }

    }

    private void prepareValidationRules() {

        checkOrCreateRule('mandatory', '.+', 'This field value is mandatory', "Mandatory fields must have a value supplied to them", true)
        checkOrCreateRule('numeric', '^[-+]?[0-9]*\\.?[0-9]+$', 'This field must be a number', "Field values must be numeric (floating point or otherwise)", false)
        checkOrCreateRule('integer', '^[-+]?[0-9]+$', 'This field must be a integer', "Field values must be integers", false)
        checkOrCreateRule('positiveInteger', '^\\d+$', 'This field must be a positive integer', "Field values must be positive integers", false)

    }

    private void checkOrCreateRule(String name, String expression, String message, String description, Boolean testEmptyValues = false) {
        def rule = ValidationRule.findByName(name)
        if (!rule) {
            logService.log("Creating default validation rule '${name}'.")
            rule = new ValidationRule(name:name, regularExpression: expression, message: message, description: description, testEmptyValues: testEmptyValues)
            rule.save(failOnError: true)
        } else {
            logService.log("Validation rule '${name}' exists.")
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

    void populateTemplateFields(Template template, String resourceName) {
        // populate default set of TemplateFields
        //
        def numberRegex = Pattern.compile('^\\d+\$')
        String fields = ApplicationHolder.application.parentContext.getResource("classpath:resources/${resourceName}.csv").inputStream.text
        int fileOrder = 0

        fields.eachCsvLine { fs ->
            if (fs.size() > 0) {
                fileOrder++
                DarwinCoreField dwcf = DarwinCoreField.valueOf(fs[0].trim())
                if (!TemplateField.findByFieldTypeAndTemplate(dwcf, template)) {
                    logService.log "creating new FieldType for template ${template.name}: " + fs + " size=" + fs.size()
                    // Work out the display order - by default it will be in the order of appearance in the file
                    def displayOrder = fileOrder
                    if (fs.size() >= 10) {
                        def orderString = fs[9].trim()
                        def m = numberRegex.matcher(orderString)
                        if (m.matches()) {
                            displayOrder = Integer.parseInt(orderString)
                        }
                    }

                    TemplateField tf = new TemplateField(
                            fieldType: dwcf,
                            label: fs[1].trim(),
                            defaultValue: fs[2].trim(),
                            category: FieldCategory.valueOf(fs[3].trim()),
                            type: FieldType.valueOf(fs[4].trim()),
                            mandatory: ((fs[5].trim() == '1') ? true : false),
                            multiValue: ((fs[6].trim() == '1') ? true : false),
                            helpText: fs[7].trim(),
                            validationRule: fs[8].trim(),
                            template: template,
                            displayOrder: displayOrder
                    ).save(flush: true, failOnError: true)
                } else {
                    logService.log "Field already exists for template ${template.name} ${dwcf}"
                }
            }
        }

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
        logService.log "creating picklists..."
        def items = ["country", "stateProvince", "typeStatus", "institutionCode", "recordedBy", "verbatimLocality", "coordinateUncertaintyInMeters"]
        items.each {
            logService.log("checking picklist: " + it)
            if (!Picklist.findByName(it)) {
                logService.log("creating new picklist " + it)
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

    private void prepareTemplates() {
        // Create default template if not in DB
        Template template = Template.findByName('default')
        if (!template) {
            logService.log "creating new Template: default"
            template = new Template(name: 'default', viewName: 'specimenTranscribe', author: 'webmaster@ala.org.au',
                    created: new Date(), fieldOrder: '').save(flush: true, failOnError: true)
        }

        populateTemplateFields(template, "defaultFields")

        template = Template.findByName("FieldNoteBook")
        if (!template) {
            logService.log "creating new Template: FieldNoteBook"
            template = new Template(name: "FieldNoteBook", viewName: "fieldNoteBookTranscribe", author: 'webmaster@ala.org.au', created: new Date(), fieldOrder: '', viewParams: [:]).save(flush: true, failOnError: true)
        }
        populateTemplateFields(template, "fieldNoteBookFields")

        template = Template.findByName("FieldNoteBookDoublePage")
        if (!template) {
            logService.log "creating new Template: FieldNoteBookDoublePage"
            template = new Template(name: "FieldNoteBookDoublePage", viewName: "fieldNoteBookTranscribe", author: 'webmaster@ala.org.au', created: new Date(), fieldOrder: '', viewParams: [doublePage: 'true']).save(flush: true, failOnError: true)
        }
        populateTemplateFields(template, "fieldNoteBookFields")

        template = Template.findByName("SpecimenLabel")
        if (!template) {
            logService.log "creating new Template: SpecimenLabel"
            template = new Template(name: "SpecimenLabel", viewName: "specimenLabelTranscribe", author: 'webmaster@ala.org.au', created: new Date(), fieldOrder: '', viewParams: [:]).save(flush: true, failOnError: true)
        }
        populateTemplateFields(template, "specimenLabelFields")

        template = Template.findByName("AerialObservations")
        if (!template) {
            logService.log "creating new Template: AerialObservations"
            template = new Template(name: "AerialObservations", viewName: "aerialObservationsTranscribe", author: 'webmaster@ala.org.au', created: new Date(), fieldOrder: '', viewParams: [:]).save(flush: true, failOnError: true)
        }
        populateTemplateFields(template, "aerialObservationsFields")

        template = Template.findByName("ObservationDiary")
        if (!template) {
            logService.log "creating new Template: ObservationDiary"
            template = new Template(name: "ObservationDiary", viewName: "observationDiaryTranscribe", author: 'webmaster@ala.org.au', created: new Date(), fieldOrder: '', viewParams: [:]).save(flush: true, failOnError: true)
        }
        populateTemplateFields(template, "observationDiaryFields")

        template = Template.findByName("ObservationDiaryWithMonth")
        if (!template) {
            logService.log "creating new Template: ObservationDiaryWithMonth"
            template = new Template(name: "ObservationDiaryWithMonth", viewName: "observationDiaryTranscribe", author: 'webmaster@ala.org.au', created: new Date(), fieldOrder: '', viewParams: [showMonth: true, hideLocality: true]).save(flush: true, failOnError: true)
        }
        populateTemplateFields(template, "observationDiaryFields")

        template = Template.findByName("FinnishLabelsTest")
        if (!template) {
            logService.log "creating new Template: FinnishLabelsTest"
            template = new Template(name: "FinnishLabelsTest", viewName: "specimenTranscribe", author: 'webmaster@ala.org.au', created: new Date(), fieldOrder: '', viewParams: [:]).save(flush: true, failOnError: true)
        }
        template.viewParams = [specialChars: "x00e5,x00e4,x00f6,x00e6,x00f8", noAutoComplete: 'recordedBy,verbatimLocality', hideMapButton: 'true']
        template.save(flush: true, failOnError: true)

        populateTemplateFields(template, "finnishTestFields")

        template = Template.findByName("GenericLabels")
        if (!template) {
            logService.log "creating new Template: GenericLabels"
            template = new Template(name: "GenericLabels", viewName: "genericLabelsTranscribe", author: 'webmaster@ala.org.au', created: new Date(), fieldOrder: '', viewParams: [:]).save(flush: true, failOnError: true)
        }
        template.save(flush: true, failOnError: true)

        populateTemplateFields(template, "genericLabelFields")

        template = Template.findByName("SmithsonianPlants")
        if (!template) {
            logService.log "creating new Template: SmithsonianPlants"
            template = new Template(name: "SmithsonianPlants", viewName: "smithsonianPlantsTranscribe", author: 'webmaster@ala.org.au', created: new Date(), fieldOrder: '', viewParams: [:]).save(flush: true, failOnError: true)
        }
        template.save(flush: true, failOnError: true)

        populateTemplateFields(template, "smithsonianPlantsFields")

    }

}
