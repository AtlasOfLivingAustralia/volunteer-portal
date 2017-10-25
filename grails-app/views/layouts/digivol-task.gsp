<%@ page contentType="text/html; charset=UTF-8" %>

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
    <meta name="layout" content="digivol-transcribe"/>

    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <title><g:layoutTitle
            default="${cl.pageTitle(title: "${(validator) ? 'Validate' : 'Expedition'} ${taskInstance?.project?.i18nName}")}"/></title>
    <g:set var="shareUrl" value="${g.createLink(absolute: true, action: 'summary', id: taskInstance?.id)}"/>
    <meta property="og:url" content="${shareUrl}"/>
    <meta property="og:type" content="website"/>
    <meta property="og:title" content="${taskInstance?.project?.i18nName} Task Details - ${taskInstance.externalIdentifier}"/>
    %{--<meta property="og:description"   content="Your description" />--}%
    <meta property="og:image" content="${thumbnail}"/>
    <cl:googleMapsScript callback="onGmapsReady"/>
    <asset:stylesheet src="image-viewer"/>
    <asset:stylesheet src="transcribe-widgets"/>
    <g:layoutHead/>

    <style type="text/css">

    .ui-state-hover, .ui-widget-content .ui-state-hover {
        border: none;
    }

    #image-container, #image-parent-container {
        background-color: #a9a9a9;
    }

    #taskMetadata ul {
        margin: 0;
        padding: 0;
    }

    #taskMetadata ul li {
        list-style: none;
        margin: 0;
        padding: 0;
    }

    #taskMetadata .metaDataLabel {
        font-weight: bold;
    }

    .transcribeSectionBody {
        border-top: 1px solid #d3d3d3;
        padding-top: 10px;
    }

    .transcribeSectionHeaderLabel {
        font-weight: bold;
    }

    .closeSectionLink {
        float: right;
    }

    /* Mapping tool (popup) */

    #mapCanvas {
        height: 500px;
    }

    #mapWidgets .searchHint {
        font-size: 12px;
        padding: 4px 0;
        line-height: 1.2em;
        color: #666;
    }

    </style>

</head>

<body>

<section id="transcription-template">
    <div id="page-header" class="row branding-row">
        <div class="col-sm-5">

            <div class="transcription-branding">
                <img src="<g:transcriptionLogoUrl id="${taskInstance?.project?.institution}"/>"
                     class="img-responsive institution-logo-main pull-left">

                <h1><g:link controller="project" action="show"
                            id="${taskInstance?.project?.id}">${taskInstance?.project?.i18nName}</g:link> ${taskInstance?.externalIdentifier}</h1>

                <h2>
                    <g:transcribeSubheadingLine task="${taskInstance}" recordValues="${recordValues}" sequenceNumber="${sequenceNumber}"/>
                    <g:if test="${taskInstance}"><ul class="list-inline" style="display: inline-block;">
                        <li style="vertical-align: top;">
                            <div class="fb-share-button" data-href="${shareUrl}" data-layout="button"
                                 data-mobile-iframe="true"><a class="fb-xfbml-parse-ignore" target="_blank"
                                                              href="https://www.facebook.com/sharer/sharer.php?u=${URLEncoder.encode(shareUrl, 'UTF-8')}&amp;src=sdkpreparse"><g:message
                                        code="task.share"/></a></div>
                        </li>
                        <li style="vertical-align: top;">
                            <a href="https://twitter.com/share" class="twitter-share-button"><g:message
                                    code="task.tweet"/></a> <script>!function (d, s, id) {
                            var js, fjs = d.getElementsByTagName(s)[0],
                                p = /^http:/.test(d.location) ? 'http' : 'https';
                            if (!d.getElementById(id)) {
                                js = d.createElement(s);
                                js.id = id;
                                js.src = p + '://platform.twitter.com/widgets.js';
                                fjs.parentNode.insertBefore(js, fjs);
                            }
                        }(document, 'script', 'twitter-wjs');</script>
                        </li>
                    </ul></g:if>
                </h2>
            </div>

        </div>

        <div class="col-sm-7 col-xs-12 transcription-controls">

            <div class="btn-group" role="group" aria-label="Transcription controls">
                <button type="button" class="btn btn-default" id="showNextFromProject" data-container="body"
                        title="${message(code: 'task.skip_image')}"><g:message
                        code="task.skip"/></button>
                <vpf:taskTopicButton task="${taskInstance}" class="btn btn-default"/>
                <g:link class="btn btn-default" controller="tutorials" action="index" target="_blank"><g:message
                        code="task.view_tutorial"/></g:link>
            </div>

        </div>

    </div>
    <g:hasErrors bean="${taskInstance}">
        <div class="row">
            <div class="col-sm-12">
                <div class="errors">
                    <g:message code="task.error_saving"/> <g:renderErrors
                            bean="${taskInstance}" as="list"/>
                </div>
            </div>
        </div>
    </g:hasErrors>

    <div class="row">
        <g:if test="${taskInstance}">
            <g:form class="transcribeForm col-sm-12">

                <g:hiddenField name="recordId" value="${taskInstance?.id}"/>
                <g:hiddenField name="redirect" value="${params.redirect}"/>
                <g:hiddenField name="id" value="${taskInstance?.id}"/>
                <g:hiddenField name="timeTaken" value="0"/>

                <g:pageProperty name="page.templateView"/>

                <div class="row">
                    <div class="col-sm-12">
                        <div class="panel panel-default transcribeSection">
                            <div class="panel-body">
                                <div class="row transcribeSectionHeader">
                                    <div class="col-sm-12">
                                        <span class="transcribeSectionHeaderLabel"><g:if
                                                test="${!template.viewParams.hideSectionNumbers}"><g:sectionNumber/>.</g:if><g:message
                                                code="task.notes"/></span> &nbsp; <g:message
                                            code="task.notes.description"/>
                                        <a style="float:right" class="closeSectionLink" href="#"><g:message
                                                code="task.shrink"/></a>
                                    </div>
                                </div>

                                <div class="transcribeSectionBody">
                                    <div class="row">

                                        <div class="col-sm-6">
                                            <div class="row">
                                                <div class="col-sm-4">
                                                    ${(validator) ? message(code: 'task.transcriber_notes')  : message ( code : 'task.your_notes' ) }
                                                </div>

                                                <div class="col-sm-8">
                                                    <g:textArea name="recordValues.0.transcriberNotes"
                                                                value="${recordValues?.get(0)?.transcriberNotes}"
                                                                id="recordValues.0.transcriberNotes" rows="5" cols="40"
                                                                class="form-control"/>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="col-sm-6">
                                            <g:if test="${validator}">
                                                <div class="row">
                                                    <div class="col-sm-4"><g:message
                                                            code="task.validator_notes"/></div>

                                                    <div class="col-sm-8">
                                                        <g:textArea name="recordValues.0.validatorNotes"
                                                                    value="${recordValues?.get(0)?.validatorNotes}"
                                                                    id="recordValues.0.validatorNotes" rows="5"
                                                                    cols="40"
                                                                    class="form-control"/>
                                                    </div>
                                                </div>
                                            </g:if>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <g:if test="${!isReadonly}">
                    <g:set var="okCaption"
                           value="${message(code: 'task.submit_anyway')}"/>
                    <g:set var="cancelCaption"
                           value="${message(code: 'task.cancel_submission')}"/>
                    <g:if test="${validator}">
                        <g:set var="okCaption"
                               value="${message(code: 'task.validate_anyway')}"/>
                        <g:set var="cancelCaption"
                               value="${message(code: 'task.cancel_validation')}"/>
                    </g:if>
                    <div class="row" id="errorMessagesContainer" style="display: none">
                        <div class="col-sm-12">
                            <div class="alert alert-danger">
                                <p class="lead">
                                    <strong><g:message code="task.warning"/></strong>
                                    <g:message
                                            code="task.warning.description"/>
                                    <br/>
                                    <button id="btnErrorCancelSubmission"
                                            class="btn btn-primary">${cancelCaption}</button>
                                </p>
                            </div>
                        </div>
                    </div>

                    <div class="row" id="warningMessagesContainer" style="display: none">
                        <div class="col-sm-12">
                            <div class="alert alert-warning">
                                <p class="lead">
                                    <strong><g:message code="task.warning"/></strong>
                                    <g:message
                                            code="task.warning.description2"/>
                                </p>

                                <div>
                                    <button id="btnValidateSubmitInvalid"
                                            class="btn btn-default bvp-submit-button">${okCaption}</button>
                                    <button id="btnWarningCancelSubmission"
                                            class="btn btn-primary bvp-submit-button">${cancelCaption}</button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <g:if test="${!template.viewParams.hideDefaultButtons}">
                        <div id="submitButtons" class="row">
                            <div class="col-sm-12">
                                <g:if test="${validator}">
                                    <button type="button" id="btnValidate" class="btn btn-success bvp-submit-button"><i
                                            class="icon-ok icon-white"></i>&nbsp;${message(code: 'default.button.validate.label', default: 'Mark as Valid')}
                                    </button>
                                    <button type="button" id="btnDontValidate"
                                            class="btn btn-danger bvp-submit-button"><i
                                            class="icon-remove icon-white"></i>&nbsp;${message(code: 'default.button.dont.validate.label', default: 'Mark as Invalid')}
                                    </button>
                                    <button type="button" class="btn btn-default bvp-submit-button"
                                            id="showNextFromProject"><g:message code="task.skip"/></button>
                                    <vpf:taskTopicButton task="${taskInstance}" class="btn-info"/>
                                    <g:if test="${validator}">
                                        <a href="${createLink(controller: "task", action: "projectAdmin", id: taskInstance?.project?.id, params: params.clone())}"/>
                                    </g:if>
                                </g:if>
                                <g:else>
                                    <button type="button" id="btnSave"
                                            class="btn btn-primary bvp-submit-button">${message(code: 'default.button.save.label', default: 'Submit for validation')}</button>
                                    <button type="button" id="btnSavePartial"
                                            class="btn btn-default bvp-submit-button">${message(code: 'default.button.save.partial.label', default: 'Save unfinished record')}</button>
                                    <button type="button" class="btn btn-default bvp-submit-button"
                                            id="showNextFromProject"><g:message code="task.skip"/></button>
                                    <vpf:taskTopicButton task="${taskInstance}" class="btn-info"/>
                                </g:else>
                            </div>
                        </div>
                    </g:if>
                </g:if>

                <div class="container-fluid">
                    <div class="row" style="margin-top:10px">
                        <div class="col-sm-12">
                            <cl:validationStatus task="${taskInstance}"/>
                        </div>
                    </div>
                </div>
            </g:form>
        </g:if>
        <g:else>
            <div class="row">
                <div class="col-sm-12">
                    <div class="alert alert-warning">
                        <g:message code="task.no_tasks_loaded"/>
                    </div>
                </div>
            </div>
        </g:else>
    </div>
</section> %{-- transcription-template --}%


<div id="submitConfirmModal" class="modal fade" tabindex="-1" role="dialog">
    <!-- dialog contents -->
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-body">
                <div class="form-horizontal">
                    <div class="col-sm-12">
                        <p><g:message code="transcribe.task.submit.confirm" default="Submit your selections?"/></p>
                    </div>

                    <div class="form-group">
                        <div class="col-sm-offset-1 col-sm-11">
                            <div class="checkbox">
                                <label>
                                    <input id="submit-dont-confirm" name="dont-confirm" type="checkbox"> <g:message
                                        code="task.dont_ask_me_again"/>
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal-footer">
                <button role="button" id="submit-confirm-cancel" type="button" class="btn btn-link"
                        data-dismiss="modal"><g:message code="default.cancel"/></button>
                <button role="button" id="submit-confirm-ok" type="button" class="btn btn-primary"><g:message
                        code="default.submit"/></button>
            </div>
        </div>
    </div>
</div>

<div id="fb-root"></div>
<asset:script type="text/javascript">(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/en_GB/sdk.js#xfbml=1&version=v2.6";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));</asset:script>
<asset:javascript src="digivol-transcribe" asset-defer=""/>
<asset:script type="text/javascript">

    // global Object
    var VP_CONF = {
        taskId: "${taskInstance?.id}",
                picklistAutocompleteUrl: "${createLink(action: 'autocomplete', controller: 'picklistItem')}",
                updatePicklistUrl: "${createLink(controller: 'picklistItem', action: 'updateLocality')}",
                nextTaskUrl: "${createLink(controller: (validator) ? "validate" : "transcribe", action: 'showNextFromProject', id: taskInstance?.project?.id)}",
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

        setInterval(function() {
          var $tt = $('#timeTaken');
          $tt.val(parseInt($tt.val()) + 1);
        }, 1000);

        $(".transcribeForm").submit(function(eventObj) {
            if (!transcribeWidgets.evaluateBeforeSubmitHooks(eventObj)) {
              return false;
            }

            transcribeWidgets.prepareFieldWidgetsForSubmission();

            // Save the form in local storage (if available). This is so we can restore in case the submission fails for some reason
            saveFormState();

            return true;
        });


        // display previous journal page in new window
        $("#showPreviousJournalPage").click(function(e) {
            e.preventDefault();
    <g:if test="${prevTask}">
        var uri = "${createLink(controller: 'task', action: 'showImage', id: prevTask.id)}"
                        var newwindow = window.open(uri,'journalWindow','directories=no,titlebar=no,toolbar=no,location=no,status=no,menubar=no,height=600,width=1000');
                        if (window.focus) {
                            newwindow.focus()
                        }
    </g:if>
    });

    // display next journal page in new window
    $("#showNextJournalPage").click(function(e) {
        e.preventDefault();
    <g:if test="${nextTask}">
        var uri = "${createLink(controller: 'task', action: 'showImage', id: nextTask.id)}"
                        var newwindow = window.open(uri,'journalWindow','directories=no,titlebar=no,toolbar=no,location=no,status=no,menubar=no,height=600,width=1000');
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
        window.open("${createLink(controller: 'task', action: "showImage", id: taskInstance.id)}", "imageViewer", 'directories=no,titlebar=no,toolbar=no,location=no,status=no,menubar=no,height=600,width=600');
                });

                suppressReturnKey();
                bindAutocomplete();
                bindSymbolButtons();
                bvp.bindTooltips();
                bvp.disableBackspace();
                bindShrinkExpandLinks();
                setupPanZoom();
                applyReadOnlyIfRequired();
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
                        submitFormWithAction("${createLink(controller: 'transcribe', action: 'save')}");
                        e.preventDefault();
                    }
                    return true;
                });

            }

            function applyReadOnlyIfRequired() {
    <g:if test="${isReadonly}">
        $(":input").not('.skip,.comment-control :input').hover(function(e){alert('${message(code: "task.no_permission")}')}).attr('disabled','disabled').attr('readonly','readonly');
    </g:if>
    }

    function showGeolocationTool() {
        bvp.showModal({
            url: "${createLink(controller: 'transcribe', action: 'geolocationToolFragment')}",
                    size: 'large',
                    //height: 500,
                    //hideHeader: true,
                    title: "${message(code:'default.tools.label')}",
                    buttons: {
                      close: {
                        label: "${message(code: 'task.close_and_cancel')}",
                        className: 'btn-default'
                      },
                      copy: {
                        label: '${message(code: "task.copy_values")} <i class="fa fa-check fa-sm"></i>',
                        className: 'btn-primary',
                        callback: function () {
                          setLocationFields(); // via geolocationtoolfragment
                        }
                      }
                    }
                });
            }

            function showPreviousTaskBrowser() {

                bvp.showModal({
                    url: "${raw(createLink(controller: 'task', action: 'taskBrowserFragment', params: [projectId: taskInstance?.project?.id, taskId: taskInstance?.id]))}",
                    width:700,
                    height:600,
                    hideHeader: false,
                    size: 'large',
                    title: '${message(code: 'task.previously_transcribed_tasks')}'
                });

            }

            function bindShrinkExpandLinks() {

                $(".closeSectionLink").click(function (e) {
                    e.preventDefault();
                    var body = $(this).closest(".transcribeSection").find(".transcribeSectionBody");
                    if (body) {
                        if (body.css('display') == 'none') {
                            body.css('display', 'block');
                            $(this).text("${message(code: 'task.shrink')}")
                        } else {
                            body.css('display', 'none');
                            $(this).text("${message(code: 'task.expand')}")
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

            function bindAutocompleteToElement(inputElement) {
                var picklistId = inputElement.data('picklist-id');
                var matches = [];
                var inputElementId = inputElement.attr('id');
                if (inputElementId) {
                    matches = inputElementId.match(/^recordValues[.](\d+)[.](\w+)$/);
                } else if (window.console) {
                    console.warn("Element doesn't have id: ", inputElement);
                }
                if (picklistId || matches.length > 1) {
                    var fieldName = matches[2];
                    var fieldIndex = matches[1];

                    var picklist = picklistId ? "&picklistId=" + picklistId : "&picklist=" + fieldName;

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
            }

            function bindAutocomplete() {

                $("input.autocomplete,textarea.autocomplete").not('.noAutoComplete').each(function(index) {

                    var inputElement = $(this);
                    bindAutocompleteToElement(inputElement);
                });

                $("input.recordedBy").blur(function(e) {
                    i18nName
                    i18nName
                    // must be cleared.
                    var matches = $(this).attr("id").match(/^recordValues[.](\d+)[.]recordedBy$/);
                    var value = $(this).val();
                    if (matches.length > 0) {
                        var recordIdx = matches[1];
                        var elemSelector = '#recordValues\\.' + recordIdx + '\\.recordedByID';
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
                var image = $("#image-container img");
                if (image) {
                    imageRotation += 90;
                    if (imageRotation >= 360) {
                        imageRotation = 0;
                    }

                    var height = $("#image-container").height();

                    $.ajax("${createLink(controller: 'transcribe', action: 'imageViewerFragment', params: [multimediaId: taskInstance.multimedia?.first()?.id])}&height=" + height +"&rotate=" + imageRotation).done(function(html) {
                        $("#image-parent-container").replaceWith(html);
                        setupPanZoom();
                    });

                }
            }

</asset:script>
<asset:script type="text/javascript">

    <g:each in="${ValidationRule.list()}" var="rule">
        transcribeValidation.rules.${rule.name} = {
            test: function(value, element) {
        <g:if test="${!rule.testEmptyValues}">
            if (value) {
        </g:if>
            var pattern = new RegExp($("<div/>").html("${rule.regularExpression}").text());
            return pattern.test(value);
        <g:if test="${!rule.testEmptyValues}">
            }
            return true;
        </g:if>
        },
        message: "${message(code: rule.message)}",
            type: "${rule.validationType ?: ValidationType.Warning}"
        };
    </g:each>

    $(document).ready(function() {

        // prompt user to save if page has been open for too long
    <g:if test="${!isReadonly}">
        var taskLockTimeout = 90 * 60; // Seconds

        window.setTimeout(function() {
            showTaskTimeoutMessage();
        }, taskLockTimeout * 1000);

        function showTaskTimeoutMessage() {
            var options = {
                url: "${createLink(controller: 'transcribe', action: 'taskLockTimeoutFragment', params: [taskId: taskInstance.id, validator: validator])}",
                        title: "${message(code:'digivolTask.task_lock_will_expire_soon')}",
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
        $.ajax("${createLink(controller: 'ajax', action: 'keepSessionAlive')}").done(function(data) { });
        }, intervalSeconds * 1000);

        $("#btnSave").click(function(e) {
            e.preventDefault();
            if (checkValidation()) {
                submitFormWithAction("${createLink(controller: 'transcribe', action: 'save', params: [failoverTaskId: taskInstance.id])}");
            }
        });

        $("#btnSavePartial").click(function(e) {
            e.preventDefault();
            submitFormWithAction("${createLink(controller: 'transcribe', action: 'savePartial', params: [failoverTaskId: taskInstance.id])}");
        });

        $("#btnValidate").click(function(e) {
            e.preventDefault();
            if (checkValidation()) {
                submitFormWithAction("${createLink(controller: 'validate', action: 'validate', params: [failoverTaskId: taskInstance.id])}");
            }
        });

        $("#btnDontValidate").click(function(e) {
            e.preventDefault();
            submitFormWithAction("${createLink(controller: 'validate', action: 'dontValidate', params: [failoverTaskId: taskInstance.id])}");
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
            submitInvalid();
        });

        $("#showNextFromProject, .btn-skip-n").click(function(e) {
            e.preventDefault();
            var skip = $(this).data('skip');
            var url = "${createLink(controller: (validator) ? "validate" : "transcribe", action: 'showNextFromProject', id: taskInstance?.project?.id, params: [prevId: taskInstance?.id])}";
            if (skip) url = url + '&skip='+skip;
            window.location = url;
        });

        //enableSubmitButtons();

        // Now check if we are have to restore from a save gone wrong...
        checkAndRecoverFromFailedSubmit();

    });


    function saveFormState() {
        var dynamicDataSetFieldId = $("#observationFields").attr("entriesFieldId");

        var taskState = {
            action: $(".transcribeForm").attr('action'),
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
            alert("${message(code: 'task.session_invalidated')}");

            // If the form uses the dynamicDataSet template (observation diaries etc), we need to render them correctly first.

            if (lastState.dynamicDataSetFieldId) {
                var numRows = 0;
                for (var fieldIdx in lastState.fields) {
                    var field = lastState.fields[fieldIdx];
                    if (field.id == lastState.dynamicDataSetFieldId) {
                        numRows = parseInt(field.value);
                    }
                }

                if (numRows && typeof addEntry === 'function') {
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


            try {
                // Allow the template a chance to react to recovery as well
                if (recoverFunction && typeof recoverFunction == 'function') {
                    recoverFunction(lastState);
                }

                // Now clear our local store so this message doesn't happen again if the user chooses not to save this time.
                amplify.store("bvp_task_${taskInstance.id ?: 0}", null);
            } catch (e) {
                if (console && console.error) console.error(e);
            }
        }
    }

    function submitInvalid() {
    <g:if test="${validator}">
        submitFormWithAction("${createLink(controller: 'validate', action: 'validate')}");
    </g:if>
    <g:else>
        submitFormWithAction("${createLink(controller: 'transcribe', action: 'save')}");
    </g:else>
    }

    var recoverFunction;

    var submitRequiresConfirmation = false;
    var $submitConfirm = $("#submitConfirmModal");

    $submitConfirm.on("hide", function() {    // remove the event listeners when the dialog is dismissed
        $("#submit-confirm-ok").off("click");
    });

    function submitFormWithAction(action) {
        var dontConfirm = amplify.store("bvp_transcribe_dontconfirm");
        if (submitRequiresConfirmation && !dontConfirm) {
          // capture action in closure so we can invoke the correct doSubmitWithAction
          $("#submit-confirm-ok").on("click", function(e) {
            amplify.store("bvp_transcribe_dontconfirm", $('#submit-dont-confirm').prop('checked'));
            doSubmitWithAction(action);
            $("#submitConfirmModal").modal('hide');     // dismiss the dialog
          });

          $('#submitConfirmModal').modal('show');
        } else {
          doSubmitWithAction(action);
        }
    }

    function doSubmitWithAction(action) {
        try {
            disableSubmitButtons();
            var form = $(".transcribeForm");
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

    var postValidationFunction = function(validationResults) {
        if (validationResults.hasErrors) {
            $("#submitButtons").css("display", "none");
            $('#warningMessagesContainer').css("display", "none");
            $('#errorMessagesContainer').css("display", "block");
        } else if (validationResults.hasWarnings) {
            $("#submitButtons").css("display", "none");
            $('#warningMessagesContainer').css("display", "block");
            $('#errorMessagesContainer').css("display", "none");
        }
    };

    function checkValidation() {

        if (typeof(transcribeBeforeValidation) === "function") {
            transcribeBeforeValidation();
        }

        transcribeWidgets.prepareFieldWidgetsForSubmission();
        var validationResults = transcribeValidation.validateFields()

        postValidationFunction(validationResults);

        return !validationResults.hasWarnings && !validationResults.hasErrors;
    }

</asset:script>
</body>
</html>
