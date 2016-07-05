/*
 *  Copyright (C) 2011 Atlas of Living Australia
 *  All Rights Reserved.
 * 
 *  The contents of this file are subject to the Mozilla Public
 *  License Version 1.1 (the "License"); you may not use this file
 *  except in compliance with the License. You may obtain a copy of
 *  the License at http://www.mozilla.org/MPL/
 * 
 *  Software distributed under the License is distributed on an "AS
 *  IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 *  implied. See the License for the specific language governing
 *  rights and limitations under the License.
 */

package au.org.ala.volunteer

import groovy.xml.MarkupBuilder

/**
 * Tag Lib for Transcribe page
 *
 */
class TranscribeTagLib {

    def taskService
    def picklistService
    def markdownService
    def imageServiceService
    def institutionService
    def grailsLinkGenerator

    static returnObjectForTags = ['imageInfos', 'templateFields', 'widgetName', 'sequenceNumbers']


    /**
     * @attr var
     * @attr task
     * @attr fieldType
     */
    def getTemplateField = { attrs, body ->
        Task task = attrs.task as Task
        DarwinCoreField fieldType = attrs.fieldType
        def field = getTemplateFieldForTask(task, fieldType)
        pageScope[attrs.var ?: 'field'] = field
    }

    private TemplateField getTemplateFieldForTask(Task task, DarwinCoreField fieldType) {
        def template = task.project.template

        TemplateField field = TemplateField.findByTemplateAndFieldType(template, fieldType);
        if (!field) {
            // There was no field for this field type defined by this template: create a default one
            field = new TemplateField(template: template, fieldType: fieldType, label: null, defaultValue: null, category: FieldCategory.miscellaneous)
        }
        return field
    }

    /**
     * @attr field
     */
    def renderFieldLabel = { attrs, body ->
        out << getFieldLabel(attrs.field)
    }

    /**
     * @attr fieldType
     * @attr task
     * @attr recordValues
     * @attr recordIdx
     * @attr labelClass
     * @attr valueClass
     * @attr field Optional, if the template already has the field object, no need to look up from it's name.
     * @attr helpTargetPosition Optional, the target position for the qtip help pop up
     * @attr helpTooltipPosition Optional, the tooltip position for the qtip help pop up
     */
    def renderFieldBootstrap = { attrs, body ->

        Task task = attrs.task as Task
        def recordValues = attrs.recordValues
        def labelClass = attrs.labelClass ?: "col-md-2"
        def valueClass = attrs.valueClass ?: "col-md-12"
        def rowClass = attrs.rowClass ?: "row"
        def recordIdx = attrs.recordIdx ?: 0
        def helpTargetPosition = attrs.helpTargetPosition
        def helpTooltipPosition = attrs.helpTooltipPosition

        if (!task) {
            return
        }

        def field = attrs.field as TemplateField
        if (!field) {
            DarwinCoreField fieldType = attrs.fieldType
            field = getTemplateFieldForTask(task, fieldType)
        }

        def mb = new MarkupBuilder(out)
        renderFieldBootstrapImpl(mb, field, task, recordValues, recordIdx, labelClass, valueClass, attrs, rowClass, helpTargetPosition, helpTooltipPosition)
    }

    private String getFieldLabel(TemplateField field) {
        if (field.label) {
            return field.label
        } else {
            return field.fieldType?.label ?: field.fieldType?.name()
        }
    }

    private void renderFieldBootstrapImpl(MarkupBuilder mb, TemplateField field, Task task, recordValues, int recordIdx, String labelClass, String valueClass, Map attrs, String rowClass = "row", String helpTargetPosition = null, String helpTooltipPosition = null) {

        if (!task || !field) {
            return
        }

        def name = field.fieldType?.name()
        def label = getFieldLabel(field)
        def hideLabel = attrs.hideLabel as Boolean

        def widgetHtml = getWidgetHtml(task, field, recordValues,recordIdx, attrs, "") // col-md-12

        if (field.type == FieldType.hidden) {
            mb.mkp.yieldUnescaped(widgetHtml)
        } else if (field.fieldType == DarwinCoreField.widgetPlaceholder) {
            mb.div() {
                mb.mkp.yieldUnescaped(widgetHtml)
            }
        } else {
            mb.div(class:rowClass) {
                if (!hideLabel) {
                    div(class:labelClass) {
                        span(class:"fieldLabel") {
                            if (field.fieldType != DarwinCoreField.spacer) {
                                mkp.yield(g.message(code:'record.' + name +'.label', default:label))
                            } else {
                                mkp.yieldUnescaped("&nbsp;")
                            }
                        }
                    }
                }
                div(class:valueClass) {
                    div(class: rowClass) {
                        div(class:'col-md-10') {
                            mkp.yieldUnescaped(widgetHtml)
                        }
                        div(class:'col-md-2') {
                            renderFieldHelp(mb, field, helpTargetPosition, helpTooltipPosition)
                        }
                    }
                }
            }
        }

    }

    def renderWidgetHtml = { attrs, body ->
        Task taskInstance = attrs.taskInstance
        TemplateField field = attrs.field
        Map recordValues = attrs.recordValues
        int recordIdx = attrs.recordIdx ?: 0
        String auxClass = attrs.auxClass

        //def mb = new MarkupBuilder(out)
        def html = getWidgetHtml(taskInstance, field, recordValues, recordIdx, attrs, auxClass)
        //mb.mkp.yieldUnescaped(html)
        out << html
    }

    /**
     * Gets the id/name for a HTML widget as a String
     *
     * @attr field The field
     * @attr recordIdx The record index
     */
    def widgetName = { attrs, body ->
        TemplateField field = attrs.field
        int recordIdx = attrs.recordIdx ?: 0

        genWidgetName(field, recordIdx)
    }

    String genWidgetName(TemplateField field, int recordIdx) {
        def name = field.fieldType.name() //+ (field.fieldTypeClassifier ? ".${field.fieldTypeClassifier}" : "")
        "recordValues.${recordIdx}.${name}"
    }

    private String getWidgetHtml(Task taskInstance, TemplateField field, recordValues, recordIdx, attrs, String auxClass) {

        if (!field) {
            return ""
        }

        if (field.fieldType == DarwinCoreField.spacer) {
            return '<span class="${auxClass}">&nbsp;</span>'
        }

        def name = field.fieldType.name()
        def widgetName = genWidgetName(field, recordIdx)
        def cssClass = name

        if (field.mandatory) {
            cssClass = cssClass + " validate[required]"
        }

        if (auxClass) {
            cssClass += " " + auxClass
        }

        String w
        def noAutoCompleteList = field.template.viewParams['noAutoComplete']?.split(",")?.toList()
        ValidationRule validationRule = null
        if (field.validationRule) {
            validationRule = ValidationRule.findByName(field.validationRule)
        }

        def tabindex = attrs.tabindex ? attrs.tabindex * 10 : null
        def existingValue = recordValues?.get(recordIdx)?.get(name)

        def widgetModel = [field:field, value: existingValue, cssClass: cssClass, validationRule: validationRule, taskInstance: taskInstance, tabindex: tabindex, recordIdx: recordIdx, widgetName: widgetName]

        switch (field.type) {
            case FieldType.imageSelect:
            case FieldType.imageMultiSelect:
                w = render(template: '/transcribe/imageSelectWidget', model: widgetModel)
                break
            case FieldType.latLong:
                w = render(template: '/transcribe/latLongWidget', model: widgetModel)
                break
            case FieldType.date:
                w = render(template: '/transcribe/dateWidget', model: widgetModel)
                break
            case FieldType.collectorColumns:
                w = render(template: '/transcribe/collectorColumnWidget', model: widgetModel)
                break
            case FieldType.mappingTool:
                w = render(template: '/transcribe/mappingToolWidget', model: widgetModel)
                break
            case FieldType.copyFromPreviousTaskButton:
                w = render(template: '/transcribe/copyFromPreviousTaskWidget', model: widgetModel)
                break
            case FieldType.unitRange:
                w = render(template: '/transcribe/rangeWidget', model: widgetModel)
                break
            case FieldType.sheetNumber:
                w = render(template: '/transcribe/sheetNumberWidget', model: widgetModel)
                break
            case FieldType.autocompleteTextarea:
                cssClass += " autocomplete" // fall through
            case FieldType.textarea:
                int rows = 6
                if (attrs.rows) {
                    rows = Integer.parseInt(attrs.rows);
                }
                w = g.textArea(
                    name: widgetName,
                    rows: rows,
                    value: existingValue,
                    'class':"$cssClass form-control",
                    validationRule: validationRule?.name,
                    tabindex: tabindex
                )
                break
            case FieldType.hidden:
                w = g.hiddenField(
                    name: widgetName,
                    value: existingValue,
                    'class':cssClass
                )
                break;
            case FieldType.checkbox:
                def checked = Boolean.parseBoolean(existingValue ?: field?.defaultValue)
                w = g.checkBox(
                    name: widgetName,
                    value: checked,
                    validationRule: validationRule?.name,
                    tabindex: tabindex,
                    class: 'form-control'
                )
                break;
            case FieldType.select:
                def options = picklistService.getPicklistItemsForProject(field.fieldType, taskInstance.project)
                if (options) {
                    w = g.select(
                        name: widgetName,
                        from: options,
                        optionValue:'value',
                        optionKey:'value',
                        value: existingValue ?: field?.defaultValue,
                        noSelection:['':''],
                        'class': "$cssClass form-control",
                        validationRule: validationRule?.name,
                        tabindex: tabindex
                    )
                    break
                }
            case FieldType.radio:
                def options = picklistService.getPicklistItemsForProject(field.fieldType, taskInstance.project)
                def labels = options*.value
                if (options) {
                    w = g.radioGroup(
                        name: widgetName,
                        value: existingValue ?:field?.defaultValue,
                        values: labels,
                        labels: labels,
                        class: 'form-control',
                        // 'class':cssClass,
                        validationRule:validationRule?.name,
                        tabindex: tabindex
                    ) {
                        out << "<span class=\"radio-item\">${it.radio}&nbsp;${it.label}</span>"
                    }
                    break
                }
            case FieldType.autocomplete:
                cssClass = cssClass + " autocomplete"
            case FieldType.text: // fall through
            default:

                if (noAutoCompleteList?.contains(name)) {
                    cssClass += ' noAutoComplete'
                }

                w = g.textField(
                    name: widgetName,
                    maxLength:200,
                    value: existingValue,
                    'class':"$cssClass form-control",
                    validationRule: validationRule?.name,
                    tabindex: tabindex
                )
        }

        return w
    }

    /**
     * @attr multimedia
     * @attr elementId
     * @attr hideControls
     * @attr hidePinImage
     * @attr preserveWidthWhenPinned
     * @attr height The height of the image viewer in pixels
     */
    def imageViewer = { attrs, body ->
        def multimedia = attrs.multimedia as Multimedia
        if (multimedia) {

            int rotate = 0
            if (attrs.rotate) {
                rotate = attrs.rotate
            }

            def mb = new MarkupBuilder(out)

            def imageMetaData = taskService.getImageMetaData(multimedia, rotate)

            if (!imageMetaData) {

                def sampleFile = grailsApplication.mainContext.getResource("images/sample-task.jpg").file


                def sampleUrl = resource(dir:'/images', file:'sample-task.jpg')
                imageMetaData = taskService.getImageMetaDataFromFile(sampleFile, sampleUrl, 0)
                mb.div(class:'alert alert-danger') {
                    button(type: 'button', class: 'close', ('data-dismiss'): 'alert') {
                        mkp.yieldUnescaped('&times;')
                    }
                    span() {
                        mkp.yield("An error occurred getting the meta data for task image ${multimedia.id}!")
                    }
                }
            }

            mb.div(id:'image-parent-container') {
                mb.div(id:attrs.elementId ?: 'image-container', preserveWidthWhenPinned:attrs.preserveWidthWhenPinned) {
                    mb.img(src:imageMetaData.url, alt: attrs.altMessage ?: 'Task image', 'image-height':imageMetaData?.height, 'image-width':imageMetaData?.width) {}
                    if (!attrs.hideControls) {
                        div(class:'imageviewer-controls') {
                            a(id:'panleft', href:"#", class:'left') {}
                            a(id:'panright', href:"#", class:'right') {}
                            a(id:'panup', href:"#", class:'up') {}
                            a(id:'pandown', href:"#", class:'down') {}
                            a(id:'zoomin', href:"#", class:'zoom') {}
                            a(id:'zoomout', href:"#", class:'back') {}
                        }

                        if (!attrs.hidePinImage) {
                            div(class:'pin-image-control') {
                                a(id:'pinImage', href:'#', title:'Fix the image in place in the browser window', ('data-container'): 'body') {
                                    mkp.yield('Pin image in place')
                                }
                            }
                        }
                        if (!attrs.hideShowInOtherWindow) {
                            div(class:'show-image-control') {
                                a(id:'showImageWindow', href:'#', title:'Show image in a separate window', ('data-container'): 'body') {
                                    mkp.yield('Show image in a separate window')
                                }
                            }

                        }
                    }
                }
            }
            if (attrs.height) {
                asset.script([type: 'text/javascript', 'asset-defer': ''], "   \$(document).ready(function() { if (setImageViewerHeight) { setImageViewerHeight(${attrs.height}); } } );" )
//                mb.script(type:"text/javascript") {
//                    mkp.yieldUnescaped("   \$(document).ready(function() { if (setImageViewerHeight) { setImageViewerHeight(${attrs.height}); } } );")
//                }
            }
        }
    }

    /**
     * @attr task
     * @attr recordValues
     * @attr category
     * @attr labelClass
     * @attr valueClass
     * @attr columns
     *
     */
    def templateFieldsForCategory = { attrs, body ->
        FieldCategory category = attrs.category
        Task task = attrs.task as Task
        int columns = 2
        String labelClass = attrs.labelClass ?: 'col-md-4'
        String valueClass = attrs.valueClass ?: 'col-md-8'
        def recordValues = attrs.recordValues
        def mb = new MarkupBuilder(out)
        def fields = TemplateField.findAllByCategoryAndTemplate(category, task?.project?.template, [sort: 'displayOrder'])
        renderFieldsInColumns(columns, mb, fields, task, labelClass, valueClass, recordValues, attrs)
    }

    private void renderFieldsInColumns(int numCols, MarkupBuilder mb, List<TemplateField> fields, Task task, String labelClass, String valueClass, recordValues, attrs) {
        if (fields) {

            if (numCols > 12 || numCols < 0) {
                throw new RuntimeException("Invalid number of columns!")
            }

            def hidden = fields.findAll { it.type == FieldType.hidden }

            def spanClass = String.format("col-md-%d", (12 / numCols).toInteger());

            fields.removeAll { it.type == FieldType.hidden }

            def fieldIndex = 0;
            while (fieldIndex < fields.size()) {
                mb.div(class:'row') {
                    for (int colIndex = 0; colIndex < numCols; ++colIndex) {
                        mb.div(class:'') {
                            mb.div(class:spanClass) {
                                if (fieldIndex < fields.size()) {
                                    def field = fields[fieldIndex++]
                                    renderFieldBootstrapImpl(mb, field, task, recordValues, 0, labelClass, valueClass, attrs)
                                } else {
                                    mkp.yieldUnescaped("&nbsp;")
                                }
                            }
                        }
                    }
                }
            }

            hidden?.each { field ->
                renderFieldBootstrapImpl(mb, field, task, recordValues, 0, labelClass, valueClass, attrs)
            }

        }
    }

    /**
     * @attr title
     * @attr description
     * @attr task
     * @attr recordValues
     * @attr category
     * @attr columns
     */
    def renderFieldCategorySection = { attrs, body ->
        def task = attrs.task as Task
        def recordValues = attrs.recordValues
        FieldCategory category = attrs.category

        int columns = 2
        if (attrs.columns) {
            columns = Integer.parseInt(attrs.columns)
        }

        Template template = task?.project?.template
        if (!category || !template) {
            return
        }

        def fields = TemplateField.findAllByCategoryAndTemplate(category, template)?.sort { it.displayOrder }
        if (!fields) {
            return
        }

        def mb = new MarkupBuilder(out)

        def bodyContent = body()

        def nextSectionNumberClosure = this.&nextSectionNumber

        mb.div(class:'panel panel-default transcribeSection') {
            div(class: 'panel-body') {
                if ((attrs?.renderHeaderTitle == null) || (attrs.renderHeaderTitle == 'true')) {
                    div(class: 'row transcribeSectionHeader') {
                        div(class: 'col-md-12') {
                            span(class: 'transcribeSectionHeaderLabel') {
                                if (nextSectionNumberClosure) {
                                    mkp.yield("${nextSectionNumberClosure()}. ")
                                }
                                mkp.yield(attrs.title)
                            }
                            if (bodyContent) {
                                span() {
                                    mkp.yieldUnescaped(bodyContent)
                                }
                            }
                            span() {
                                if (attrs.description) {
                                    mkp.yieldUnescaped("&nbsp;&ndash;&nbsp;")
                                    mkp.yield(attrs.description)
                                }
                            }
                            a(class: 'closeSectionLink', href: '#') {
                                mkp.yield('Shrink');
                            }
                        }

                    }
                    div(class: 'transcribeSectionBody') {
                        renderFieldsInColumns(columns, mb, fields, task, "col-md-4", "col-md-8", recordValues, attrs)
                        mkp.yieldUnescaped("&nbsp;")
                    }
                } else {
                    renderFieldsInColumns(columns, mb, fields, task, "col-md-4", "col-md-8", recordValues, attrs)
                }
            }

        }

    }

    /**
     * @attr title
     * @attr description
     * @attr task
     * @attr recordValues
     * @attr category
     */
    def renderCategoryFieldsColumn = { attrs, body ->
        def task = attrs.task as Task
        def recordValues = attrs.recordValues
        FieldCategory category = attrs.category

        Template template = task?.project?.template
        if (!category || !template) {
            return
        }

        def fields = TemplateField.findAllByCategoryAndTemplate(category, template)?.sort { it.displayOrder }
        if (!fields) {
            return
        }

        def mb = new MarkupBuilder(out)

        def bodyContent = body()

        renderFieldsInColumns(1, mb, fields, task, "col-md-4", "col-md-8", recordValues, attrs)

    }

    def fieldHelp = { attrs, body ->
        def field = attrs.field as TemplateField
        def tooltipPosition = attrs.tooltipPosition
        def targetPosition = attrs.targetPosition
        renderFieldHelp(new MarkupBuilder(out), field, targetPosition, tooltipPosition)
    }

    private renderFieldHelp(MarkupBuilder mb, TemplateField field, String targetPosition = null, String tooltipPosition = null) {
        if (field && field.helpText) {
            def helpText = markdownService.markdown(field.helpText)
            mb.a(href:'#', class:'btn btn-default btn-xs fieldHelp', title:helpText, tabindex: "-1", targetPosition: targetPosition, tooltipPosition: tooltipPosition) {
                i(class:'fa fa-question help-container') {
                    mkp.yieldUnescaped('')
                }
            }
        } else {
            mb.mkp.yieldUnescaped("&nbsp;")
        }
    }

    def imageInfos = { attrs, body ->
        //List<TemplateField> fields = attrs.fields
        Project project = attrs.project
        Picklist pl = attrs.picklist
        TemplateField field = attrs.field
        def warnings = []

        if (!pl && !field) return [error: "No valid picklist or field provided"]
        if (!pl)
            pl = Picklist.findByNameAndFieldTypeClassifier(field.fieldType.name(), field.fieldTypeClassifier)
        if (!pl)
            pl = Picklist.findByName(field.fieldType.name())

        if (!pl) return [error: "No picklist found for ${field.fieldType.name()} (${field.fieldTypeClassifier}"]

        def items = PicklistItem.findAllByPicklistAndInstitutionCode(pl, project?.picklistInstitutionCode)

        // fallback to default picklist if institution code given and no items found
        if (project?.picklistInstitutionCode && !items) items = PicklistItem.findAllByPicklistAndInstitutionCodeIsNull(pl)

        if (!items) return [error: "No picklist items found for picklist ${pl.uiLabel} and picklist institution code ${project?.picklistInstitutionCode}"]
        def items2 = items.collectEntries {
            def key = it.key?.split(',')?.toList()?.collect { it?.trim() } ?: []
            [ (key) : it.value ]
        }
        def imageIds = items2*.key.flatten()
        def imageInfos
        try {
            imageInfos = imageServiceService.getImageInfoForIds(imageIds)
        } catch (e) {
            log.error("Error calling image service for ${imageIds}", e)
            return [error: "Error contacting image service: ${e.message}"]
        }

        if (!imageInfos)
            return [error: "Could not retrieve image infos for keys ${imageIds.join(", ")}"]
        else {
            //def missing = imageIds.collect { [name: it, info:imageInfos[it]] }.findAll { it.info == null }.collect { it.name }
            def missing = imageIds.findAll { imageInfos[it] == null }
            if (missing) warnings.add("The following image ids can not be found: ${missing.join(', ')}")
        }

        [picklist: pl, items: items2, infos: imageInfos, warnings: warnings]
    }

    def templateFields = { attrs, body ->
        def category = attrs.category ?: FieldCategory.dataset
        def hiddenFields = attrs.hidden ?: false
        def template = attrs.template
        def fields
        if (hiddenFields) fields = TemplateField.findAllByCategoryAndTemplateAndType(category, template, FieldType.hidden, [sort:'displayOrder'])
        else fields = TemplateField.findAllByCategoryAndTemplateAndTypeNotEqual(category, template, FieldType.hidden, [sort:'displayOrder'])
        def groupedFields = fields.groupBy { it.fieldType }
        fields.collect { [field: it, recordIdx: groupedFields[it.fieldType].findIndexOf { it2 -> it == it2 }] }
    }

    def sequenceNumbers = { attrs, body ->
        def project = attrs.project
        def number = attrs.number ?: 0
        def count = attrs.count ?: 0

        def max = taskService.findMaxSequenceNumber(project)
        def results
        if (max) {
            def previous = (Math.max(0, number - count))..<number
            def next = number == max ? [] : (number+1)..(Math.min(max,number+count))
            results = [previous: previous, next: next]
        } else {
            results = [previous:[], next:[]]
        }

        return results
    }

    def transcriptionLogoUrl = { attrs, body ->
        Task task = attrs.task
        if (task?.project?.institution) {
            out << institutionService.getLogoImageUrl(task.project.institution)
        } else if (task?.project) {
            out << task.project.featuredImage
        } else {
            out << grailsLinkGenerator.resource( dir: 'images/2.0/', file: 'logoDigivolGrey.png' )
        }
    }

    /**
     * Get the title line for a v2 transcription
     * @attr task The task
     * @attr recordValues The record values
     * @attr sequenceNumber The task sequence number
     */
    def transcribeSubheadingLine = { attrs, body ->
        def task = attrs.task
        def recordValues = attrs.recordValues
        def sequenceNumber = attrs.sequenceNumber

        def maxSeqNo = sequenceNumber ? taskService.findMaxSequenceNumber(task.project) : -1

        def cn = recordValues?.get(0)?.catalogNumber
        def m
        if (cn && sequenceNumber) {
            m = message(code: 'transcribe.subheading.full', default: 'Catalog Number {0} <span>({1} of {2})</span>', args: [cn, sequenceNumber, maxSeqNo])
        } else if (cn) {
            m = message(code: 'transcribe.subheading.catalog', default: 'Catalog Number {0}', args: [cn])
        } else if (sequenceNumber) {
            m = message(code: 'transcribe.subheading.seqNo', default: '<span>{0} of {1}</span>', args: [sequenceNumber, maxSeqNo])
        } else {
            m = ''
        }

        out << m
    }

    private def nextSectionNumber() {
        def sectionNumber = ++(request.getAttribute('sectionNumber') ?: 0)
        request.setAttribute('sectionNumber', sectionNumber)
        return sectionNumber
    }

    def sectionNumber = { attrs, body ->
        def sectionNumber = nextSectionNumber()
        out << sectionNumber
    }

}