<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="default.application.name"/></title>
    <asset:stylesheet src="forum.css"/>

</head>

<body class="forum">
<cl:headerContent title="Formatting Forum Messages" selectedNavItem="forum">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'forum', action: 'index'), label: 'Forum']
        ]
    %>
</cl:headerContent>
<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <cl:messages/>
                    <p>
                        <g:message code="forum.markdown.description"/>
                    </p>

                    <p>
                        <g:message code="forum.markdown.feature_description"/>
                    </p>

                    <h3><g:message code="forum.markdown.markdown_syntax"/></h3>

                    <table style="width: 100%">
                        <thead>
                        <tr>
                            <th><g:message code="forum.markdown.effect"/></th>
                            <th><g:message code="forum.markdown.syntax"/></th>
                        </tr>
                        </thead>
                        <g:each in="${items}" var="item">
                            <tr>
                                <td><strong>${item.effect}</strong></td>
                                <td>
                                    <div>
                                        ${item.description}
                                    </div>
                                    <g:message code="forum.markdown.example.for_example"/>
                                    <div style="border: 1px solid #d3d3d3; padding: 5px">
                                        <code>
                                            ${item.code.replace("\n", "<br/>")}
                                        </code>
                                    </div>
                                    <g:message code="forum.markdown.example.will_produce"/>
                                    <div style="border: 1px solid #d3d3d3; padding: 5px">
                                        <markdown:renderHtml text="${item.code.replace("&nbsp;", " ")}"/>
                                    </div>
                                </td>
                            </tr>
                        </g:each>
                    </table>

                    <code></code>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
