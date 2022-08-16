package au.org.ala.volunteer

import com.google.common.base.Strings
import com.google.common.hash.HashCode
import grails.converters.JSON
import grails.gorm.transactions.Transactional
import org.apache.commons.io.FilenameUtils
import org.springframework.dao.DataIntegrityViolationException
import org.springframework.web.multipart.MultipartFile

import static javax.servlet.http.HttpServletResponse.*

class TemplateController {

    static allowedMethods = [save: "POST", update: "POST", cloneTemplate: "POST"]

    def userService
    def templateFieldService
    def templateService
    def fileUploadService

    def index() {
        redirect(action: "list", params: params)
    }

    def list() {
		if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }
        params.max = Math.min(params.max ? params.int('max') : 20, 100)
        params.offset = (params.offset ? params.int('offset') : 0)
        def allTemplates

        // If no parameters and is an institution admin, default to that user's institution filter.
        if ((Strings.isNullOrEmpty(params.institution?.toString())
                && Strings.isNullOrEmpty(params.sort?.toString())
                && Strings.isNullOrEmpty(params.q?.toString())
                && Strings.isNullOrEmpty(params.viewName?.toString())) && (userService.isInstitutionAdmin() && !userService.isSiteAdmin())) {
            params.institution = "${userService.getAdminInstitutionList().first().id}"
        }

        allTemplates = templateService.getTemplatesWithFilter(params)

        def templateList = []
        allTemplates.templateList.each { template ->
            templateList.add(templateService.getTemplatePermissions(template as Template))
        }

        def statusFilter = [[key: 'global', value: 'Global templates'],
                            [key: 'unassigned', value: 'Unassigned templates']]
        if (userService.isSiteAdmin()) {
            statusFilter.add([key: 'hidden', value: 'Hidden templates'])
        }

        [templateInstanceList: templateList,
         templateInstanceTotal: allTemplates.totalCount,
         params: params,
         statusFilter: statusFilter,
         viewFilter: templateService.getTemplateViews()]
    }

    def create() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }
        def templateInstance = new Template()
        templateInstance.author = userService.currentUserId
        return [templateInstance: templateInstance, availableViews: templateService.getAvailableTemplateViews()]
    }

    @Transactional
    def save() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }
        params.author = userService.currentUserId
        def templateInstance = new Template(params)
        if (templateInstance.save(flush: true)) {
            flash.message = message(code: 'default.created.message',
                    args: [message(code: 'template.label', default: 'Template'), templateInstance.name]) as String
            redirect(action: "edit", id: templateInstance.id)
        } else {
            flash.message = message(code: 'default.not.created.message',
                    args: [message(code: 'template.label', default: 'Template'), templateInstance.name]) as String
            render(view: "create", model: [templateInstance: templateInstance])
        }
    }

    def edit() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }
        def template = Template.get(params.long('id'))
        if (!template) {
            flash.message = message(code: 'default.not.found.message',
                     args: [message(code: 'template.label', default: 'Template'), params.id as String]) as String
            redirect(action: "list")
        } else {
            // Is the user allowed to edit this template?
            def permissions = templateService.getTemplatePermissions(template)
            if (!permissions.canEdit) {
                render(view: '/notPermitted')
                return
            }

            def availableViews = templateService.getAvailableTemplateViews()
            def projectUsageList = [:]
            def projectList = template.projects.sort { a, b -> a.institution?.name <=> b.institution?.name }
            def institutionName = ""

            for (Project project in projectList) {
                log.debug("Sorted project list: ${project}")

                if (project.institution?.name != institutionName) {
                    institutionName = project.institution?.name
                    projectUsageList[institutionName] = []
                }
                projectUsageList[institutionName].add(project)
            }
            return [templateInstance: template, availableViews: availableViews, projectUsageList: projectUsageList]
        }
    }

    @Transactional
    def update() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }
        def template = Template.get(params.long('id'))
        if (template) {
            def permissions = templateService.getTemplatePermissions(template)
            if (!permissions.canEdit) {
                render(view: '/notPermitted')
                return
            }

            if (params.version) {
                def version = params.version.toLong()
                if (template.version > version) {
                    
                    template.errors.rejectValue("version", "default.optimistic.locking.failure",
                            [message(code: 'template.label', default: 'Template')] as Object[],
                            "Another user has updated this Template while you were editing")
                    render(view: "edit", model: [templateInstance: template])
                    return
                }
            }

            // This is to stop an IDE warning about incompatible objects
            bindData(template, params)

            def viewParams = JSON.parse(params.viewParamsJSON as String) as Map

            def newViewParams = new HashMap<String, String>()
            if (viewParams) {
                viewParams.keySet().each {
                    newViewParams[it.toString()] = viewParams[it]?.toString()
                }
            }
            template.viewParams = newViewParams

            if (!template.hasErrors() && template.save(flush: true)) {
                flash.message = message(code: 'default.updated.message',
                         args: [message(code: 'template.label', default: 'Template'), template.name]) as String
                redirect(action: "edit", id: template.id)
            } else {
                render(view: "edit", model: [templateInstance: template])
            }
        } else {
            flash.message = message(code: 'default.not.found.message',
                     args: [message(code: 'template.label', default: 'Template'), params.id as String]) as String
            redirect(action: "list")
        }
    }

    def delete() {
        // Only Site Admins can delete templates.
        if (!userService.isSiteAdmin()) {
            render(view: '/notPermitted')
            return
        }

        def template = Template.get(params.long('id'))
        if (template) {
            try {
                templateService.deleteTemplate(template)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'template.label', default: 'Template'), "'${template.name}'"])}"
                redirect(action: "list", params: params)
            } catch (Exception e) {
                String message = "${message(code: 'default.not.deleted.message', args: [message(code: 'template.label', default: 'Template'), params.id])}"
                flash.message = message
                log.error(message, e)
                redirect(action: "edit", id: params.id)
            }
        } else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'template.label', default: 'Template'), params.id])}"
            redirect(action: "list", params: params)
        }
    }

    def manageFields() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }
        def template = Template.get(params.int("id"))
        if (template) {
            def permissions = templateService.getTemplatePermissions(template)
            if (!permissions.canEdit) {
                render(view: '/notPermitted')
                return
            }

            def fields = TemplateField.findAllByTemplate(template)?.sort { it.displayOrder }

            [templateInstance: template, fields: fields]
        }
    }

    def addTemplateFieldFragment() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }
        def template = Template.get(params.int("id"))
        if (template) {
            def permissions = templateService.getTemplatePermissions(template)
            if (!permissions.canEdit) {
                render(view: '/notPermitted')
                return
            }

            def fields = TemplateField.findAllByTemplate(template)?.sort { it.displayOrder }
            [templateInstance: template, fields: fields]
        }
    }

    @Transactional
    def moveFieldUp() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }
        def field = TemplateField.get(params.int("fieldId"))
        if (field) {
            def permissions = templateService.getTemplatePermissions(field.template)
            if (!permissions.canEdit) {
                render(view: '/notPermitted')
                return
            }

            if (field.displayOrder > 1) {
                def predecessor = TemplateField.findByTemplateAndDisplayOrder(field.template, field.displayOrder - 1)
                if (predecessor) {
                    // swap their positions
                    predecessor.displayOrder++
                    predecessor.save()
                }
                field.displayOrder--
                field.save()
            }
        }

        redirect(action:'manageFields', id: field?.template?.id)
    }

    @Transactional
    def moveFieldDown() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }
        def field = TemplateField.get(params.int("fieldId"))
        if (field) {
            def permissions = templateService.getTemplatePermissions(field.template)
            if (!permissions.canEdit) {
                render(view: '/notPermitted')
                return
            }

            def max = getLastDisplayOrder(field.template)
            if (field.displayOrder < max ) {
                def successor = TemplateField.findByTemplateAndDisplayOrder(field.template, field.displayOrder + 1)
                if (successor) {
                    // swap their positions
                    successor.displayOrder--
                    successor.save()
                }
                field.displayOrder++
                field.save()
            }
        }

        redirect(action:'manageFields', id: field?.template?.id)
    }

    @Transactional
    def moveFieldToPosition() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }

        def template = Template.get(params.int("id"))
        def field = TemplateField.findByTemplateAndId(template, params.int("fieldId"))
        def newOrder = params.int("newOrder")
        if (template && field && newOrder) {
            def permissions = templateService.getTemplatePermissions(template)
            if (!permissions.canEdit) {
                render(view: '/notPermitted')
                return
            }

            def fields = TemplateField.findAllByTemplate(template)?.sort { it.displayOrder }
            if (newOrder >= 0 && newOrder <= fields.size()) {
                fields.each {
                    if (it.displayOrder >= newOrder) {
                        it.displayOrder++
                    }
                }
                field.displayOrder = newOrder
                redirect(action:'cleanUpOrdering', id:template.id)
                return
            }
        }

        redirect(action:'manageFields', id: field?.template?.id)
    }

    @Transactional
    def cleanUpOrdering() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }
        def template = Template.get(params.int("id"))
        if (template) {
            def permissions = templateService.getTemplatePermissions(template)
            if (!permissions.canEdit) {
                render(view: '/notPermitted')
                return
            }

            def fields = TemplateField.findAllByTemplate(template)?.sort { it.displayOrder }
            int i = 1
            fields.each {
                it.displayOrder = i++
            }
            TemplateField.saveAll(fields)
        }

        redirect(action:'manageFields', id: template?.id)
    }

    @Transactional
    def addField() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }
        Template template = Template.get(params.int("id"))
        String fieldType = params.fieldType
        String classifier = params.fieldTypeClassifier

        if (template && fieldType) {
            def permissions = templateService.getTemplatePermissions(template)
            if (!permissions.canEdit) {
                render(view: '/notPermitted')
                return
            }

            def existing = TemplateField.findAllByTemplateAndFieldTypeAndFieldTypeClassifier(template, fieldType as DarwinCoreField, classifier)
            if (existing && fieldType != DarwinCoreField.spacer.toString() && fieldType != DarwinCoreField.widgetPlaceholder.toString()) {
                flash.message = "Add field failed: Field type " + fieldType + " already exists in this template!"
            } else {
                def displayOrder = getLastDisplayOrder(template) + 1
                FieldCategory category = params.category ?: FieldCategory.none
                FieldType type = params.type ?: FieldType.text
                def label = params.label ?: ""
                def field = new TemplateField(template: template, category: category, fieldType: fieldType, fieldTypeClassifier: classifier, displayOrder: displayOrder, defaultValue: '', type: type, label: label)
                field.save(failOnError: true)
            }
        }

        redirect(action:'manageFields', id: template?.id)
    }

    private int getLastDisplayOrder(Template template) {
        def c = TemplateField.createCriteria()
        def maxDisplayOrderCount = c.get({
            eq('template', template)
            projections {
                max('displayOrder')
            }
        })
        log.debug("Max order count: ${maxDisplayOrderCount}")

        return (maxDisplayOrderCount == null ? 0 : maxDisplayOrderCount as int)
    }

    @Transactional
    def deleteField() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }
        def template = Template.get(params.int("id"))
        def permissions = templateService.getTemplatePermissions(template)
        if (!permissions.canEdit) {
            render(view: '/notPermitted')
            return
        }

        def field = TemplateField.findByTemplateAndId(template, params.int("fieldId"))
        if (field && template) {
            field.delete()
        }
        redirect(action:'manageFields', id: template?.id)
    }

    def preview() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }
        def template = Template.get(params.int("id"))

        def project = new Project(template: template, featuredLabel: "PreviewProject", featuredOwner: "ALA",
                name: "${template.name} Preview (${template.viewName})")
        def taskInstance = new Task(project: project)
        def multiMedia = new Multimedia(id: 0)
        taskInstance.addToMultimedia(multiMedia)
        def recordValues = [:]
        def imageMetaData = [0: [width: 2048, height: 1433]]

        render(view: '/transcribe/templateViews/' + template.viewName,
                model: [taskInstance: taskInstance,
                        recordValues: recordValues,
                        isReadonly: null,
                        template: template,
                        nextTask: null,
                        prevTask: null,
                        sequenceNumber: 0,
                        imageMetaData: imageMetaData,
                        isPreview: true,
                        pageController: 'template',
                        mode: params.mode ? params.mode : '',
                        pageAction: 'preview'])
    }

    def exportFieldsAsCSV() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }

        def template = Template.get(params.int("id"))
        if (template) {
            def permissions = templateService.getTemplatePermissions(template)
            if (!permissions.canEdit) {
                render(view: '/notPermitted')
                return
            }
            templateFieldService.exportFieldToCSV(template, response)
        }
    }

    def importFieldsFromCSV() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }

        MultipartFile f = request.getFile('uploadFile')

        if (!f || f.isEmpty()) {
            flash.message = "File missing or invalid. Make sure you select an upload file first!"
        } else {
            def template = Template.get(params.int("id"))
            if (template) {
                def permissions = templateService.getTemplatePermissions(template)
                if (!permissions.canEdit) {
                    render(view: '/notPermitted')
                    return
                }

                templateFieldService.importFieldsFromCSV(template, f)
            } else {
                flash.message = "Missing/invalid template id specified in request!"
            }
        }

        redirect(action:'manageFields', params:[id: params.id])
    }

    def cloneTemplate() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }

        def template = Template.get(params.int("templateId"))
        String newName = params.newName

        if (newName) {
            def existing = Template.findByName(newName)
            if (existing) {
                flash.message = "Failed to clone template - a template with the name " + newName + " already exists!"
                redirect(action: 'list')
                return
            }
        }

        Template newTemplate = null
        if (template && newName) {
            newTemplate = templateService.cloneTemplate(template, newName)
        }

        if (!newTemplate) {
            flash.message = "Failed to clone template due to an unknown error! Please contact the DigiVol Admins."
            redirect(action: 'list')
            return
        }

        redirect(action:'edit', id: newTemplate.id)
    }

    def cloneTemplateFragment() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }

        def template = Template.get(params.int("sourceTemplateId"))
        [templateInstance: template]
    }

    def viewParamsForm(Template template) {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }

        def permissions = templateService.getTemplatePermissions(template)
        if (!permissions.canEdit) {
            render(view: '/notPermitted')
            return
        }

        def view = (params?.view ?: '') + 'Params'
        try {
            def model = [templateInstance: template]
            render template: view, model: model
        } catch (e) {
            log.trace("Could not render template $view", e)
            render status: 404
        }
    }

    /**
     * Config page for Wildlife Spotter template.
     * @param id Template ID to load config for.
     * @return
     */
    def wildlifeTemplateConfig(long id) {
        redirect(action: 'spotterTemplateConfig', id: id)
    }

    def spotterTemplateConfig(long id) {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }
        def template = Template.get(id)

        def permissions = templateService.getTemplatePermissions(template)
        if (!permissions.canEdit) {
            render(view: '/notPermitted')
            return
        }

        def viewParams2 = template.viewParams2 ?: [ categories: [], animals: [] ]
        def viewName = "wildlifeTemplateConfig"
        if (template.viewName == "audioTranscribe") viewName = "audioTemplateConfig"
        render(view: viewName, model: [id: id, templateInstance: template, viewParams2: viewParams2])
    }

    /**
     * Save action for Wildlife Spotter template config
     * @param id Template ID to save config to.
     */
    @Transactional
    def saveWildlifeTemplateConfig(long id) {
        if (!userService.isInstitutionAdmin()) {
            respond status: SC_FORBIDDEN
            return
        }

        def template = Template.get(id)

        def permissions = templateService.getTemplatePermissions(template)
        if (!permissions.canEdit) {
            render(view: '/notPermitted')
            return
        }

        template.viewParams2 = request.getJSON() as Map
        template.save()

        respond status: SC_NO_CONTENT
    }

    /**
     * Upload image for Wildlife Spotter template picklists
     */
    def uploadSpotterFile() {
        if (!userService.isInstitutionAdmin()) {
            respond status: SC_FORBIDDEN
            return
        }

        MultipartFile upload = request.getFile('animal') ?: request.getFile('entry')
        def fileType = "wildlifespotter"
        if (!Strings.isNullOrEmpty(params.fileType as String) && params.fileType == "audio") {
            fileType = "audiotranscribe"
        }

        if (upload) {
            def file = fileUploadService.uploadImage(/* directory */ fileType, upload) { MultipartFile f, HashCode h ->
                h.toString() + "." + fileUploadService.extension(f)
            }
            def hash = FilenameUtils.getBaseName(file.name)
            def ext = FilenameUtils.getExtension(file.name)
            render([ hash: hash, format: ext ] as JSON)
        } else {
            render([ error: "One of animal or entry must be provided" ] as JSON, status: SC_BAD_REQUEST)
        }
    }

    /**
     * This is an AJAX endpoint for the project create form. Returns a list of available templates for the given
     * institution ID. Returns status 401 if no institution parameter provided.
     * Results include the category (global, available or unassigned) and sorted in that order.
     * @param id the Institution ID.
     * @return a list of available templates.
     */
    def templatesForInstitution(long id) {
        log.debug("AJAX templatesForInstitution: ${id}")
        log.debug("Params: ${params}")
        if (!userService.isInstitutionAdmin()) {
            render status: SC_FORBIDDEN
            return
        }

        if (id <= 0) {
            render status: SC_BAD_REQUEST
        } else {
            Institution institution = Institution.get(id)
            def results = templateService.getTemplatesForInstitution(institution, userService.isSiteAdmin(), true)
            render(results as JSON)
        }
    }
}
