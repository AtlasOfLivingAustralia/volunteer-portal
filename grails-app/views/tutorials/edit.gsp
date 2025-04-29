<%@ page import="au.org.ala.volunteer.TutorialsController; org.springframework.validation.FieldError" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <g:set var="entityName" value="${message(code: 'tutorial.name.label', default: 'Tutorial')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>
    <g:set var="migrate" value="${(params.migrate == 'true' || params.migrate == true)}"/>
    <g:set var="admin" value="${(params.admin == 'true' || params.admin == true)}"/>

    <style>
        .file-input-wrapper {
            border-radius: 4px !important;
        }

        .tutorial-text-row {
            padding-top: 0.7rem;
            padding-bottom: 1rem;
        }

        .tutorial-button-row {
            padding-top: 1rem;
        }

        .btn {
            border-radius: 4px !important;
        }
    </style>
</head>

<body class="admin">
<cl:headerContent title="${message(code: 'default.edit.label', args: [entityName])}" selectedNavItem="bvpadmin">
    <%
        def sessionParams = session[TutorialsController.SESSION_KEY_TUTORIAL_FILTER]
        pageScope.crumbs = [
            [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
            [link: createLink(controller: 'tutorials', action: 'manage', params: sessionParams), label: message(code: 'tutorial.manage.label', default: 'Manage tutorials')]
        ]
    %>
</cl:headerContent>
<div id="edit-tutorial" class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <g:hasErrors bean="${tutorial}">
                        <div class="alert alert-danger">
                            <ul class="errors" role="alert" style="padding-left: 0px;">
                                <g:eachError bean="${tutorial}" var="error">
                                    <li style="list-style: none" <g:if test="${error in FieldError}">data-field-id="${error.field}"</g:if>><g:message
                                            error="${error}"/></li>
                                </g:eachError>
                            </ul>
                        </div>
                    </g:hasErrors>
                </div>
                <div class="col-md-12">
                    <h4>Tutorial Details</h4>
                    <p>Edit the following details for your Tutorial. You may upload a new version of the tutorial. This will overwrite the existing version.</p>
                </div>
                <div class="col-md-12" style="margin-top: 20px;">
                    <g:form action="update" class="form-horizontal" id="${tutorial?.id}" enctype="multipart/form-data">

                        <div class="form-group">
                            <label class="control-label col-md-3" for="institutionId">Institution*</label>
                            <div class="col-md-6">
                            <cl:ifSiteAdmin>
                                <g:select class="form-control" name="institutionId" id="institutionId" from="${institutionList}"
                                          optionKey="id" value="${tutorial?.institution?.id}" noSelection="['':'- Select an Institution -']"/>
                            </cl:ifSiteAdmin>
                            <cl:ifNotSiteAdmin>
                                <g:select class="form-control" name="institutionId" id="institutionId" from="${institutionList}"
                                          optionKey="id" value="${tutorial?.institution?.id}" noSelection="['':'- Select an Institution -']" required="required"/>
                            </cl:ifNotSiteAdmin>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="name">Tutorial name*</label>

                            <div class="col-md-6">
                                <g:textField class="form-control" maxlength="130" name="name" id="name" value="${tutorial?.name}" required="required"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="description">Description</label>

                            <div class="col-md-6">
                                <g:textField class="form-control" name="description" maxlength="255" id="description" value="${tutorial?.description}" />
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="tutorialFileLink">Tutorial File</label>

                            <div class="col-md-6 tutorial-text-row">
                                <cl:tutorialLink tutorial="${tutorial}"><span class="fa fa-file"></span>&nbsp;${tutorial?.filename}</cl:tutorialLink>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="tutorialFile">Upload New Tutorial File</label>

                            <div class="col-md-6">
                                <input type="file" data-filename-placement="inside" name="tutorialFile" id="tutorialFile" />
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="fileInfo">Tutorial Created</label>
                            <div class="col-md-6 tutorial-text-row">
                                <g:formatDate date="${tutorial?.dateCreated}" format="dd/MM/yyyy HH:mm:ss" /> by ${tutorial?.createdBy?.displayName}
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="fileInfo">Tutorial Last Updated</label>
                            <div class="col-md-6 tutorial-text-row">
                                <g:if test="${tutorial?.lastUpdated}">
                                <g:formatDate date="${tutorial?.lastUpdated}" format="dd/MM/yyyy HH:mm:ss" /> by ${tutorial?.updatedBy ? tutorial?.updatedBy?.displayName : 'System (migration)'}
                                </g:if>
                                <g:else>
                                    -
                                </g:else>
                            </div>
                        </div>

                        <div class="form-group">
                            <div class="col-md-offset-3 col-md-9 tutorial-button-row">
                                <g:if test="${!migrate}">
                                <g:submitButton name="edit" class="save btn btn-primary tutorial-upload"
                                                value="${message(code: 'default.button.update.label', default: 'Save')}"/>
                                </g:if>
                            </div>
                        </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <h4>Expeditions</h4>
                    <g:if test="${migrate}">
                    <p>Below is a list of expeditions that potentially have this tutorial linked. Please select the checkbox to confirm which projects to save:</p>
                    <p>If an Institution is not yet selected, selecting the first checkbox will set the Institution to that Expedition's institution.</p>
                        <g:hiddenField name="migrate" value="true"/>
                    </g:if>
                    <g:else>
                    <p>Below is a list of expeditions that this tutorial is currently assigned to:</p>
                        <g:hiddenField name="admin" value="${admin}"/>
                    </g:else>
                </div>
                <div class="col-md-12">
                    <table class="table table-striped" id="project-table">
                        <g:if test="${migrate}">
                            <tr>
                                <th></th>
                                <th>Project</th>
                                <th>Institution</th>
                                <th><a class="autoSelectMatch" title="Auto-check 100% matches">Match Likeliness</a></th>
                            </tr>
                            <g:each in="${projectMatchList}" var="projectMatch">
                                <g:set var="project" value="${projectMatch.project}" />
                                <tr data-institution-id="${project.institution.id}">
                                    <td class="col-md-1"><g:checkBox name="projectLink" value="${project.id}" class="projectListItem" checked="false"/></td>
                                    <td class="col-md-4"><g:link controller="project" action="editTutorialLinksSettings" id="${project.id}" target="_blank">${project.name}</g:link></td>
                                    <td class="col-md-4"><g:link controller="institution" action="index" id="${project.institution.id}" target="_blank">${project.institution.name}</g:link></td>
                                    <td class="col-md-3"><span title="Matched Words: [${projectMatch.matchedTokenList}]" class="match-percentage">${projectMatch.matchPercentage}%</span></td>
                                </tr>
                            </g:each>
                        </g:if>
                        <g:else>
                            <g:each in="${tutorial?.projects?.sort{ a,b -> a.name <=> b.name }}" var="project">
                        <tr>
                            <td><g:link controller="project" action="editTutorialLinksSettings" id="${project.id}" target="_blank">${project.name}</g:link></td>
                        </tr>
                            </g:each>
                        </g:else>
                    </table>
                </div>
                <g:if test="${migrate}">
                <div class="form-group">
                    <div class="col-md-offset-3 col-md-9 tutorial-button-row">
                            <g:submitButton name="edit" class="save btn btn-primary tutorial-upload"
                                            value="${message(code: 'default.button.update.label', default: 'Save')}"/>
                    </div>
                </div>
                </g:if>
                </g:form>
            </div>
        </div>
    </div>
</div>
<asset:javascript src="bootstrap-file-input" asset-defer=""/>
<asset:script type="text/javascript">
    $(document).ready(function() {
        $('input[type=file]').bootstrapFileInput();
        <g:if test="${migrate}">
        $('.projectListItem').on('change', function() {
           const $row = $(this).closest('tr');
           const institutionId = $row.data('institution-id');
           const $select = $('#institutionId');
           if (this.checked && $select.val() === '') {
               $select.val(institutionId);
           }
        });

        $('.autoSelectMatch').click(function(e) {
            e.preventDefault();

            $('#project-table tr').each(function() {
                const $row = $(this);
                const matchText = $row.find('.match-percentage').text().trim();
                if (matchText === "100%") {
                    $row.find('.projectListItem').prop('checked', true).trigger('change');
                }
            });
        });
        </g:if>
    });


</asset:script>
</body>
</html>