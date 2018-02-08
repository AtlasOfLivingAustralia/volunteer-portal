<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="au.org.ala.volunteer.DarwinCoreField; au.org.ala.volunteer.Task; au.org.ala.volunteer.PicklistItem; au.org.ala.volunteer.Picklist" %>
<%
    def values = ["", message(code: 'transcribe.range.metres'), message(code: 'transcribe.range.feet')]
    def picklist = Picklist.findByName(DarwinCoreField.measurementUnit.toString())
    if (picklist) {
        def items = PicklistItem.findAllByPicklistAndInstitutionCode(picklist, ((Task) taskInstance).project.picklistInstitutionCode ?: null)
        if (items) {
            values = [""] + items*.value
        }
    }
%>
<div class="row unitRangeWidget form-group ${cssClass}" targetField="${field.fieldType}">
    <div class="col-md-3">
        <g:textField tabindex="${tabindex}" name="${field.fieldType}.minValue" class="form-control rangeMinValue" value=""
                     placeholder="${message(code: 'transcribe.range.from')}"/>
    </div>
    <span class="col-md-1 text-muted" style="text-align: center">-</span>
    <div class="col-md-3">
        <g:textField tabindex="${tabindex}" name="${field.fieldType}.maxValue" class="form-control rangeMaxValue" value=""
                     placeholder="${message(code: 'transcribe.range.to')}"/>
    </div>

    <div class="col-md-5"><g:select tabindex="${tabindex}" class="form-control rangeUnits" name="${field.fieldType}.units" value="" from="${values}"/></div><g:hiddenField id="recordValues.0.${field.fieldType}" name="recordValues.0.${field.fieldType}" value="${value}" validationRule="${field.validationRule}"/></div>