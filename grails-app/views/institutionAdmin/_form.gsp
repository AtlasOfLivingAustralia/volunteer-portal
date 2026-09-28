<%@ page import="au.org.ala.volunteer.Institution" %>
<input type="hidden" name="entry" value="${entry}" />
<div class="form-group">
    <label class="form-label col-md-3" for="name">
        <g:message code="institution.name.label" default="Name"/>
        <span class="required-indicator">*</span>
    </label>
    <div class="col-md-6">
        <g:textField class="form-control ${hasErrors(bean: institutionInstance, field: 'name', 'is-invalid')}" name="name" required="" value="${institutionInstance?.name}"/>
        <cl:fieldError bean="${institutionInstance}" field="name"/>
    </div>
</div>

<div class="form-group">
    <label class="form-label col-md-3" for="acronym">
        <g:message code="institution.acronym.label" default="Acronym"/>
        <span class="required-indicator">*</span>
    </label>
    <div class="col-md-6">
        <g:textField class="form-control ${hasErrors(bean: institutionInstance, field: 'acronym', 'is-invalid')}" name="acronym" required="" value="${institutionInstance?.acronym}"/>
        <cl:fieldError bean="${institutionInstance}" field="acronym"/>
    </div>
</div>

<div class="form-group">
    <label class="form-label col-md-3" for="shortDescription">
        <g:message code="institution.shortDescription.label" default="Short Description"/>
    </label>
    <div class="col-md-6">
        <g:textArea class="form-control ${hasErrors(bean: institutionInstance, field: 'shortDescription', 'is-invalid')}" name="shortDescription" rows="2" value="${institutionInstance?.shortDescription}"/>
        <cl:fieldError bean="${institutionInstance}" field="shortDescription"/>
    </div>
</div>

<div class="form-group">
    <label class="form-label col-md-3" for="description">
        <g:message code="institution.description.label" default="Description"/>
    </label>
    <div class="col-md-9">
        <g:textArea name="description" rows="10" class="mce form-control ${hasErrors(bean: institutionInstance, field: 'description', 'is-invalid')}" value="${institutionInstance?.description}" />
        <cl:fieldError bean="${institutionInstance}" field="description"/>
    </div>
</div>

<div class="form-group">
    <label class="form-label col-md-3" for="contactName">
        <g:message code="institution.contactName.label" default="Contact Name"/>
        <span class="required-indicator">*</span>
    </label>
    <div class="col-md-6">
        <g:textField name="contactName" class="form-control ${hasErrors(bean: institutionInstance, field: 'contactName', 'is-invalid')}" value="${institutionInstance?.contactName}" required=""/>
        <cl:fieldError bean="${institutionInstance}" field="contactName"/>
    </div>
</div>

<div class="form-group">
    <label class="form-label col-md-3" for="contactEmail">
        <g:message code="institution.contactEmail.label" default="Contact Email"/>
        <span class="required-indicator">*</span>
    </label>
    <div class="col-md-6">
        <g:field type="email" name="contactEmail" class="form-control inst-contact-email ${hasErrors(bean: institutionInstance, field: 'contactEmail', 'is-invalid')}" value="${institutionInstance?.contactEmail}" required=""/>
        <cl:fieldError bean="${institutionInstance}" field="contactEmail"/>
    </div>
</div>

<div class="form-group">
    <label class="form-label col-md-3" for="contactPhone">
        <g:message code="institution.contactPhone.label" default="Contact Phone"/>
    </label>
    <div class="col-md-6">
        <g:textField name="contactPhone" class="form-control ${hasErrors(bean: institutionInstance, field: 'contactPhone', 'is-invalid')}" value="${institutionInstance?.contactPhone}"/>
        <cl:fieldError bean="${institutionInstance}" field="contactPhone"/>
    </div>
</div>

<div class="form-group">
    <label class="form-label col-md-3" for="websiteUrl">
        <g:message code="institution.websiteUrl.label" default="Website URL"/>
    </label>
    <div class="col-md-6">
        <g:textField name="websiteUrl" class="form-control ${hasErrors(bean: institutionInstance, field: 'websiteUrl', 'is-invalid')}" value="${institutionInstance?.websiteUrl}"/>
        <cl:fieldError bean="${institutionInstance}" field="websiteUrl"/>
    </div>
</div>

<g:if test="${entry == 'CREATE' || (mode == 'edit' && institutionInstance?.isApproved)}">
<div class="form-group">
    <label class="form-label col-md-3" for="isInactive">
        <g:message code="institution.displayContact.label" default="Display Contact Details"/>
    </label>
    <div class="col-md-6">
        <g:checkBox name="displayContact" class="form-check-input ${hasErrors(bean: institutionInstance, field: 'displayContact', 'is-invalid')}" value="${institutionInstance?.displayContact}" />
        <cl:fieldError bean="${institutionInstance}" field="displayContact"/>
    </div>
</div>

<div class="form-group">
    <label class="form-label col-md-3" for="imageCaption">
        <g:message code="institution.imageCaption.label" default="Image caption/attribution"/>
    </label>
    <div class="col-md-6">
        <g:textField name="imageCaption" class="form-control ${hasErrors(bean: institutionInstance, field: 'imageCaption', 'is-invalid')}" value="${institutionInstance?.imageCaption}"/>
        <cl:fieldError bean="${institutionInstance}" field="imageCaption"/>
    </div>
</div>

<div class="form-group">
    <label class="form-label col-md-3" for="themeColour">
        <g:message code="institution.themeColour.label" default="Theme colour code (hex)"/>
    </label>
    <div class="col-md-6">
        <div class="input-group colpick" data-format="hex">
            <g:textField name="themeColour" class="form-control ${hasErrors(bean: institutionInstance, field: 'themeColour', 'is-invalid')}" value="${institutionInstance?.themeColour}"/>
            <span class="input-group-text"><i></i></span>
            <cl:fieldError bean="${institutionInstance}" field="themeColour"/>
        </div>
    </div>
</div>
</g:if>
<g:if test="${institutionInstance?.collectoryUid}">
    <div class="form-group">
        <label class="form-label col-md-3" for="collectoryUid">
            <g:message code="institution.collectoryUid.label" default="Collectory Uid"/>
        </label>
        <div class="col-md-6">
            <g:textField name="collectoryUid" class="form-control ${hasErrors(bean: institutionInstance, field: 'collectoryUid', 'is-invalid')}" value="${institutionInstance?.collectoryUid}"/>
            <cl:fieldError bean="${institutionInstance}" field="collectoryUid"/>
        </div>
    </div>
</g:if>
<cl:ifSiteAdmin>
    <g:if test="${mode == 'edit' && institutionInstance?.isApproved}">
        <div class="form-group">
            <label class="form-label col-md-3" for="isInactive">
                <g:message code="institution.isInactive.label" default="Inactive"/>
            </label>
            <div class="col-md-6">
                <g:checkBox name="isInactive" class="form-check-input ${hasErrors(bean: institutionInstance, field: 'isInactive', 'is-invalid')}" value="${institutionInstance?.isInactive}" />
                <cl:fieldError bean="${institutionInstance}" field="isInactive"/>
            </div>
        </div>
    </g:if>
</cl:ifSiteAdmin>
<asset:javascript src="bootstrap-colorpicker" asset-defer="" />
<asset:javascript src="tinymce-simple" asset-defer=""/>
<asset:script>
    jQuery(function ($) {
        $('.colpick').colorpicker({ component: '.input-group-text' });
    });


</asset:script>