<%@ page import="org.springframework.validation.FieldError" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <g:set var="entityName" value="${message(code: 'newsItem.name.label', default: 'News Item')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>

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

    .news-image-row {
        display: flex;
        align-items: center;
    }

    .news-image-remove-btn {
        align-self: flex-start;
        margin-left: 0.5rem;
        margin-top: 7px;
    }
    </style>

    <link id="bsdp-css" href="https://unpkg.com/bootstrap-datepicker@1.9.0/dist/css/bootstrap-datepicker3.min.css" rel="stylesheet">
</head>

<body class="admin">
<cl:headerContent title="${message(code: 'default.edit.label', args: [entityName])}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
                [link: createLink(controller: 'newsItem', action: 'manage'), label: message(code: 'newsItem.manage.label', default: 'Manage News Items')]
        ]
    %>
</cl:headerContent>
<div id="edit-news-item" class="container">
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
                    <p>Modify the following details for your News Item. </p>
                </div>
                <div class="col-md-12" style="margin-top: 20px;">
                    <g:form action="update" id="${newsItem?.id}" class="form-horizontal" enctype="multipart/form-data">
                        <div class="form-group">
                            <label class="control-label col-md-3" for="title">Title*</label>
                            <div class="col-md-6">
                                <g:textField class="form-control" maxlength="60" name="title" id="title" value="${newsItem?.title}" required="required"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="content">Content*</label>

                            <div class="col-md-6">
                                <g:textArea name="content" id="content" class="mce form-control" rows="10" value="${newsItem?.content}" />
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="isActive">Is Active</label>
                            <div class="col-md-6">
                                <g:set var="initIsActive" value="${newsItem?.isActive}"/>
                                <g:checkBox name="isActive" id="isActive" class="form-control" checked="${initIsActive}"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="dateExpiresPicker">Date Expires*</label>
                            <div class="input-group col-md-3">
                                <g:set var="dateExpiresPicker" value="${newsItem?.dateExpires?.format('dd/MM/yyyy') ?: ''}"/>
                                <input type="text" class="form-control datepicker form-control" name="dateExpiresPicker" id="dateExpiresPicker" required="required" value="${dateExpiresPicker ?: ''}"/>
                                <div class="input-group-addon">
                                    <span class="glyphicon glyphicon-th"></span>
                                </div>
                            </div>
                        </div>

                        <div class="form-group">
                            <cl:ifNewsItemHasThumb newsItemId="${newsItem.id}">
                            <label class="control-label col-md-3" for="newsItemThumb">Image Thumbnail</label>
                            <div class="col-md-6 news-image-row">

                                <img src="<cl:newsItemThumbUrl newsItemId="${newsItem.id}"/>" class="img-responsive control-label" alt="News Item Thumbnail" style="max-width: 200px; max-height: 200px;"/>
                                <button role="button" class="btn btn-danger btn-xs news-image-remove-btn"
                                        data-href="${createLink(controller: "newsItem", action: "clearImage", id: newsItem.id)}"
                                        title="Clear Image"><i class="fa fa-trash"></i></button>
                            </div>
                            </cl:ifNewsItemHasThumb>

                            <cl:ifNewsItemHasNoImage newsItemId="${newsItem.id}">
                            <label class="control-label col-md-3" for="newsItemThumb">Upload Thumbnail</label>

                            <div class="col-md-6">
                                <input type="file" class="form-control" data-filename-placement="inside" name="newsItemThumb" id="newsItemThumb"/>
                            </div>
                            </cl:ifNewsItemHasNoImage>
                        </div>

                        <div class="form-group submit-button-row">
                            <div class="col-md-offset-3 col-md-9">
                                <g:submitButton name="create" class="save btn btn-primary"
                                                value="${message(code: 'default.button.update.label', default: 'Update')}"/>
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
<asset:script type="text/javascript">
    $(document).ready(function() {
        $('.datepicker').datepicker({
            format: "dd/mm/yyyy",
            autoclose: true,
            todayBtn: true,
            orientation: "top auto",
            todayHighlight: true,
            startDate: "${defaultStartDate}",
            endDate: "${defaultEndDate}"
        });

    <cl:ifNewsItemHasNoImage newsItemId="${newsItem.id}">
        $('input[type=file]').bootstrapFileInput();
    </cl:ifNewsItemHasNoImage>

    <cl:ifNewsItemHasThumb newsItemId="${newsItem.id}">
        $('.news-image-remove-btn').click(function(e) {
            e.preventDefault();
            var href = $(this).data('href');
            if (confirm("Are you sure you want to remove this image? This action will not save any changes to news item content.")) {
                window.location.href = href;
            }
        });
    </cl:ifNewsItemHasThumb>
     });
</asset:script>
</body>
</html>