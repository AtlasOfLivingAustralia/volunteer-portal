<%@ page import="au.org.ala.volunteer.WebUtils; au.org.ala.volunteer.NewsItem" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'newsItem.label', default: 'NewsItem')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>
</head>

<body class="admin">
<div class="container">
    <cl:headerContent title="${message(code: 'default.edit.label', args: [entityName])}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
                    [link: createLink(controller: 'newsItem', action: 'list'), label: message(code: 'default.list.label', args: [entityName])]
            ]
        %>
    </cl:headerContent>
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <g:hasErrors bean="${newsItemInstance}">
                        <div class="alert alert-danger">
                            <g:renderErrors bean="${newsItemInstance}" as="list"/>
                        </div>
                    </g:hasErrors>
                    <g:form method="post" class="form-horizontal">
                        <g:hiddenField name="id" value="${newsItemInstance?.id}"/>
                        <g:hiddenField name="version" value="${newsItemInstance?.version}"/>


                        <!-- form language selector -->
                        <g:render template="/layouts/formLanguageDropdown"/>
                        <!-- Title -->
                        <div class="form-group" >
                            <label class="control-label col-md-3" for="name">
                                <span><g:message code="newsItem.title.label" default="Name"/>
                                (<span class="form-locale locale"></span>)</span>
                            </label>

                            <div class="col-md-6" id="name">
                                <g:each in="${grailsApplication.config.languages.enabled.tokenize(',')}">
                                    <g:textArea style="display:none;" class="form-control i18n-field i18n-field-${it.toString()}" name="i18nTitle.${it.toString()}" rows="1" value="${ WebUtils.safeGet(newsItemInstance?.i18nTitle, it.toString()) }"/>
                                </g:each>
                            </div>
                        </div>

                        <!-- Short Description -->
                        <div class="form-group" >
                            <label class="control-label col-md-3" for="name">
                                <span><g:message code="newsItem.shortDescription.label" default="Short description"/>
                                (<span class="form-locale locale"></span>)</span>
                            </label>

                            <div class="col-md-6" id="i18nShortDescription">
                                <g:each in="${grailsApplication.config.languages.enabled.tokenize(',')}">
                                    <g:textArea style="display:none;" class="form-control i18n-field i18n-field-${it.toString()}" name="i18nShortDescription.${it.toString()}" rows="1" value="${ WebUtils.safeGet(newsItemInstance?.i18nShortDescription, it.toString()) }"/>
                                </g:each>
                            </div>
                        </div>

                        <!-- Description -->
                        <div class="form-group" >
                            <label class="control-label col-md-3" for="description">
                                <span><g:message code="newsItem.body.label" default="Body"/>
                                (<span class="form-locale locale"></span>)</span>
                            </label>

                            <div class="col-md-8" id="description">
                                <g:each in="${grailsApplication.config.languages.enabled.tokenize(',')}">
                                    <span class="i18n-field i18n-field-${it.toString()}">
                                        <g:textArea class="mce form-control" id="i18nBody.${it.toString()}" name="i18nBody.${it.toString()}" rows="10" value="${WebUtils.safeGet(newsItemInstance?.i18nBody, it.toString())}"/>
                                    </span>
                                </g:each>
                            </div>
                        </div>

                        <div class="form-group">
                            <div class="col-md-offset-2 col-md-10">
                                <g:actionSubmit class="save btn btn-small btn-primary" action="update"
                                                value="${message(code: 'default.button.update.label', default: 'Update')}"/>
                                <g:actionSubmit class="delete btn btn-small btn-danger" action="delete"
                                                value="${message(code: 'default.button.delete.label', default: 'Delete')}"
                                                onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');"/>
                            </div>
                        </div>
                    </g:form>
                </div>
            </div>
        </div>
    </div>
</div>
<asset:javascript src="tinymce-simple" asset-defer=""/>
</body>
</html>
