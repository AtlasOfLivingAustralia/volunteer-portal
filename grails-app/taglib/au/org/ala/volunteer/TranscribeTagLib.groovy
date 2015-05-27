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
import org.codehaus.groovy.grails.compiler.support.GrailsResourceLoader

/**
 * Tag Lib for Transcribe page
 *
 */
class TranscribeTagLib {

    def taskService
    def picklistService
    def markdownService
    def imageServiceService

    static returnObjectForTags = ['imageInfos', 'templateFields', 'widgetName']


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
        def labelClass = attrs.labelClass ?: "span2"
        def valueClass = attrs.valueClass ?: "span12"
        def rowClass = attrs.rowClass ?: "row-fluid"
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

    private void renderFieldBootstrapImpl(MarkupBuilder mb, TemplateField field, Task task, recordValues, int recordIdx, String labelClass, String valueClass, Map attrs, String rowClass = "row-fluid", String helpTargetPosition = null, String helpTooltipPosition = null) {

        if (!task || !field) {
            return
        }

        def name = field.fieldType?.name()
        def label = getFieldLabel(field)
        def hideLabel = attrs.hideLabel as Boolean

        def widgetHtml = getWidgetHtml(task, field, recordValues,recordIdx, attrs, "span12")

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
                    div(class:'span10') {
                        mkp.yieldUnescaped(widgetHtml)
                    }
                    div(class:'span2') {
                        renderFieldHelp(mb, field, helpTargetPosition, helpTooltipPosition)
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
        def name = field.fieldType.name()
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
                    'class':cssClass,
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
                    tabindex: tabindex
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
                        'class':cssClass,
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
                    'class':cssClass,
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
                mb.dev(class:'alert alert-danger') {
                    mkp.yield("An error occurred getting the meta data for task image ${multimedia.id}!")
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
                                a(id:'pinImage', href:'#', title:'Fix the image in place in the browser window') {
                                    mkp.yield('Pin image in place')
                                }
                            }
                        }
                        if (!attrs.hideShowInOtherWindow) {
                            div(class:'show-image-control') {
                                a(id:'showImageWindow', href:'#', title:'Show image in a separate window') {
                                    mkp.yield('Show image in a separate window')
                                }
                            }

                        }
                    }
                }
            }
            if (attrs.height) {
                mb.script(type:"text/javascript") {
                    mkp.yieldUnescaped("   \$(document).ready(function() { if (setImageViewerHeight) { setImageViewerHeight(${attrs.height}); } } );")
                }
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
        String labelClass = attrs.labelClass ?: 'span4'
        String valueClass = attrs.valueClass ?: 'span8'
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

            def spanClass = String.format("span%d", (12 / numCols).toInteger());

            fields.removeAll { it.type == FieldType.hidden }

            def fieldIndex = 0;
            while (fieldIndex < fields.size()) {
                mb.div(class:'row-fluid') {
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

        def nextSectionNumberClosure = pageScope.getProperty("nextSectionNumber")

        mb.div(class:'well well-small transcribeSection') {
            div(class:'row-fluid transcribeSectionHeader') {
                div(class:'span12') {
                    span(class:'transcribeSectionHeaderLabel') {
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
                    a(class:'closeSectionLink', href:'#') {
                        mkp.yield('Shrink');
                    }
                }

            }

            div(class:'transcribeSectionBody') {
                renderFieldsInColumns(columns, mb, fields, task, "span4", "span8", recordValues, attrs)
                mkp.yieldUnescaped("&nbsp;")
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

        def nextSectionNumberClosure = pageScope.getProperty("nextSectionNumber")

        renderFieldsInColumns(1, mb, fields, task, "span4", "span8", recordValues, attrs)

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
            mb.a(href:'#', class:'fieldHelp', title:helpText, tabindex: "-1", targetPosition: targetPosition, tooltipPosition: tooltipPosition) {
                span(class:'help-container') {
                    mkp.yieldUnescaped('&nbsp;')
                }
            }
        } else {
            mb.mkp.yieldUnescaped("&nbsp;")
        }
    }

    def imageInfos = { attrs, body ->
        //List<TemplateField> fields = attrs.fields
        TemplateField field = attrs.field

        //def pls = fields.collect { Picklist.findByNameAndClazz(it.fieldType.name(), field.layoutClass) }
        def pl = Picklist.findByNameAndClazz(field.fieldType.name(), field.layoutClass)
        //def items = []
        //if (pls) {
        //    items = PicklistItem.findAllByPicklistInList(pls)
        //}
        def items = PicklistItem.findAllByPicklist(pl)
        def imageIds = items*.key
        def imageInfos = imageServiceService.getImageInfoForIds(imageIds)

        [picklist: pl, items: items, infos: imageInfos]
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

}