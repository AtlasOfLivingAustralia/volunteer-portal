<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="au.org.ala.volunteer.WebUtils" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>

    <meta name="layout" content="digivol-projectSettings"/>
    <asset:stylesheet src="institution-dropdown"/>
    <asset:stylesheet src="label-autocomplete"/>
    <asset:stylesheet src="jquery"/>
    <asset:stylesheet src="jquery-ui"/>
</head>

<body>

<content tag="pageTitle"><g:message code="project.general_settings"/></content>

<content tag="adminButtonBar">
</content>

<g:form method="post" class="form-horizontal">
    <g:hiddenField name="id" value="${projectInstance?.id}"/>
    <g:hiddenField name="version" value="${projectInstance?.version}"/>

    <!-- form language selector -->
    <g:render template="/layouts/formLanguageDropdown"/>

    <div class="form-group" style="    margin-top: 40px;    ">
        <label class="control-label col-md-3" for="featuredOwner"><g:message code="project.expedition_institution"/></label>

        <div class="col-md-6">
            <g:textField class="form-control"  name="featuredOwner" value="${projectInstance.featuredOwner}"/>
            <g:hiddenField name="institutionId" value="${projectInstance?.institution?.id}"/>
        </div>

        <div class="col-md-3 control-label text-left">
            <i class="fa fa-check"></i> <g:message code="project.general_settings.linked_to_institution"/>
        </div>
    </div>

    <!-- Name -->
    <div class="form-group" >
        <label class="control-label col-md-3" for="name">
            <span><g:message code="project.general_settings.expedition_name"/>
            (<span class="form-locale locale"></span>)</span>
        </label>

        <div class="col-md-6" id="name">
            <g:each in="${grailsApplication.config.languages.enabled.tokenize(',')}">
                <g:textField style="display:none;" class="form-control i18n-field i18n-field-${it.toString()}" name="i18nName.${it.toString()}" rows="1" value="${ WebUtils.safeGet(projectInstance?.i18nName, it.toString()) }"/>
            </g:each>
        </div>
    </div>


    <!-- Short Description -->
    <div class="form-group" >
        <label class="control-label col-md-3" for="shortDescription">
            <span><g:message code="project.general_settings.short_description"/>
            (<span class="form-locale locale"></span>)</span>
        </label>

        <div class="col-md-6" id="shortDescription">
            <g:each in="${grailsApplication.config.languages.enabled.tokenize(',')}">
                <g:textField style="display:none;" class="form-control i18n-field i18n-field-${it.toString()}" name="i18nShortDescription.${it.toString()}" rows="1" value="${ WebUtils.safeGet(projectInstance?.i18nShortDescription, it.toString()) }"/>
            </g:each>
        </div>
    </div>


    <!-- Long Description -->
    <div class="form-group " >
        <label class="control-label col-md-3" for="description">
            <span><g:message code="project.general_settings.long_description"/>
            (<span class="form-locale locale"></span>)</span>
        </label>

        <div class="col-md-8" id="description">
            <g:each in="${grailsApplication.config.languages.enabled.tokenize(',')}">
                <span class="i18n-field i18n-field-${it.toString()}">
                    <g:textArea class="mce form-control" name="i18nDescription.${it.toString()}" rows="10" value="${WebUtils.safeGet(projectInstance.i18nDescription, it.toString())}"/>
                </span>
            </g:each>
        </div>
    </div>



    <div class="form-group">
        <label class="control-label col-md-3" for="template"><g:message code="project.template.label"/></label>

        <div class="col-md-6">
            <g:select name="template" class="form-control" from="${templates}" value="${projectInstance.template?.id}" optionKey="id"/>
        </div>

        <div class="col-md-3">
            <a class="btn btn-default"
               href="${createLink(controller: 'template', action: 'edit', id: projectInstance?.template?.id)}"><g:message code="project.edit_template.label"/></a>
        </div>
    </div>

    <div class="form-group">
        <label class="control-label col-md-3" for="projectType"><g:message code="project.projectType.label"/></label>

        <div class="col-md-6">
            <g:select name="projectType" from="${projectTypes}" value="${projectInstance.projectType?.id}" optionValue="${{message(code: it.label)}}" optionKey="id" class="form-control"/>
        </div>
    </div>

    <div class="form-group">
        <label class="control-label col-md-3" for="label"><g:message code="project.general_settings.tags"/></label>

        <div class="col-md-6">
            <input autocomplete="off" type="text" id="label" class="form-control typeahead"/>

        </div>

        <div id="labels" class="col-md-offset-3 col-md-9">
            <g:each in="${sortedLabels}" var="l">
                <span class="label ${labelColourMap[l.category]}" title="${l.category}">
                    ${l.value} <i class="fa fa-times-circle delete-label" data-label-id="${l.id}"></i>
                </span>
            </g:each>
        </div>

        %{--<div class="clearfix visible-md-block visible-lg-block"></div>--}%

        %{--<div class="col-md-offset-3 col-md-6"></div>--}%
    </div>

    <div class="form-group">
        <div class="col-md-9 col-md-offset-3">
            <label for="harvestableByAla" class="checkbox">
                <g:checkBox name="harvestableByAla"
                            checked="${projectInstance.harvestableByAla}"/>&nbsp;<g:message code="project.general_settings.data_should_be_harvested_by"/>
            </label>
        </div>
    </div>

    <div class="form-group">
        <div class="col-md-9 col-md-offset-3">
            <g:actionSubmit class="save btn btn-primary" action="updateGeneralSettings"
                            value="${message(code: 'default.button.update.label', default: 'Update')}"/>
        </div>
    </div>

</g:form>
<asset:javascript src="institution-dropdown" asset-defer=""/>
<asset:javascript src="label-autocomplete" asset-defer=""/>
<asset:script type="text/javascript">
    jQuery(function($) {
        var institutions = <cl:json value="${institutions}"/>;
            var nameToId = <cl:json value="${institutionsMap}"/>;
            var labelColourMap = <cl:json value="${labelColourMap}"/>;
            var baseUrl = "${createLink(controller: 'institution', action: 'index')}";

            setupInstitutionAutocomplete("#featuredOwner", "#institutionId", "#institution-link-icon", "#institution-link", institutions, nameToId, baseUrl);
            labelAutocomplete("#label", "${createLink(controller: 'project', action: 'newLabels', id: projectInstance.id)}", '', function(item) {
                //var obj = JSON.parse(item);
                var updateUrl = "${createLink(controller: 'project', action: 'addLabel', id: projectInstance.id)}";
                //showSpinner();
                $.ajax(updateUrl, {type: 'POST', data: { labelId: item.id }})
                    .done(function(data) {
                        $( "<span>" )
                            .addClass("label")
                            .addClass(labelColourMap[item.category])
                            .attr("title", item.category)
                            .text(item.value)
                            .append(
                            $( "<i>" )
                                .attr("data-label-id", item.id)
                                .addClass("fa")
                                .addClass("fa-times-circle")
                                .addClass("delete-label")
                            )
                            .appendTo(
                                $( "#labels" )
                            );
                    })
                    .fail(function() { alert("${message(code: 'project.general_settings.error1')}")});
                    //.always(hideSpinner);
                return null;
            });

            function onDeleteClick(e) {
                var deleteUrl = "${createLink(controller: 'project', action: 'removeLabel', id: projectInstance.id)}";
            //    showSpinner();
                $.ajax(deleteUrl, {type: 'POST', data: { labelId: e.target.dataset.labelId }})
                    .done(function (data) {
                        var t = $(e.target);
                        var p = t.parent("span");
                        p.remove();
                    })
                    .fail(function() { alert("${message(code: 'project.general_settings.error2')}")});
                    //.always(hideSpinner);
            }

            $('#labels').on('click', 'span.label i.delete-label', onDeleteClick);
        });
</asset:script>
</body>
</html>
