<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="au.org.ala.volunteer.Project; au.org.ala.volunteer.Picklist" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'picklist.label', default: 'Picklist')}"/>
    <title><g:message code="default.list.label" args="[entityName]"/></title>
</head>

<body class="admin">
<div class="container">
    <cl:headerContent title="${message(code: 'default.picklists.label', default: 'Manage Picklists')}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')]
            ]
        %>
    </cl:headerContent>
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <g:form method="post" class="form-horizontal" name="picklist-form">

                        <g:hiddenField name="id" value="${params.id}"/>

                        <div class="form-group">
                            <label class="col-md-2 control-label" for="picklistId"><g:message code="picklist.picklists"/></label>

                            <div class="col-md-4">
                                <g:select name="picklistId" class="form-control" from="${picklistInstanceList}" optionKey="id" optionValue="uiLabel"
                                          value="${params.picklistId}"/>
                            </div>
                            <div class="col-md-6">
                                <a class="btn btn-default"
                                   href="${createLink(controller: 'picklist', action: 'create')}"><g:message code="picklist.create"/></a>
                                <a class="btn btn-default"
                                   href="${createLink(controller: 'picklist', action: 'list')}"><g:message code="picklist.show_all"/></a>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-2" for="institutionCode"><g:message code="picklist.collection_code"/></label>

                            <div class="col-md-4">
                                <g:select name="institutionCode" class="form-control" from="${collectionCodes}" value="${institutionCode}"/>
                            </div>
                            <div class="col-md-6">
                                <button id="btnAddCollectionCode" type="button" class="btn btn-success"><i
                                        class="icon-plus icon-white"></i>&nbsp;<g:message code="picklist.add_collection_code"/></button>
                                <g:actionSubmit class="btn btn-default" name="download.picklist"
                                                value="${message(code: 'download.picklist.label', default: 'Download items as CSV')}"
                                                action="download"/>
                                <g:actionSubmit class="btn btn-default" name="load.textarea"
                                                value="${message(code: 'loadtextarea.label', default: 'Load items into text area')}"
                                                action="loadcsv"/>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="control-label col-md-2" for="picklist">
                                <g:message code="picklist.csv_list.label"
                                           default="CSV List"/>
                            </label>
                            <div class="col-md-8">
                                <g:textArea class="input-block-level form-control" name="picklist" rows="25" cols="40" value="${picklistData}"/>
                                <span class="help-block"><g:message code="picklist.paste_csv_list"/></span>
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-md-offset-2 col-md-10">
                                <g:actionSubmit id="upload-picklist-button"
                                                disabled="${(picklistData?.getBytes('UTF-8')?.length ?: 0) > (grailsApplication.config.bvp.maxPostSize ?: 2097152)}"
                                                class="btn btn-primary" name="upload.picklist"
                                                value="${message(code: 'upload.picklist.label', default: 'Upload')}"
                                                action="uploadCsvData"/>
                                <a href="#picklistModal" id="upload-picklist-file" role="button" class="btn btn-default"
                                   data-toggle="modal">${message(code: 'upload.bulkpicklist.label', default: 'Upload CSV File')}</a>
                                <button id="sort-button" type="button" class="btn btn-default" title="Sort list"><i class="fa fa-arrow-down"></i>
                                </button>
                                <button id="reverse-button" type="button" class="btn btn-default" title="${message(code:'picklist.reverse_order')}"><i
                                        class="fa fa-refresh"></i></button>
                            </div>
                        </div>
                    %{--<g:link elementId="img-picklist-button" class="btn btn-link" controller="picklist" action="images"><g:message code="picklist.button.view.as.images" default="View as images"/></g:link>--}%
                    </g:form>

                </div>
            </div>
        </div>
    </div>

    <!-- Upload Picklist File Modal -->
    <div id="picklistModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="picklistModalLabel"
         aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <g:uploadForm class="form-horizontal" action="uploadCsvFile">
                    <g:hiddenField name="id" value="${params.id}"/>
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>

                        <h3 id="picklistModalLabel"><g:message code="picklist.upload_picklist_file"/></h3>
                    </div>

                    <div class="modal-body">

                        <div class="form-group">
                            <label class="control-label col-md-3" for="upPicklistId"><g:message code="picklist.picklists"/></label>

                            <div class="col-md-6">
                                <g:select id="upPicklistId" class="form-control" name="picklistId" from="${picklistInstanceList}" optionKey="id"
                                          optionValue="uiLabel" value="${params.picklistId}"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="upInstitutionCode"><g:message code="picklist.collection_code"/></label>

                            <div class="col-md-6">
                                <g:select id="upInstitutionCode" class="form-control" name="institutionCode" from="${collectionCodes}"
                                          value="${institutionCode}"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-3" for="picklistFile"><g:message code="picklist.picklist_file"/></label>

                            <div class="col-md-6">
                                <input type="file" data-filename-placement="inside" id="picklistFile" name="picklistFile"/>
                            </div>
                        </div>
                    </div>

                    <div class="modal-footer">
                        <button class="btn btn-default" data-dismiss="modal" aria-hidden="true"><g:message code="default.close"/></button>
                        <input class="btn btn-primary" type="submit"/>
                    </div>
                </g:uploadForm>
            </div>
        </div>
    </div>
</div>
<asset:javascript src="underscore" asset-defer="" />
<asset:javascript src="bootstrap-file-input" asset-defer=""/>
<asset:script type="text/javascript">

            $(document).ready(function() {

                $("#btnAddCollectionCode").click(function(e) {
                    e.preventDefault();
                    bvp.newCollectionCode = "";
                    bvp.showModal({
                        title:'Create picklist collection code',
                        url: "addCollectionCodeFragment",
                        onClose: function() {
                            if (bvp.newCollectionCode) {
                                // Add item to list...
                                var select = $("#institutionCode, #upInstitutionCode");
                                select.append(
                                    $('<option></option>').val(bvp.newCollectionCode).html(bvp.newCollectionCode)
                                );
                                select.val(bvp.newCollectionCode);
                            }
                        }
                    });
                });

                $('#upload-picklist-file').click(function(e) {
                    var modal = $('#picklistModal');
                    var form = $('#picklist-form');
                    modal.find('#upPicklistId').val(form.find('#picklistId').val());
                    modal.find('#upInstitutionCode').val(form.find('#institutionCode').val());
                });

                var maxSize = ${grailsApplication.config.bvp.maxPostSize ?: 2097152};
                var imageLink = "${createLink(controller: 'picklist', action: 'images')}";
                $('#picklist').change(function(e) {
                    var $this = $(this);
                    var pl = $('#upload-picklist-button');
                    var disabled = pl.prop('disabled');
                    var shouldDisable = byteLength($(e.target).val()) > maxSize;
                    if (disabled != shouldDisable) pl.prop('disabled', shouldDisable);
                });

                $('#picklistId').change(function(e) {
                  var $this = $(this);
                  $('#img-picklist-button').prop('href', imageLink+'/'+$this.val());
                });

                $('#sort-button').click(function() {
                    var $picklist = $('#picklist');
                    // detect field char
                    var fc = $picklist.val().trim().charAt(0);
                    var ifn = (fc == '"' || fc == "'") ? function(s) { return s.indexOf(fc, 1); } : function(s) { return 0; };
                    //var lines = _.sortBy(_.compact($picklist.val().split(/\r?\n/)), function(v) { return v.substring(1, ifn(v)); });
                    var lines = _.chain($picklist.val().split(/\r?\n/)).compact().sortBy(function(v) { return v.substring(1, ifn(v)); });
                    $picklist.val(lines.join('\n'));
                });

                $('#reverse-button').click(function() {
                    var $picklist = $('#picklist');
                    var lines = _.compact($picklist.val().split(/\r?\n/).reverse());
                    $picklist.val(lines.join('\n'));
                });
            });

            function byteLength(str) {
                // returns the byte length of an UTF-8 string
                var s = str.length;
                for (var i=str.length-1; i>=0; i--) {
                    var code = str.charCodeAt(i);
                    if (code > 0x7f && code <= 0x7ff) s++;
                    else if (code > 0x7ff && code <= 0xffff) s+=2;
                    if (code >= 0xDC00 && code <= 0xDFFF) i--; //trail surrogate
                }
                return s;
            }

            // Initialize input type file
            $('input[type=file]').bootstrapFileInput();

</asset:script>
</body>
</html>
