<%@ page import="org.springframework.validation.FieldError" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'project.name.label', default: 'Expedition')}"/>
    <title><g:message code="default.create.label" args="[entityName]"/></title>
    <asset:stylesheet src="bootstrap-colorpicker"/>
</head>

<body class="admin">
<cl:headerContent title="${message(code: 'default.create.label', args: [entityName])}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')]
        ]
    %>
</cl:headerContent>
<div id="create-project" class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <g:hasErrors bean="${projectInstance}">
                        <ul class="errors" role="alert">
                            <g:eachError bean="${projectInstance}" var="error">
                                <li <g:if test="${error in FieldError}">data-field-id="${error.field}"</g:if>><g:message
                                        error="${error}"/></li>
                            </g:eachError>
                        </ul>
                    </g:hasErrors>
                </div>
                <div class="col-md-12">
                    <h4>Expedition Details</h4>
                    <p>Fill out the following details for your new Expedition. Once you have created your expedition,
                    you will be able to customise it with extra options, such as:</p>
                    <ul>
                        <li>Expedition and background images</li>
                        <li>Map information</li>
                        <li>Picklists</li>
                        <li>Tutorial information</li>
                    </ul>
                </div>
                <div class="col-md-12" style="margin-top: 20px;">
                    <g:form action="save" class="form-horizontal">

                        <div class="form-group">
                            <label class="control-label col-md-3" for="institutionId">Expedition institution</label>
                            <div class="col-md-6">
                                <g:select class="form-control" name="institutionId" id="institution" from="${institutionList}"
                                          optionKey="id" noSelection="['':'- Select an Institution -']" />
                            </div>
                            <div id="institution-link-icon" class="col-md-3 control-label text-left">
                                <i class="fa fa-home"></i> <a id="institution-link" href="${createLink(controller: 'institution',
                                    action: 'index', id: projectInstance?.institution?.id)}" target="_blank">Institution Page</a>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="name">Expedition name</label>

                            <div class="col-md-6">
                                <g:textField class="form-control" name="name" />
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="shortDescription">Short description</label>

                            <div class="col-md-6">
                                <g:textField class="form-control" name="shortDescription"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="description">Long description</label>

                            <div class="col-md-9">
                                <g:textArea name="description" class="mce form-control" rows="10" />
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="template">Template</label>

                            <div class="col-md-6">
                                <g:select name="template" from="${templateList}" optionValue="name" optionKey="id"
                                          class="form-control" noSelection="['':'- Select a Template -']"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="projectType">Expedition type</label>

                            <div class="col-md-6">
                                <g:select name="projectType" from="${projectTypes}" optionValue="label" optionKey="id"
                                          class="form-control" noSelection="['':'- Select a Project type -']"/>
                            </div>
                        </div>


                        <div class="form-group">
                            <div class="col-md-offset-3 col-md-9">
                                <g:submitButton name="create" class="save btn btn-primary"
                                                value="${message(code: 'default.button.create.label', default: 'Create')}"/>
                            </div>
                        </div>
                    </g:form>
                </div>
            </div>
        </div>
    </div>
</div>
<asset:javascript src="tinymce-simple" asset-defer="" />
</body>
</html>