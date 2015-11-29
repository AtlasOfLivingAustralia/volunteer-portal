<%@ page import="au.org.ala.volunteer.Institution" %>
<tinyMce:resources/>
<r:require module="bootstrap-colorpicker" />
<div class="form-group ${hasErrors(bean: institutionInstance, field: 'name', 'has-error')}">
    <label class="control-label col-md-3" for="name">
        <g:message code="institution.name.label" default="Name"/>
        <span class="required-indicator">*</span>
    </label>
    <div class="col-md-6">
        <g:textField class="form-control" name="name" required="" value="${institutionInstance?.name}"/>
    </div>
</div>

<div class="form-group ${hasErrors(bean: institutionInstance, field: 'acronym', 'has-error')}">
    <label class="control-label col-md-3" for="acronym">
        <g:message code="institution.acronym.label" default="Acronym"/>
        <span class="required-indicator">*</span>
    </label>
    <div class="col-md-6">
        <g:textField class="form-control" name="acronym" required="" value="${institutionInstance?.acronym}"/>
    </div>
</div>

<div class="form-group ${hasErrors(bean: institutionInstance, field: 'shortDescription', 'has-error')}">
    <label class="control-label col-md-3" for="shortDescription">
        <g:message code="institution.shortDescription.label" default="Short Description"/>
    </label>
    <div class="col-md-6">
        <g:textArea class="form-control" name="shortDescription" rows="2" value="${institutionInstance?.shortDescription}"/>
    </div>
</div>

<div class="form-group ${hasErrors(bean: institutionInstance, field: 'description', 'has-error')}">
    <label class="control-label col-md-3" for="description">
        <g:message code="institution.description.label" default="Description"/>
    </label>
    <div class="col-md-7">
        <tinyMce:renderEditor type="advanced" name="description" rows="10" class="form-control">
            ${institutionInstance?.description}
        </tinyMce:renderEditor>
    </div>
</div>

<div class="form-group ${hasErrors(bean: institutionInstance, field: 'contactName', 'has-error')}">
    <label class="control-label col-md-3" for="contactName">
        <g:message code="institution.contactName.label" default="Contact Name"/>
    </label>
    <div class="col-md-6">
        <g:textField name="contactName" class="form-control" value="${institutionInstance?.contactName}"/>
    </div>
</div>

<div class="form-group ${hasErrors(bean: institutionInstance, field: 'contactEmail', 'has-error')}">
    <label class="control-label col-md-3" for="contactEmail">
        <g:message code="institution.contactEmail.label" default="Contact Email"/>
    </label>
    <div class="col-md-6">
        <g:field type="email" name="contactEmail" class="form-control" value="${institutionInstance?.contactEmail}"/>
    </div>
</div>

<div class="form-group ${hasErrors(bean: institutionInstance, field: 'contactPhone', 'has-error')}">
    <label class="control-label col-md-3" for="contactPhone">
        <g:message code="institution.contactPhone.label" default="Contact Phone"/>
    </label>
    <div class="col-md-6">
        <g:textField name="contactPhone" class="form-control" value="${institutionInstance?.contactPhone}"/>
    </div>
</div>

<div class="form-group ${hasErrors(bean: institutionInstance, field: 'websiteUrl', 'has-error')}">
    <label class="control-label col-md-3" for="websiteUrl">
        <g:message code="institution.websiteUrl.label" default="Website URL"/>
    </label>
    <div class="col-md-6">
        <g:textField name="websiteUrl" class="form-control" value="${institutionInstance?.websiteUrl}"/>
    </div>
</div>

<div class="form-group ${hasErrors(bean: institutionInstance, field: 'imageCaption', 'has-error')}">
    <label class="control-label col-md-3" for="imageCaption">
        <g:message code="institution.imageCaption.label" default="Image caption/attribution"/>
    </label>
    <div class="col-md-6">
        <g:textField name="imageCaption" class="form-control" value="${institutionInstance?.imageCaption}"/>
    </div>
</div>

<div class="form-group ${hasErrors(bean: institutionInstance, field: 'themeColour', 'has-error')}">
    <label class="control-label col-md-3" for="themeColour">
        <g:message code="institution.themeColour.label" default="Theme colour code (hex)"/>
    </label>
    <div class="col-md-6">
        <div class="input-group colpick" data-format="hex">
            <g:textField name="themeColour" class="form-control" value="${institutionInstance?.themeColour}"/>
            <span class="input-group-addon"><i></i></span>
        </div>
    </div>
</div>

<g:if test="${institutionInstance.collectoryUid}">
    <div class="form-group ${hasErrors(bean: institutionInstance, field: 'collectoryUid', 'has-error')}">
        <label class="control-label col-md-3" for="collectoryUid">
            <g:message code="institution.collectoryUid.label" default="Collectory Uid"/>
        </label>
        <div class="col-md-6">
            <g:textField name="collectoryUid" class="form-control" value="${institutionInstance?.collectoryUid}"/>
        </div>
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
        $('.colpick').colorpicker();
    });
</r:script>