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
            </div>
        </div>
    </body>
</html>
