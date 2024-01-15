<%@ page import="au.org.ala.volunteer.AchievementDescription" %>
<%@ page import="au.org.ala.volunteer.Institution" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}">
    <g:set var="entityName" value="${message(code: 'project.name.label', default: 'Expedition')}"/>
    <title><cl:pageTitle title="${g.message(code:"project.manage.label", default:"Manage Expeditions")}" /></title>
</head>

<body class="admin">
<cl:headerContent title="${message(code: 'project.manage.label', default: 'Manage Expeditions')}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
            [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')]
        ]
    %>

    <cl:ifAdmin>
        <a class="btn btn-success" href="${createLink(action: "create")}"><i
                class="icon-plus icon-white"></i>&nbsp;Create Expedition</a>
    </cl:ifAdmin>
</cl:headerContent>
<div class="container" role="main">
    <div class="panel panel-default">
        <div class="panel-body">
            <p>
                This page is your expedition management console. It lists all expeditions within your institution, displaying
                information such as active and archive status and disk usage.<br/>
                <a data-toggle="collapse" href="#collapseInformation" aria-expanded="false"
                   aria-controls="collapseInformation">Click here for more information</a>.
            </p>
            <div class="collapse" id="collapseInformation">
                <div class="panel panel-default panel-body">
                    <p>
                        This tool provides useful information about the expedition and allows you to perform a number of
                        functions on your expedition.
                    </p>
                    <p>
                        You can filter expeditions by status or by expedition name.
                    </p>
                    <ul>
                        <li><b>Status filter:</b> To filter the expedition list by either inactive, archived or vice versa,
                        select a status from the filter select list.</li>
                        <li><b>Expedition Name search:</b> To filter the list with a search term, enter a key word and
                        press enter or click the search icon.</li>
                        <li><b>Completion %:</b> This displays the percentage of transcriptions and validations respectively
                        of the expedition.</li>
                        <li><b>Size:</b> This is the amount of physical disk the expedition is using.</li>
                    </ul>
                    <p><b>Actions:</b></p>
                    <ul>
                        <li><b>Edit:</b> Click on the expedition name to access the expedition settings.</li>
                        <li><b>Activate/Deactivate:</b> Click on the toggle action button to toggle the expedition's
                        activity status. Inactive expeditions are hidden from transcribers.</li>
                        <li><b>Clone:</b> The Clone action allows you to clone the expedition and it's current settings
                        to a new, empty expedition. This is useful if you need to create multiple expeditions of the same type.</li>
                        <li><b>Download Task Images:</b> This creates a zip archive of all the expedition's task images for download.</li>
                        <li><b>Archive Expedition:</b> This deletes ALL task images from the expedition and updates the
                        expedition to inactive and archived. This is to ensure the DigiVol system does not fill up it's
                        disk resources. It's encouraged to archive expeditions once they have been completed and exported. <br/>
                            <b>Note:</b> This action is final and not reversable. Please ensure you have backed up your
                        task images first!</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
    <cl:ifSiteAdmin>
    <div class="panel panel-default">
        <div class="panel-body">
            <h4>Disk Usage Statistics</h4>
            <table class="table table-condensed">
                <tr>
                    <th><g:message code="system.space.usable" default="Usable space"/></th>
                    <th><g:message code="system.space.free" default="Free space"/></th>
                    <th><g:message code="system.space.total" default="Total space"/></th>
                    <th><g:message code="system.space.percentFull" default="Percent full"/></th>
                </tr>
                <tr>
                    <td><cl:formatFileSize size="${imageStoreStats.usable}"/></td>
                    <td><cl:formatFileSize size="${imageStoreStats.free}"/></td>
                    <td><cl:formatFileSize size="${imageStoreStats.total}"/></td>
                    <td>
                        <g:formatNumber number="${((imageStoreStats.total - imageStoreStats.free) / imageStoreStats.total) * 100.0}"
                                        type="number" maxFractionDigits="3" />%
                    </td>
                </tr>
            </table>
        </div>
    </div>
    </cl:ifSiteAdmin>
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-6">

                        <g:select class="form-control institutitonFilter" name="institutionFilter" from="${institutionList}"
                                  optionKey="id"
                                  value="${params?.institutionFilter}" noSelection="['':'- Filter by Institution -']" />

                </div>
                <div class="col-md-3">

                        <g:select class="form-control statusFilter" name="statusFilter" from="${statusFilterList}"
                                    optionKey="key" optionValue="value"
                                  value="${params?.statusFilter}" noSelection="['':'- Filter by Status -']" />

                </div>
                <div class="col-md-3">
                    <div class="custom-search-input body">
                        <div class="input-group">
                            <input type="text" id="searchbox" class="form-control input-lg" value="${params.q}" placeholder="Search Expedition Name..."/>
                            <span class="input-group-btn">
                                <button id="btnSearch" class="btn btn-info btn-lg" type="button">
                                    <i class="glyphicon glyphicon-search"></i>
                                </button>
                            </span>
                        </div>
                    </div>
                </div>

            </div>
            <div class="row">
                <div class="col-md-6" style="margin-top: 20px;margin-left: 5px;">
                    ${archiveProjectInstanceListSize ?: 0} Expeditions found.
                </div>
            </div>
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <table class="table table-striped table-hover">
                        <thead>
                        <tr>
                            <g:sortableColumn property="id"
                                              title="${message(code: 'project.id.label')}"
                                              params="${params}"/>

                            <g:sortableColumn property="name"
                                              title="${message(code: 'project.name.label')}"
                                              params="${params}"/>

                            <g:sortableColumn property="status"
                                              title="${message(code: 'project.status.label')}"
                                              params="${params}"/>

                            <th><span title="Transcribed % / Validated %"><g:message code="project.manage.completion.label"/></span></th>

                            <g:sortableColumn property="dateCreated" params="${params}"
                                              title="${message(code: 'project.dateCreated.label')}"/>


%{--                            <th><span><g:message code="project.manage.size.label"/></span></th>--}%
                            <g:sortableColumn property="sizeInBytes" params="${params}"
                                              title="${message(code: 'project.manage.size.label')}"/>

                            <th></th>

                        </tr>
                        </thead>
                        <tbody>
                        <g:each in="${archiveProjectInstanceList}" status="i" var="projectInstance">
                            <tr class="${(i % 2) == 0 ? 'even' : 'odd'}" projectId="${projectInstance.project.id}">
                                <td style="vertical-align: middle;">
                                    ${projectInstance.project.id}
                                </td>
                                <td style="vertical-align: middle;" width="45%">
                                    <g:link action="edit" id="${projectInstance.project.id}" title="${projectInstance.project.name}">${fieldValue(bean: projectInstance.project, field: "name")}</g:link>
                                </td>

                                <td style="vertical-align: middle;">
                                    <g:if test="${projectInstance.project.archived}">
                                        <i class="fa fa-times-circle-o" title="Archived"></i></span>
                                    </g:if>
                                    <g:if test="${projectInstance.project.inactive}">
                                        <i class="fa fa-eye-slash" title="Inactive"></i></span>
                                    </g:if>
                                </td>

                                <td style="vertical-align: middle; white-space: nowrap;">${fieldValue(bean: projectInstance, field: "percentTranscribed")} / ${fieldValue(bean: projectInstance, field: "percentValidated")}</td>

                                <td style="vertical-align: middle; white-space: nowrap;"><g:formatDate type="date" style="medium"
                                        date="${projectInstance.project.dateCreated}"/></td>

                                <td style="vertical-align: middle; white-space: nowrap;"><span data-id="${projectInstance.project.id}">${projectInstance.project.getProjectSizeFormatted()}</span></td>

                                <td style="white-space: nowrap;">
                                    <!-- Toggle Status -->
                                    <g:if test="${projectInstance.project.inactive}">
                                        <g:if test="${projectInstance.project.archived}">
                                            <button role="button" class="btn btn-default btn-xs"
                                                    title="You cannot activate an archived expedition." disabled><i class="fa fa-toggle-off"></i></button>
                                        </g:if>
                                        <g:else>
                                            <a class="btn btn-xs btn-default toggle-project-status" alt="Activate" title="Activate Expedition"><i class="fa fa-toggle-off"></i></a>
                                        </g:else>
                                    </g:if>
                                    <g:else>
                                        <a class="btn btn-xs btn-default toggle-project-status" alt="Deactivate" title="Deactivate Expedition"><i class="fa fa-toggle-on"></i></a>
                                    </g:else>

                                    <!-- Export -->
                                    <a class="btn btn-xs btn-default export-project" alt="Export" title="Export Expedition (all tasks)"><i class="fa fa-table"></i></a>

                                    <!-- Clone -->
                                    <a class="btn btn-xs btn-default clone-project" alt="Clone" title="Clone Expedition"><i class="fa fa-clone"></i></a>

                                    <!-- Download Archive -->
                                    <g:if test="${!projectInstance.project.archived}">
                                        <button role="button" class="btn btn-default btn-xs download-archive"
                                                data-project-id="${projectInstance.project.id}"
                                                data-href="${createLink(controller: "project", action: "downloadImageArchive", id: projectInstance.project.id, params: params)}"
                                                title="Download Task Images">
                                            <i class="fa fa-download"></i>
                                        </button>
                                    </g:if>
                                    <g:else>
                                        <button role="button" class="btn btn-default btn-xs download-archive"
                                                title="You cannot download images from an archived expedition." disabled><i class="fa fa-download"></i></button>
                                    </g:else>

                                    <!-- Archive -->
                                    <g:if test="${!projectInstance.project.archived}">
                                        <button role="button" class="btn btn-danger btn-xs archive-project"
                                                data-project-name="${projectInstance.project.name}"
                                                data-href="${createLink(controller: "project", action: "archive", id: projectInstance.project.id, params: params)}"
                                                title="Archive Expedition"><i class="fa fa-trash"></i></button>
                                    </g:if>
                                    <g:else>
                                        <button role="button" class="btn btn-default btn-xs download-archive"
                                                title="This expedition has already been archived." disabled><i class="fa fa-trash"></i></button>
                                    </g:else>
%{--                                    </g:form>--}%
                                </td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>

                    <div class="pagination">
                        <g:paginate total="${archiveProjectInstanceListSize ?: 0}" action="manage" params="${params}"/>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<asset:script type="text/javascript">
jQuery(function($) {
    $.extend({
        postGo: function(url, params) {
            var $form = $("<form>")
                .attr("method", "post")
                .attr("action", url);
            $.each(params, function(name, value) {
                $("<input type='hidden'>")
                    .attr("name", name)
                    .attr("value", value)
                    .appendTo($form);
            });
            $form.appendTo("body");
            $form.submit();
        }
    });

    $(".export-project").click(function(e) {
            e.preventDefault();
            var projectId = $(this).parents("[projectId]").attr("projectId");
            var options = {
                title:'Export all tasks',
                url:"${createLink(controller: "task", action: "exportOptionsFragment", params: [exportCriteria: 'all']).encodeAsJavaScript()}&projectId=" + projectId
            };
            bvp.showModal(options);
        });

    $(".clone-project").click(function(e) {
        e.preventDefault();
        var oldProjectId = $(this).parents("[projectId]").attr("projectId");

        if (oldProjectId) {
            bvp.showModal({
                url:"${createLink(action: 'cloneProjectFragment')}?sourceProjectId=" + oldProjectId,
                title:"Clone Expedition"
            });
        }
    });

    $('.archive-project').click(function(e) {
        var $this = $(this);
        var href = $this.data('href');
        var name = $this.data('projectName');
        bootbox.confirm("Are you sure you wish to archive \"" + name + "\"?  Note that this will remove all task images and there may not be any backups!", function(result) {
            if (result) {
                $.postGo(href);
            }
        });
    });

    $('.download-archive').click(function(e) {
        var $this = $(this);
        var href = $this.data('href');
        window.location = href;
    });

    $("#searchbox").keydown(function(e) {
        if (e.keyCode ==13) {
            doProjectSearch();
        }
    });

    $("#btnSearch").click(function(e) {
        e.preventDefault();
        doProjectSearch();
    });

    $('.statusFilter').change(function() {
        let filter = $(this).val();
        var url = "${createLink(controller: 'project', action: 'manage')}" +
            "?institutionFilter=${params.institutionFilter}&q=${params.q}&statusFilter=" + filter;
        window.location = url;
    });

    $('.institutitonFilter').change(function() {
        let filter = $(this).val();
        var url = "${createLink(controller: 'project', action: 'manage')}" +
            "?q=${params.q}&statusFilter=${params.statusFilter}&institutionFilter=" + filter;
        window.location = url;
    });

    function doProjectSearch() {
        var q = $("#searchbox").val();
        var url = "${createLink(controller: 'project', action: 'manage')}" +
            "?institutionFilter=${params.institutionFilter}&statusFilter=${params.statusFilter}&q=" +
            encodeURIComponent(q);
        window.location = url;
    }

    $(".toggle-project-status").click(function (e) {
        e.preventDefault();

        const projectId = $(this).closest('tr').attr("projectId");
        let url = "${createLink(controller: 'project', action: 'toggleProjectInactivity')}/" + projectId;
        const paramString = getQueryStringParams();
        if (paramString) url += "?" + paramString;
         console.log("url: " + url);

        $('<form/>', { action: url, method: 'POST' }).append(
            $('<input>', {type: 'hidden', id: 'verifyId', name: 'verifyId', value: projectId})
        ).appendTo('body').submit();
    });

    function getQueryStringParams() {
        const params = new URLSearchParams(window.location.search);
        let institution = params.get('institutionFilter');
        let q = params.get('q');
        let statusFilter = params.get('statusFilter');

        let paramString = "", s = false;
        if (institution) {
            paramString += (s ? "&" : "") + "institutionFilter=" + institution;
            s = true;
        }
        if (q) {
            paramString += (s ? "&" : "") + "q=" + q;
            s = true;
        }
        if (statusFilter) {
            paramString += (s ? "&" : "") + "statusFilter=" + statusFilter;
        }
        return paramString;
    }

});
</asset:script>
</body>
</html>
