<%@ page import="org.springframework.validation.FieldError" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <g:set var="entityName" value="${message(code: 'newsItem.name.label', default: 'News Item')}"/>
    <title><g:message code="default.create.label" args="[entityName]"/></title>
    <asset:stylesheet src="bootstrap-datepicker.css"/>
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

<g:hasErrors bean="${newsItem}">
    <g:render template="/common/notificationAlert"
              model="[attachedBean: newsItem, style: 'danger',
                      alertTitle: message(code: 'default.not.updated.message', default: 'News Item could not be updated', args: [entityName, newsItem?.title]),
                      alertDescription: message(code: 'default.alert.description.error',
                              default: 'There were errors with saving your News Item. Please review the errors below and try again.', args: [entityName])]"/>
</g:hasErrors>

<div id="create-news-item" class="container">
    <div class="card shadow-sm mb-4">
        <div class="card-header bg-white py-3">
            <h4 class="card-title mb-1 fw-bold text-dark">News Item Details</h4>
            <p class="card-subtitle text-muted small mb-0">Fill out the following details for your News Item. </p>
        </div>

        <g:form action="save" enctype="multipart/form-data">
            <div class="card-body">
                <div class="required mb-3">
                    <label class="form-label fw-semibold" for="title">Title</label>
                    <g:textField class="form-control" maxlength="60" name="title" id="title" value="${params?.title}" required="required"/>
                </div>

                <div class="required mb-3">
                    <label class="form-label fw-semibold" for="content">Content</label>
                    <g:textArea name="content" id="content" class="mce form-control" rows="10" value="${params?.content}" aria-required="true"/>
                    <span class="form-text text-muted">
                        Provide the content for the news item. The <strong>first
                        2 paragraphs</strong> will be displayed as larger, lead text.
                    </span>
                </div>

                <div class="mb-3">
                    <div class="form-check">
                        <g:set var="initIsActive" value="${params?.isActive ?: true}"/>
                        <g:checkBox name="isActive" id="isActive" class="form-check-input" checked="${initIsActive}"/>
                        <label class="form-check-label" for="isActive">Is Active</label>
                    </div>
                </div>

                <div class="required mb-3">
                    <label class="form-label fw-semibold" for="dateExpiresPicker">Date Expires</label>
                    <div class="input-group">
                        <input type="text" class="form-control datepicker ${hasErrors(bean: newsItem, field: 'dateExpires', 'is-invalid')}" name="dateExpiresPicker" id="dateExpiresPicker" required="required" pattern="[0-9]{2}/[0-9]{2}/[0-9]{4}" title="Use format dd/MM/yyyy" aria-describedby="dateExpiresPickerHelp" value="${params?.dateExpiresPicker ?: ''}"/>
                        <button type="button" class="btn btn-outline-secondary datepicker-trigger">
                            <i class="fa fa-calendar" aria-hidden="true"></i>
                            <span class="visually-hidden">Choose date expires</span>
                        </button>
                    </div>
                    <div id="dateExpiresPickerHelp" class="form-text">Format: dd/MM/yyyy</div>
                    <cl:fieldError bean="${newsItem}" field="dateExpires"/>
                </div>

                <div class="mb-3">
                    <label class="form-label fw-semibold" for="newsItemThumb">Upload Thumbnail</label>
                    <input type="file" class="form-control" name="newsItemThumb" id="newsItemThumb" accept="image/jpeg,image/png"/>
                </div>

                <div class="mb-3">
                    <label class="form-label fw-semibold" for="imageCaption">Image Caption</label>
                    <input type="text" class="form-control" name="imageCaption" id="imageCaption" maxlength="255" value="${params?.imageCaption ?: ''}"/>
                </div>
            </div>

            <div class="card-footer bg-light d-flex justify-content-start py-3">
                <g:submitButton name="create" class="save btn btn-primary px-4"
                                value="${message(code: 'default.button.create.label', default: 'Create')}"/>
            </div>
        </g:form>
    </div>
</div>
<asset:javascript src="bootstrap-datepicker" asset-defer=""/>
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

    $('.datepicker-trigger').on('click', function () {
      $(this).closest('.input-group').find('.datepicker').datepicker('show');
    });
});
</asset:script>
</body>
</html>