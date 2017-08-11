<%@ page import="au.org.ala.volunteer.WebUtils; au.org.ala.volunteer.Institution" %>

<!-- form language selector -->

<asset:script>
    function showLocale(localeString) {
        $(".i18n-field").hide();
        $(".i18n-field-"+localeString).show();
        $(".form-locale").html(localeString.substr(0,2))
    }
    $(function() {
        showLocale('${ org.springframework.context.i18n.LocaleContextHolder.getLocale().toString()}')
    });
</asset:script>
<ul class="nav">
    <li class="dropdown language-selection ">
        <a href="#" class="dropdown-toggle" data-toggle="dropdown">
            <span class="locale form-locale" >${ org.springframework.context.i18n.LocaleContextHolder.getLocale().getLanguage()}</span>
            <span class="glyphicon glyphicon-chevron-down"></span>
        </a>
        <ul class="dropdown-menu language-dropdown-menu">
            <g:each in="${grailsApplication.config.languages.enabled.tokenize(',')}">
                <li ><a onclick="showLocale('${it.toString()}')"><span class="locale">${it.toString().substring(0,2)}</span></a></li>
            </g:each>
        </ul>
    </li>
</ul>
<!-- End form language selector -->
<!-- Name -->
<!--<div class="form-group {hasErrors(bean: instii18nNameonInstance, field: 'name', 'has-error')}">
    <label class="control-label col-md-3" for="name">
        g:message code="institution.name.label" default="Name"/>
        <span class="required-indicator">*</span>
    </label>
    <div class="col-md-6">
        g:textField class="form-control" name="name" required="" value="{institutionInstance?.name}"/>
    </div>
</div>-->
<div class="form-group ${hasErrors(bean: institutionInstance, field: 'i18nName', 'has-error')}" >
    <label class="control-label col-md-3" for="name">
        <g:message code="institution.name.label" default="Name"/>
        <span class="required-indicator">*</span>
        (<span class="form-locale"></span>)
    </label>

    <div class="col-md-6" id="name">
        <g:each in="${grailsApplication.config.languages.enabled.tokenize(',')}">
            <g:textArea style="display:none;" class="form-control i18n-field i18n-field-${it.toString()}" name="i18nName.${it.toString()}" rows="1" value="${ WebUtils.safeGet(institutionInstance.i18nName, it.toString()) }"/>
        </g:each>
    </div>
</div>
<!-- Acronym -->
<!--<div class="form-group {hasErrors(bean: institutionInstance, fieli18nAcronymonym', 'has-error')}">
    <label class="control-label col-md-3" fi18nAcronymonym">
        g:message code="instituti18nAcronymonym.label" default="Acronym"/>
        <span class="required-indicator">*</span>
    </label>
    <div class="col-md-6">
        g:textField class="form-contri18nNamenai18nAcronymonym" required="" value="{institutionInstance?.acronym}"/>
    </div>
</div>-->
<div class="form-group ${hasErrors(bean: institutionInstance, field: 'i18nAcronym', 'has-error')}" >
    <label class="control-label col-md-3" for="acronym">
        <g:message code="institution.acronym.label" default="Name"/>
        <span class="required-indicator">*</span>
        (<span class="form-locale"></span>)
    </label>

    <div class="col-md-6" id="acronym">
        <g:each in="${grailsApplication.config.languages.enabled.tokenize(',')}">
            <g:textArea style="display:none;" class="form-control i18n-field i18n-field-${it.toString()}" name="i18nAcronym.${it.toString()}" rows="1" value="${WebUtils.safeGet(institutionInstance.i18nAcronym, it.toString())}"/>
        </g:each>
    </div>
</div>


<!-- ShortDescription -->
<!--<div class="form-group {hasErrors(bean: institutionInstance, fieli18nShortDescriptiontion', 'has-error')}">
    <label class="control-label col-md-3" fi18nShortDescriptiontion">
        g:message code="instituti18nShortDescriptiontion.label" default="Short Description"/>
    </label>
    <div class="col-md-6">
        g:textArea class="form-contri18nNamenai18nShortDescriptiontion" rows="2" value="{institutionInstance?.shortDescription}"/>
    </div>
</div>-->
<div class="form-group ${hasErrors(bean: institutionInstance, field: 'i18nShortDescription', 'has-error')}" >
    <label class="control-label col-md-3" for="shortDescription">
        <g:message code="institution.shortDescription.label" default="Name"/>
        <span class="required-indicator">*</span>
        (<span class="form-locale"></span>)
    </label>

    <div class="col-md-6" id="shortDescription">
        <g:each in="${grailsApplication.config.languages.enabled.tokenize(',')}">
            <g:textArea style="display:none;" class="form-control i18n-field i18n-field-${it.toString()}" name="i18nShortDescription.${it.toString()}" rows="1" value="${WebUtils.safeGet(institutionInstance.i18nShortDescription, it.toString())}"/>
        </g:each>
    </div>
</div>


<!-- Description
<div class="form-group {hasErrors(bean: institutionInstance, field: 'description', 'has-error')}">
    <label class="control-label col-md-3" for="description">
        g:message code="institution.description.label" default="Description"/>
    </label>
    <div class="col-md-7">
        g:textAi18nNamename="description" rows="10" class="mce form-control" value="{institutionInstance?.description}" />
    </div>
</div> -->
<div class="form-group ${hasErrors(bean: institutionInstance, field: 'i18nDescription', 'has-error')}" >
    <label class="control-label col-md-3" for="description">
        <g:message code="institution.description.label" default="Description"/>
        (<span class="form-locale"></span>)
    </label>

    <div class="col-md-6" id="description">
        <g:each in="${grailsApplication.config.languages.enabled.tokenize(',')}">
            <span class="i18n-field i18n-field-${it.toString()}">
                <g:textArea class="mce form-control" name="i18nDescription.${it.toString()}" rows="10" value="${WebUtils.safeGet(institutionInstance.i18nDescription, it.toString())}"/>
            </span>
        </g:each>
    </div>
</div>

<!-- Contact Name -->
<div class="form-group ${hasErrors(bean: institutionInstance, field: 'contactName', 'has-error')}">
    <label class="control-label col-md-3" for="contactName">
        <g:message code="institution.contactName.label" default="Contact Name"/>
    </label>
    <div class="col-md-6">
        <g:textField name="contactName" class="form-control" value="${institutionInstance?.contactName}"/>
    </div>
</div>

<!-- Contact Email -->
<div class="form-group ${hasErrors(bean: institutionInstance, field: 'contactEmail', 'has-error')}">
    <label class="control-label col-md-3" for="contactEmail">
        <g:message code="institution.contactEmail.label" default="Contact Email"/>
    </label>
    <div class="col-md-6">
        <g:field type="email" name="contactEmail" class="form-control" value="${institutionInstance?.contactEmail}"/>
    </div>
</div>
<!-- Contact phone -->
<div class="form-group ${hasErrors(bean: institutionInstance, field: 'contactPhone', 'has-error')}">
    <label class="control-label col-md-3" for="contactPhone">
        <g:message code="institution.contactPhone.label" default="Contact Phone"/>
    </label>
    <div class="col-md-6">
        <g:textField name="contactPhone" class="form-control" value="${institutionInstance?.contactPhone}"/>
    </div>
</div>
<!-- website url -->
<div class="form-group ${hasErrors(bean: institutionInstance, field: 'websiteUrl', 'has-error')}">
    <label class="control-label col-md-3" for="websiteUrl">
        <g:message code="institution.websiteUrl.label" default="Website URL"/>
    </label>
    <div class="col-md-6">
        <g:textField name="websiteUrl" class="form-control" value="${institutionInstance?.websiteUrl}"/>
    </div>
</div>
<!-- image caption -->
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
<asset:javascript src="bootstrap-colorpicker" asset-defer="" />
<asset:javascript src="tinymce-simple" asset-defer=""/>
<asset:script>
    jQuery(function ($) {
        $('.colpick').colorpicker();
    });
</asset:script>