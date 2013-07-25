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
 * @author "Nick dos Remedios <Nick.dosRemedios@csiro.au>"
 */
class TranscribeTagLib {

    def taskService

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
        def recordIdx = attrs.recordIdx ?: 0

        if (!task) {
            return
        }

        def template = task.project.template

        TemplateField field = TemplateField.findByTemplateAndFieldType(template, fieldType);
        if (!field) {
            // There was no field for this field type defined by this template: create a default one
            field = new TemplateField(template: template, fieldType: fieldType, label: null, defaultValue: null, category: FieldCategory.miscellaneous)
        }

        def mb = new MarkupBuilder(out)
        renderFieldBootstrapImpl(mb, field, task, recordValues, recordIdx, labelClass, valueClass, attrs)
    }

    private void renderFieldBootstrapImpl(MarkupBuilder mb, TemplateField field, Task task, recordValues, int recordIdx, String labelClass, String valueClass, Map attrs) {

        if (!task || !field) {
            return
        }

        def name = field.fieldType?.name()
        def label
        if (field.label) {
            label = field.label
        } else {
            label = field.fieldType?.label
        }


        def widgetHtml = getWidgetHtml(field, recordValues,recordIdx, attrs, "span10")

        if (field.type == FieldType.hidden) {
            mb.mkp.yieldUnescaped(widgetHtml)
        } else {
            mb.div(class:'row-fluid') {
                div(class:labelClass) {
                    span(class:"fieldLabel") {
                        if (field.fieldType != DarwinCoreField.spacer) {
                            mkp.yield(g.message(code:'record.' + name +'.label', default:label))
                        } else {
                            mkp.yieldUnescaped("&nbsp;")
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

    private String getWidgetHtml(TemplateField field, recordValues, recordIdx, attrs, String cssClass) {

        if (!field) {
            return ""
        }

        if (field.fieldType == DarwinCoreField.spacer) {
            return "&nbsp;"
        }

        String w
        def name = field.fieldType.name()
        def noAutoCompleteList = field.template.viewParams['noAutoComplete']?.split(",")?.toList()
        switch (field.type) {

            case FieldType.textarea:
                int rows = ((name == 'occurrenceRemarks') ? 6 : 4)
                if (attrs.rows) {
                    rows = Integer.parseInt(attrs.rows);
                }
                w = g.textArea(
                    name:"recordValues.${recordIdx}.${name}",
                    rows: rows,
                    value:recordValues?.get(0)?.get(name),
                    'class':cssClass
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
                def pl = Picklist.findByName(name)
                if (pl) {
                    def options = PicklistItem.findAllByPicklist(pl)
                    w = g.select(
                        name:"recordValues.${recordIdx}.${name}",
                        from: options,
                        optionValue:'value',
                        optionKey:'value',
                        value:recordValues?.get(0)?.get(name)?:field?.defaultValue,
                        noSelection:['':''],
                        'class':cssClass
                    )
                    break
                }
            case FieldType.radio: // fall through TODO
            case FieldType.checkbox: // fall through TODO
            case FieldType.text: // fall through
            case FieldType.autocomplete:
                cssClass = cssClass + " autocomplete"
            default:

                if (noAutoCompleteList?.contains(name)) {
                    cssClass += ' noAutoComplete'
                }

                w = g.textField(
                    name:"recordValues.${recordIdx}.${name}",
                    maxLength:200,
                    value:recordValues?.get(0)?.get(name),
                    'class':cssClass
                )
        }

        return w
    }

    private def renderWidgetTD(MarkupBuilder mb, TemplateField field, recordValues, recordIdx, attrs) {

        if (!field) {
            return
        }

        def name = field.fieldType.name()
        def cssClass = name
        def tdcssClass = "td_" + name;

        if (field.fieldType == DarwinCoreField.spacer) {
            mb.td(class:"value ${tdcssClass}" ) {
                mkp.yieldUnescaped("&nbsp;");
            }
            return
        }

        if (name =~ /[Dd]ate/) {
            // so we can add a date widget with JQuery
            cssClass = cssClass + ' datePicker';
        }
        if (field.mandatory) {
            cssClass = cssClass + " validate[required]"
        }

        def noAutoCompleteList = field.template.viewParams['noAutoComplete']?.split(",")?.toList()

        mb.td(class:"value ${tdcssClass}" ) {
            def w // widget
            switch (field.type) {
                case FieldType.textarea:
                    int rows = ((name == 'occurrenceRemarks') ? 6 : 4)
                    if (attrs.rows) {
                        rows = Integer.parseInt(attrs.rows);
                    }
                    w = g.textArea(
                        name:"recordValues.${recordIdx}.${name}",
                        rows: rows,
                        //style: 'width: 100%',
                        value:recordValues?.get(0)?.get(name),
                        'class':cssClass
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
                    def pl = Picklist.findByName(name)
                    if (pl) {
                        def options = PicklistItem.findAllByPicklist(pl)
                        w = g.select(
                            name:"recordValues.${recordIdx}.${name}",
                            from: options,
                            optionValue:'value',
                            optionKey:'value',
                            value:recordValues?.get(0)?.get(name)?:field?.defaultValue,
                            noSelection:['':''],
                            style: 'max-width: 295px;',
                            'class':cssClass
                        )
                        break
                    }
                case FieldType.radio: // fall through TODO
                case FieldType.checkbox: // fall through TODO
                case FieldType.text: // fall through
                case FieldType.autocomplete:
                    cssClass = cssClass + " autocomplete"
                default:

                    if (noAutoCompleteList?.contains(name)) {
                        cssClass += ' noAutoComplete'
                    }

                    w = g.textField(
                        name:"recordValues.${recordIdx}.${name}",
                        maxLength:200,
                        value:recordValues?.get(0)?.get(name),
                        'class':cssClass
                    )
            }
            mkp.yieldUnescaped(w)

            if (field.helpText) {
                def help = "<a href='#' class='fieldHelp' title='${field.helpText}'><span class='help-container'>&nbsp;</span></a>"
                mkp.yieldUnescaped(help)
            }
        }

    }

    private def renderWidgetLabelTD(MarkupBuilder mb, TemplateField field) {

        if (!field) {
            return
        }

        def name = field.fieldType?.name()
        def label
        if (field.label) {
            label = field.label
        } else {
            label = field.fieldType?.label
        }

        mb.td(class:'name') {
            if (field.type != FieldType.hidden && field.fieldType != DarwinCoreField.spacer) {
                mb.yield(g.message(code:'record.' + name +'.label', default:label))
            }
        }

    }

    /**
     *  Create the field label and form field for the requested
     *  TemplateField type
     *  
     *  @attr templateField REQUIRED
     *  @attr recordValues REQUIRED
     *  @attr recordIdx
     *  @attr rowClass
     */
    def fieldFromTemplateField = { attrs, body ->
        def field = attrs.templateField
        def recordValues = attrs.recordValues
        def recordIdx = attrs.recordIdx ? Integer.parseInt(attrs.recordIdx) : (int) 0;

        // Uses MarkupBuilder to create HTML
        def mb = new groovy.xml.MarkupBuilder(out)
        def trClass = (field.type == FieldType.hidden) ? 'hidden' : 'prop'

        if (attrs.rowClass) {
            trClass += " " + attrs.rowClass
        }

        mb.tr(class:trClass) {
            renderWidgetLabelTD(delegate, field);
            renderWidgetTD(delegate, field, recordValues, recordIdx, attrs)
        }
    }

    /**
     *  Create the field label and form field for the requested
     *  TemplateField type
     *
     *  @attr task REQUIRED
     *  @attr fieldType REQUIRED
     *  @attr recordValues REQUIRED
     *  @attr recordIdx
     */
    def fieldTDPair = { attrs, body ->

        try {
            Task task = attrs.task;
            DarwinCoreField fieldType = attrs.fieldType;
            def template = task.project.template;

            TemplateField field = TemplateField.findByTemplateAndFieldType(template, fieldType);
            if (!field) {
                // There was no field for this field type defined by this template: create a default one
                field = new TemplateField(template: template, fieldType: fieldType, label: null, defaultValue: null, category: FieldCategory.miscellaneous)
            }

            def recordValues = attrs.recordValues
            def recordIdx = attrs.recordIdx ? Integer.parseInt(attrs.recordIdx) : (int) 0;

            // Uses MarkupBuilder to create HTML
            def mb = new groovy.xml.MarkupBuilder(out)

            renderWidgetLabelTD(mb, field);
            renderWidgetTD(mb, field, recordValues, recordIdx, attrs)
        } catch (Exception ex) {
            throw ex
        }
    }

    /**
     *  Create the field label and form field for the requested
     *  TemplateField type
     *
     *  @attr task REQUIRED
     *  @attr fieldType REQUIRED
     *  @attr recordValues REQUIRED
     *  @attr recordIdx
     *  @attr labelClass
     *  @attr inputClass
     */
    def fieldLabelPair = { attrs, body ->
        try {
            Task task = attrs.task;
            DarwinCoreField fieldType = attrs.fieldType;
            def template = task.project.template;

            TemplateField field = TemplateField.findByTemplateAndFieldType(template, fieldType);
            if (!field) {
                // There was no field for this field type defined by this template: create a default one
                field = new TemplateField(template: template, fieldType: fieldType, label: null, defaultValue: null, category: FieldCategory.miscellaneous)
            }

            def recordValues = attrs.recordValues
            def recordIdx = attrs.recordIdx ? Integer.parseInt(attrs.recordIdx) : (int) 0;

            // Uses MarkupBuilder to create HTML
            def mb = new MarkupBuilder(out)

            renderWidgetLabelSpan(mb, field, attrs.labelClass ?: 'span2');
            renderWidgetSpan(mb, field, recordValues, recordIdx, attrs, attrs.inputClass ?: 'span4')

        } catch (Exception ex) {
            throw ex
        }
    }
    /**
     *  Create the field label and form field for the requested
     *  TemplateField type
     *
     *  @attr task REQUIRED
     *  @attr fieldType REQUIRED
     *  @attr recordValues REQUIRED
     *  @attr recordIdx
     */
    def fieldWidget = { attrs, body ->
        Task task = attrs.task;
        DarwinCoreField fieldType = attrs.fieldType;
        def template = task.project.template;

        TemplateField field = TemplateField.findByTemplateAndFieldType(template, fieldType);

        def recordValues = attrs.recordValues
        def recordIdx = attrs.recordIdx ? Integer.parseInt(attrs.recordIdx) : (int) 0;

        // Uses MarkupBuilder to create HTML
        def mb = new MarkupBuilder(out)
        renderWidgetTD(mb, field, recordValues, recordIdx, attrs)
    }

    /**
     * @attr multimedia
     * @attr elementId
     * @attr hideControls
     */
    def imageViewer = { attrs, body ->
        def multimedia = attrs.multimedia as Multimedia
        if (multimedia) {
            def imageUrl = "${grailsApplication.config.server.url}${multimedia.filePath}"
            def imageMetaData = taskService.getImageMetaData(multimedia)
            def mb = new MarkupBuilder(out)
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

                    div(class:'pin-image-control') {
                        a(id:'pinImage', href:'#', title:'Fix the image in place in the browser window') {
                            mkp.yield('Pin image in place')
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
     *
     */
    def templateFieldsForCategory = { attrs, body ->
        FieldCategory category = attrs.category
        Task task = attrs.task as Task
        String labelClass = attrs.labelClass ?: 'span4'
        String valueClass = attrs.valueClass ?: 'span8'

        Template template = task?.project?.template
        def recordValues = attrs.recordValues

        if (category && template) {
            def fields = TemplateField.findAllByCategoryAndTemplate(category, template, [sort: 'displayOrder'])

            def hidden = fields.findAll { it.type == FieldType.hidden }

            fields.removeAll { it.type == FieldType.hidden }

            def mb = new MarkupBuilder(out)
            for (int i = 0; i < fields.size(); i += 2) {
                def lhs = fields[i]
                def rhs = (i+1 < fields.size() ? fields[i+1] : null)

                mb.div(class:'row-fluid') {
                    mb.div(class:"span6") {
                        renderFieldBootstrapImpl(mb, lhs, task, recordValues, 0, labelClass, valueClass, attrs)
                    }
                    mb.div(class:"span6") {
                        if (rhs) {
                            renderFieldBootstrapImpl(mb, rhs, task, recordValues, 0, labelClass, valueClass, attrs)
                        } else {
                            mkp.yieldUnescaped("&nbsp;")
                        }
                    }
                }
            }

            hidden?.each { field ->
                renderFieldBootstrapImpl(mb, field, task, recordValues, 0, labelClass, valueClass, attrs)
            }

        }
    }


}