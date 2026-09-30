package au.org.ala.volunteer

import grails.testing.web.taglib.TagLibUnitTest
import spock.lang.Specification

class TranscribeTagLibSpec extends Specification implements TagLibUnitTest<TranscribeTagLib> {

    private static Template templateWithViewParams() {
        new Template(viewParams: [:])
    }

    void "checkbox widget keeps cssClass for mandatory fields"() {
        given:
        def field = new TemplateField(
            fieldType: DarwinCoreField.country,
            type: FieldType.checkbox,
            mandatory: true,
            template: templateWithViewParams()
        )

        when:
        def html = applyTemplate('<g:renderWidgetHtml taskInstance="${task}" field="${field}" recordValues="${[:]}" recordIdx="0"/>', [
            task : new Task(project: new Project()),
            field: field
        ])

        then:
        html.contains('class="country validate[required] form-check-input"')
    }

    void "radio widget keeps cssClass for mandatory fields"() {
        given:
        tagLib.picklistService = Stub(PicklistService) {
            getPicklistItemsForProject(_, _) >> [[value: 'A'], [value: 'B']]
        }

        def field = new TemplateField(
            fieldType: DarwinCoreField.country,
            type: FieldType.radio,
            mandatory: true,
            template: templateWithViewParams()
        )

        when:
        def html = applyTemplate('<g:renderWidgetHtml taskInstance="${task}" field="${field}" recordValues="${[:]}" recordIdx="0"/>', [
            task : new Task(project: new Project()),
            field: field
        ])

        then:
        html.contains('class="country validate[required] form-check-input"')
        html.contains('<div class="form-check"><label class="form-check-label">')
    }
}
