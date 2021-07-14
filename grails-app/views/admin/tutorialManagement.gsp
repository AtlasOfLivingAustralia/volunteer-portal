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
                            <label for="tutorialFile"><strong>Upload new tutorial:</strong></label>
                            <input type="file" data-filename-placement="inside" name="tutorialFile" id="tutorialFile"/>
                            <g:submitButton class="btn btn-success" name="Upload"/>
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

                    <div class="row" style="margin-top: 20px;">
                        <div class="col-sm-6">
                            <h3>Tutorial Files</h3>
                            <g:if test="${params.q}">
                                <span class="tag currentFilter">
                                    <span>${params.q}</span>
                                    <a href="?"><i class="remove glyphicon glyphicon-remove-sign glyphicon-white"></i></a>
                                </span>
                            </g:if>
                        </div>

                        <div class="col-sm-6">
                            <div class="custom-search-input body">
                                <div class="input-group">
                                    <input type="text" id="searchbox" class="form-control input-lg" placeholder="Search files"/>
                                    <span class="input-group-btn">
                                        <button id="btnSearch" class="btn btn-info btn-lg" type="button">
                                            <i class="glyphicon glyphicon-search"></i>
                                        </button>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="table-responsive">
                        <table class="table table-hover table-striped">
                            <thead>
                            <tr>
                                <th>Tutorial</th>
                                <th class="col-md-2 text-center">Actions</th>
                            </tr>
                            </thead>
                            <g:each in="${tutorials}" var="tute">
                                <tr>
                                    <td>${tute.name}<br />
                                        <a href="${tute.url}">${tute.url}</a>
                                    </td>
                                    <td class="text-center">
                                        <button class="btn btn-sm btn-default btnRenameTutorial" tutorial="${tute.name}">Rename</button>
                                        <button class="btn btn-sm btn-danger btnDeleteTutorial"
                                                tutorial="${tute.name}">Delete</button>
                                    </td>
                                </tr>
                            </g:each>
                        </table>
                    </div>

                    <div>
                        <strong>Warning!</strong> Renaming tutorial files will break existing links to those files. Make sure you update project links after renaming!
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
                <h4>Rename Tutorial</h4>
            </div>
            <div class="modal-body">
                <div class="form-horizontal">
                    <div class="form-group">
                        <label class="control-label col-md-3" for="oldName">Old Name</label>
                        <div class="col-md-9">
                            <g:textField name="oldName" disabled="true" class="form-control"/>
                        </div>
                    </div>

                    <div class="form-group new-name-grp">
                        <label class="control-label col-md-3" for="oldName">New Name</label>
                        <div class="col-md-9">
                            <g:textField name="newName" title="New Filename (no special characters)" class="form-control"/>
                            <span class="help-block"></span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-default" id="btnCancelRename">Cancel</button>
                <button class="btn btn-primary" id="btnApplyRename">Rename</button>
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
            // Validate input
            const regexp = /^[-._()\]\[\w\s]*$/
            if (!regexp.test(newName)) {
                $('.new-name-grp').addClass('has-error');
                $('.help-block').html('Filename includes disallowed special characters. Allowed chars: a-z, 0-9, -, ., _, +, [, ]');
                return;
            } else if (newName.indexOf('.pdf') < 0) {
                $('.new-name-grp').addClass('has-error');
                $('.help-block').html('Filename does not have a ".pdf" extension.');
                return;
            } else {
                $('.new-name-grp').removeClass('has-error');
                $('.help-block').html('');
            }

            if (oldName && newName) {
                window.location = "${createLink(controller: 'admin', action: 'renameTutorial')}?tutorialFile=" + oldName + "&newName=" + newName;
            }
        });

        // Initialize input type file
        $('input[type=file]').bootstrapFileInput();

        $("#searchbox").keydown(function(e) {
            if (e.keyCode ==13) {
                doSearch();
            }
        });

        $("#btnSearch").click(function(e) {
            e.preventDefault();
            doSearch();
        });

        function doSearch() {
            var q = $("#searchbox").val();
            var url = "${createLink(controller: 'admin', action: 'tutorialManagement')}?q=" + encodeURIComponent(q);
                window.location = url;
        }

    });

</asset:script>
</body>
</html>
