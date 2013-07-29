<%@ page contentType="text/html;charset=UTF-8"  %>
<!DOCTYPE html>
<html>
    <head>
        <title>Volunteer Portal - Atlas of Living Australia - Forum formatting help</title>
        <link rel="stylesheet" href="http://www.ala.org.au/wp-content/themes/ala2011/style.css" type="text/css" media="screen" />
        <link rel="stylesheet" href="http://www.ala.org.au/wp-content/themes/ala2011/css/bvp.css" type="text/css" media="screen" />
        <link rel="stylesheet" href="http://www.ala.org.au/wp-content/themes/ala2011/css/wp-styles.css" type="text/css" media="screen" />
        <link rel="stylesheet" href="http://www.ala.org.au/wp-content/themes/ala2011/css/buttons.css" type="text/css" media="screen" />
        <link rel="icon" type="image/x-icon" href="http://www.ala.org.au/wp-content/themes/ala2011/images/favicon.ico" />
        <link rel="shortcut icon" type="image/x-icon" href="http://www.ala.org.au/wp-content/themes/ala2011/images/favicon.ico" />
        <link rel="stylesheet" type="text/css" media="screen" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css" />
        <link rel="stylesheet" type="text/css" media="screen" href="http://www.ala.org.au/wp-content/themes/ala2011/css/search.css" />
        <link rel="stylesheet" type="text/css" media="screen" href="http://www.ala.org.au/wp-content/themes/ala2011/css/skin.css" />
        <link rel="stylesheet" type="text/css" media="screen" href="http://www.ala.org.au/wp-content/themes/ala2011/css/sf-blue.css" />
        <link rel="stylesheet" href="${resource(dir: 'css', file: 'forum.css')}"/>

        <link rel="stylesheet" href="${resource(dir:'css',file:'public.css')}"/>

        <script type="text/javascript" src="${resource(dir: 'js/jquery-ui-1.9.1.custom/js', file: 'jquery-1.8.2.js')}"></script>
        <script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.mousewheel.min.js')}"></script>

        <style type="text/css">
        </style>
        <r:script type="text/javascript">
            $(document).ready(function () {
            });
        </r:script>

    </head>
    <body class="sublevel sub-site volunteerportal" style="overflow-x: hidden; overflow-y: scroll;">
        <div class="inner">
            <cl:messages />
            <H2>Formatting Forum Messages</H2>
            <p>
                The BVP Forum makes use of a text markup technology called <strong>MarkDown</strong> that allows you to format your forum message posts to include font effects (such as <b>bolding</b> and <i>italics</i>), headings, lists and others.
            </p>
            <p>
                This page demonstrates how to use some basic features of MarkDown. For a more comprehensive overview of MarkDown and its capabilities, please see the <a href="http://en.wikipedia.org/wiki/Markdown">MarkDown Wikipedia page</a> or the <a href="http://daringfireball.net/projects/markdown/">MarkDown website</a>.
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
    </body>
</html>
