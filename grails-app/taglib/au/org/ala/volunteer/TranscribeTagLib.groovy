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

/**
 * Tag Lib for Transcribe page
 * 
 * @author "Nick dos Remedios <Nick.dosRemedios@csiro.au>"
 */
class TranscribeTagLib {
    /**
     *  Create the field label and form field for the requested
     *  TemplateField type
     *  
     *  @attr templateField REQUIRED
     *  @attr recordValues REQUIRED
     */
    def fieldFromTemplateField = { attrs, body ->
        def field = attrs.templateField
        def recordValues = attrs.recordValues
        def name = field.fieldType.name()
        println "TranscribeTagLib: recordValues = " + recordValues 
        def label
        if (field.label) {
            label = field.label
        } else {
            label = field.fieldType.label
        }
        def cssClass = name + ((name =~ /[Dd]ate/) ? ' dateWidget' : '') // so we can add a date widget with JQuery
        // Uses MarkupBuilder to create HTML
        def mb = new groovy.xml.MarkupBuilder(out)
        mb.tr(class:'prop') {
            td(class:'name') {
                mb.yield(g.message(code:'record.' + name +'.label', default:label))
            }
            td(class:"value") {
                // Special case fields are caught first
                if (name == 'typeStatus') {
                    // Collector (recordedBy) field has autocomplete via picklist
                    mkp.yieldUnescaped g.select(
                        name:'recordValues.0.' + name,
                        from:PicklistItem.findAllByPicklist(Picklist.findByName(name)),
                        value:recordValues?.get(0)?.get(name),
                        optionValue:'value',
                        optionKey:'value',
                        noSelection:['':''],
                        'class':cssClass
                    )
                } else {
                    // regular fields
                    def w // widget
                    switch (field.type) {
                        case FieldType.textarea:
                            w = g.textArea(
                                name:'recordValues.0.' + name,
                                rows: 4,
                                style: 'width: 295px',
                                value:recordValues?.get(0)?.get(name),
                                'class':cssClass
                            )
                            break
                        case FieldType.hidden:
                            w = g.hiddenField(
                                name:'recordValues.0.' + name,
                                value:recordValues?.get(0)?.get(name),
                                'class':cssClass
                            )
                            break;
                        case FieldType.select:
                            // <g:select name="recordValues.0.${fieldName}" from="${PicklistItem.findAllByPicklist(Picklist.findByName(fieldName))}"
                            // value="${recordValues?.get(0)?.(fieldName)}" optionValue="value" optionKey="value" 
                            // noSelection="${['':'-- Select an option --']}" class="${fieldName}" />    
                            def pl = Picklist.findByName(name)
                            if (pl) {
                                def options = PicklistItem.findAllByPicklist(pl)
                                w = g.select(
                                    name:'recordValues.0.' + name,
                                    from: options,
                                    optionValue:'value',
                                    optionKey:'value',
                                    value:recordValues?.get(0)?.get(name)?:field?.defaultValue,
                                    noSelection:['':''],
                                    style: 'max-width: 295px;',
                                    'class':cssClass
                                )
                                break
                            } else {
                                // no picklist so render as a textbox - fall through
                            }
                        case FieldType.radio: // fall through TODO
                        case FieldType.checkbox: // fall through TODO
                        case FieldType.text: // fall through
                        default:
                            w = g.textField(
                                name:'recordValues.0.' + name,
                                maxLength:200,
                                value:recordValues?.get(0)?.get(name),
                                'class':cssClass
                            )
                    }
                    mkp.yieldUnescaped(w)
                }
            }
        }
    }
}