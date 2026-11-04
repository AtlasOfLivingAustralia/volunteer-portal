package au.org.ala.volunteer

import org.springframework.validation.Errors

class AlertTagLib {

    static namespace = 'al'

    def renderErrors = {attrs, body ->
        def attachedBean = attrs.attachedBean
        def errorsList = extractErrors(bean: attachedBean)
        def style = attrs.style ?: 'danger'

        if (errorsList) {
            out << eachErrorInternalForList(attrs, errorsList, {
                out << "<li class=\"list-group-item list-group-item-${style}\">${message(error: it)}</li>"
            })
        }
    }

    def extractErrors(attrs) {
        def model = attrs.model
        def checkList = []
        if (attrs.containsKey('bean')) {
            if (attrs.bean) {
                checkList << attrs.bean
            }
        } else if (attrs.containsKey('model')) {
            if (model) {
                checkList = model.findAll { it.value?.errors instanceof Errors }.collect { it.value }
            }
        } else {
            for (attributeName in request.attributeNames) {
                def ra = request[attributeName]
                if (ra) {
                    def mc = GroovySystem.metaClassRegistry.getMetaClass(ra.getClass())
                    if (ra instanceof Errors && !checkList.contains(ra)) {
                        checkList << ra
                    } else if (mc.hasProperty(ra, 'errors') && ra.errors instanceof Errors && !checkList.contains(ra.errors)) {
                        checkList << ra.errors
                    }
                }
            }
        }

        def resultErrorsList = []

        for (i in checkList) {
            def errors = null
            if (i instanceof Errors) {
                errors = i
            } else {
                def mc = GroovySystem.metaClassRegistry.getMetaClass(i.getClass())
                if (mc.hasProperty(i, 'errors')) {
                    errors = i.errors
                }
            }
            if (errors?.hasErrors()) {
                // if the 'field' attribute is not provided then we should output a body,
                // otherwise we should check for field-specific errors
                if (!attrs.field || errors.hasFieldErrors(attrs.field)) {
                    resultErrorsList << errors
                }
            }
        }

        resultErrorsList
    }

    def eachErrorInternalForList(attrs, errorsList, body, boolean outputResult = false) {
        def var = attrs.var
        def field = attrs.field

        def errorList = []
        for (errors in errorsList) {
            if (field) {
                if (errors.hasFieldErrors(field)) {
                    errorList += errors.getFieldErrors(field)
                }
            } else {
                errorList += errors.allErrors
            }
        }

        for (error in errorList) {
            def result
            if (var) {
                result = body([(var): error])
            } else {
                result = body(error)
            }
            if (outputResult) {
                out << result
            }
        }

        null
    }
}
