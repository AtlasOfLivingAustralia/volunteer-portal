package au.org.ala.volunteer

import grails.testing.web.taglib.TagLibUnitTest
import org.springframework.validation.BeanPropertyBindingResult
import org.springframework.validation.Errors
import spock.lang.Specification

class VolunteerTagLibSpec extends Specification implements TagLibUnitTest<VolunteerTagLib> {

    /** Minimal stand-in for a domain object: the tag only ever reads `bean.errors`. */
    static class Thing {
        String name
        Errors errors
    }

    private static Thing thingWithErrors(Map<String, List<String>> messagesByField) {
        def thing = new Thing(name: 'value')
        def errors = new BeanPropertyBindingResult(thing, 'thing')
        messagesByField.each { field, messages ->
            messages.each { message ->
                errors.rejectValue(field, "thing.${field}.invalid", null, message)
            }
        }
        thing.errors = errors
        return thing
    }

    void "renders an invalid-feedback block containing the field's message"() {
        given:
        def thing = thingWithErrors(name: ['Name cannot be blank'])

        when:
        def html = applyTemplate('<cl:fieldError bean="${bean}" field="name"/>', [bean: thing])

        then:
        html == '<div class="invalid-feedback">Name cannot be blank</div>'
    }

    void "joins multiple errors on the same field"() {
        given:
        def thing = thingWithErrors(name: ['Name cannot be blank', 'Name must be unique'])

        when:
        def html = applyTemplate('<cl:fieldError bean="${bean}" field="name"/>', [bean: thing])

        then:
        html == '<div class="invalid-feedback">Name cannot be blank<br/>Name must be unique</div>'
    }

    void "renders nothing when the field has no errors"() {
        given:
        def thing = thingWithErrors(name: ['Name cannot be blank'])

        when: 'a different field is asked for'
        def html = applyTemplate('<cl:fieldError bean="${bean}" field="other"/>', [bean: thing])

        then:
        html == ''
    }

    void "renders nothing when the bean is null"() {
        when:
        def html = applyTemplate('<cl:fieldError bean="${bean}" field="name"/>', [bean: null])

        then:
        html == ''
    }

    void "renders nothing when no field is given"() {
        given:
        def thing = thingWithErrors(name: ['Name cannot be blank'])

        when:
        def html = applyTemplate('<cl:fieldError bean="${bean}"/>', [bean: thing])

        then:
        html == ''
    }

    void "escapes markup in the message"() {
        given:
        def thing = thingWithErrors(name: ['Must not contain <script>'])

        when:
        def html = applyTemplate('<cl:fieldError bean="${bean}" field="name"/>', [bean: thing])

        then:
        html == '<div class="invalid-feedback">Must not contain &lt;script&gt;</div>'
    }
}

