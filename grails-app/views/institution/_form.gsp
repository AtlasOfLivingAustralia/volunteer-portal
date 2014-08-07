<%@ page import="au.org.ala.volunteer.Institution" %>

<div class="fieldcontain ${hasErrors(bean: institutionInstance, field: 'collectoryId', 'error')} ">
    <label for="collectoryId">
        <g:message code="institution.collectoryId.label" default="Collectory Id" />
    </label>
    <g:field class="input-mini" name="collectoryId" type="number" value="${institutionInstance.collectoryId}"/>
</div>

<div class="fieldcontain ${hasErrors(bean: institutionInstance, field: 'name', 'error')} required">
    <label for="name">
        <g:message code="institution.name.label" default="Name" />
        <span class="required-indicator">*</span>
    </label>
    <g:textField class="input-block-level" name="name" required="" value="${institutionInstance?.name}"/>
</div>

<div class="fieldcontain ${hasErrors(bean: institutionInstance, field: 'description', 'error')}">
    <label for="description">
        <g:message code="institution.description.label" default="Description" />
    </label>
    <g:textArea class="input-block-level" rows="6" name="description" value="${institutionInstance?.description}"/>
</div>

<div class="fieldcontain ${hasErrors(bean: institutionInstance, field: 'contactName', 'error')}">
    <label for="contactName">
        <g:message code="institution.contactName.label" default="Contact Name" />
    </label>
    <g:textField name="contactName" value="${institutionInstance?.contactName}"/>
</div>

<div class="fieldcontain ${hasErrors(bean: institutionInstance, field: 'contactEmail', 'error')}">
    <label for="contactEmail">
		<g:message code="institution.contactEmail.label" default="Contact Email" />
	</label>
    <g:field type="email" name="contactEmail" value="${institutionInstance?.contactEmail}"/>
</div>

<div class="fieldcontain ${hasErrors(bean: institutionInstance, field: 'contactPhone', 'error')}">
    <label for="contactPhone">
        <g:message code="institution.contactPhone.label" default="Contact Phone" />
    </label>
    <g:textField name="contactPhone" value="${institutionInstance?.contactPhone}"/>
</div>
