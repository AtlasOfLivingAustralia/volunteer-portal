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
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
                [link: createLink(controller: 'project', action: 'manage'), label: message(code: 'default.project.manage', default: 'Manage projects')]
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
                    <p>* denotes required information.</p>
                </div>
                <div class="col-md-12" style="margin-top: 20px;">
                    <g:form action="save" class="form-horizontal">

                        <div class="form-group">
                            <label class="control-label col-md-3" for="institutionId">Expedition institution*</label>
                            <div class="col-md-6">
                                <g:select class="form-control" name="institutionId" id="institution" from="${institutionList}"
                                          optionKey="id" value="${params?.institutionId}" noSelection="['':'- Select an Institution -']" required="required" />
                            </div>
                            <div id="institution-link-icon" class="col-md-3 control-label text-left">
                                <i class="fa fa-home"></i> <a id="institution-link" href="${createLink(controller: 'institution',
                                    action: 'index', id: params?.institutionId)}" target="_blank">Institution Page</a>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="name">Expedition name*</label>

                            <div class="col-md-6">
                                <g:textField class="form-control" name="name" value="${params?.name}" required="required"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="shortDescription">Short description</label>

                            <div class="col-md-6">
                                <g:textField class="form-control" name="shortDescription" value="${params?.shortDescription}" />
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="description">Long description</label>

                            <div class="col-md-9">
                                <g:textArea name="description" class="mce form-control" value="${params?.description}" rows="10" />
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="template">Template*</label>

                            <div class="col-md-6">
                                <g:select name="template" from="${[]}" id="template" required="required"
                                          class="form-control" value="${params?.template}" noSelection="['':'- Select a Template -']"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="projectType">Expedition type*</label>

                            <div class="col-md-6">
                                <g:select name="projectType" from="${projectTypes}" optionValue="label" optionKey="id"
                                          class="form-control"  value="${params?.projectType}" noSelection="['':'- Select a Project type -']" required="required"/>
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
<asset:script type="text/javascript">
    $(document).ready(function() {
        function loadTemplatesOnError() {
            const templateId = ${(params?.institutionId ?: 0)};
            if (templateId > 0) {
                // Update institution Home page link
                updateInstitutionLink(templateId);
                getTemplatesForInstitution(templateId);
            }
        }

        loadTemplatesOnError();

        function updateInstitutionLink(institutionId) {
            // Update institution Home page link
            let url = "${createLink(controller: 'institution', action: 'index')}";
            url = url + "/" + institutionId;
            $('#institution-link').attr('href', url);
        }

        $('#institution').change(function() {
            // Update institution Home page link
            updateInstitutionLink(this.value);

            // Update Template select list
            getTemplatesForInstitution(this.value);
        });
    });

    function getTemplatesForInstitution(institutionId) {
        //console.log(institutionId);
        const url = "${createLink(controller: 'template', action: 'templatesForInstitution')}/" + institutionId;
        //console.log(url);
        $.get({
            url: url,
            dataType: 'json'
        }).done(function(data) {
            //console.log(data)
            buildTemplateSelect(data);
        });
    }

    function buildTemplateSelect(data) {
        const selectedTemplate = ${(params?.template ?: 0)};
        let templateList = "";
        const noSelection = '<option value>- Select a Template -</option>';
        let currentCategory = "";
        $.each(data, function(idx, t) {
            console.log(t);
            if (currentCategory !== t.category) {
                if (templateList.length > 0) templateList += '</optGroup>';
                templateList += "<optgroup label='" + getTemplateCategory(t.category) + "'>";
                currentCategory = t.category;
            }

            templateList += "<option value='" + t.template.id + "'" + (selectedTemplate === t.template.id ? " selected='selected'" : "") +
                ">" + t.template.name + (t.template.isHidden ? ' (HIDDEN)' : '') + "</option>";

        });
        $('#template').empty()
            .append(noSelection + templateList);
    }

    function getTemplateCategory(categoryCode) {
        let category = "";
        switch (categoryCode) {
            case 'c1': category = "Global Templates";
                break;
            case 'c2': category = "Hidden Templates";
                break;
            case 'c4': category = "Unassigned Templates (templates not assigned to an expedition)";
                break;
            default: category = "Available Templates";
        }
        return category;
    }
</asset:script>
</body>
</html>