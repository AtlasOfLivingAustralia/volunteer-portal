<%@ page import="au.org.ala.volunteer.Project; au.org.ala.volunteer.Picklist" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'picklist.label', default: 'Picklist')}"/>
        <title><g:message code="default.list.label" args="[entityName]"/></title>
    </head>

    <body>

        <cl:headerContent title="${message(code:'default.picklists.label', default:'Manage Picklists')}">
            <%
                pageScope.crumbs = [
                    [link:createLink(controller:'admin'),label:message(code:'default.admin.label', default:'Admin')]
                ]
            %>
        </cl:headerContent>

        <div class="row">
            <div class="span12">
                <g:form method="post">

                    <g:hiddenField name="id" value="${params.id}" />

                    <div id="picklist-form" class="form-horizontal">
                        <div class="control-group">
                            <label class="control-label" for="picklistId">Picklist</label>
                            <div class="controls">
                                <g:select name="picklistId" from="${picklistInstanceList}" optionKey="id" optionValue="name" value="${params.picklistId}"/>
                                <a class="btn" href="${createLink(controller:'picklist', action:'create')}">Create new picklist</a>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label" for="institutionCode">Collection code:</label>
                            <div class="controls">
                                <g:select name="institutionCode" from="${collectionCodes}" value="${institutionCode}" />
                                %{--<g:textField name="institutionCode" id="institutionCode" value="${institutionCode}"/>--}%
                                <button id="btnAddCollectionCode" type="button" class="btn btn-success"><i class="icon-plus icon-white"></i>&nbsp;Add collection code</button>
                                <g:actionSubmit class="btn" name="download.picklist" value="${message(code: 'download.picklist.label', default: 'Download items as CSV')}" action="download"/>
                                <g:actionSubmit class="btn" name="load.textarea" value="${message(code: 'loadtextarea.label', default: 'Load items into text area')}" action="loadcsv"/>
                                %{--<span>Can be left blank to use default values</span>--}%
                            </div>
                        </div>
                        %{--<div class="control-group">--}%
                        %{--</div>--}%
                    </div>

                    <p>
                        <g:message code="picklist.paste.here.label" default="Paste csv list here. Each line should take the format '&lt;value&gt;'[,&lt;optional key&gt;]"/>
                    </p>
                    <g:textArea class="input-xxlarge" name="picklist" rows="25" cols="40" value="${picklistData}"/>
                    <br>
                    <g:actionSubmit id="upload-picklist-button" disabled="${(picklistData?.getBytes('UTF-8')?.length ?: 0)> (grailsApplication.config.bvp.maxPostSize ?: 2097152)}" class="btn btn-primary" name="upload.picklist" value="${message(code: 'upload.picklist.label', default: 'Upload')}" action="uploadCsvData"/>
                    <a href="#picklistModal" id="upload-picklist-file" role="button" class="btn" data-toggle="modal">${message(code: 'upload.bulkpicklist.label', default: 'Upload CSV File')}</a>
                </g:form>

            </div>
        </div>

    <!-- Upload Picklist File Modal -->
    <div id="picklistModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="picklistModalLabel" aria-hidden="true">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
            <h3 id="picklistModalLabel">Upload picklist file</h3>
        </div>
        <g:uploadForm class="form-horizontal" action="uploadCsvFile">
            <g:hiddenField name="id" value="${params.id}" />
            <div class="modal-body">
                <div class="control-group">
                    <label class="control-label" for="upPicklistId">Picklist</label>
                    <div class="controls">
                        <g:select id="upPicklistId" name="picklistId" from="${picklistInstanceList}" optionKey="id" optionValue="name" value="${params.picklistId}"/>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label" for="upInstitutionCode">Collection Code</label>
                    <div class="controls">
                        <g:select id="upInstitutionCode" name="institutionCode" from="${collectionCodes}" value="${institutionCode}" />
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label" for="picklistFile">Picklist file</label>
                    <div class="controls">
                        <input type="file" id="picklistFile" name="picklistFile" />
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
                <input class="btn btn-primary" type="submit" />
            </div>
        </g:uploadForm>
    </div>

        <r:script>

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
                $('#picklist').change(function(e) {
                    var pl = $('#upload-picklist-button');
                    var disabled = pl.prop('disabled');
                    var shouldDisable = byteLength($(e.target).val()) > maxSize;
                    if (disabled != shouldDisable) pl.prop('disabled', shouldDisable);
                })
            });

            function byteLength(str) {
                // returns the byte length of an utf8 string
                var s = str.length;
                for (var i=str.length-1; i>=0; i--) {
                    var code = str.charCodeAt(i);
                    if (code > 0x7f && code <= 0x7ff) s++;
                    else if (code > 0x7ff && code <= 0xffff) s+=2;
                    if (code >= 0xDC00 && code <= 0xDFFF) i--; //trail surrogate
                }
                return s;
            }

        </r:script>
    </body>
</html>
