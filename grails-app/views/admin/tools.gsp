<%@ page import="au.org.ala.volunteer.Project" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <title><g:message code="admin.tools.label" default="Administration - Tools"/></title>
        <style type="text/css">
        </style>
        <r:require module="bootbox"/>
        <r:require modules="codemirror-json, codemirror-codeedit, codemirror-sublime, codemirror-monokai" />
        <r:script type='text/javascript'>

            jQuery(function($) {
                $('button.confirmation-required').click(function(e) {
                    var confirm = e.target.dataset.confirm || 'Confirm';
                    var cancel = e.target.dataset.cancel || 'Cancel';
                    bootbox.confirm("Are you sure you want to " + e.target.dataset.message, cancel, confirm, function(result) {
                        if (result) {
                            window.open(e.target.dataset.href, "_self");
                        }
                    })
                })
            })

        </r:script>
    </head>

    <body>

        <cl:headerContent title="${message(code:'default.tools.label', default:'Tools')}">
            <%
                pageScope.crumbs = [
                        [link:createLink(controller:'admin'),label:message(code:'default.admin.label', default:'Admin')]
                ]
            %>
        </cl:headerContent>

        <div class="row">
            <div class="span12">
                <a href="${createLink(action:'mappingTool')}" class="btn">Mapping tool</a>
                <a href="${createLink(action:'migrateProjectsToInstitutions')}" class="btn">Expedition-Institution migration tool</a>
                <a href="${createLink(action:'stagingTasks')}" class="btn">Manage staging queue</a>
            </div>
        </div>

        <div class="row">
            <div class="span12">
                <div class="well well-small" style="margin-top: 10px">
                    <h3>Caches</h3>
                    <a href="${createLink(action:'clearPageCaches')}" class="btn">Clear page caches</a>
                    <a href="${createLink(action:'clearAllCaches')}" class="btn">Clear entity caches</a>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="span12">
                <div class="well" style="margin-top: 10px">
                <h3>Full Text Index</h3>
                    <button class="confirmation-required btn btn-warning" data-href="${createLink(action:'reindexAllTasks')}" data-message="reindex all Task objects?  This will take a long time.">Reindex all tasks</button>
                    <button class="confirmation-required btn btn-danger" data-href="${createLink(action:'rebuildIndex')}" data-message="destroy and recreate the search index?  This will take a long time.">Recreate index</button>
                    <div>
                        Background queue length: <span id="queueLength"><cl:spinner /></span>
                    </div>
                    <g:form method="GET" action="testQuery" class="form-horizontal">
                        <fieldset>
                            <legend>Raw Search Query</legend>
                            <div class="control-group">
                                <label class="control-label" for="query">Query text</label>
                                <div class="controls">
                                    <textarea class="input-block-level" id="query" name="query" rows="10">{
    "query_string": {
        "query": "query string"
    }
}</textarea>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label" for="searchType">Search Type</label>
                                <div class="controls">
                                    <select id="searchType" name="searchType">
                                        <option value="dfs_query_then_fetch">DFS Query then Fetch</option>
                                        <option value="dfs_query_and_fetch">DFS Query and Fetch</option>
                                        <option value="query_then_fetch" selected>Query then Fetch</option>
                                        <option value="query_and_fetch">Query and Fetch</option>
                                        <option value="scan">Scan</option>
                                        <option value="count">Count</option>
                                    </select>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label" for="aggregation">Aggregation</label>
                                <div class="controls">
                                    <textarea class="input-block-level" id="aggregation" name="aggregation" rows="10">{
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
                            <div class="control-group">
                                <div class="controls">
                                    <g:submitButton class="btn" name="submitQuery" value="Run Query" />
                                </div>
                            </div>
                        </fieldset>
                    </g:form>
                </div>
            </div>
        </div>

    </body>
    <r:script>


        $(document).ready(function() {
            updateQueueLength();
            setInterval(updateQueueLength, 5000);
        });

        function updateQueueLength() {
            $.ajax("${createLink(controller:'ajax', action:'getIndexerQueueLength')}").done(function(results) {
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

    </r:script>
</html>
