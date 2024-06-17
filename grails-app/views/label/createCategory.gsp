<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}">
    <g:set var="entityName" value="${message(code: 'default.label.category.label', default: 'Category')}"/>
    <title><g:message code="default.create.label" args="[entityName]" default="Create"/></title>
</head>

<body class="admin">
<cl:headerContent title="${message(code: 'default.create.label', args: [entityName], default: 'Create')}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
            [
                link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration'),
                link: createLink(controller: 'label'), label: message(code: 'default.label.admin', default: 'Manage Tags')
            ]
        ]
    %>
</cl:headerContent>
<div id="create-project" class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <g:hasErrors bean="${labelCategory}">
            <div class="row">
                <div class="col-md-12">

                    <div class="alert alert-danger">
                        <ul class="errors" role="alert" style="padding-left: 0px;">
                            <g:eachError bean="${labelCategory}" var="error">
                                <li style="list-style: none" <g:if test="${error in FieldError}">data-field-id="${error.field}"</g:if>><g:message
                                        error="${error}"/></li>
                            </g:eachError>
                        </ul>
                    </div>
                </div>
            </div>
            </g:hasErrors>

            <div class="row">
                <div class="col-md-12">
                    <h4><g:message code="default.label.category.label" default="${entityName}"/> Details</h4>
                </div>
                <div class="col-md-12" style="margin-top: 20px;">
                    <g:form action="saveCategory" class="form-horizontal">
                        <div class="form-group">
                            <label class="control-label col-md-3" for="categoryName"><g:message code="default.label.category.label" default="${entityName}"/> Name*</label>
                            <div class="col-md-9">
                                <g:textField class="form-control" id="categoryName" name="name" value="${params?.name}" required="required"/>
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

</body>
</html>