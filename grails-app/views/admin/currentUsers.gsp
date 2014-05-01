<%@ page import="au.org.ala.volunteer.Project" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <title><g:message code="admin.label" default="Administration - Current users"/></title>
        <style type="text/css">
        </style>
        <r:script type='text/javascript'>

            function refreshActivity() {
                $.ajax("${createLink(controller:'admin', action:'userActivityFragment')}").done(function(content) {
                    $("#userActivityContent").html(content);
                });
            }

            $(document).ready(function() {
                refreshActivity();
                setInterval(refreshActivity, 5000);
            });

        </r:script>
    </head>

    <body>

        <cl:headerContent title="${message(code:'default.currentUsers.label', default:'Current User Activity')}">
            <%
                pageScope.crumbs = [
                        [link:createLink(controller:'admin'),label:message(code:'default.admin.label', default:'Admin')]
                ]
            %>
        </cl:headerContent>

        <div class="row">
            <div class="span12">

                <h3>Current User Activity</h3>
                <div id="userActivityContent"></div>
            </div>
        </div>
    </body>
</html>
