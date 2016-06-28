<%@ page contentType="text/html; UTF-8" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <meta name="viewport" content="initial-scale=1.0, user-scalable=no"/>
    <title>${taskInstance.project.name} Task Details - ${taskInstance.externalIdentifier}</title>

    <g:set var="shareUrl" value="${g.createLink(absolute: true, action: 'summary', id: taskInstance?.id)}"/>
    <meta property="og:url"           content="${shareUrl}" />
    <meta property="og:type"          content="website" />
    <meta property="og:title"         content="${taskInstance.project.name }Task Details - ${taskInstance.externalIdentifier}" />
    %{--<meta property="og:description"   content="Your description" />--}%
    <meta property="og:image"         content="${stringInstanceMap.thumbnail}" />


    <r:require module="bootstrap-js"/>
    <r:require module="panZoom"/>
    <r:require module="imageViewer"/>

    <asset:script>

        $(document).ready(function () {
            setupPanZoom();
        });

    </asset:script>

    <style type="text/css">

    .imageDiv {
        margin-bottom: 10px;
    }

    </style>

</head>

<body>
<cl:headerContent title="Task Details - ${stringInstanceMap?.filename}">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'project', action: 'list'), label: message(code: 'default.expeditions.label')]

        ]
        if (taskInstance) {
            pageScope.crumbs << [link: createLink(controller: 'project', action: 'index', id: taskInstance?.project?.id), label: taskInstance?.project?.featuredLabel]
        }
    %>

    <div>
        <g:if test="${sequenceNumber >= 0}">
            <span>Image sequence number: ${sequenceNumber}</span>
        </g:if>
    </div>
</cl:headerContent>

<section id="main-content">
<g:if test="${!stringInstanceMap}">
    <div class="alert alert-danger">
        Task is null!
    </div>
</g:if>
<g:else>
    <div class="container">
        <div class="row">
            <div class="col-sm-12 col-md-6">
                <div class="panel panel-default">
                    <div class="panel-body">
                        <div class="imageDiv">
                            <g:set var="multimedia" value="${taskInstance?.multimedia?.first()}"/>
                            <g:imageViewer multimedia="${multimedia}"/>
                        </div>
                        <ul class="list-inline">
                            <li>
                                <div class="fb-share-button" data-href="${shareUrl}" data-layout="button" data-mobile-iframe="true"><a class="fb-xfbml-parse-ignore" target="_blank" href="https://www.facebook.com/sharer/sharer.php?u=${URLEncoder.encode(shareUrl, 'UTF-8')}&amp;src=sdkpreparse">Share</a></div>
                            </li>
                            <li style="vertical-align: middle;">
                                <a href="https://twitter.com/share" class="twitter-share-button">Tweet</a> <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>
                            </li>
                            <g:if test="${!taskInstance.fullyTranscribedBy}">
                                <li>
                                    <g:link class="btn btn-small btn-primary" action="show" id="${taskInstance?.id}">Transcribe/Validate Task</g:link>
                                </li>
                            </g:if>
                            <cl:ifAdmin>
                                <li>
                                    <g:link class="btn btn-small btn-warning" controller="task" action="showDetails" id="${taskInstance?.id}">Show full details</g:link>
                                </li>
                            </cl:ifAdmin>
                        </ul>
                    </div>
                </div>
            </div>

            <div class="col-sm-12 col-md-6">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h2>Task details</h2>
                    </div>
                    <div class="panel-body">
                        <table class="table table-bordered table-condensed">
                            <tr>
                                <td>ID</td>
                                <td>${taskInstance.id}</td>
                            </tr>
                            <tr>
                                <td>External Id</td>
                                <td>${taskInstance.externalIdentifier}</td>
                            </tr>
                            <tr>
                                <td>Project</td>
                                <td>${taskInstance.project?.name}</td>
                            </tr>
                            <tr>
                                <td>Transcribed</td>
                                <td>
                                    <g:if test="${taskInstance.dateFullyTranscribed}">
                                        ${taskInstance.dateFullyTranscribed?.format("yyyy-MM-dd HH:mm:ss")} by ${stringInstanceMap.transcriber}
                                    </g:if>
                                    <g:else>
                                        <span class="muted">
                                            Not transcribed
                                        </span>
                                    </g:else>
                                </td>
                            </tr>
                            <tr>

                                <td>Validated</td>
                                <td>
                                    <g:if test="${taskInstance.dateFullyValidated}">
                                        ${taskInstance.dateFullyValidated?.format("yyyy-MM-dd HH:mm:ss")} by ${stringInstanceMap.validator}
                                    </g:if>
                                    <g:else>
                                        <span class="muted">
                                            Not validated
                                        </span>
                                    </g:else>

                                </td>
                            </tr>
                            <g:if test="${taskInstance.externalUrl}">
                                <tr>
                                    <td>External URL</td>
                                    <td>${taskInstance.externalUrl}</td>
                                </tr>
                            </g:if>
                            <tr>
                                <td>Is Valid</td>
                                <td>
                                    <g:if test="${taskInstance.isValid != null}">
                                        ${taskInstance.isValid}
                                    </g:if>
                                    <g:else>
                                        <span class="muted">
                                            Not set
                                        </span>
                                    </g:else>

                                </td>
                            </tr>
                        </table>
                        %{--<cl:validationStatus task="${taskInstance}"/>--}%
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-sm-12">
                <h2 class="heading">Transcribed information<div class="subheading">Showing ${stringInstanceMap.records.size} records</div></h2>
            </div>
            <g:each in="${stringInstanceMap.records}" status="i" var="fields">
                <div class="col-sm-12 col-md-6">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h3>Record ${i+1}</h3>
                    </div>
                    <table class="table">
                        <tbody>
                        <g:each in="${fields.entrySet()}" var="field">
                            <tr>
                                <td>${field.key}</td>
                                <td>${field.value}</td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>
                </div>
                </div>
            </g:each>
        </div>
    </div>
</g:else>
</section>
<div id="fb-root"></div>
<script>(function(d, s, id) {
    var js, fjs = d.getElementsByTagName(s)[0];
    if (d.getElementById(id)) return;
    js = d.createElement(s); js.id = id;
    js.src = "//connect.facebook.net/en_GB/sdk.js#xfbml=1&version=v2.6";
    fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));</script>
</body>
<asset:script>

        $(document).ready(function() {

            $("#showImageWindow").click(function(e) {
                e.preventDefault();
                window.open("${createLink(controller: 'task', action: "showImage", id: taskInstance?.id)}", "imageViewer", 'directories=no,titlebar=no,toolbar=no,location=no,status=no,menubar=no,height=600,width=600');
            });

        });

</asset:script>
</html>
