<%@ page import="org.springframework.validation.FieldError" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <g:set var="entityName" value="${message(code: 'tutorial.name.label', default: 'Tutorial')}"/>
    <title><g:message code="default.create.label" args="[entityName]"/></title>

    <style>
        .file-input-wrapper {
            border-radius: 4px !important;
        }

        .btn, .custom-search-input {
            border-radius: 4px !important;
        }

        .submit-button-row {
            padding-top: 0.5rem;
        }


    </style>
</head>

<body class="admin">
<cl:headerContent title="${message(code: 'default.create.label', args: [entityName])}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
                [link: createLink(controller: 'tutorials', action: 'manage'), label: message(code: 'tutorial.manage.label', default: 'Manage tutorials')]
        ]
    %>
</cl:headerContent>
<div id="create-tutorial" class="container">
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
                    <p>Fill out the following details for your Tutorial. </p>
                </div>
                <div class="col-md-12" style="margin-top: 20px;">
                    <g:form action="save" class="form-horizontal" enctype="multipart/form-data">

                        <div class="form-group">
                            <label class="control-label col-md-3" for="institutionId">Institution*</label>
                            <div class="col-md-6">
                            <cl:ifSiteAdmin>
                                <g:select class="form-control" name="institutionId" id="institutionId" from="${institutionList}"
                                          optionKey="id" value="${params?.institutionId}" noSelection="['':'- Select an Institution -']" />
                            </cl:ifSiteAdmin>
                            <cl:ifNotSiteAdmin>
                                <g:select class="form-control" name="institutionId" id="institutionId" from="${institutionList}"
                                          optionKey="id" value="${params?.institutionId}" noSelection="['':'- Select an Institution -']" required="required" />
                            </cl:ifNotSiteAdmin>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="name">Tutorial name*</label>

                            <div class="col-md-6">
                                <g:textField class="form-control" maxlength="130" name="name" id="name" value="${params?.name}" required="required"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="description">Description</label>

                            <div class="col-md-6">
                                <g:textField class="form-control" name="description" maxlength="255" id="description" value="${params?.description}" />
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="tutorialFile">Upload Tutorial File</label>

                            <div class="col-md-6">
                                <input type="file" data-filename-placement="inside" name="tutorialFile" id="tutorialFile" required="required"/>
                            </div>
                        </div>

                        <div class="form-group submit-button-row">
                            <div class="col-md-offset-3 col-md-9">
                                <g:submitButton name="create" class="save btn btn-primary tutorial-upload"
                                                value="${message(code: 'default.button.create.label', default: 'Save')}"/>
                            </div>
                        </div>
                    </g:form>
                </div>
            </div>
        </div>
    </div>
</div>
<asset:javascript src="bootstrap-file-input" asset-defer=""/>
<asset:script type="text/javascript">
    $(document).ready(function() {
        $('input[type=file]').bootstrapFileInput();

    });


</asset:script>
</body>
</html>