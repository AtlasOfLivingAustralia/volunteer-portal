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

        .button {
            height: 30px;
        }

        </style>

    </head>

    <body class="sublevel sub-site volunteerportal">

        <script type="text/javascript">

            $(document).ready(function () {

                $("#btnReply").click(function (e) {
                    e.preventDefault();
                    window.location = "${createLink(controller:'forum', action:'postProjectMessage', params: [topicId:topic.id])}";
                });

                $("#btnReturnToProject").click(function(e) {
                    e.preventDefault();
                    window.location = "${createLink(controller:'forum', action:'projectForum', params:[projectId:projectInstance.id])}";
                });

            });

        </script>

        <cl:navbar selected=""/>

        <header id="page-header">
            <div class="inner">
                <cl:messages/>
                <nav id="breadcrumb">
                    <ol>
                        <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
                        <li><a href="${createLink(controller: 'project', action: 'index', id: projectInstance.id)}">${projectInstance.featuredLabel}</a></li>
                        <li><a href="${createLink(controller: 'forum', action: 'projectForum', params: [projectId: projectInstance.id])}"><g:message code="forum.project.forum" default="Project Forum"/></a></li>
                        <li class="last">${topic.title}</li>
                    </ol>
                </nav>

                <h1>Project Forum - ${projectInstance.featuredLabel} - ${topic.title}</h1>
            </div>
        </header>

        <div>
            <div class="inner">
                <div class="buttonBar">
                    <button id="btnReturnToProject" class="button"><img src="${resource(dir: 'images', file: 'left_arrow.png')}"/>&nbsp;Return to forum</button>
                    <button id="btnReply" class="button"><img src="${resource(dir: 'images', file: 'reply.png')}"/>&nbsp;Post Reply</button>
                </div>

                <vpf:topicTable topic="${topic}"/>

            </div>
        </div>
    </body>
</html>
