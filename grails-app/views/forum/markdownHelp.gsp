<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="default.application.name"/> - Atlas of Living Australia - Forum formatting help</title>
    <asset:styleshhet src="forum.css"/>

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
                        The <g:message
                                code="default.application.name"/> Forum makes use of a text markup technology called <strong>MarkDown</strong> that allows you to format your forum message posts to include font effects (such as <b>bolding</b> and <i>italics</i>), headings, lists and others.
                    </p>

                    <p>
                        This page demonstrates how to use some basic features of MarkDown. For a more comprehensive overview of MarkDown and its capabilities, please see the <a
                            href="http://en.wikipedia.org/wiki/Markdown">MarkDown Wikipedia page</a> or the <a
                            href="http://daringfireball.net/projects/markdown/">MarkDown website</a>.
                    </p>

                    <h3>Markdown syntax</h3>

                    <table style="width: 100%">
                        <thead>
                        <tr>
                            <th>Effect</th>
                            <th>Example syntax</th>
                        </tr>
                        </thead>
                        <g:each in="${items}" var="item">
                            <tr>
                                <td><strong>${item.effect}</strong></td>
                                <td>
                                    <div>
                                        ${item.description}
                                    </div>
                                    For example:
                                    <div style="border: 1px solid #d3d3d3; padding: 5px">
                                        <code>
                                            ${item.code.replace("\n", "<br/>")}
                                        </code>
                                    </div>
                                    will produce:
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
