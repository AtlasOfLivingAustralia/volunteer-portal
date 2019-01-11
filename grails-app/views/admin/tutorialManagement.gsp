<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="au.org.ala.volunteer.Project" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="admin.label" default="Administration"/></title>
</head>

<body class="admin">

<cl:headerContent title="${message(code: 'default.tutorialmanagement.label', default: 'Tutorial Management')}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')]
        ]
    %>
</cl:headerContent>
<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">

                    <div id="buttonBar">
                        <g:form action="uploadTutorial" controller="admin" method="post" enctype="multipart/form-data">
                            <label for="tutorialFile"><strong><g:message code="admin.tutorial_management.upload_new"/>:</strong></label>
                            <input type="file" data-filename-placement="inside" name="tutorialFile" id="tutorialFile"/>
                            <g:submitButton class="btn btn-success" name="Upload"/>
                        </g:form>
                        <div>
                            <br/>
                            <g:message code="admin.tutorial_management.upload_new.description1"/>
                            <br>
                            <g:message code="admin.tutorial_management.upload_new.description2"/>
                        </div>
                    </div>

                    <h3><g:message code="admin.tutorial_management.tutorial_files"/></h3>
                    <div class="table-responsive">
                        <table class="table table-hover table-striped">
                            <thead>
                            <tr>
                                <th><g:message code="admin.tutorial_management.name"/></th>
                                <th><g:message code="admin.tutorial_management.link"/></th>
                                <th class="col-md-2 text-center"><g:message code="admin.tutorial_management.actions"/></th>
                            </tr>
                            </thead>
                            <g:each in="${tutorials}" var="tute">
                                <tr>
                                    <td>${tute.name}</td>
                                    <td><a href="${tute.url}">${tute.url}</a></td>
                                    <td class="text-center">
                                        <button class="btn btn-sm btn-default btnRenameTutorial" tutorial="${tute.name}"><g:message code="admin.tutorial_management.rename"/></button>
                                        <button class="btn btn-sm btn-danger btnDeleteTutorial"
                                                tutorial="${tute.name}"><g:message code="admin.tutorial_management.delete"/></button>
                                    </td>
                                </tr>
                            </g:each>
                        </table>
                    </div>

                    <div>
                        <g:message code="admin.tutorial_management.warning"/>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- Modal -->
<div class="modal fade" id="renameDialog" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h4><g:message code="admin.tutorial_management.rename_tutorial"/></h4>
            </div>
            <div class="modal-body">
                <div class="form-horizontal">
                    <div class="form-group">
                        <label class="control-label col-md-2" for="oldName"><g:message code="admin.tutorial_management.old_name"/></label>
                        <div class="col-md-10">
                            <g:textField name="oldName" disabled="true" class="form-control"/>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="control-label col-md-2" for="oldName"><g:message code="admin.tutorial_management.new_name"/></label>
                        <div class="col-md-10">
                            <g:textField name="newName" class="form-control"/>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-default" id="btnCancelRename"><g:message code="admin.tutorial_management.cancel"/></button>
                <button class="btn btn-primary" id="btnApplyRename"><g:message code="admin.tutorial_management.rename"/></button>
            </div>
        </div>
    </div>
</div>
<asset:javascript src="bootstrap-file-input" asset-defer=""/>
<asset:javascript src="bootbox" asset-defer=""/>
<asset:script type='text/javascript'>

    $(function() {

        //$( "#dialog" ).dialog({
        //    minHeight: 200,
        //    minWidth: 500,
        //    resizable: false,
        //    autoOpen: false
        //});

        $(".btnDeleteTutorial").click(function(e) {
            e.preventDefault();
            var name = $(this).attr("tutorial");
            var self = this;
            bootbox.confirm("Are you sure?", function (result) {
                _result = result;
                if(result) {
                   name = escape(name);
                   window.location = "${createLink(controller: 'admin', action: 'deleteTutorial')}?tutorialFile=" + name;
                }
            });
        });

        $(".btnRenameTutorial").click(function(e) {
            e.preventDefault();
            var name = $(this).attr("tutorial");
            $("#oldName").val(name);
            $("#newName").val(name);
            $( "#renameDialog" ).modal( "show" );
        });

        $("#btnCancelRename").click(function(e) {
            e.preventDefault();
            $( "#renameDialog" ).modal( "hide" );
        });

        $("#btnApplyRename").click(function(e) {
            e.preventDefault();
            var oldName = $("#oldName").val();
            var newName = $("#newName").val();
            if (oldName && newName) {
                oldName = escape(oldName);
                newName = escape(newName);
                window.location = "${createLink(controller: 'admin', action: 'renameTutorial')}?tutorialFile=" + oldName + "&newName=" + newName;
            }
        });

        // Initialize input type file
        $('input[type=file]').bootstrapFileInput();

    });

</asset:script>
</body>
</html>
