<%@ page import="au.org.ala.volunteer.Template" %>
<%@ page import="au.org.ala.volunteer.Institution" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'template.label', default: 'Template')}"/>
    <asset:stylesheet src="jquery-ui"/>
    <title><g:message code="default.list.label" args="[entityName]"/></title>
    <style type="text/css">

    table.bvp-expeditions thead th {
        text-align: left;
    }

    </style>
</head>

<body class="admin">
<div class="container">
    <cl:headerContent title="${message(code: 'default.list.label', args: [entityName])}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin', action: 'index'), label: 'Administration']
            ]
        %>
        <div>
            <a href="${createLink(action: 'create')}" class="btn btn-default">Create new template</a>
        </div>
    </cl:headerContent>

    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-4">
                    <g:select class="form-control" name="institution" id="institution" from="${Institution.list(sort: 'name', order: 'asc')}"
                              optionKey="id"
                              value="${params?.institution}" noSelection="['all':'- View ALL Institutions -']" />
                </div>
                <div class="col-md-3">
                    <input type="text" id="searchbox" class="form-control" value="${params.q}" placeholder="Filter by Project..."/>
                </div>
                <div class="col-md-3">
                    <g:select class="form-control" name="viewName" id="viewName" from="${viewFilter}"
                              value="${params?.viewName}" noSelection="['':'- View ALL views -']" />
                </div>
                <div class="col-md-2">
                    <button type="button" class="btn btn-default bs3" id="apply-filter">Apply</button>
                    <a class="btn btn-default bs3"
                       href="${createLink(controller: 'template', action: 'list')}">Reset</a>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <table class="table table-striped table-hover admin-table">
                        <thead>
                        <tr>
                            <g:sortableColumn property="name"
                                              title="${message(code: 'template.name.label', default: 'Name')}"
                                              params="${params}"/>
                            <th>Status</th>
                            <g:sortableColumn property="author"
                                              title="${message(code: 'template.author.label', default: 'Author')}"
                                              params="${params}"/>
                            <g:sortableColumn property="viewName"
                                              title="${message(code: 'template.viewName.label', default: 'View Name')}"
                                              params="${params}"/>
                            <th>Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        <g:each in="${templateInstanceList}" status="i" var="templateListItem">
                            <g:set var="templateInstance" value="${templateListItem.template}" />
                            <tr class="${(i % 2) == 0 ? 'odd' : 'even'}" templateId="${templateInstance.id}"
                                templateName="${templateInstance.name}">

                                <td>${fieldValue(bean: templateInstance, field: "name")}</td>
                                <td style="text-align: center"><span>
                                <g:if test="${templateInstance.isGlobal}">
                                    <i class="fa fa-globe" title="Global Template"></i></span>
                                </g:if>
                                <g:if test="${templateInstance.isHidden}">
                                    <i class="fa fa-eye-slash" title="Hidden; only visible to Site Admins"></i></span>
                                </g:if>
                                </td>
                                <td>${cl.displayNameForUserId(id: templateInstance.author)}</td>
                                <td>${fieldValue(bean: templateInstance, field: "viewName")}</td>

                                <td>
                                    <a class="btn btn-xs btn-default btnCloneTemplate" alt="Clone" title="Clone Template"><i class="fa fa-clone"></i></a>
                            <g:if test="${templateListItem.canEdit}">
                                    <a class="btn btn-xs btn-default" alt="Edit" title="Edit"
                                       href="${createLink(controller: 'template', action: 'edit', id: templateInstance.id)}">
                                        <i class="fa fa-pencil"></i>
                                    </a>
                            </g:if>
                            <g:else>
                                    <button class="btn btn-xs btn-default" alt="Edit" title="You cannot edit this template" disabled><i class="fa fa-pencil"></i></button>
                            </g:else>
                                    <a class="btn btn-xs btn-default" alt="Preview Template" title="Preview Template"
                                       href="${createLink(controller: 'template', action: 'preview', id: templateInstance.id)}">
                                        <i class="fa fa-tv"></i>
                                    </a>
                            <g:if test="${templateListItem.canEdit && templateInstance.projects?.size() == 0}">
                                    <a class="btn btn-xs btn-danger btnDeleteTemplate" data-link-count="${templateInstance.projects?.size()}" alt="Delete" title="Delete"><i class="fa fa-times"></i></a>
                            </g:if>
                            <g:else>
                                    <button class="btn btn-xs btn-danger" alt="Delete" title="You cannot delete this template" disabled><i class="fa fa-times"></i></button>
                            </g:else>
                                </td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>
                </div>

                <div class="text-center">
                    <g:paginate total="${templateInstanceTotal}"/>
                </div>
            </div>
        </div>
    </div>
</div>
<asset:javascript src="jquery-ui" asset-defer=""/>
<asset:javascript src="bootbox" asset-defer=""/>
<asset:script type="text/javascript">
    $(function() {

        $(".btnDeleteTemplate").click(function(e) {
            e.preventDefault();
            var templateId = $(this).parents("[templateId]").attr("templateId");
            var templateName = $(this).parents("[templateName]").attr("templateName");
            var linkCount = $(this).data('link-count');
            if (linkCount === null || linkCount === undefined) linkCount = 0;
            if (templateId && templateName) {
                let linkMsg = "";
                if (linkCount > 0) linkMsg = "<br />There are <b>" + linkCount + "</b> expeditions linked to this template.";
                let confirmMsg = "Are you sure you wish to delete template " + templateName + "? " + linkMsg
                bootbox.confirm(confirmMsg, function(result) {
                    if (result) window.location = "${createLink(controller: 'template', action: 'delete')}/" + templateId;
                });
            }
        });

        $(".btnCloneTemplate").click(function(e) {
            e.preventDefault();
            var oldTemplateId = $(this).parents("[templateId]").attr("templateId");
            var oldTemplateName = $(this).parents("[templateName]").attr("templateName");

            if (oldTemplateId && oldTemplateName) {
                bvp.showModal({
                    url:"${createLink(action: 'cloneTemplateFragment')}?sourceTemplateId=" + oldTemplateId,
                    title:"Clone template '" + oldTemplateName + "'"
                });
            }
        });

        $("#searchbox").keydown(function(e) {
            if (e.keyCode === 13) {
                doSearch();
            }
        });

        $('#apply-filter').click(function(e) {
            e.preventDefault();
            doSearch();
        });

        function doSearch() {
            console.log(window.location.search);
            const params = new URLSearchParams(window.location.search);
            let institutionId = params.get('institution');
            let viewName = params.get('viewName');
            let q = params.get('q');
            let sort = params.get('sort');
            let order = params.get('order');

            function addAmpersand(string) {
                return string + "&";
            }

            institutionId = $('#institution').val();
            q = encodeURIComponent($('#searchbox').val());
            viewName = $('#viewName').val();
            console.log();

            let hasParams = false;
            let url = "${createLink(controller: 'template', action: 'list')}?";

            if (institutionId) {
                url += "institution=" + institutionId;
                if (!hasParams) hasParams = true;
            }
            if (viewName) {
                if (hasParams) {
                    //url += "&";
                    url = addAmpersand(url);
                }
                url += "viewName=" + viewName;
                if (!hasParams) hasParams = true;
            }
            if (q) {
                if (hasParams) {
                    //url += "&";
                    url = addAmpersand(url);
                }
                url += "q=" + q;
                if (!hasParams) hasParams = true;
            }
            if (sort) {
                if (hasParams) {
                    //url += "&";
                    url = addAmpersand(url);
                }
                url += "sort=" + sort + "&order=" + order;
                if (!hasParams) hasParams = true;
            }

            console.log(url);
            window.location = url;
        }
    });

</asset:script>
</body>
</html>
