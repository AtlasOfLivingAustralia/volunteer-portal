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
    <cl:headerContent title="${message(code: 'template.manage.label', default: "Manage Templates")}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin', action: 'index'), label: 'Administration']
            ]
        %>
        <div>
            <a href="${createLink(action: 'create')}" class="btn btn-success">Create new template</a>
        </div>
    </cl:headerContent>

    <div class="panel panel-default">
        <div class="panel-body">
            <p>
                This tool allows Administrators to manage the templates for transcriptions in expeditions. <br/>
                <a data-toggle="collapse" href="#collapseInformation" aria-expanded="false"
                   aria-controls="collapseInformation">Click here for more information</a>.
            </p>
            <div class="collapse" id="collapseInformation">
                <div class="panel panel-default panel-body">
                    <p>
                        <b>Global Templates:</b><br/>
                        Global Templates (marked with the <i class="fa fa-globe" title="Global Template"></i> icon) are read-only
                        templates available to all expeditions.<br/>
                        <b>Editing:</b><br/>
                        Editing is restricted to only those templates that are assigned to expeditions for your institution(s)
                        or templates that are not yet assigned to an expedition. All other templates are viewable and may be
                        cloned for your own institutions/expeditions.<br/>
                        To view templates that are not yet assigned to an expedition, select 'View all institutions' and filter by
                        'Unassigned templates'.<br/>
                        <b>Clone Template:</b><br/>
                        When cloning a template, it will be created unassigned to any expeditions. To find your newly
                        cloned template, select 'View ALL Institutions' in the institution filter and 'Unassigned templates'
                        in the status filter.<br/>
                    <cl:ifSiteAdmin>
                        <b>Deleting:</b><br/>
                        Deleting is only available when the template is not assigned to an expedition. Please be aware
                        that this action is final and not reversable.
                    </cl:ifSiteAdmin>
                    </p>
                </div>
            </div>
        </div>
    </div>
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-4">
                    <g:select class="form-control" name="institution" id="institution" from="${Institution.listApproved(sort: 'name', order: 'asc')}"
                              optionKey="id"
                              value="${params?.institution}" noSelection="['all':'- View ALL Institutions -']" />
                </div>
                <cl:ifSiteAdmin>
                    <g:set var="searchWidth" value="2" />
                    <g:set var="viewFilterWidth" value="2" />
                </cl:ifSiteAdmin>
                <cl:ifNotSiteAdmin>
                    <g:set var="searchWidth" value="3" />
                    <g:set var="viewFilterWidth" value="3" />
                </cl:ifNotSiteAdmin>
                <div class="col-md-${searchWidth}">
                    <input type="text" id="searchbox" class="form-control" value="${params.q}" placeholder="Filter by template name ..."/>
                </div>
                <div class="col-md-${viewFilterWidth}">
                    <g:select class="form-control" name="viewName" id="viewName" from="${viewFilter}"
                              value="${params?.viewName}" noSelection="['':'- View ALL views -']" />
                </div>
                <div class="col-md-2">
                    <g:select class="form-control" name="status" id="status" from="${statusFilter}"
                        optionKey="key" optionValue="value"
                              value="${params?.status}" noSelection="['':'- View ALL templates -']" />
                </div>
                <div class="col-md-2">
                    <button type="button" class="btn btn-default bs3" id="apply-filter">Apply</button>
                    <a class="btn btn-default bs3"
                       href="${createLink(controller: 'template', action: 'list')}">Reset</a>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6" style="margin-top: 20px;margin-left: 5px;">
                    ${templateInstanceTotal ?: 0} Templates found.
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

                                <td>
                                    ${fieldValue(bean: templateInstance, field: "name")}&nbsp;
                                    <cl:ifSiteAdmin><span style="color: #bbbbbb">(${templateListItem.projectCount} Projects)</span></cl:ifSiteAdmin>
                                </td>
                                <td style="text-align: center"><span>
                                <g:if test="${templateInstance.isGlobal}">
                                    <i class="fa fa-globe" title="Global Template"></i></span>
                                </g:if>
                                <g:if test="${templateInstance.isHidden}">
                                    <i class="fa fa-eye-slash" title="Hidden; only visible to Site Admins"></i></span>
                                </g:if>
                                </td>
                                <td style="white-space: nowrap;">${cl.displayNameForUserId(id: templateInstance.author)}</td>
                                <td>${fieldValue(bean: templateInstance, field: "viewName")}</td>

                                <td style="white-space: nowrap;">
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
                            <cl:ifSiteAdmin>
                            <g:if test="${templateListItem.canEdit && templateInstance.projects?.size() == 0}">
                                    <a class="btn btn-xs btn-danger btnDeleteTemplate" data-link-count="${templateInstance.projects?.size()}" alt="Delete" title="Delete"><i class="fa fa-times"></i></a>
                            </g:if>
                            <g:else>
                                    <button class="btn btn-xs btn-danger" alt="Delete" title="You cannot delete this template" disabled><i class="fa fa-times"></i></button>
                            </g:else>
                            </cl:ifSiteAdmin>
                                </td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>
                </div>

                <div class="text-center">
                    <g:paginate total="${templateInstanceTotal}" params="${params}"/>
                </div>
            </div>
        </div>
    </div>
</div>
<asset:javascript src="jquery-ui" asset-defer=""/>
<asset:javascript src="bootbox" asset-defer=""/>
<asset:script type="text/javascript">
    $(function() {

        function getQueryStringParams() {
            const params = new URLSearchParams(window.location.search);
            let institution = params.get('institution');
            let q = params.get('q');
            let statusFilter = params.get('status');
            let viewName = params.get('viewName');

            let paramString = "", s = false;
            if (institution) {
                paramString += (s ? "&" : "") + "institution=" + institution;
                s = true;
            }
            if (q) {
                paramString += (s ? "&" : "") + "q=" + q;
                s = true;
            }
            if (viewName) {
                paramString += (s ? "&" : "") + "viewName=" + viewName;
                s = true;
            }
            if (statusFilter) {
                paramString += (s ? "&" : "") + "status=" + statusFilter;
            }
            return paramString;
        }

        $(".btnDeleteTemplate").click(function(e) {
            e.preventDefault();
            console.log("deleting template");
            var templateId = $(this).parents("[templateId]").attr("templateId");
            var templateName = $(this).parents("[templateName]").attr("templateName");
            var linkCount = $(this).data('link-count');
            if (linkCount === null || linkCount === undefined) linkCount = 0;
            if (templateId) {
                let linkMsg = "";
                if (linkCount > 0) linkMsg = "<br />There are <b>" + linkCount + "</b> expeditions linked to this template.";
                let confirmMsg = "Are you sure you wish to delete template " + templateName + "? " + linkMsg
                bootbox.confirm(confirmMsg, function(result) {
                    if (result) {
                        let url = "${createLink(controller: 'template', action: 'delete')}/" + templateId;
                        const params = getQueryStringParams();
                        if (params) {
                            url += "?" + params;
                        }
                        window.location = url;
                    }
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

        $('#institution').change(function() {
            doSearch();
        });

        $('#viewName').change(function() {
            doSearch();
        });

        $('#status').change(function() {
            doSearch();
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
            let status = params.get('status');
            let sort = params.get('sort');
            let order = params.get('order');

            function addAmpersand(string) {
                return string + "&";
            }

            function addParam(url, param, value, addAmpersandToUrl = false) {
                if (addAmpersandToUrl) url = addAmpersand(url);
                return url + param + "=" + value;
            }

            institutionId = $('#institution').val();
            q = encodeURIComponent($('#searchbox').val());
            viewName = $('#viewName').val();
            status = $('#status').val();
            console.log();

            let hasParams = false;
            let url = "${createLink(controller: 'template', action: 'list')}?";

            if (institutionId) {
                url = addParam(url, 'institution', institutionId, hasParams);
                if (!hasParams) hasParams = true;
            }
            if (viewName) {
                url = addParam(url, 'viewName', viewName, hasParams);
                if (!hasParams) hasParams = true;
            }
            if (q) {
                url = addParam(url, 'q', encodeURIComponent(q), hasParams);
                if (!hasParams) hasParams = true;
            }
            if (status) {
                url = addParam(url, 'status', status, hasParams);
                if (!hasParams) hasParams = true;
            }
            if (sort) {
                url = addParam(url, 'sort', sort, hasParams);
                url = addParam(url, 'order', order, hasParams);
            }

            console.log(url);
            window.location = url;
        }
    });

</asset:script>
</body>
</html>
