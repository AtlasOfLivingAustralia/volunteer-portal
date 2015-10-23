<!doctype html>
<html>
<head>
    <meta name="layout" content="digivol-projectSettings"/>
</head>

<body>

<content tag="pageTitle">Picklists</content>

<content tag="adminButtonBar">
</content>

<g:form method="post" class="form-horizontal">
    <g:hiddenField name="id" value="${projectInstance?.id}"/>
    <g:hiddenField name="version" value="${projectInstance?.version}"/>

    <div class="alert">A picklist with a specific 'Collection Code' must be <a
            href="${createLink(controller: 'picklist', action: 'manage')}">loaded</a> first</div>

    <div class="control-group">
        <label class="control-label" for="projectType"><g:message code="project.picklistInstitutionCode.label"
                                                                  default="Picklist Collection Code"/></label>

        <div class="controls">
            <g:select name="picklistInstitutionCode" from="${picklistInstitutionCodes}"
                      value="${projectInstance?.picklistInstitutionCode}"/>
        </div>

    </div>

    <div class="control-group">
        <div class="controls">
            <g:actionSubmit class="save btn btn-primary" action="updatePicklistSettings"
                            value="${message(code: 'default.button.update.label', default: 'Update')}"/>
        </div>
    </div>

</g:form>

<script type='text/javascript'>
    $(document).ready(function () {
    });
</script>
</body>
</html>
