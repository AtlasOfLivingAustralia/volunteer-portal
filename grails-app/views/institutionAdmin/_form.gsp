<%@ page import="au.org.ala.volunteer.Institution" %>
<tinyMce:resources/>
<div class="fieldcontain ${hasErrors(bean: institutionInstance, field: 'name', 'error')} required">
    <label for="name">
        <g:message code="institution.name.label" default="Name"/>
        <span class="required-indicator">*</span>
    </label>
    <g:textField class="input-block-level" name="name" required="" value="${institutionInstance?.name}"/>
</div>

<div class="fieldcontain ${hasErrors(bean: institutionInstance, field: 'acronym', 'error')}">
    <label for="acronym">
        <g:message code="institution.acronym.label" default="Acronym"/>
    </label>
    <g:textField class="input-block-level" name="acronym" required="" value="${institutionInstance?.acronym}"/>
</div>

<div class="fieldcontain ${hasErrors(bean: institutionInstance, field: 'shortDescription', 'error')}">
    <label for="shortDescription">
        <g:message code="institution.description.label" default="Short description"/>
    </label>
    <g:textArea class="input-block-level" rows="2" name="shortDescription"
                value="${institutionInstance?.shortDescription}"/>
</div>

<div class="fieldcontain ${hasErrors(bean: institutionInstance, field: 'description', 'error')}">
    <label for="description">
        <g:message code="institution.description.label" default="Description"/>
    </label>
    <tinyMce:renderEditor type="advanced" name="description" cols="60" rows="10" class="span12">
        ${institutionInstance?.description}
    </tinyMce:renderEditor>
    %{--<g:textArea class="input-block-level" rows="6" name="description" value="${institutionInstance?.description}"/>--}%
</div>

<div class="fieldcontain ${hasErrors(bean: institutionInstance, field: 'contactName', 'error')}">
    <label for="contactName">
        <g:message code="institution.contactName.label" default="Contact Name"/>
    </label>
    <g:textField name="contactName" value="${institutionInstance?.contactName}"/>
</div>

<div class="fieldcontain ${hasErrors(bean: institutionInstance, field: 'contactEmail', 'error')}">
    <label for="contactEmail">
        <g:message code="institution.contactEmail.label" default="Contact Email"/>
    </label>
    <g:field type="email" name="contactEmail" value="${institutionInstance?.contactEmail}"/>
</div>

<div class="fieldcontain ${hasErrors(bean: institutionInstance, field: 'contactPhone', 'error')}">
    <label for="contactPhone">
        <g:message code="institution.contactPhone.label" default="Contact Phone"/>
    </label>
    <g:textField name="contactPhone" value="${institutionInstance?.contactPhone}"/>
</div>

<div class="fieldcontain ${hasErrors(bean: institutionInstance, field: 'websiteUrl', 'error')}">
    <label for="websiteUrl">
        <g:message code="institution.websiteUrl.label" default="Website URL"/>
    </label>
    <g:textField name="websiteUrl" value="${institutionInstance?.websiteUrl}"/>
</div>

<div class="fieldcontain ${hasErrors(bean: institutionInstance, field: 'imageCaption', 'error')}">
    <label for="imageCaption">
        <g:message code="institution.imageCaption.label" default="Image caption/attribution"/>
    </label>
    <g:textField name="imageCaption" value="${institutionInstance?.imageCaption}"/>
</div>

<div class="fieldcontain ${hasErrors(bean: institutionInstance, field: 'themeColour', 'error')}">
    <label for="themeColour">
        <g:message code="institution.themeColour.label" default="Theme colour code (hex)"/>
    </label>
    <g:textField name="themeColour" value="${institutionInstance?.themeColour}"/>
</div>

<g:if test="${institutionInstance.collectoryUid}">
    <div class="fieldcontain ${hasErrors(bean: institutionInstance, field: 'collectoryUid', 'error')} ">
        <label for="collectoryUid">
            <g:message code="institution.collectoryUid.label" default="Collectory Uid"/>
        </label>
        <g:textField class="input-mini" name="collectoryUid" value="${institutionInstance.collectoryUid}"/>
    </div>
</g:if>
<r:script>
    jQuery(function ($) {
        tinyMCE.init({
            mode: "textareas",
            theme: "advanced",
            editor_selector: "mceadvanced",
            theme_advanced_toolbar_location: "top",
            convert_urls: false
        });
    });
</r:script>