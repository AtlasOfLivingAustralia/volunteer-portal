<%@ page import="org.springframework.validation.FieldError" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <g:set var="entityName" value="${message(code: 'newsItem.name.label', default: 'News Item')}"/>
    <title><g:message code="default.create.label" args="[entityName]"/></title>

    <style>
    .btn, .custom-search-input {
        border-radius: 4px !important;
    }

    .input-group[class*="col-"] {
        padding-left: 15px;
    }

    .datepicker table tr td.disabled {
        color: #ddd !important;
    }
    </style>

    <link id="bsdp-css" href="https://unpkg.com/bootstrap-datepicker@1.9.0/dist/css/bootstrap-datepicker3.min.css" rel="stylesheet">
</head>

<body class="admin">
<cl:headerContent title="${message(code: 'default.create.label', args: [entityName])}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
                [link: createLink(controller: 'newsItem', action: 'manage'), label: message(code: 'newsItem.manage.label', default: 'Manage News Items')]
        ]
    %>
</cl:headerContent>
<div id="create-news-item" class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <g:hasErrors bean="${newsItem}">
                        <div class="alert alert-danger">
                            <ul class="errors" role="alert" style="padding-left: 0px;">
                                <g:renderErrors bean="${newsItem}" as="list"/>
                            </ul>
                        </div>
                    </g:hasErrors>
                </div>
                <div class="col-md-12">
                    <h4>News Item Details</h4>
                    <p>Fill out the following details for your News Item. </p>
                </div>
                <div class="col-md-12" style="margin-top: 20px;">
                    <g:form action="save" class="form-horizontal" enctype="multipart/form-data">

                        <div class="form-group">
                            <label class="control-label col-md-3" for="title">Title*</label>
                            <div class="col-md-6">
                                <g:textField class="form-control" maxlength="60" name="title" id="title" value="${params?.title}" required="required"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="content">Content*</label>

                            <div class="col-md-6">
                                <g:textArea name="content" id="content" class="mce form-control" rows="10" value="${params?.content}" />
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="isActive">Is Active*</label>
                            <div class="col-md-6">
                                <g:set var="initIsActive" value="${params?.isActive ?: true}"/>
                                <g:checkBox name="isActive" id="isActive" class="form-control" checked="${initIsActive}"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="dateExpiresPicker">Date Expires*</label>
                            <div class="input-group col-md-3">
                                <input type="text" class="form-control datepicker form-control" name="dateExpiresPicker" id="dateExpiresPicker" required="required" value="${params?.dateExpiresPicker ?: ''}"/>
                                <div class="input-group-addon">
                                    <span class="glyphicon glyphicon-th"></span>
                                </div>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="newsItemThumb">Upload Thumbnail</label>

                            <div class="col-md-6">
                                <input type="file" data-filename-placement="inside" name="newsItemThumb" id="newsItemThumb"/>
                            </div>
                        </div>

                        <div class="form-group submit-button-row">
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
<asset:script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/js/bootstrap-datepicker.min.js" asset-defer=""/>
<asset:javascript src="tinymce-simple" asset-defer="" />
<asset:javascript src="bootstrap-file-input" asset-defer=""/>
<asset:script type="text/javascript">
$(document).ready(function() {
    $('input[type=file]').bootstrapFileInput();

    $('.datepicker').datepicker({
        format: "dd/mm/yyyy",
        autoclose: true,
        todayBtn: true,
        orientation: "top auto",
        todayHighlight: true,
        startDate: "${defaultStartDate}",
        endDate: "${defaultEndDate}"
    });
});
</asset:script>
</body>
</html>