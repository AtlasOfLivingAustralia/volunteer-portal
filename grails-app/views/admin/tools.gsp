<%@ page import="au.org.ala.volunteer.Project" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <title><g:message code="admin.label" default="Administration - Tools"/></title>
        <style type="text/css">
        </style>
        <r:script type='text/javascript'>

            $(document).ready(function() {
            });

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
            </div>
        </div>

        <div class="row">
            <div class="span12">
                <div class="well" style="margin-top: 10px">
                <h3>Full Text Index</h3>
                    <a href="${createLink(action:'reindexAllTasks')}" class="btn">Reindex all tasks</a>
                    <a href="${createLink(action:'rebuildIndex')}" class="btn">Recreate index</a>
                    <div>
                        Background queue length: <span id="queueLength"><cl:spinner /></span>
                    </div>
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

    </r:script>
</html>
