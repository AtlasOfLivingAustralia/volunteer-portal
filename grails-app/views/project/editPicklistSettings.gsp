<!doctype html>
<html>
<head>
    <meta name="layout" content="digivol-projectSettings"/>
</head>

<body>

<content tag="pageTitle"><g:message code="project.piclists.label"/></content>

<content tag="adminButtonBar">
</content>

<g:form method="post" class="form-horizontal">
    <g:hiddenField name="id" value="${projectInstance?.id}"/>
    <g:hiddenField name="version" value="${projectInstance?.version}"/>

    <div class="alert alert-warning">
        <g:message code="project.piclists.warning" args="${ [createLink(controller: 'picklist', action: 'manage')] }" />
    </div>

    <div class="form-group">
        <label class="control-label col-md-3" for="picklistInstitutionCode">
            <g:message code="project.picklistInstitutionCode.label" default="Picklist Collection Code"/>
        </label>

        <div class="col-md-6">
            <g:select class="form-control" name="picklistInstitutionCode" from="${picklistInstitutionCodes}"
                      value="${projectInstance?.picklistInstitutionCode}"/>
        </div>

    </div>

    <div class="form-group">
        <div class="col-md-offset-3 col-md-9">
            <g:actionSubmit class="save btn btn-primary" action="updatePicklistSettings"
                            value="${message(code: 'default.button.update.label', default: 'Update')}"/>
        </div>
    </div>

</g:form>
</body>
</html>
