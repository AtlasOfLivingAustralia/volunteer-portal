<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Volunteer Portal - Atlas of Living Australia</title>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <link rel="stylesheet" href="${resource(dir: 'css', file: 'vp.css')}"/>
        <link rel="stylesheet" href="${resource(dir: 'css', file: 'forum.css')}"/>
        <script type="text/javascript" src="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.pack.js')}"></script>
        <link rel="stylesheet" href="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.css')}"/>

        <style type="text/css">

            .buttonBar {
                margin-bottom: 10px;
            }

        </style>

    </head>

    <body class="sublevel sub-site volunteerportal">

        <script type="text/javascript">
            $(document).ready(function() {
                $("#btnNewSiteTopic").click(function(e) {
                    e.preventDefault();
                    window.location = "${createLink(controller: 'forum', action:'addForumTopic')}";
                });
            });

        </script>

        <cl:navbar selected="forum"/>

        <header id="page-header">
            <div class="inner">
                <cl:messages/>
                <nav id="breadcrumb">
                    <ol>
                        <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
                        <li><a href="${createLink(controller: 'forum', action:'index')}"><g:message code="default.forum.label" default="Forum" /></a></li>
                        <li class="last"><g:message code="default.generaldiscussion.label" default="General Discussion" /></li>
                    </ol>
                </nav>
                <h1><g:message code="default.generaldiscussiontopics.label" default="General Discussion Topics" /></h1>
            </div>
        </header>

        <div class="inner">
            <div class="buttonBar">
                <button id="btnNewSiteTopic" class="button">Create a new topic&nbsp;<img src="${resource(dir: 'images', file: 'newTopic.png')}"/></button>
            </div>
            <h2>Discussion Topics</h2>
            <g:if test="${!topics}">
                <strong>No forum topics have yet been created. Click on the 'Create a new topic' button above to add a discussion topic.</strong>
            </g:if>
            <g:else>
                <vpf:topicTable topics="${topics}"/>
            </g:else>
        </div>

    </body>
</html>
