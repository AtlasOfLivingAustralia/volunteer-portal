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

    /**
    * @attr task
    * @attr fieldType
    * @attr recordValues
    * @attr recordIdx
    * @attr labelClass
    * @attr widgetClass
    */
    def renderFieldLabelAndWidgetSpans = { attrs, body ->
        Task task = attrs.task as Task
        DarwinCoreField fieldType = attrs.fieldType
        def recordValues = attrs.recordValues
        def recordIdx = attrs.recordIdx ?: 0
        def field = getTemplateFieldForTask(task, fieldType)
        def fieldLabel = getFieldLabel(field)
        def widgetHtml = getWidgetHtml(task, field, recordValues, recordIdx, attrs, 'span10')
        def mb = new MarkupBuilder(out)
        mb.div(class:attrs.labelClass ?: 'span2') {
            if (field.fieldType != DarwinCoreField.spacer) {
                mkp.yield(g.message(code:'record.' + field.fieldType.toString() +'.label', default:fieldLabel))
            } else {
                mkp.yieldUnescaped("&nbsp;")
            }
        }
        mb.div(class:attrs.widgetClass ?: 'span10') {
            mkp.yieldUnescaped(widgetHtml)
            if (field.helpText) {
                def help = "<a href='#' class='fieldHelp' title='${field.helpText}'><span class='help-container'>&nbsp;</span></a>"
                mkp.yieldUnescaped(help)
            }
        }

    }

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
     */
    def renderFieldBootstrap = { attrs, body ->

        Task task = attrs.task as Task
        DarwinCoreField fieldType = attrs.fieldType
        def recordValues = attrs.recordValues
        def labelClass = attrs.labelClass ?: "span2"
        def valueClass = attrs.valueClass ?: "span10"
        def rowClass = attrs.rowClass ?: "row-fluid"
        def recordIdx = attrs.recordIdx ?: 0

        if (!task) {
            return
        }

        def field = getTemplateFieldForTask(task, fieldType)

        def mb = new MarkupBuilder(out)
        renderFieldBootstrapImpl(mb, field, task, recordValues, recordIdx, labelClass, valueClass, attrs, rowClass)
    }

    private String getFieldLabel(TemplateField field) {
        if (field.label) {
            return field.label
        } else {
            return field.fieldType?.label ?: field.fieldType?.name()
        }
    }

    private void renderFieldBootstrapImpl(MarkupBuilder mb, TemplateField field, Task task, recordValues, int recordIdx, String labelClass, String valueClass, Map attrs, String rowClass = "row-fluid") {

        if (!task || !field) {
            return
        }

        def name = field.fieldType?.name()
        def label = getFieldLabel(field)
        def hideLabel = attrs.hideLabel as Boolean
        def widgetHtml = getWidgetHtml(task, field, recordValues,recordIdx, attrs, "span10")

        if (field.type == FieldType.hidden) {
            mb.mkp.yieldUnescaped(widgetHtml)
        } else if (field.fieldType == DarwinCoreField.widgetPlaceholder) {
            mb.mkp.yieldUnescaped(widgetHtml)
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
                    mkp.yieldUnescaped(widgetHtml)
                    if (field.helpText) {
                        def help = "<a href='#' class='fieldHelp' title='${field.helpText}'><span class='help-container'>&nbsp;</span></a>"
                        mkp.yieldUnescaped(help)
                    }
                }
            }
        }

    }

    private String getWidgetHtml(Task taskInstance, TemplateField field, recordValues, recordIdx, attrs, String auxClass) {

        if (!field) {
            return ""
        }

        if (field.fieldType == DarwinCoreField.spacer) {
            return '<span class="${auxClass}">&nbsp;</span>'
        }

        def name = field.fieldType.name()
        def cssClass = name

        if (field.mandatory) {
            cssClass = cssClass + " validate[required]"
        }

        if (auxClass) {
            cssClass += " " + auxClass
        }

        String w
        def noAutoCompleteList = field.template.viewParams['noAutoComplete']?.split(",")?.toList()
        def widgetModel = [field:field, value: recordValues?.get(0)?.get(name), cssClass: cssClass]
        def validationRuleName = field.validationRule?.replaceAll('\\s', '_')

        switch (field.type) {
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
            case FieldType.elevationRange:
                widgetModel.minFieldType = DarwinCoreField.minimumElevationInMeters
                widgetModel.maxFieldType = DarwinCoreField.maximumElevationInMeters
                w = render(template: '/transcribe/rangeWidget', model: widgetModel)
                break
            case FieldType.depthRange:
                widgetModel.minFieldType = DarwinCoreField.minimumDepthInMeters
                widgetModel.maxFieldType = DarwinCoreField.maximumDepthInMeters
                w = render(template: '/transcribe/rangeWidget', model: widgetModel)
                break
            case FieldType.sheetNumber:
                w = render(template: '/transcribe/sheetNumberWidget', model: widgetModel)
                break
            case FieldType.textarea:
                int rows = ((name == 'occurrenceRemarks') ? 6 : 4)
                if (attrs.rows) {
                    rows = Integer.parseInt(attrs.rows);
                }
                w = g.textArea(
                    name:"recordValues.${recordIdx}.${name}",
                    rows: rows,
                    value:recordValues?.get(0)?.get(name),
                    'class':cssClass,
                    validationRule: validationRuleName
                )
                break
            case FieldType.hidden:
                w = g.hiddenField(
                    name:"recordValues.${recordIdx}.${name}",
                    value:recordValues?.get(0)?.get(name),
                    'class':cssClass
                )
                break;
            case FieldType.select:
                def options = picklistService.getPicklistItemsForProject(field.fieldType, taskInstance.project)
                if (options) {
                    w = g.select(
                        name:"recordValues.${recordIdx}.${name}",
                        from: options,
                        optionValue:'value',
                        optionKey:'value',
                        value:recordValues?.get(0)?.get(name)?:field?.defaultValue,
                        noSelection:['':''],
                        'class':cssClass,
                        validationRule: validationRuleName
                    )
                    break
                }
            case FieldType.radio:
                def options = picklistService.getPicklistItemsForProject(field.fieldType, taskInstance.project)
                def labels = options*.value
                if (options) {
                    w = g.radioGroup(
                        name:"recordValues.${recordIdx}.${name}",
                        value:recordValues?.get(0)?.get(name)?:field?.defaultValue,
                        values: labels,
                        labels: labels,
                        // 'class':cssClass,
                        validationRule:validationRuleName
                    ) {
                        out << "<span class=\"radio-item\">${it.radio}&nbsp;${it.label}</span>"
                    }
                    break
                }
            case FieldType.checkbox:
                def checked = Boolean.parseBoolean(recordValues?.get(0)?.get(name)?:field?.defaultValue)
                w = g.checkBox(
                    name: "recordValues.${recordIdx}.${name}",
                    value: checked,
                    validationRule:field.validationRule
                )
                break;
            case FieldType.autocomplete:
                cssClass = cssClass + " autocomplete"
            case FieldType.text: // fall through
            default:

                if (noAutoCompleteList?.contains(name)) {
                    cssClass += ' noAutoComplete'
                }

                w = g.textField(
                    name:"recordValues.${recordIdx}.${name}",
                    maxLength:200,
                    value:recordValues?.get(0)?.get(name),
                    'class':cssClass,
                    validationRule: validationRuleName
                )
        }

        return w
    }

    /**
     * @attr multimedia
     * @attr elementId
     * @attr hideControls
     * @attr hidePinImage
     */
    def imageViewer = { attrs, body ->
        def multimedia = attrs.multimedia as Multimedia
        if (multimedia) {
            def imageUrl = "${grailsApplication.config.server.url}${multimedia.filePath}"
            def imageMetaData = taskService.getImageMetaData(multimedia)
            def mb = new MarkupBuilder(out)
            mb.div(id:'image-parent-container') {
                mb.div(id:attrs.elementId ?: 'image-container') {
                    mb.img(src:imageUrl, alt: attrs.altMessage ?: 'Task image', 'image-height':imageMetaData?.height, 'image-width':imageMetaData?.width) {}
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
                    }
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
        int columns = attrs.columns ?: 2
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
     */
    def renderFieldCategorySection = { attrs, body ->
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
                renderFieldsInColumns(2, mb, fields, task, "span4", "span8", recordValues, attrs)
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
        if (field && field.helpText) {
            def mb = new MarkupBuilder(out)
            mb.a(href:'#', class:'fieldHelp', title:field.helpText) {
                span(class:'help-container') {
                    mkp.yieldUnescaped('&nbsp;')
                }
            }
        }
    }

}