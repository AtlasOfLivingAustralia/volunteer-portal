
<%@ page import="org.springframework.validation.FieldError; au.org.ala.volunteer.Label" %>
<!DOCTYPE html>
<html>
	<head>
		<meta name="layout" content="${grailsApplication.config.ala.skin}">
		<g:set var="entityName" value="${message(code: 'label.label', default: 'Label')}" />
		<title><g:message code="default.list.label" args="[entityName]" /></title>
        <style>
        .vptable { display: table; }
        .vptable>* { display: table-row; }
        .vptable>*>div {
            display: table-cell;
            padding: 8px;
            line-height: 1.42857143;
            vertical-align: top;
            border-top: 1px solid #ddd;
        }
        .vptable>*>.vpth { font-weight: bold; }
        .min-input-small { min-width: 90px }
        </style>
	</head>
	<body>
        <a href="#list-label" class="skip" tabindex="-1"><g:message code="default.link.skip.label" default="Skip to content&hellip;"/></a>
        <cl:headerContent title="${message(code:'default.tools.label', default:'Labels')}">
            <%
                pageScope.crumbs = [
                        [link:createLink(controller:'admin'),label:message(code:'default.admin.label', default:'Admin')]
                ]
            %>
        </cl:headerContent>
		<div id="list-label" class="content scaffold-list" role="main">
            <g:hasErrors bean="${labelInstance}">
                <ul class="errors" role="alert">
                    <g:eachError bean="${labelInstance}" var="error">
                        <li <g:if test="${error in FieldError}">data-field-id="${error.field}"</g:if>><g:message error="${error}"/></li>
                    </g:eachError>
                </ul>
            </g:hasErrors>
            <div class="vptable">
                <div>
                    <s:sortableColumn tag="div" class="vpth min-input-small" property="category" title="${message(code: 'label.category.label', default: 'Category')}" />
                    <s:sortableColumn tag="div" class="vpth min-input-small" property="value" title="${message(code: 'label.value.label', default: 'Value')}" />
                    <div class="vpth min-input-small"><span>&nbsp;</span></div>
                </div>
                <g:each in="${labelInstanceList}" status="i" var="labelInstance">
                <g:form url="[resource:labelInstance, action:'update']" method="PUT" >
                    <g:hiddenField name="version" value="${labelInstance?.version}" />
                    <div><g:textField class="input-small" placeholder="${message(code: 'label.category.label', default: 'Category')}" name="category" required="" value="${labelInstance?.category}"/></div>
                    <div><g:textField class="input-small" placeholder="${message(code: 'label.value.label', default: 'Value')}" name="value" required="" value="${labelInstance?.value}"/></div>
                    <div class="min-input-small">
                        <button type="submit" class="btn btn-mini btn-primary"><i class="icon-thumbs-up icon-white"></i></button>
                        <button type="reset" class="btn btn-mini"><i class="icon-thumbs-down"></i></button>
                        <button type="button" class="btn btn-mini btn-danger"><i class="icon-remove icon-white"></i></button>
                    </div>
                </g:form>
                </g:each>
            </div>
            <g:if test="${labelInstanceCount > (params.max ?: 10)}">
                <div class="pagination">
                    <g:paginate total="${labelInstanceCount ?: 0}" />
                </div>
            </g:if>
            <div class="vptable">
                <g:form class="form-inline" url="[resource:labelInstance, action:'save']" >
                    <div><g:textField autofocus="true" class="input-small" placeholder="${message(code: 'label.category.label', default: 'Category')}" name="category" required="" value="${labelInstance?.category}"/></div>
                    <div><g:textField class="input-small" placeholder="${message(code: 'label.value.label', default: 'Value')}" name="value" required="" value="${labelInstance?.value}"/></div>
                    <div class="min-input-small">
                        <button type="submit" class="btn btn-mini btn-primary"><i class="icon-thumbs-up icon-white"></i></button>
                        <button type="reset" class="btn btn-mini"><i class="icon-thumbs-down"></i></button>
                    </div>
                </g:form>
            </div>
		</div>
	</body>
</html>
