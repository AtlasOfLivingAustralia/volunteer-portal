<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Volunteer Portal - Atlas of Living Australia</title>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <link rel="stylesheet" href="${resource(dir: 'css', file: 'vp.css')}"/>
        <style type="text/css">

        div#wrapper > div#content {
            background-color: transparent !important;
        }

        .volunteerportal #page-header {
            background: #f0f0e8 url(${resource(dir:'images/vp',file:'bg_volunteerportal.jpg')}) center top no-repeat;
            padding-bottom: 12px;
            border: 1px solid #d1d1d1;
        }

        </style>

    </head>

    <body>

        <sitemesh:parameter name="selectedNavItem" value="tutorials" />
        <content tag="page-header">
            <nav id="breadcrumb">
                <ol>
                    <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
                    <li class="last"><g:message code="default.tutorials.label" default="Tutorials"/></li>
                </ol>
            </nav>
            <h1>Tutorials</h1>
            <cl:ifAdmin>
                <a class="btn" href="${createLink(controller:'admin', action:'tutorialManagement')}">Manage</a>
            </cl:ifAdmin>
        </content>


    %{----}%

        %{--<cl:navbar selected="tutorials"/>--}%

        %{--<header id="page-header">--}%
            %{--<div class="inner">--}%
                %{--<cl:messages/>--}%
                %{--<hgroup>--}%
                    %{--<h1>Tutorials</h1>--}%
                    %{--<cl:ifAdmin>--}%
                        %{--<button class="button" onclick="location.href = '${createLink(controller:'admin', action:'tutorialManagement')}'">Manage</button>--}%
                    %{--</cl:ifAdmin>--}%
                %{--</hgroup>--}%
            %{--</div>--}%
        %{--</header>--}%

        <div>
            <div class="inner">
                <g:each in="${tutorials.keySet().sort()}" var="group">
                    <h3>${group == '-' ? 'Generic Tutorials' : group}</h3>
                        <table class="table">
                            <g:if test="${group == '-'}">
                                <tr>
                                    <td>
                                        <a href="${createLink(controller:'tutorials', action:'transcribingSpecimenLabels')}">Transcribing Specimen Labels</a>
                                    </td>
                                </tr>
                            </g:if>
                            <g:each in="${tutorials[group]?.sort({it.title})}" var="tute">
                                <tr>
                                    <td>
                                        <a href="${tute.url}">${tute.title}</a>
                                    </td>
                                </tr>
                            </g:each>
                        </table>
                </g:each>
            </div>

        </div>
    </body>
</html>
