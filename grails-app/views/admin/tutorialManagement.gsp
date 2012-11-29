<%@ page import="au.org.ala.volunteer.Project" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <title><g:message code="admin.label" default="Administration"/></title>
        <style type="text/css">

            #buttonBar {
                margin-bottom: 10px;
            }

            .bvp-expeditions td button {
                margin-top: 5px;
            }

        </style>
        <script type='text/javascript'>

            $(document).ready(function() {

                $("#btnUpload").click(function(e){
                    e.preventDefault();
                    alert("Goo!");
                });

                $(".btnDeleteTutorial").click(function(e) {
                    e.preventDefault();
                    var name = $(this).attr("tutorial");
                    window.location = "${createLink(controller:'admin', action:'deleteTutorial')}?tutorialFile=" + name;
                });
            });

        </script>
    </head>

    <body class="sublevel sub-site volunteerportal">
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
            <span class="menuButton"><a class="home" href="${createLink(controller: 'admin', action: 'index')}"><g:message code="default.admin.label" default="Admin"/></a></span>
            <span class="menuButton">Manage Tutorials</span>
        </div>

        <div>
            <h2>Tutorial Management</h2>
            <div class="inner">
                <cl:messages />
                <div id="buttonBar">
                    <g:form action="uploadTutorial" controller="admin" method="post" enctype="multipart/form-data">
                        <label for="tutorialFile"><strong>Upload new tutorial:</strong></label>
                        <input type="file" name="tutorialFile" id="tutorialFile"/>
                        <g:submitButton name="Upload" />
                    </g:form>
                </div>


                <table class="bvp-expeditions">
                    <thead>
                        <tr>
                            <th style="text-align: left">Name</th>
                            <th style="text-align: left">Link</th>
                            <th style="text-align: left">Actions</th>
                        </tr>
                    </thead>
                    <g:each in="${tutorials}" var="tute">
                        <tr>
                            <td>${tute.name}</td>
                            <td><a href="${tute.url}">${tute.url}</a></td>
                            <td><button class="button btnDeleteTutorial" tutorial="${tute.name}">Delete</button></td>
                        </tr>
                    </g:each>
                </table>
            </div>
        </div>
        <br/>
    </body>
</html>
