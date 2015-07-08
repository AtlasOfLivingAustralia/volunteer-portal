<%@ page import="au.org.ala.volunteer.ValidationType; au.org.ala.volunteer.ValidationRule; au.org.ala.volunteer.Template; au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Picklist" %>
<%@ page import="au.org.ala.volunteer.PicklistItem" %>
<%@ page import="au.org.ala.volunteer.TemplateField" %>
<%@ page import="au.org.ala.volunteer.field.*" %>
<%@ page import="au.org.ala.volunteer.FieldCategory" %>
<%@ page import="au.org.ala.volunteer.DarwinCoreField" %>
<%@ page contentType="text/html; UTF-8" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <meta name="viewport" content="initial-scale=1.0, user-scalable=no"/>
        <title>${(validator) ? 'Validate' : 'Transcribe'} Task ${taskInstance?.id} : ${taskInstance?.project?.name}</title>
        <script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.4&sensor=false"></script>
        <r:require module="bootstrap-js" />
        <r:require module="panZoom" />
        <r:require module="jqZoom" />
        <r:require module="imageViewer" />
        <r:require module="transcribeWidgets" />
        <r:require module="amplify" />

        <r:script>

            // global Object
            var VP_CONF = {
                taskId: "${taskInstance?.id}",
                picklistAutocompleteUrl: "${createLink(action:'autocomplete', controller:'picklistItem')}",
                updatePicklistUrl: "${createLink(controller:'picklistItem', action:'updateLocality')}",
                nextTaskUrl: "${createLink(controller:(validator) ? "validate" : "transcribe", action:'showNextFromProject', id:taskInstance?.project?.id)}",
                isReadonly: "${isReadonly}",
                isValid: ${(taskInstance?.isValid) ? "true" : "false"}
            };

            <g:if test="${complete}">
                amplify.store("bvp_task_${complete}", null);
            </g:if>

            $(document).ready(function () {

                jQuery.fn.extend({

                    insertAtCaret: function(myValue) {

                        return this.each(function(i) {
                            if (document.selection) {
                                //For browsers like Internet Explorer
                                this.focus();
                                var sel = document.selection.createRange();
                                sel.text = myValue;
                                this.focus();
                            } else if (this.selectionStart || this.selectionStart == '0') {
                                //For browsers like Firefox and Webkit based
                                var startPos = this.selectionStart;
                                var endPos = this.selectionEnd;
                                var scrollTop = this.scrollTop;
                                this.value = this.value.substring(0, startPos)+myValue+this.value.substring(endPos,this.value.length);
                                this.focus();
                                this.selectionStart = startPos + myValue.length;
                                this.selectionEnd = startPos + myValue.length;
                                this.scrollTop = scrollTop;
                            } else {
                                this.value += myValue;
                                this.focus();
                            }
                        });
                    }
                });

                $(".transcribeForm").submit(function(eventObj) {
                    if (!transcribeWidgets.evaluateBeforeSubmitHooks(eventObj)) {
                      return false;
                    }

                    transcribeWidgets.prepareFieldWidgetsForSubmission();

                    return true;
                });


                // display previous journal page in new window
                $("#showPreviousJournalPage").click(function(e) {
                    e.preventDefault();
                    <g:if test="${prevTask}">
                        var uri = "${createLink(controller: 'task', action:'showImage', id: prevTask.id)}"
                        newwindow = window.open(uri,'journalWindow','directories=no,titlebar=no,toolbar=no,location=no,status=no,menubar=no,height=600,width=1000');
                        if (window.focus) {
                            newwindow.focus()
                        }
                    </g:if>
                });

                // display next journal page in new window
                $("#showNextJournalPage").click(function(e) {
                    e.preventDefault();
                    <g:if test="${nextTask}">
                        var uri = "${createLink(controller: 'task', action:'showImage', id: nextTask.id)}"
                        newwindow = window.open(uri,'journalWindow','directories=no,titlebar=no,toolbar=no,location=no,status=no,menubar=no,height=600,width=1000');
                        if (window.focus) {
                            newwindow.focus()
                        }
                    </g:if>
                });

                $("#rotateImage").click(function(e) {
                    e.preventDefault();
                    rotateImage();
                });

                $(".btnCopyFromPreviousTask").click(function(e) {
                    e.preventDefault();
                    showPreviousTaskBrowser();
                });

                $("#btnGeolocate").click(function(e) {
                    e.preventDefault();
                    showGeolocationTool();
                });

                $("#showImageWindow").click(function(e) {
                    e.preventDefault();
                    window.open("${createLink(controller:'task', action:"showImage", id:taskInstance.id)}", "imageViewer", 'directories=no,titlebar=no,toolbar=no,location=no,status=no,menubar=no,height=600,width=600');
                });

                suppressReturnKey();
                bindAutocomplete();
                bindSymbolButtons();
                bvp.bindTooltips();
                bvp.disableBackspace();
                bindShrinkExpandLinks();
                setupPanZoom();
                applyReadOnlyIfRequired();
                insertCoordinateSymbolButtons();
                bindGlobalKeyHandlers();
                transcribeWidgets.initializeTranscribeWidgets();

            }); // end Document.ready

            function suppressReturnKey() {
                $('input,select').keypress(function(event) {
                    return event.keyCode != 13;
                });
            }

            function bindGlobalKeyHandlers() {

                $(document).keypress(function(event) {
                    if ((event.which == 115 || event.which == 19) && event.ctrlKey && event.shiftKey) {
                        submitFormWithAction("${createLink(controller:'transcribe', action:'save')}");
                        e.preventDefault();
                    }
                    return true;
                });

            }

            function insertCoordinateSymbolButtons() {
                // Add clickable icons for deg, min sec in lat/lng inputs
                var title = "Click to insert this symbol";
                var icons = " symbols: <span class='coordsIcons'>" +
                        "<a href='#' title='" + title + "' class='&deg;'>&deg;</a>&nbsp;" +
                        "<a href='#' title='" + title + "' class='&#39;'>&#39;</a>&nbsp;" +
                        "<a href='#' title='" + title + "' class='&quot;'>&quot;</a></span>";
                $(":input.verbatimLatitude, :input.verbatimLongitude").each(function() {
                    $(this).css('width', '140px');
                    $(this).after(icons);
                });

                // Bind an event handler to each button to insert the correct symbol
                $(".coordsIcons a").click(function(e) {
                    e.preventDefault();
                    var input = $(this).parent().prev(':input');
                    var text = $(input).val();
                    var char = $(this).attr('class');
                    $(input).val(text + char);
                    $(input).focus();
                });

            }

            function applyReadOnlyIfRequired() {
                <g:if test="${isReadonly}">
                $(":input").not('.skip,.comment-control :input').hover(function(e){alert('You do not have permission to edit this task.')}).attr('disabled','disabled').attr('readonly','readonly');
                </g:if>
            }

            function showGeolocationTool() {
                bvp.showModal({
                    url: "${createLink(controller: 'transcribe', action:'geolocationToolFragment')}",
                    width: 978,
                    height: 500,
                    hideHeader: true,
                    title: ''
                });
            }

            function showPreviousTaskBrowser() {

                bvp.showModal({
                    url: "${createLink(controller: 'task', action:'taskBrowserFragment', params: [projectId: taskInstance?.project?.id, taskId: taskInstance?.id])}",
                    width:700,
                    height:600,
                    hideHeader: false,
                    title: 'Previously transcribed tasks'
                });

            }

            function bindShrinkExpandLinks() {

                $(".closeSectionLink").click(function (e) {
                    e.preventDefault();
                    var body = $(this).closest(".transcribeSection").find(".transcribeSectionBody");
                    if (body) {
                        if (body.css('display') == 'none') {
                            body.css('display', 'block');
                            $(this).text("Shrink")
                        } else {
                            body.css('display', 'none');
                            $(this).text("Expand")
                        }
                    }
                });
            }

            function bindSymbolButtons() {

                var selector = $(".insert-symbol-button");

                selector.each(function (index) {
                    $(this).html($(this).attr("symbol"));
                    $(this).attr("tabindex", "-1");
                }).click(function (e) {
                    e.preventDefault();
                    var input = $("#recordValues\\.0\\.occurrenceRemarks");
                    $(input).insertAtCaret($(this).attr('symbol'));
                    $(input).focus();
                }).keypress(function(event) {
                    return event.keyCode != 13;
                });

            }

            function bindAutocomplete() {

                $("input.autocomplete,textarea.autocomplete").not('.noAutoComplete').each(function(index) {

                    var inputElement = $(this);
                    var picklistId = inputElement.data('picklist-id');
                    var matches = $(inputElement).attr("id").match(/^recordValues[.](\d+)[.](\w+)$/);
                    if (picklistId || matches.length > 1) {
                        var fieldName = matches[2];
                        var fieldIndex = matches[1];

                        var picklist = picklistId ? "&picklistId=" + picklistId : "&picklist=" + fieldName

                        var autoCompleteOptions = {
                            disabled: false,
                            minLength: 2,
                            delay: 200,
                            select: function(event, ui) {
                                var item = ui.item.data;

                                if (fieldName == 'recordedBy') {
                                    var matches = $(this).attr("id").match(/^recordValues[.](\d+)[.]recordedBy$/);
                                    if (matches.length > 0) {
                                        var recordIdx = matches[1];
                                        var elemSelector = '#recordValues\\.' + recordIdx + '\\.recordedByID';
                                        $(elemSelector).val(item.key).attr('collector_name', item.name);;
                                    }
                                }
                            },
                            source: function(request, response) {
                                var url = VP_CONF.picklistAutocompleteUrl + "?taskId=${taskInstance.id}" + picklist + "&q=" + request.term;
                                $.ajax(url).done(function(data) {
                                    var rows = new Array();
                                    if (data.autoCompleteList) {
                                        var list = data.autoCompleteList;
                                        for (var i = 0; i < list.length; i++) {
                                            rows[i] = {
                                                value: list[i].name,
                                                label: list[i].name,
                                                data: list[i]
                                            };
                                        }
                                    }
                                    if (response) {
                                        response(rows);
                                    }
                                });
                            }
                        };
                        inputElement.autocomplete(autoCompleteOptions);
                    }
                });

                $("input.recordedBy").blur(function(e) {
                    // If the value of the recordedBy field does not match the name in the collector_name attribute
                    // of the recordedByID element it means that the collector name no longer matches the id, so the id
                    // must be cleared.
                    var matches = $(this).attr("id").match(/^recordValues[.](\d+)[.]recordedBy$/);
                    var value = $(this).val();
                    if (matches.length > 0) {
                        var recordIdx = matches[1]
                        var elemSelector = '#recordValues\\.' + recordIdx + '\\.recordedByID'
                        var collectorName = $(elemSelector).attr("collector_name");
                        if (value != collectorName) {
                            $(elemSelector).val('');
                            $(elemSelector).attr("collector_name", "");
                        }
                    }
                });

            }

            function disableSection(classSelector) {
                $(classSelector + " :input").attr("disabled", "true");
                $(classSelector).css("opacity", "0.5");
            }

            function enableSection(classSelector) {
                $(classSelector + " :input").removeAttr("disabled");
                $(classSelector).css("opacity", "1");
            }

            function setFieldValue(fieldName, value) {
                var id = "recordValues\\.0\\." + fieldName;
                $("#" + id).val(value);
            }

            function getFieldValue(fieldName) {
                var id = "recordValues\\.0\\." + fieldName;
                return $("#" + id).val();
            }

            var imageRotation = 0;

            function rotateImage() {
                var image = $("#image-container img")
                if (image) {
                    imageRotation += 90;
                    if (imageRotation >= 360) {
                        imageRotation = 0;
                    }

                    var height = $("#image-container").height();

                    $.ajax("${createLink(controller:'transcribe', action:'imageViewerFragment', params:[multimediaId:taskInstance.multimedia?.first()?.id])}&height=" + height +"&rotate=" + imageRotation).done(function(html) {
                        $("#image-parent-container").replaceWith(html);
                        setupPanZoom();
                    });

                }
            }

        </r:script>

        <style type="text/css">

            .row-fluid input[type="text"] {
               height: 12px;
               font-size: 12px;
               line-height: 12px;
               margin-bottom: 2px;
               padding: 1px;
               /*border-radius:2px;*/
               min-height: 24px;
            }

            .row-fluid textarea {
                font-size: 12px;
                line-height: 12px;
                margin-bottom: 2px;
                padding: 2px;
                /*border-radius:2px;*/
                min-height: 24px;
            }

            .row-fluid [class*=span] select {
                height: 24px;
                font-size: 12px;
                line-height: 12px;
                margin-bottom: 2px;
                padding: 1px;
                /*border-radius:2px;*/
                min-height: 24px;
            }

            .ui-state-hover, .ui-widget-content .ui-state-hover {
                border: none;
            }

            #image-container, #image-parent-container {
                background-color: #a9a9a9;
            }

            .insert-symbol-button {
                font-family: courier;
                color: #DDDDDD;
                background: #4075C2;
                -moz-border-radius: 4px;
                -webkit-border-radius: 4px;
                -o-border-radius: 4px;
                -icab-border-radius: 4px;
                -khtml-border-radius: 4px;
                border-radius: 4px;
            }

            .insert-symbol-button:hover {
                background: #0046AD;
                color: #DDDDDD;
            }

            #collectionEventFields table tr.columnLayout {
                width: 450px;
                min-height: 34px;
                float: left;
            }

            #taskMetadata h3 {
                margin-bottom: 0;
                margin-top: 0;
            }

            #taskMetadata ul {
                margin:0;
                padding:0;
            }

            #taskMetadata ul li {
                list-style: none;
                margin:0;
                padding:0;
            }

            #taskMetadata .metaDataLabel {
                font-weight: bold;
            }

            .transcribeSectionBody select {
                margin-bottom: 10px;
            }

            .transcribeSectionBody {
                border-top: 1px solid #d3d3d3;
                padding-top: 10px;
            }

            .transcribeSectionHeaderLabel {
                font-weight: bold;
            }

            .prop .name {
                vertical-align: top;
            }

            .closeSectionLink {
                float: right;
            }

            .radio-item input {
                margin: 0;
                /*vertical-align: middle;*/
            }

            /* Mapping tool (popup) */

            div#mapWidgets {
                width: 950px;
                height: 500px;
                overflow: hidden;
            }

            #mapWidgets img {
                max-width: none !important;
            }

            #mapWidgets #mapWrapper {

                width: 500px;
                height: 500px;
                float: left;
                padding-right: 10px;
            }

            #mapWidgets #mapCanvas {
                width: 500px;
                height: 500px;
                /*// height: 94%;*/
                margin-bottom: 6px;
            }

            #mapWidgets #mapInfo {
                float: left;
                height: 100%;
                width: 44%;
                padding: 0 0 0 10px;
                text-align: left;
                border-left: 2px solid #cccccc;
            }

            #mapWidgets #sightingAddress {
                margin-bottom: 4px;
                line-height: 22px;
            }

            #mapWidgets .searchHint {
                font-size: 12px;
                padding: 4px 0;
                line-height: 1.2em;
                color: #666;
            }

            #mapWidgets #address {
                width: 360px;
            }

            span.coordsIcons {
                height: 18px;
            }
            span.coordsIcons a {
                display: inline-block;
                width: 10px;
                text-align: center;
                font-size: 20px;
                line-height: 13px;
                text-decoration: none;
                color: #DDDDDD;
                background-color: #4075C2;
                padding: 4px 2px 0 2px;
                -moz-border-radius: 4px;
                -webkit-border-radius: 4px;
                -o-border-radius: 4px;
                -icab-border-radius: 4px;
                -khtml-border-radius: 4px;
                border-radius: 4px;
            }

            span.coordsIcons a:hover {
                background-color: #0046AD;
            }

            .row-fluid select {
                margin-bottom: 6px;
            }

            <g:if test="${taskInstance.project.institution}">
                <cl:ifInstitutionHasBanner institution="${taskInstance.project.institution}">
                #page-header {
                    background-image: url(<cl:institutionBannerUrl id="${taskInstance.project.institution.id}" />);
                }
                </cl:ifInstitutionHasBanner>
            </g:if>


        </style>

    </head>

    <body>

        <cl:headerContent title="${(validator) ? 'Validate' : 'Transcribe'} Task ${taskInstance?.externalIdentifier}" hideTitle="${true}">
            <%
                def crumbs = []
                if (taskInstance.project.institution) {
                    crumbs << [link: createLink(controller:'institution', action: 'index', id:taskInstance.project.institution.id), label: taskInstance.project.institution.name]
                } else {
                    crumbs << [link: createLink(controller: 'project', action: 'list'), label: message(code: 'default.expeditions.label', default: 'Expeditions')]
                }
                crumbs << [link: createLink(controller: 'project', action: 'index', id:taskInstance?.project?.id), label: taskInstance?.project.featuredLabel]

                pageScope.crumbs = crumbs
            %>

            <div>
                <g:if test="${sequenceNumber >= 0}">
                    <span>Image sequence number: ${sequenceNumber}</span>
                </g:if>
                <cl:ifAdmin>
                    <a href="${createLink(controller:'task', action:'showDetails', id:taskInstance?.id)}" class="btn btn-small btn-info pull-right">View Details</a>
                </cl:ifAdmin>
            </div>

        </cl:headerContent>

        <div class="row">
            <div class="span12">
                <g:hasErrors bean="${taskInstance}">
                    <div class="errors">
                        There was a problem saving your edit: <g:renderErrors bean="${taskInstance}" as="list"/>
                    </div>
                </g:hasErrors>
            </div>
        </div>
        <g:if test="${taskInstance}">
            <g:form class="transcribeForm">

                <g:hiddenField name="recordId" value="${taskInstance?.id}"/>
                <g:hiddenField name="redirect" value="${params.redirect}"/>
                <g:hiddenField name="id" value="${taskInstance?.id}"/>

                <g:set var="sectionNumber" value="${1}" />

                <g:set var="nextSectionNumber" value="${ { sectionNumber++ } }" />

                <g:render template="/transcribe/${template.viewName}" model="${[taskInstance: taskInstance, recordValues: recordValues, isReadonly: isReadonly, template: template, nextTask: nextTask, prevTask: prevTask, sequenceNumber: sequenceNumber, imageMetaData: imageMetaData]}" />

                <div class="container-fluid">
                    <div class="well well-small transcribeSection">
                        <div class="row-fluid transcribeSectionHeader">
                            <div class="span12">
                                <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}. Notes</span> &nbsp; Record any comments here that may assist in validating this task
                                <a style="float:right" class="closeSectionLink" href="#">Shrink</a>
                            </div>
                        </div>

                        <div class="transcribeSectionBody">
                            <div class="row-fluid">

                                <div class="span6">
                                    <div class="row-fluid">
                                        <div class="span4">
                                            ${(validator) ? 'Transcriber' : 'Your'} Notes
                                        </div>
                                        <div class="span8">
                                            <g:textArea name="recordValues.0.transcriberNotes" value="${recordValues?.get(0)?.transcriberNotes}" id="recordValues.0.transcriberNotes" rows="5" cols="40" class="span12" />
                                        </div>
                                    </div>
                                </div>

                                <div class="span6">
                                    <g:if test="${validator}">
                                        <div class="row-fluid">
                                            <div class="span4">Validator Notes</div>
                                            <div class="span8">
                                                <g:textArea name="recordValues.0.validatorNotes" value="${recordValues?.get(0)?.validatorNotes}" id="recordValues.0.validatorNotes" rows="5" cols="40" class="span12" />
                                            </div>
                                        </div>
                                    </g:if>
                                </div>
                            </div>

                        </div>
                    </div>
                </div>

                <g:if test="${!isReadonly}">
                    <div class="container-fluid">
                        <div class="row-fluid" id="errorMessagesContainer" style="display: none">
                            <div class="alert alert-error">
                                <p class="lead">
                                <strong>Warning!</strong>
                                    There are problems with the field(s) indicated.
                                    Please correct the fields marked in red before proceeding.
                                    <br />
                                    <button id="btnErrorCancelSubmission" class="btn btn-primary">Continue</button>
                                </p>
                            </div>
                        </div>
                        <div class="row-fluid" id="warningMessagesContainer" style="display: none">
                            <div class="alert alert-warning">
                                <p class="lead">
                                <strong>Warning!</strong> There may be some problems with the fields indicated.
                                If you are confident that the data entered accurately reflects the image, then you may continue to submit the record, otherwise please cancel the submission and correct the marked fields.
                                </p>
                                <div>
                                    <g:set var="okCaption" value="It's ok, submit for validation anyway" />
                                    <g:set var="cancelCaption" value="Cancel submission, and let me fix the marked fields" />
                                    <g:if test="${validator}">
                                        <g:set var="okCaption" value="It's ok, mark as valid anyway" />
                                        <g:set var="cancelCaption" value="Cancel validation, and let me fix the marked fields" />
                                    </g:if>
                                    <button id="btnValidateSubmitInvalid" class="btn bvp-submit-button">${okCaption}</button>
                                    <button id="btnWarningCancelSubmission" class="btn btn-primary bvp-submit-button">${cancelCaption}</button>
                                </div>
                            </div>
                        </div>
                        <g:if test="${!template.viewParams.hideDefaultButtons}">
                        <div id="submitButtons" class="row-fluid">
                            <div class="span12">
                                <g:if test="${validator}">
                                    <button type="button" id="btnValidate" class="btn btn-success bvp-submit-button"><i class="icon-ok icon-white"></i>&nbsp;${message(code: 'default.button.validate.label', default: 'Mark as Valid')}</button>
                                    <button type="button" id="btnDontValidate" class="btn btn-danger bvp-submit-button"><i class="icon-remove icon-white"></i>&nbsp;${message(code: 'default.button.dont.validate.label', default: 'Mark as Invalid')}</button>
                                    <button type="button" class="btn" id="showNextFromProject bvp-submit-button">Skip</button>
                                    <vpf:taskTopicButton task="${taskInstance}" class="btn-info"/>
                                    <g:if test="${validator}">
                                        <a href="${createLink(controller: "task", action:"projectAdmin", id:taskInstance?.project?.id, params: params.clone())}" />
                                    </g:if>
                                </g:if>
                                <g:else>
                                    <button type="button" id="btnSave" class="btn btn-primary bvp-submit-button">${message(code: 'default.button.save.label', default: 'Submit for validation')}</button>
                                    <button type="button" id="btnSavePartial" class="btn bvp-submit-button">${message(code: 'default.button.save.partial.label', default: 'Save unfinished record')}</button>
                                    <button type="button" class="btn bvp-submit-button" id="showNextFromProject">Skip</button>
                                    <vpf:taskTopicButton task="${taskInstance}" class="btn-info"/>
                                </g:else>
                            </div>
                        </div>
                        </g:if>

                    </div>
                </g:if>

                <div class="container-fluid">
                    <div class="row-fluid" style="margin-top:10px">
                        <div class="span12">
                            <cl:validationStatus task="${taskInstance}" />
                        </div>
                    </div>
                </div>
            </g:form>
        </g:if>
        <g:else>
            <div class="row">
                <div class="span12">
                    <div class="alert">
                        No tasks loaded for this project !
                    </div>
                </div>
            </div>
        </g:else>
    </body>
    <r:script>

        $(document).ready(function() {

            // prompt user to save if page has been open for too long
            <g:if test="${!isReadonly}">
                var taskLockTimeout = 90 * 60; // Seconds

                window.setTimeout(function() {
                    showTaskTimeoutMessage();
                }, taskLockTimeout * 1000);

                function showTaskTimeoutMessage() {
                    var options = {
                        url: "${createLink(controller:'transcribe', action:'taskLockTimeoutFragment', params:[taskId:taskInstance.id, validator: validator])}",
                        title: 'Task lock will expire soon!',
                        backdrop: 'static',
                        keyboard: false
                    };

                    bvp.showModal(options);
                }

            </g:if>

            var keepAliveInterval = 10; // Minutes
            var intervalSeconds = 60 * keepAliveInterval;

            // Set up the session keep alive
            setInterval(function() {
                $.ajax("${createLink(controller: 'ajax', action:'keepSessionAlive')}").done(function(data) {
                });
            }, intervalSeconds * 1000);

            $("#btnSave").click(function(e) {
                e.preventDefault();
                if (checkValidation()) {
                    submitFormWithAction("${createLink(controller:'transcribe', action:'save', params:[failoverTaskId: taskInstance.id])}");
                }
            });

            $("#btnSavePartial").click(function(e) {
                e.preventDefault();
                submitFormWithAction("${createLink(controller:'transcribe', action:'savePartial', params:[failoverTaskId: taskInstance.id])}");
            });

            $("#btnValidate").click(function(e) {
                e.preventDefault();
                if (checkValidation()) {
                    submitFormWithAction("${createLink(controller:'validate', action:'validate', params:[failoverTaskId: taskInstance.id])}");
                }
            });

            $("#btnDontValidate").click(function(e) {
                e.preventDefault();
                submitFormWithAction("${createLink(controller:'validate', action:'dontValidate', params:[failoverTaskId: taskInstance.id])}");
            });

            $("#btnWarningCancelSubmission").click(function(e) {
                e.preventDefault();
                $("#submitButtons").css("display", "block");
                $('#warningMessagesContainer').css("display", "none");
                $('#errorMessagesContainer').css("display", "none");
            });

            $("#btnErrorCancelSubmission").click(function(e) {
                e.preventDefault();
                $("#submitButtons").css("display", "block");
                $('#warningMessagesContainer').css("display", "none");
                $('#errorMessagesContainer').css("display", "none");
            });

            $("#btnValidateSubmitInvalid").click(function(e) {
                e.preventDefault();
                <g:if test="${validator}">
                    submitFormWithAction("${createLink(controller:'validate', action:'validate')}");
                </g:if>
                <g:else>
                    submitFormWithAction("${createLink(controller:'transcribe', action:'save')}");
                </g:else>

            });

            $("#showNextFromProject").click(function(e) {
                e.preventDefault();
                window.location = "${createLink(controller:(validator) ? "validate" : "transcribe", action:'showNextFromProject', id:taskInstance?.project?.id)}";
            });

            <g:each in="${ValidationRule.list()}" var="rule">
                transcribeValidation.rules.${rule.name} = {
                    test: function(value, element) {
                        <g:if test="${!rule.testEmptyValues}">
                        if (value) {
                        </g:if>
                            var pattern = /${rule.regularExpression}/;
                            return pattern.test(value);
                        <g:if test="${!rule.testEmptyValues}">
                        }
                        return true;
                        </g:if>
                    },
                    message: "${rule.message}",
                    type: "${rule.validationType ?: ValidationType.Warning}"
                };
            </g:each>

            //enableSubmitButtons();

            // Now check if we are have to restore from a save gone wrong...
            checkAndRecoverFromFailedSubmit();

    });


    function saveFormState(action) {
        var dynamicDataSetFieldId = $("#observationFields").attr("entriesFieldId");

        var taskState = {
            action: action,
            taskId: ${taskInstance.id ?: 0},
                dynamicDataSetFieldId: dynamicDataSetFieldId,
                fields: []
            };
            $('[id*="recordValues\\."]').each(function (index, widget) {
                var field = { id: $(widget).attr("id"), value: $(widget).val() };
                taskState.fields.push(field);
        });

        amplify.store("bvp_task_${taskInstance.id ?: 0}", taskState);
    }

    function checkAndRecoverFromFailedSubmit() {
        var lastState = amplify.store("bvp_task_${taskInstance.id ?: 0}");
        if (lastState && lastState.fields) {
            alert("It looks like your session was timed out or prematurely invalidated for some reason. Transcription data will be restored from your last attempt to save this task.");

            // If the form uses the dynamicDataSet template (observation diaries etc), we need to render them correctly first.

            if (lastState.dynamicDataSetFieldId) {
                var numRows = 0;
                for (var fieldIdx in lastState.fields) {
                    var field = lastState.fields[fieldIdx];
                    if (field.id == lastState.dynamicDataSetFieldId) {
                        numRows = parseInt(field.value);
                    }
                }

                if (numRows && addEntry) {
                    for (var i = 0; i < numRows; ++i) {
                        addEntry();
                    }
                }
            }

            for (var i = 0; i < lastState.fields.length; ++i) {
                var field = lastState.fields[i];
                if (field.id) {
                    var key = "#" + field.id.replace(/\./g, '\\.');
                    $(key).val(field.value);
                    $(key).change();
                }
            }
            // Now clear our local store so this message doesn't happen again if the user chooses not to save this time.
            amplify.store("bvp_task_${taskInstance.id ?: 0}", null);
        }
    }

    function submitFormWithAction(action) {
        try {
            disableSubmitButtons();
            var form = $(".transcribeForm");
            // Save the form in local storage (if available). This is so we can restore in case the submission fails for some reason
            saveFormState(action);
            // Now we can attempt the submission
            form.get(0).setAttribute('action', action);
            form.submit();
        } catch(error) {
            enableSubmitButtons();
        }
    }

    function disableSubmitButtons() {
        $(".bvp-submit-button").attr('disabled', 'disabled');
    }

    function enableSubmitButtons() {
        $(".bvp-submit-button").removeAttr('disabled');
    }

    function checkValidation() {

        if (typeof(transcribeBeforeValidation) === "function") {
            transcribeBeforeValidation();
        }

        transcribeWidgets.prepareFieldWidgetsForSubmission();
        var validationResults = transcribeValidation.validateFields()

        if (validationResults.hasErrors) {
            $("#submitButtons").css("display", "none");
            $('#warningMessagesContainer').css("display", "none");
            $('#errorMessagesContainer').css("display", "block");
        } else if (validationResults.hasWarnings) {
            $("#submitButtons").css("display", "none");
            $('#warningMessagesContainer').css("display", "block");
            $('#errorMessagesContainer').css("display", "none");
        }
        return !validationResults.hasWarnings && !validationResults.hasErrors;
    }


    </r:script>
</html>
