<%@ page import="au.org.ala.volunteer.Institution" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}">
    <g:set var="entityName" value="${message(code: 'tutorial.name.label', default: 'Tutorial')}"/>
    <title><cl:pageTitle title="${g.message(code:"tutorial.manage.label", default:"Manage Tutorials")}" /></title>

    <style>
        .btn, .custom-search-input {
            border-radius: 4px !important;
        }

        .btn-secondary {
            color: white;
            background-color: #5d8ab1 !important;
            border-color: #2e6da4 !important;
        }

        .tutorial-status {
            padding-left: 0.2rem;
            padding-right: 0.2rem;
        }
    </style>
</head>

<body class="admin">
<cl:headerContent title="${message(code: 'tutorial.manage.label', default: 'Manage Tutorials')}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')]
        ]
    %>

    <cl:ifAdmin>
        <a class="btn btn-success" href="${createLink(action: "create")}">
            Add Tutorial
        </a>
        <cl:ifSiteAdmin>
        <g:if test="${params.migrate}">
        <a class="btn btn-secondary" href="${createLink(controller: 'tutorials', action: "manage")}">
            Back to Tutorials
        </a>
        </g:if>
        <g:else>
        <a class="btn btn-secondary" href="${createLink(controller: 'tutorials', action: "manage", params: ['admin': true])}">
            Admin Tutorials
        </a>
        <a class="btn btn-secondary" href="${createLink(controller: 'tutorials', action: "manage", params: ['migrate': true])}">
            Migrate Tutorials
        </a>
        </g:else>
        </cl:ifSiteAdmin>
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
                        This tool provides useful information about the tutorial and allows you to perform a number of
                        functions on your tutorial.
                    </p>
                    <p>
                        You can filter tutorials by Institution (if you have access to more than one), status or by tutorial name.
                    </p>
                    <ul>
                        <li><b>Status filter:</b> To filter the tutorial list by it's active status,
                        select a status from the filter select list.</li>
                        <li><b>Tutorial Name search:</b> To filter the list with a search term, enter a key word and
                        press enter or click the search icon.</li>
                    </ul>
                    <p><b>Actions:</b></p>
                    <ul>
                        <li><b>Edit:</b> Click on the pencil edit button to access the tutorial's details and settings.
                        This will also display a list of expeditions that the tutorial has been linked with.</li>
                        <li><b>Activate/Deactivate:</b> Click on the toggle action button to toggle the tutorial's
                        activity status. Inactive tutorials are hidden from transcribers.</li>
                        <li><b>Delete:</b> Click on the rubbish bin button to do delete the tutorial. <br/>
                            <b>Note:</b> This action is final and not reversible.</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>

    <div class="panel panel-default">
        <div class="panel-body">
            <g:if test="${!params.migrate}">
            <div class="row">
                <div class="col-md-4">

                    <g:select class="form-control institutionFilter" name="institutionFilter" from="${institutionList}"
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
                            <input type="text" id="searchbox" class="form-control input-lg" value="${params.q}" placeholder="Search Tutorial Name..."/>
                            <span class="input-group-btn">
                                <button id="btnSearch" class="btn btn-info btn-lg" type="button">
                                    <i class="glyphicon glyphicon-search"></i>
                                </button>
                            </span>
                        </div>
                    </div>
                </div>

                <div class="col-md-2">
                    <a class="btn btn-default bs3"
                       href="${createLink(controller: 'tutorials', action: 'manage')}">Reset</a>
                </div>

            </div>
            </g:if>
            <div class="row">
                <div class="col-md-6" style="margin-top: 20px;margin-left: 5px;">
                    ${tutorialListSize ?: 0} Tutorials found.
                </div>
            </div>
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <table class="table table-striped table-hover">
                        <thead>
                        <tr>
                            <g:sortableColumn property="name"
                                              title="${message(code: 'tutorial.name.label')}"
                                              params="${params}"/>

                            <g:sortableColumn property="status"
                                              title="${message(code: 'tutorial.status.label')}"
                                              params="${params}"/>

                            <g:sortableColumn property="dateCreated" params="${params}"
                                              title="${message(code: 'tutorial.dateCreated.label')}"/>

                            <g:sortableColumn property="lastUpdated" params="${params}"
                                              title="${message(code: 'tutorial.lastUpdated.label')}"/>

                            <th></th>

                        </tr>
                        </thead>
                        <tbody>
                        <g:each in="${tutorialList}" status="i" var="tutorial">
                            <tr class="${(i % 2) == 0 ? 'even' : 'odd'}" data-tutorial-id="${tutorial.id}">
                                <td style="vertical-align: middle; width: 65%;">
                                    <cl:tutorialLink tutorial="${tutorial}" hideLinkIcon="true">${fieldValue(bean: tutorial, field: "name")}</cl:tutorialLink>
                                </td>

                                <td style="vertical-align: middle; text-align: right;">
                                    <g:if test="${!tutorial.isActive}">
                                        <i class="fa fa-eye-slash tutorial-status" title="Inactive"></i>
                                    </g:if>
                                    <g:if test="${tutorial.projects.size() > 0}">
                                        <i class="fa fa-file-text tutorial-status" title="Has been linked to an expedition"></i>
                                    </g:if>
                                </td>

                                <td style="vertical-align: middle; white-space: nowrap;"><g:formatDate type="date" style="medium" date="${tutorial.dateCreated}"/></td>

                                <td style="vertical-align: middle; white-space: nowrap;"><g:formatDate type="date" style="medium" date="${tutorial.lastUpdated}"/></td>

                                <td style="white-space: nowrap;">
                                <!-- Toggle Status -->
                                    <g:if test="${!tutorial.isActive}">
                                        <a class="btn btn-xs btn-default toggle-tutorial-status" alt="Activate" title="Activate Tutorial"><i class="fa fa-toggle-off"></i></a>
                                    </g:if>
                                    <g:else>
                                        <a class="btn btn-xs btn-default toggle-tutorial-status" alt="Deactivate" title="Deactivate Tutorial"><i class="fa fa-toggle-on"></i></a>
                                    </g:else>

                                <!-- Edit -->
                                    <g:link action="edit" id="${tutorial.id}" title="Edit Tutorial" alt="Edit" params="${[migrate: params.migrate ?: false]}">
                                        <span class="btn btn-xs btn-default edit-tutorial">
                                            <i class="fa fa-pencil"></i>
                                        </span>
                                    </g:link>

                                <!-- Delete -->
                                    <button role="button" class="btn btn-danger btn-xs delete-tutorial"
                                            data-tutorial-name="${tutorial.name}"
                                            data-href="${createLink(controller: "tutorials", action: "delete", id: tutorial.id)}"
                                            title="Delete Tutorial"><i class="fa fa-trash"></i></button>
                                </td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>

                    <div class="pagination">
                        <g:paginate total="${tutorialListSize ?: 0}" action="manage" params="${params}"/>
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

        $('.delete-tutorial').click(function(e) {
            var $this = $(this);
            var href = $this.attr('data-href');
            var name = $this.attr('data-tutorial-name');
            let warningText = "<b>Warning:</b><br/>Are you sure you wish to delete the tutorial titled: " + name
                + "?<br/>This action is permanent!"
            bootbox.confirm(warningText, function(result) {
                if (result) {
                    $.postGo(href);
                }
            });
        });

        $("#searchbox").keydown(function(e) {
            if (e.keyCode === 13) {
                doTutorialSearch();
            }
        });

        $("#btnSearch").click(function(e) {
            e.preventDefault();
            doTutorialSearch();
        });

        $('.statusFilter').change(function() {
            let filter = $(this).val();
            var url = "${createLink(controller: 'tutorials', action: 'manage')}" +
                "?institutionFilter=${params.institutionFilter}&q=${params.q}&statusFilter=" + filter;
            window.location = url;
        });

        $('.institutionFilter').change(function() {
            let filter = $(this).val();
            var url = "${createLink(controller: 'tutorials', action: 'manage')}" +
                "?q=${params.q}&statusFilter=${params.statusFilter}&institutionFilter=" + filter;
            window.location = url;
        });

        function doTutorialSearch() {
            var q = $("#searchbox").val();
            var url = "${createLink(controller: 'tutorials', action: 'manage')}" +
                "?institutionFilter=${params.institutionFilter}&statusFilter=${params.statusFilter}&q=" +
                encodeURIComponent(q);
            window.location = url;
        }

        $(".toggle-tutorial-status").click(function (e) {
            e.preventDefault();

            const tutorialId = $(this).closest('tr').attr("data-tutorial-id");
            let url = "${createLink(controller: 'tutorials', action: 'toggleTutorialStatus')}/" + tutorialId;
            const paramString = getQueryStringParams();
            if (paramString) url += "?" + paramString;
             console.log("url: " + url);

            $('<form/>', { action: url, method: 'POST' }).append(
                $('<input>', {type: 'hidden', id: 'verifyId', name: 'verifyId', value: tutorialId})
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
