<%@ page import="au.org.ala.volunteer.Label" %>



<div class="fieldcontain ${hasErrors(bean: labelInstance, field: 'category', 'error')} required">
    <label for="category">
        <g:message code="label.category.label" default="Category"/>
        <span class="required-indicator">*</span>
    </label>
    <g:textField name="category" required="" value="${labelInstance?.category}"/>

</div>

<div class="fieldcontain ${hasErrors(bean: labelInstance, field: 'value', 'error')} required">
    <label for="value">
        <g:message code="label.value.label" default="Value"/>
        <span class="required-indicator">*</span>
    </label>
    <g:textField name="value" required="" value="${labelInstance?.value}"/>

</div>

