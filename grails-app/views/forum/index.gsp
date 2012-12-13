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
        </style>

    </head>

    <body class="sublevel sub-site volunteerportal">

        <script type="text/javascript">

        </script>

        <cl:navbar selected="forum"/>

        <header id="page-header">
            <div class="inner">
                <cl:messages/>
                <nav id="breadcrumb">
                    <ol>
                        <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
                        <li class="last"><g:message code="default.forum.label" default="Forum"/></li>
                    </ol>
                </nav>

                <h1><g:message code="default.forum.label" default="Forum"/></h1>
            </div>
        </header>

        <div class="inner">
            <h2>Welcome to the Volunteer Portal Forum!</h2>
            The forum is organised into a number of sections...
            <h3><a href="${createLink(controller:'forum',action:'generalDiscussion')}">General Discussion Topics</a></h3>
            This section is for general comments and queries about the Biodiversity Volunteer Portal in general
        </div>

    </body>
</html>
