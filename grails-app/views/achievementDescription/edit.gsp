<%@ page import="au.org.ala.volunteer.AchievementDescription" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="digivol-achievementSettings">
    <g:set var="entityName" value="${message(code: 'achievementDescription.label', default: 'Badge Description')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>
    <asset:stylesheet href="codemirror/codemirror-monokai.css" />
</head>

<body>
<content tag="pageTitle">General Settings</content>

<content tag="adminButtonBar">

    <form class="form-inline" style="display: inline-block;">
        <div class="form-check form-switch" style="font-size: 1.5rem;">
            <label class="form-check-label" id="switchLgLabel" for="switchLg">${achievementDescriptionInstance?.enabled ? 'Enabled' : 'Disabled'}</label>
            <input class="form-check-input" type="checkbox" name="enabled" role="switch" id="switchLg" ${achievementDescriptionInstance?.enabled ? 'checked="checked"' : ''}>
        </div>
    </form>
</content>

<div id="edit-achievementDescription" class="content scaffold-edit" role="main">
%{--<g:if test="${flash.message}">--}%
%{--<div class="message" role="status">${flash.message}</div>--}%
%{--</g:if>--}%
    <g:hasErrors bean="${achievementDescriptionInstance}">
        <ul class="errors" role="alert">
            <g:eachError bean="${achievementDescriptionInstance}" var="error">
                <li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message
                        error="${error}"/></li>
            </g:eachError>
        </ul>
    </g:hasErrors>
    <g:form class="form-horizontal" url="[resource: achievementDescriptionInstance, action: 'update']" method="PUT">
        <g:hiddenField name="version" value="${achievementDescriptionInstance?.version}"/>
        <g:render template="form"/>
        <div class="form-group">
            <div class="col-md-offset-3 col-md-9">
                <g:actionSubmit class="save btn btn-primary" action="update"
                                value="${message(code: 'default.button.update.label', default: 'Update')}"/>
            </div>
        </div>
    </g:form>
    <g:form class="form-inline" style="display: inline-block; padding-right:10px;" action="delete"
            id="${achievementDescriptionInstance?.id}" method="delete">
        <g:submitButton class="btn btn-danger" id="deleteButton" name="Delete"/>
    </g:form>
</div>
<asset:javascript src="bootstrap-file-input" asset-defer=""/>
<asset:javascript src="codemirror/codemirror-groovy-js-sublime.js" asset-defer="" />
<asset:script type="text/javascript" asset-defer="">
    $(function() {
        // Initialize input type file
        $('input[type=file]').bootstrapFileInput();

        $('#deleteButton').on('click', function(e) {
            e.preventDefault();
            var self = this;
            bootbox.confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}', function(result) {
                if (result) {
                    $(self).closest('form').submit();
                }
            });
        });

        $(document).on('change', "[name='enabled']", function (event) {
            // Get checkbox state
            const state = $(event.target).prop('checked');
            let p = $.ajax({
                type: 'POST',
                headers: {
                    Accept : "application/json"
                },
                url: '${createLink(controller: 'achievementDescription', action: 'enable', id: achievementDescriptionInstance?.id)}?format=json',
                data: {
                    enabled: state
                },
                dataType: 'json'
            });

            p.success(function (data, textStatus, jqXHR) {
                $('#switchLgLabel').text(state ? 'Enabled' : 'Disabled');
            });

            p.fail(function ( jqXHR, textStatus, errorThrown ) {
                alert("Could not enable badge :(  Please refresh and try again.");
                console.log(errorThrown);
            });
        });
    });

</asset:script>
</body>
</html>
