<%@ page import="au.org.ala.volunteer.Template; au.org.ala.volunteer.Task" %>
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
        <r:require module="imageViewerCss" />

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

                $(window).scroll(function (e) {
                    if ($("#floatingImage").is(":visible")) {
                        var parent = $("#floatingImage").parents('.ui-dialog');
                        var position = parent.position();
                        var top = position.top - $(window).scrollTop();
                        if (top < 0) {
                            $("#floatingImage").dialog("option", "position", [position.left, 10]);
                        } else if (top + parent.height() > $(window).height()) {
                            $("#floatingImage").dialog("option", "position", [position.left, $(window).scrollTop() + $(window).height() - (parent.height() + 20) ]);
                        }
                    }
                });

                $("#pinImage").click(function (e) {
                    e.preventDefault();
                    if ($(".pan-image").css("position") == 'fixed') {
                        $(".pan-image").css({"position": "relative", top: 'inherit', left: 'inherit', 'border': 'none' });
                        $(".new-window-control").css({'background-image': "url(${resource(dir:'images', file:'pin-image.png')})"});
                        $(".pan-image a").attr("title", "Fix the image in place in the browser window");
                    } else {
                        $(".pan-image").css({"position": "fixed", top: 10, left: 10, "z-index": 600, 'border': '2px solid #535353' });
                        $(".new-window-control").css("background-image", "url(${resource(dir:'images', file:'unpin-image.png')})");
                        $("#imageContainer").css("background", "darkgray");
                        $(".pan-image a").attr("title", "Return the image to its normal position");
                    }

                });

                // display previous journal page in new window
                $("#showImageButton").click(function (e) {
                    e.preventDefault();
                    var uri = "${createLink(controller: 'task', action:'showImage', id: taskInstance.id)}"
                    newwindow = window.open(uri, 'journalWindow', 'directories=no,titlebar=no,toolbar=no,location=no,status=no,menubar=no,height=600,width=1000');
                    if (window.focus) {
                        newwindow.focus()
                    }
                });

                bindAutocomplete();
                bindSymbolButtons();
                bindTooltips();
                bindShrinkExpandLinks();
                setupPanZoom();
                bindImagePinning();
                applyReadOnlyIfRequired();
                insertCoordinateSymbolButtons();
            });

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
                showModal({
                    url: "${createLink(controller: 'transcribe', action:'geolocationToolFragment')}",
                    width:978,
                    height:520,
                    hideHeader: true,
                    title: '',
                    onShown: function() {
                        initializeGeolocateTool();
                        google.maps.event.trigger(map, "resize");
                    }
                });
            }

            function bindImagePinning() {

                $("#pinImage").click(function (e) {
                    e.preventDefault();
                    if ($("#image-container").css("position") == 'fixed') {
                        $("#image-container").css({"position":"relative", top:'inherit', left:'inherit', 'border':'none' });
                        $(".pin-image-control").css({'background-image':"url(${resource(dir:'images', file:'pin-image.png')})"});
                        $(".pin-image-control a").attr("title", "Fix the image in place in the browser window");
                    } else {
                        $("#image-container").css({"position":"fixed", top:0, left:0, "z-index":600, 'border':'2px solid #535353', 'background':'darkgray' });
                        $(".pin-image-control").css("background-image", "url(${resource(dir:'images', file:'unpin-image.png')})");
                        $(".pin-image-control a").attr("title", "Return the image to its normal position");
                    }
                });

            }

            function setupPanZoom() {
                var target = $("#image-container img");
                if (target.length > 0) {
                    target.panZoom({
                        pan_step:10,
                        zoom_step:10,
                        min_width:200,
                        min_height:200,
                        mousewheel:true,
                        mousewheel_delta:5,
                        'zoomIn':$('#zoomin'),
                        'zoomOut':$('#zoomout'),
                        'panUp':$('#pandown'),
                        'panDown':$('#panup'),
                        'panLeft':$('#panright'),
                        'panRight':$('#panleft')
                    });

                    target.panZoom('fit');
                }
            }

            function showPreviousTaskBrowser() {

                showModal({
                    url: "${createLink(controller: 'task', action:'taskBrowserFragment', params: [projectId: taskInstance.project.id, taskId: taskInstance.id])}",
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

                $(".insert-symbol-button").each(function (index) {
                    $(this).html($(this).attr("symbol"));
                });

                $(".insert-symbol-button").click(function (e) {
                    e.preventDefault();
                    var input = $("#recordValues\\.0\\.occurrenceRemarks");
                    $(input).insertAtCaret($(this).attr('symbol'));
                    $(input).focus();
                });
            }

            function bindTooltips() {
                // Context sensitive help popups
                $("a.fieldHelp").qtip({
                    tip: true,
                    position: {
                        corner: {
                            target: 'topMiddle',
                            tooltip: 'bottomRight'
                        }
                    },
                    style: {
                        width: 400,
                        padding: 8,
                        background: 'white', //'#f0f0f0',
                        color: 'black',
                        textAlign: 'left',
                        border: {
                            width: 4,
                            radius: 5,
                            color: '#E66542'// '#E66542' '#DD3102'
                        },
                        tip: 'bottomRight',
                        name: 'light' // Inherit the rest of the attributes from the preset light style
                    }
                }).bind('click', function(e){ e.preventDefault(); return false; });
            }

            function bindAutocomplete() {

                $("input.recordedBy").not('.noAutoComplete').autocomplete({
                    disabled: false,
                    minLength: 2,
                    delay: 200,
                    select: function(event, ui) {
                        var item = ui.item.data;
                        // There can be multiple collector boxes on a transcribe form, so we need to update the correct collector id...
                        var matches = $(event.currentTarget).attr("id").match(/^recordValues[.](\d+)[.]recordedBy$/);
                        if (matches.length > 0) {
                            var recordIdx = matches[1];
                            var inputField = $('#recordValues\\.' + recordIdx + '\\.recordedByID');
                            if (inputField) {
                                inputField.val(item.key);
                                // We store the collector name in the form attribute so we can compare it on a change event
                                // to see if we need to wipe the collectorId out should the name in the inputfield change
                                inputField.attr('collector_name', item.name);
                            }
                        } else {
                            $(':input.recordedByID').val(item.key);
                        }

                    },
                    source: function(request, response) {
                        $.ajax(VP_CONF.picklistAutocompleteUrl + "?taskId=${taskInstance.id}&picklist=recordedBy&q=" + request.term).done(function(data) {
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
                });

                $("input.recordedBy").change(function(e) {
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

        </r:script>

        <style type="text/css">

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

        </style>

    </head>

    <body>

        <cl:headerContent title="${(validator) ? 'Validate' : 'Transcribe'} Task: ${taskInstance?.project?.name} (ID: ${taskInstance?.externalIdentifier})">
            <%
                pageScope.crumbs = [
                    [link: createLink(controller: 'project', action: 'list'), label: message(code: 'default.expeditions.label', default: 'Expeditions')],
                    [link: createLink(controller: 'project', action: 'index', id:taskInstance?.project?.id), label: taskInstance?.project.featuredLabel]
                ]
            %>

            <div>
                <vpf:taskTopicButton task="${taskInstance}"/>
                <g:if test="${taskInstance?.project?.tutorialLinks}">
                    ${taskInstance.project.tutorialLinks}
                </g:if>
                <g:if test="${sequenceNumber >= 0}">
                    <span>Image sequence number: ${sequenceNumber}</span>
                </g:if>
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
                                            <g:textArea name="recordValues.0.transcriberNotes" value="${recordValues?.get(0)?.transcriberNotes}" id="transcriberNotes" rows="5" cols="40" class="span12" />
                                        </div>
                                    </div>
                                </div>

                                <div class="span6">
                                    <g:if test="${validator}">
                                        <div class="row-fluid">
                                            <div class="span4">Validator Notes</div>
                                            <div class="span8">
                                                <g:textArea name="recordValues.0.validatorNotes" value="${recordValues?.get(0)?.validatorNotes}" id="transcriberNotes" rows="5" cols="40" class="span12" />
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
                        <div class="row-fluid">
                            <div class="span12">
                                <g:hiddenField name="id" value="${taskInstance?.id}"/>
                                <g:if test="${validator}">
                                    <g:actionSubmit class="validate btn btn-small" action="validate" value="${message(code: 'default.button.validate.label', default: 'Validate')}"/>
                                    <g:actionSubmit class="dontValidate btn btn-small" action="dontValidate" value="${message(code: 'default.button.dont.validate.label', default: 'Dont validate')}"/>
                                    <button class="btn btn-small skip" id="showNextFromProject">Skip</button><cl:validationStatus task="${taskInstance}"/>
                                </g:if>
                                <g:else>
                                    <g:actionSubmit class="save btn btn-small" action="save"
                                                                         value="${message(code: 'default.button.save.label', default: 'Submit for validation')}"/>
                                    <g:actionSubmit class="savePartial btn btn-small" action="savePartial"
                                                                         value="${message(code: 'default.button.save.partial.label', default: 'Save unfinished record')}"/>
                                    <cl:isLoggedIn>
                                        <button id="showNextFromProject" class="skip btn btn-small">Skip</button>
                                    </cl:isLoggedIn>
                                </g:else>
                            </div>
                        </div>
                    </div>
                </g:if>

                <cl:timeoutPopup/>

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
        <cl:timeoutPopup/>
        <div id="floatingImage" style="display:none"></div>

    </body>
</html>
