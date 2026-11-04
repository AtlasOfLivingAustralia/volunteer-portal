<%@ page import="org.springframework.validation.FieldError" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <g:set var="entityName" value="${message(code: 'newsItem.name.label', default: 'News Item')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>

    <style>
    .news-image-row {
        display: flex;
        flex-direction: column;
        align-items: flex-start;
    }

    .news-image-remove-btn {
        align-self: flex-start;
        margin-top: 7px;
    }
    </style>

    <asset:stylesheet src="bootstrap-datepicker"/>
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

<g:hasErrors bean="${newsItem}">
    <g:render template="/common/notificationAlert"
              model="[attachedBean: newsItem, style: 'danger',
                   alertTitle: message(code: 'default.not.updated.message', default: 'News Item could not be updated', args: [entityName, newsItem?.title]),
                   alertDescription: message(code: 'default.alert.description.error',
                           default: 'There were errors with saving your News Item. Please review the errors below and try again.', args: [entityName])]"/>
</g:hasErrors>

<div id="edit-news-item" class="container">

    <g:form action="update" id="${newsItem?.id}" enctype="multipart/form-data">

    <!-- Main Form Section -->
    <div class="card shadow-sm mb-4">
        <div class="card-header bg-white py-3">
            <h4 class="card-title mb-1 fw-bold text-dark">${entityName} Details</h4>
            <p class="card-subtitle text-muted small mb-0">
                Edit the following details for your ${entityName}.
            </p>
        </div>

        <div class="card-body">
            <div class="form-group required mb-3">
                <label for="title" class="form-label fw-semibold">Title</label>
                <g:textField class="form-control" maxlength="60" name="title" id="title" value="${newsItem?.title}" required="required" aria-required="true"/>
            </div>

            <div class="form-group required mb-3">
                <label class="form-label fw-semibold" for="content">Content</label>
                    <g:textArea name="content" id="content" class="mce form-control" rows="10" value="${newsItem?.content}" aria-required="true"/>
                <span class="form-text text-muted">
                    Provide the content for the news item. The <strong>first
                    2 paragraphs</strong> will be displayed as larger, lead text.
                </span>
            </div>

            <div class="mb-3">
                <div class="form-check">
                    <g:set var="initIsActive" value="${newsItem?.isActive}"/>
                    <g:checkBox name="isActive" id="isActive" class="form-check-input" checked="${initIsActive}"/>
                    <label class="form-check-label" for="isActive">Is Active</label>
                </div>
            </div>

            <div class="form-group required mb-3">
                <label class="form-label fw-semibold" for="dateExpiresPicker">Date Expires</label>
                <div class="input-group">
                    <g:set var="dateExpiresPicker" value="${params?.dateExpiresPicker ?: newsItem?.dateExpires?.format('dd/MM/yyyy') ?: ''}"/>
                    <input type="text" class="form-control datepicker ${hasErrors(bean: newsItem, field: 'dateExpires', 'is-invalid')}" name="dateExpiresPicker" id="dateExpiresPicker" required="required" pattern="[0-9]{2}/[0-9]{2}/[0-9]{4}" title="Use format dd/MM/yyyy" aria-describedby="dateExpiresPickerHelp" value="${dateExpiresPicker}"/>
                    <button type="button" class="btn btn-outline-secondary datepicker-trigger">
                        <i class="fa fa-calendar" aria-hidden="true"></i>
                        <span class="visually-hidden">Choose date expires</span>
                    </button>
                </div>
                <div id="dateExpiresPickerHelp" class="form-text">Format: dd/MM/yyyy</div>
                <cl:fieldError bean="${newsItem}" field="dateExpires"/>
            </div>

            <div class="mb-3">
                <cl:ifNewsItemHasThumb newsItemId="${newsItem.id}">
                    <label class="form-label fw-semibold" for="newsItemThumb">Image Thumbnail</label>
                    <div class="news-image-row">
                        <img src="<cl:newsItemThumbUrl newsItemId="${newsItem.id}"/>" class="img-fluid img-thumbnail w-200" alt="News Item Thumbnail" />
                        <button role="button" class="btn btn-outline-danger btn-sm news-image-remove-btn d-block"
                                data-href="${createLink(controller: "newsItem", action: "clearImage", id: newsItem.id)}"
                                title="Clear Image">Remove image</button>
                    </div>
                </cl:ifNewsItemHasThumb>

                <cl:ifNewsItemHasNoImage newsItemId="${newsItem.id}">
                    <label class="form-label fw-semibold" for="newsItemThumb">Upload Thumbnail</label>
                    <input type="file" class="form-control" name="newsItemThumb" id="newsItemThumb" accept="image/jpeg,image/png"/>
                </cl:ifNewsItemHasNoImage>
            </div>

            <div class="mb-3">
                <label class="form-label fw-semibold" for="imageCaption">Image Caption</label>
                <input type="text" class="form-control" name="imageCaption" id="imageCaption" maxlength="255" value="${params?.imageCaption ?: newsItem.imageCaption}"/>
                <small class="form-text text-muted">
                    Provide a caption for the image. This caption will be displayed
                    alongside the image in the news item. Required if an image is uploaded.
                </small>
            </div>

            <!-- Read-Only Audit Metadata -->
            <div class="row g-3 pt-2 border-top mt-3">
                <div class="col-md-6">
                    <label class="form-label text-muted small mb-1">${entityName} Created</label>
                    <div class="fw-medium text-dark">
                        <g:formatDate date="${newsItem?.dateCreated}" format="dd/MM/yyyy HH:mm:ss"/>
                        <span class="text-muted">(by ${newsItem.createdBy?.displayName})</span>
                    </div>
                </div>
                <div class="col-md-6">
                    <g:if test="${newsItem?.updatedBy}">
                    <label class="form-label text-muted small mb-1">${entityName} Last Updated</label>
                    <div class="fw-medium text-dark">
                        <g:formatDate date="${newsItem?.lastUpdated}" format="dd/MM/yyyy HH:mm:ss"/>
                        <span class="text-muted">(by ${newsItem.updatedBy?.displayName})</span>
                    </div>
                    </g:if>
                </div>
            </div>
        </div>
        <!-- Card Actions -->
        <div class="card-footer bg-light d-flex justify-content-start gap-2 py-3">
            <button type="submit" class="btn btn-primary px-4">Save Changes</button>
            <a href="${createLink(controller: 'newsItem', action: 'manage')}" class="btn btn-outline-secondary">Cancel</a>
        </div>
    </div>


    </g:form>
</div>

<asset:javascript src="bootstrap-datepicker.js" asset-defer=""/>
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

    <cl:ifNewsItemHasThumb newsItemId="${newsItem.id}">
        $('.news-image-remove-btn').click(function(e) {
            e.preventDefault();
            var href = $(this).data('href');
            bvp.confirm("Are you sure you want to remove this image? This action will not save any changes to news item content.", function() {
                window.location.href = href;
            });
        });
    </cl:ifNewsItemHasThumb>
    });

</asset:script>
</body>
</html>