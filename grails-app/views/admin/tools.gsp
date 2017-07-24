<%@ page import="au.org.ala.volunteer.Project" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="admin.tools.label" default="Administration - Tools"/></title>
    <asset:stylesheet src="codemirror/codemirror-monokai.css"/>
</head>

<body class="admin">

<div class="container">
    <cl:headerContent title="${message(code: 'default.tools.label', default: 'Tools')}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')]
            ]
        %>
    </cl:headerContent>
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <div class="well well-sm">
                        <h3><g:message code="admin.tools.general"/></h3>
                        <hr/>
                        <a href="${createLink(action: 'mappingTool')}" class="btn btn-default"><g:message code="admin.tools.mapping_tool"/></a>
                        <a href="${createLink(action: 'migrateProjectsToInstitutions')}"
                           class="btn btn-default"><g:message code="admin.tools.expedition_institution_migration"/></a>
                        <a href="${createLink(action: 'stagingTasks')}" class="btn btn-default"><g:message code="admin.tools.manage_staging_queue"/></a>
                        <g:link controller="project" action="archiveList" class="btn btn-warning"><g:message code="admin.tools.archive_expeditions"/></g:link>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <div class="well well-sm">
                        <h3><g:message code="admin.tools.caches"/></h3>
                        <hr/>
                        <a href="${createLink(action: 'clearPageCaches')}" class="btn btn-default"><g:message code="admin.tools.clear_page_caches"/></a>
                        <a href="${createLink(action: 'clearAllCaches')}" class="btn btn-default"><g:message code="admin.tools.clear_entity_caches"/></a>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <div class="well" style="margin-top: 10px">
                        <h3><g:message code="admin.tools.full_text_index"/></h3>
                        <hr/>
                        <button class="confirmation-required btn btn-warning" data-href="${createLink(action: 'reindexAllTasks')}"
                                data-message="${message(code: 'admin.tools.reindex.confirmation')}"><g:message code="admin.tools.reindex"/></button>
                        <button class="confirmation-required btn btn-danger" data-href="${createLink(action: 'rebuildIndex')}"
                                data-message="${message(code: 'admin.tools.recreate.confirmation')}"><g:message code="admin.tools.recreate_index"/></button>

                        <div>
                            <g:message code="admin.tools.queue_length"/>: <span id="queueLength"><cl:spinner/></span>
                        </div>
                        <g:form method="GET" action="testQuery" class="form-horizontal">
                            <fieldset>
                                <legend><g:message code="admin.tools.raw_search_query"/></legend>

                                <div class="form-group">
                                    <div id="set-query" class="col-sm-10">
                                        <button id="match_all" class="btn btn-default btn-sm" data-query="matchAll"><g:message code="admin.tools.match_all"/></button>
                                        <button id="project_name" class="btn btn-default btn-sm"
                                                data-query="projectName"><g:message code="admin.tools.project_name"/></button>
                                        <button id="project_id" class="btn btn-default btn-sm" data-query="projectId"><g:message code="admin.tools.project_id"/></button>
                                        <button id="task_id" class="btn btn-default btn-sm" data-query="taskId"><g:message code="admin.tools.task_id"/></button>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="control-label col-sm-2" for="query"><g:message code="admin.tools.query_text"/></label>

                                    <div class="col-sm-10">
                                        <textarea class="form-control" id="query" name="query" rows="10">{
    "query_string": {
        "query": "query string"
    }
}</textarea>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="control-label col-sm-2" for="searchType"><g:message code="admin.tools.search_type"/></label>

                                    <div class="col-sm-10">
                                        <select id="searchType" class="form-control" name="searchType">
                                            <option value="dfs_query_then_fetch"><g:message code="admin.tools.dfs_query_then"/></option>
                                            <option value="dfs_query_and_fetch"><g:message code="admin.tools.dfs_query_and_fetch"/></option>
                                            <option value="query_then_fetch" selected><g:message code="admin.tools.dfs_query_then_fetch"/></option>
                                            <option value="query_and_fetch"><g:message code="admin.tools.query_and_fetch"/></option>
                                            <option value="scan"><g:message code="admin.tools.scan"/></option>
                                            <option value="count"><g:message code="admin.tools.count"/></option>
                                        </select>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="control-label col-sm-2" for="aggregation"><g:message code="admin.tools.aggregation"/></label>

                                    <div class="col-sm-10">
                                        <textarea class="form-control" id="aggregation" name="aggregation" rows="10">{
    "&lt;aggregation_name>" : {
        "&lt;aggregation_type>" : {
            &lt;aggregation_body>
        }
        [,"aggregations" : { [&lt;sub_aggregation>]+ } ]?
    }
    [,"&lt;aggregation_name_2>" : { ... } ]*
}</textarea>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-offset-2 col-sm-10">
                                        <g:submitButton class="btn btn-default" name="submitQuery" value="Run Query"/>
                                    </div>
                                </div>
                            </fieldset>
                        </g:form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
<asset:javascript src="bootbox" asset-defer=""/>
<asset:javascript src="codemirror/codemirror-js-sublime" asset-defer="" />
<asset:script type='text/javascript'>

    jQuery(function ($) {
        $('button.confirmation-required').click(function (e) {
            var confirm = e.target.dataset.confirm || 'Confirm';
            var cancel = e.target.dataset.cancel || 'Cancel';
            bootbox.confirm({
                message: "Are you sure you want to " + e.target.dataset.message,
                callback: function (result) {
                    if (result) {
                        window.open(e.target.dataset.href, "_self");
                    }
                }

            });
        });
    });

</asset:script>
<asset:script type='text/javascript'>


        $(document).ready(function() {
            updateQueueLength();
            setInterval(updateQueueLength, 5000);
        });

        function updateQueueLength() {
            $.ajax("${createLink(controller: 'ajax', action: 'getUpdateQueueLength')}").done(function(results) {
                $("#queueLength").html(results.queueLength);
            });
        }

        var qEditor = CodeMirror.fromTextArea(document.getElementById("query"), {
            matchBrackets: true,
            autoCloseBrackets: true,
            mode: "application/json",
            lineWrapping: true,
            theme: 'monokai'
        });
        var aEditor = CodeMirror.fromTextArea(document.getElementById("aggregation"), {
            matchBrackets: true,
            autoCloseBrackets: true,
            mode: "application/json",
            lineWrapping: true,
            theme: 'monokai'
        });


        var queries = {
            matchAll: { q: { "match_all": { } }, a: null },
            projectId: { q: { "constant_score": { "filter": { "term" : { "projectid" : 0 } } } } },
            projectName: { q: { "constant_score": { "filter": { "term" : { "project.name" : "<project name>" } } } } },
            taskId: { q: { "constant_score": { "filter": { "term" : { "id" : 0 } } } } }
        }

        $('#set-query').click('button', function(e) {
            e.preventDefault();
            var q = queries[e.target.dataset.query];
            qEditor.getDoc().setValue(JSON.stringify(q.q, null, 2));
            aEditor.getDoc().setValue(q.a ? JSON.stringify(q.a, null, 2) : "");
        });

</asset:script>
</html>
