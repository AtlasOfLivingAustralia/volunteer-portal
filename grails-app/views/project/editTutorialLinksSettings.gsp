<%@ page import="au.org.ala.volunteer.Project" %>
<!doctype html>
<html>
<head>
    <meta name="layout" content="digivol-projectSettings"/>
</head>

<body>

<content tag="pageTitle">Tutorial Links</content>

<content tag="adminButtonBar">
</content>
<div style="margin-bottom: 3em;">
    <h4>Introduction</h4>
    <p>Use this content area to give your volunteers helpful information on how to transcribe the expedition tasks. Provide
    some introductory information to your expedition and then select the applicable tutorials from below.</p>

    <p>You can add new tutorials
    <g:link controller="tutorials" action="manage" params="${[institutionFilter: projectInstance.institution.id]}">here</g:link>.</p>
</div>
<g:form method="post" class="form-horizontal">
    <g:hiddenField name="id" value="${projectInstance?.id}"/>
    <g:hiddenField name="version" value="${projectInstance?.version}"/>
    <g:hiddenField name="formType" value="${Project.EDIT_SECTION_TUTORIAL}" />

    <div class="form-group">
        <div class="col-md-12">
            <g:textArea name="tutorialLinks" class="mce form-control" rows="10" value="${projectInstance?.tutorialLinks}" />
        </div>

    </div>

    <div class="form-group">
        <div class="col-md-12">
            <g:actionSubmit class="save btn btn-primary" action="updateTutorialLinksSettings"
                            value="${message(code: 'project.update.tutorial.info', default: 'Update Information')}"/>
        </div>
    </div>
</g:form>

<div style="padding-top: 1rem; margin-bottom: 3em;">
    <h4>Tutorials</h4>
    <p>Select the tutorials you wish to link to this expedition.</p>
</div>

<g:form method="post">
    <g:hiddenField name="id" value="${projectInstance?.id}"/>
    <div class="form-group">
        <div class="col-md-12">
            <table class="table table-striped">
                <g:each in="${tutorialList}" var="tutorial">
                    <tr>
                        <td><g:checkBox name="tutorials" value="${tutorial.id}" checked="${projectInstance.tutorials.contains(tutorial)}"/></td>
                        <td>${tutorial.name}</td>
                    </tr>
                </g:each>
            </table>
        </div>
    </div>
    <div class="form-group">
        <div class="col-md-12">
            <g:actionSubmit class="save btn btn-primary" action="updateTutorialsInProject"
                            value="${message(code: 'project.update.tutorial.links', default: 'Update Tutorials')}"/>
        </div>
    </div>
</g:form>

</body>
</html>
