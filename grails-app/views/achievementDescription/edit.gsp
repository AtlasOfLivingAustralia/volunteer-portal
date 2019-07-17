<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="au.org.ala.volunteer.AchievementDescription" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="digivol-achievementSettings">
    <g:set var="entityName" value="${message(code: 'achievementDescription.label', default: 'Badge Description')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>
    <asset:stylesheet href="codemirror/codemirror-monokai.css" />
</head>

<body>
<content tag="pageTitle"><g:message code="achievementDescription.edit.general_settings"/></content>

<content tag="adminButtonBar">
    <g:form class="form-inline" style="display: inline-block; padding-right:10px;" action="delete"
            id="${achievementDescriptionInstance?.id}" method="delete">
        <g:submitButton class="btn btn-danger" id="deleteButton" name="Delete"/>
    </g:form>
    <form class="form-inline" style="display: inline-block;">
        <g:checkBox name="enabled" checked="${achievementDescriptionInstance?.enabled}"/>
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
    <g:form class="form-horizontal" url="[resource: achievementDescriptionInstance, action: 'update']" method="PUT" accept-charset="UTF-8">
        <g:hiddenField name="version" value="${achievementDescriptionInstance?.version}"/>
        <g:render template="form"/>
        <div class="form-group">
            <div class="col-md-offset-3 col-md-9">
                <g:actionSubmit class="save btn btn-primary" action="update"
                                value="${message(code: 'default.button.update.label', default: 'Update')}"/>
            </div>
        </div>
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

        $("[name='enabled']").bootstrapSwitch().on('switchChange.bootstrapSwitch', function(event, state) {
            var p = $.ajax({
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

            p.fail(function ( jqXHR, textStatus, errorThrown ) {
                alert("${message(code: 'achievementDescription.edit.error.could_not_save')}");
                $(event.target).bootstrapSwitch('state', !state, true);
                console.log(errorThrown);
            });
        });
    });

</asset:script>
</body>
</html>
