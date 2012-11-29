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

                $( "#dialog" ).dialog({
                    minHeight: 200,
                    minWidth: 500,
                    resizable: false,
                    autoOpen: false
                });

                $(".btnDeleteTutorial").click(function(e) {
                    e.preventDefault();
                    var name = $(this).attr("tutorial");
                    window.location = "${createLink(controller:'admin', action:'deleteTutorial')}?tutorialFile=" + name;
                });

                $(".btnRenameTutorial").click(function(e) {
                    e.preventDefault();
                    var name = $(this).attr("tutorial");
                    $("#oldName").val(name);
                    $("#newName").val(name);
                    $( "#dialog" ).dialog( "open" );
                });

                $("#btnCancelRename").click(function(e) {
                    e.preventDefault();
                    $( "#dialog" ).dialog( "close" );
                });

                $("#btnApplyRename").click(function(e) {
                    e.preventDefault();
                    var oldName = $("#oldName").val();
                    var newName = $("#newName").val();
                    if (oldName && newName) {
                        window.location = "${createLink(controller:'admin', action:'renameTutorial')}?tutorialFile=" + oldName + "&newName=" + newName;
                    }
                });

            });

        </script>
    </head>

    <body class="sublevel sub-site volunteerportal">

        <cl:navbar />

        <header id="page-header">
            <div class="inner">
                <cl:messages/>
                <nav id="breadcrumb">
                    <ol>
                        <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
                        <li><a class="home" href="${createLink(controller: 'admin', action: 'index')}"><g:message code="default.admin.label" default="Admin"/></a></li>
                        <li class="last"><g:message code="default.tutorials.label" default="Tutorial Management"/></li>
                    </ol>
                </nav>
                <hgroup>
                    <h1>Tutorial Management</h1>
                </hgroup>
            </div>
        </header>

        <div>
            <div class="inner">
                <cl:messages />
                <div id="buttonBar">
                    <g:form action="uploadTutorial" controller="admin" method="post" enctype="multipart/form-data">
                        <label for="tutorialFile"><strong>Upload new tutorial:</strong></label>
                        <input type="file" name="tutorialFile" id="tutorialFile"/>
                        <g:submitButton name="Upload" />
                    </g:form>
                    <div>
                        <br/>
                        <strong>Note:</strong>The filename of the tutorial file will be used in the top level 'Tutorials' page. If the name contains an underscore '_', the portion of the
                        name to the left of the underscore will be used to categorize the tutorial, and the portion to the right (less the file extension) will be used as its name.
                        <br>
                        For example:
                        <code>Expedition Tutorials_The Tutorial Name.pdf</code>
                        will be displayed on the Tutorials page as 'The Tutorial Name' under the heading 'Expedition Tutorials'
                    </div>
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
                            <td>
                                <button class="button btnDeleteTutorial" tutorial="${tute.name}">Delete</button>
                                <button class="button btnRenameTutorial" tutorial="${tute.name}">Rename</button>
                            </td>
                        </tr>
                    </g:each>
                </table>
                <div>
                    <strong>Warning!</strong> Renaming tutorial files will break existing links to those files. Make sure you update project links after renaming!
                </div>
            </div>
        </div>
        <div id="dialog" title="Rename Tutorial" style="display: none">
            <table style="width: 100%">
                <tr>
                    <td><strong>Old&nbsp;name:</strong></td>
                    <td><g:textField name="oldName" id="oldName" disabled="true" size="50"/></td>
                </tr>
                <tr>
                    <td><strong>New&nbsp;name:</strong></td>
                    <td><g:textField name="newName" id="newName" size="50"/></td>
                </tr>
            </table>
            <div>
                <button class="button" id="btnCancelRename">Cancel</button>
                <button class="button" id="btnApplyRename">Rename</button>
            </div>
        </div>
    </body>
</html>
