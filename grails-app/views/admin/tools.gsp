<%@ page import="au.org.ala.volunteer.Project" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
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
                        <h3>General</h3>
                        <hr/>
                        <a href="${createLink(action: 'mappingTool')}" class="btn btn-default">Mapping tool</a>
                        <a href="${createLink(action: 'migrateProjectsToInstitutions')}"
                           class="btn btn-default">Expedition-Institution migration tool</a>
                        <g:link action="updateUsers" class="btn btn-default">Update users now</g:link>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <div class="well well-sm">
                        <h3>Caches</h3>
                        <hr/>
                        <a href="${createLink(action: 'clearPageCaches')}" class="btn btn-default">Clear page caches</a>
                        <a href="${createLink(action: 'clearAllCaches')}" class="btn btn-default">Clear entity caches</a>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <div class="well" style="margin-top: 10px">
                        <h3>Full Text Index</h3>
                        <hr/>
                        <button class="confirmation-required btn btn-warning" data-href="${createLink(action: 'reindexAllTasks')}"
                                data-message="reindex all Task objects?  This will take a long time.">Reindex all tasks</button>
                        <button class="confirmation-required btn btn-danger" data-href="${createLink(action: 'rebuildIndex')}"
                                data-message="destroy and recreate the search index?  This will take a long time.">Recreate index</button>

                        <div>
                            Background queue length: <span id="queueLength"><cl:spinner/></span>
                        </div>
                        <g:form method="GET" action="testQuery" class="form-horizontal">
                            <fieldset>
                                <legend>Raw Search Query</legend>

                                <div class="form-group">
                                    <div id="set-query" class="col-sm-10">
                                        <button id="match_all" class="btn btn-default btn-sm" data-query="matchAll">Match All</button>
                                        <button id="project_name" class="btn btn-default btn-sm"
                                                data-query="projectName">Project Name</button>
                                        <button id="project_id" class="btn btn-default btn-sm" data-query="projectId">Project Id</button>
                                        <button id="task_id" class="btn btn-default btn-sm" data-query="taskId">Task Id</button>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="control-label col-sm-2" for="query">Query text</label>

                                    <div class="col-sm-10">
                                        <textarea class="form-control" id="query" name="query" rows="10">{
    "query_string": {
        "query": "query string"
    }
}</textarea>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="control-label col-sm-2" for="searchType">Search Type</label>

                                    <div class="col-sm-10">
                                        <select id="searchType" class="form-control" name="searchType">
                                            <option value="dfs_query_then_fetch">DFS Query then Fetch</option>
                                            <option value="dfs_query_and_fetch">DFS Query and Fetch</option>
                                            <option value="query_then_fetch" selected>Query then Fetch</option>
                                            <option value="query_and_fetch">Query and Fetch</option>
                                            <option value="scan">Scan</option>
                                            <option value="count">Count</option>
                                        </select>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="control-label col-sm-2" for="aggregation">Aggregation</label>

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

            <div class="row">
                <div class="col-md-12">
                    <div class="well" style="margin-top: 10px">
                        <h3>S3 Configuration</h3>
                        <hr/>
                        <button id="test-s3" class="btn btn-default" data-href="${createLink(action: 'testS3')}">Test S3</button>
                        <span id="test-s3-spinner" class="hidden"><cl:spinner/></span>

                        <div id="test-s3-results" class="hidden" style="margin-top: 15px">
                            <div id="test-s3-message" class="alert" role="alert"></div>
                            <table class="table table-condensed table-bordered">
                                <tbody>
                                <tr>
                                    <th>Status</th>
                                    <td id="test-s3-status"></td>
                                </tr>
                                <tr>
                                    <th>Enabled</th>
                                    <td id="test-s3-enabled"></td>
                                </tr>
                                <tr>
                                    <th>Region</th>
                                    <td id="test-s3-region"></td>
                                </tr>
                                <tr>
                                    <th>Bucket</th>
                                    <td id="test-s3-bucket"></td>
                                </tr>
                                <tr>
                                    <th>Auth Mode</th>
                                    <td id="test-s3-auth-mode"></td>
                                </tr>
                                </tbody>
                            </table>
                            <pre id="test-s3-json"></pre>
                        </div>
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

        $('#test-s3').click(function(e) {
            e.preventDefault();

            var $button = $(this);
            var $spinner = $('#test-s3-spinner');
            var $results = $('#test-s3-results');
            var $message = $('#test-s3-message');

            $button.prop('disabled', true);
            $spinner.removeClass('hidden');
            $results.addClass('hidden');

            $.ajax({
                url: $button.data('href'),
                dataType: 'json'
            }).done(function(results) {
                var status = results.status || 'UNKNOWN';
                var alertClass = status === 'READY' ? 'alert-success' : (status === 'DISABLED' || status === 'UNCHECKED' ? 'alert-warning' : 'alert-danger');

                $message
                    .removeClass('alert-success alert-warning alert-danger')
                    .addClass(alertClass)
                    .text(results.message || 'S3 test completed.');

                $('#test-s3-status').text(status);
                $('#test-s3-enabled').text(results.s3Enabled);
                $('#test-s3-region').text(results.region || '');
                $('#test-s3-bucket').text(results.bucket || '');
                $('#test-s3-auth-mode').text(results.authMode || '');
                $('#test-s3-json').text(JSON.stringify(results, null, 2));
                $results.removeClass('hidden');
            }).fail(function(xhr) {
                $message
                    .removeClass('alert-success alert-warning alert-danger')
                    .addClass('alert-danger')
                    .text('S3 test failed: ' + (xhr.statusText || 'Unexpected error'));

                $('#test-s3-status').text(xhr.status || 'ERROR');
                $('#test-s3-enabled').text('');
                $('#test-s3-region').text('');
                $('#test-s3-bucket').text('');
                $('#test-s3-auth-mode').text('');
                $('#test-s3-json').text(xhr.responseText || '');
                $results.removeClass('hidden');
            }).always(function() {
                $button.prop('disabled', false);
                $spinner.addClass('hidden');
            });
        });

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
