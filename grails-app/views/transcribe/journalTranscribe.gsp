<html xmlns="http://www.w3.org/1999/html">
<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Picklist" %>
<%@ page import="au.org.ala.volunteer.PicklistItem" %>
<%@ page import="au.org.ala.volunteer.TemplateField" %>
<%@ page import="au.org.ala.volunteer.field.*" %>
<%@ page import="au.org.ala.volunteer.FieldCategory" %>
<%@ page import="au.org.ala.volunteer.DarwinCoreField" %>

<%@ page contentType="text/html; UTF-8" %>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<meta name="layout" content="${grailsApplication.config.ala.skin}"/>
<meta name="viewport" content="initial-scale=1.0, user-scalable=no"/>
<title>Transcribe Task ${taskInstance?.id} : ${taskInstance?.project?.name}</title>
<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.mousewheel.min.js')}"></script>
<script type="text/javascript" src="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.pack.js')}"></script>
<link rel="stylesheet" href="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.css')}"/>
%{--<script type="text/javascript" src="${resource(dir: 'js', file: 'ui.core.js')}"></script>--}%
%{--<script type="text/javascript" src="${resource(dir: 'js', file: 'ui.datepicker.js')}"></script>--}%
<link rel="stylesheet" href="${resource(dir: 'css/smoothness', file: 'ui.all.css')}"/>
<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.validationEngine.js')}"></script>
<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.validationEngine-en.js')}"></script>
<link rel="stylesheet" href="${resource(dir: 'css', file: 'validationEngine.jquery.css')}"/>
<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.qtip-1.0.0-rc3.min.js')}"></script>
<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.cookie.js')}"></script>
<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.scrollview.js')}"></script>
<script type="text/javascript" src="${resource(dir: 'js', file: 'ScottSisiters.js')}"></script>

<script type="text/javascript">
    // global Object 
    var VP_CONF = {
        isReadonly: "${isReadonly}",
        isValid: ${(taskInstance?.isValid) ? "true" : "false"},
        validator: "${validator}"
    };

    $(document).ready(function() {
        // prompt user to save if page has been open for too long
        if (!VP_CONF.isReadonly && !VP_CONF.validator) {
            var timeoutInMin = 30;
            var message = "Please save your work by clicking the 'save unfinished record' button as it has been " +
                    timeoutInMin + " minutes since the last page refresh.";
            window.setTimeout(function() { alert(message); }, timeoutInMin * 60 * 1000);
        }
        // prevent enter key submitting form
        $(window).keydown(function(event) {
            if (event.keyCode == 13 && event.target.nodeName != "TEXTAREA") {
                event.preventDefault();
                return false;
            }
        });
        // 
        var maxEntries = $("tr.fieldNoteFields").size();
        showHideEntries();
        $(":input#noOfEntries").change(showHideEntries);

        function showHideEntries(e) {
            //e.preventDefault();
            var max = $(":input#noOfEntries").val();
            $("tr.fieldNoteFields").each(function(i, el) {
                if (i > max) {
                    $(el).fadeOut();
                } else {
                    $(el).fadeIn();
                }
            });
        }

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

        $("#showNextFromProject").click(function(e) {
            e.preventDefault();
            location.href = "${createLink(controller:(validator) ? "validate" : "transcribe", action:'showNextFromProject', id:taskInstance?.project?.id)}";
        });

        $("#range").slider({
            min: 50,
            value: 100,
            max: 200,
            slide: function(e, ui) {
                var value = $("#range").slider( "option", "value" );
                $("#journalPageImg").css("width", value + "%");
            }
        });

        // Display painting for a given painting number
        $("#showPainting").click(function(e) {
            e.preventDefault();
            var paintingRef = $(":input#paintingRefNo").val();
            var uri = getSketchUri(paintingRef); 

            if (uri) {
                window.open(uri, "paintingWindow");
            } else {
                alert("There is no painting corresponding to reference number " + paintingRef + ". Not all field notes have a corresponding painting.");
            }
        });

        // display previous journal page in new window
        $("#showPreviousJournalPage").click(function(e) {
            e.preventDefault();
            var uri = showNotebookPage("${taskInstance?.externalIdentifier}", -1);

            if (uri) {
                window.open(uri, "journalWindow");
            } else {
                alert("Previous journal page was not found");
            }
        });

        // display next journal page in new window
        $("#showNextJournalPage").click(function(e) {
            e.preventDefault();
            var uri = showNotebookPage("${taskInstance?.externalIdentifier}", 1);

            if (uri) {
                window.open(uri, "journalWindow");
            } else {
                alert("Next journal page was not found");
            }
        });

        $("#imagePane").scrollview({
            grab:"${resource(dir: 'images', file: 'openhand.cur')}",
            grabbing:"${resource(dir: 'images', file: 'closedhand.cur')}"
        });

        $("#rotateImage").click(function(e) {
          e.preventDefault();
          $("#image_0").toggleClass("rotate-image");
        });

        var isReadonly = VP_CONF.isReadonly;
        if (isReadonly) {
            // readonly more
            $(":input").not('.skip,.comment-control :input').hover(function(e){alert('You do not have permission to edit this task.')}).attr('disabled','disabled').attr('readonly','readonly');
        }

    });

    function zoomJournalImage(event, value) {
        //console.info("value changed to", value);
        $("#journalPageImg").css("width", value + "%");
    }
</script>
%{--<script type="text/javascript" src="${resource(dir: 'js', file: 'journalTranscribe.js')}"></script>--}%
</head>

<body class="sublevel sub-site volunteerportal">

  <cl:navbar selected="expeditions" />

  <header id="page-header">
    <div class="inner">

      <cl:messages />

      <nav id="breadcrumb">
        <ol>
          <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
          <li><a href="${createLink(controller: 'project', action:'list')}"><g:message code="default.projects.label"/></a></li>
          <li><g:link controller="project" action="index" id="${taskInstance?.project?.id}" class="crumb">${taskInstance?.project?.name}</g:link></li>
          <li class="last">${(validator) ? 'Validate' : 'Transcribe'} Task - ${(recordValues?.get(0)?.catalogNumber) ? recordValues?.get(0)?.catalogNumber : taskInstance?.id}</li>
        </ol>
      </nav>
      <hgroup>
        <h1>${(validator) ? 'Validate' : 'Transcribe'} Task: ${taskInstance?.project?.name} (ID: ${taskInstance?.externalIdentifier})</h1>
      </hgroup>
    </div>
  </header>

<div class="inner">
    <g:hasErrors bean="${taskInstance}">
        <div class="errors">
            There was a problem saving your edit: <g:renderErrors bean="${taskInstance}" as="list" />
        </div>
    </g:hasErrors>
    <div id="videoLinks" style="padding-top: 6px; float: right;">
        ${taskInstance?.project?.tutorialLinks}
    </div>

    <g:if test="${taskInstance}">
        <g:form class="transcribeForm">
            <g:hiddenField name="recordId" value="${taskInstance?.id}"/>
            <g:hiddenField name="redirect" value="${params.redirect}"/>
            <div style="float:left;margin-top:5px;">Zoom image:&nbsp;</div>

            <div id="range" style="display: inline-block; width:150px; margin-left: 10px; margin-right: 10px;"></div>

            <span id="journalPageButtons">
                <button id="showPreviousJournalPage" title="displays page in new window">&lt;&ndash; show previous page</button>
                <button id="showNextJournalPage" title="displays page in new window">show next page &ndash;&gt;</button>
                <button id="rotateImage" title="Rotate the page 180 degrees">Rotate&nbsp;<img style="vertical-align: middle; margin: 0 !important;" src="${resource(dir:'images',file:'rotate.png')}"></button>
            </span>
            <div class="dialog" id="imagePane">
                <g:set var="imageIndex" value="0"/>
                <g:each in="${taskInstance.multimedia}" var="m" status="i">
                    <g:set var="imageUrl" value="${grailsApplication.config.server.url}${m.filePath}"/>
                    <div class="pageViewer" id="journalPageImg" style="width:100%;height:300px;">
                        <div><img id="image_${imageIndex++}" src="${imageUrl}" style="width:100%;"/></div>
                    </div>
                </g:each>
            </div>
            <div class="fields" id="journalText">
                <table>
                    <thead>
                        <tr>
                            <th>
                                <h3>1. Transcribe all text from the above field<br/>note page into this box as it appears</h3>
                            </th>
                            <th>
                                <div>Paint Ref No. <input type="text" id="paintingRefNo" value="" size="5"/> <input type="button" id="showPainting" value="Show Me">
                                    <a href="#" class="fieldHelp" title="Displays the associated painting to assist in transcribing text from field note"><span class="help-container">&nbsp;</span></a></div>
                            </th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td colspan="2">
                                <g:textArea name="recordValues.0.occurrenceRemarks" value="${recordValues?.get(0)?.occurrenceRemarks}"
                                          id="transcribeAllText" rows="12" cols="40" style="width:98%;height:300px;"/>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <div class="fields" id="journalFields">
                <table>
                    <thead>
                        <tr>
                            <th colspan="2">
                                <h3>2. For each entry on the field note, please transcribe information into the following fields.</h3>
                                <g:set var="entriesField" value="${TemplateField.findByFieldTypeAndTemplate(DarwinCoreField.individualCount, template)}"/>
                                No. Entries on page: <g:select name="recordValues.0.${entriesField?.fieldType}" id="noOfEntries" from="${[0:1, 1:2, 2:3, 3:4]}"
                                                               optionKey="key" optionValue="value" value="${recordValues?.get(0)?.get(entriesField?.fieldType?.name())?:entriesField?.defaultValue}"/>
                            </th>
                        </tr>
                    </thead>
                    <tbody>
                        <g:each in="${[0, 1, 2, 3]}" var="i">
                            <tr class="fieldNoteFields" id="${i}">
                                <td><strong>Entry ${i+1}.</strong><br/>
                                    <g:each in="${TemplateField.findAllByCategoryAndTemplate(FieldCategory.dataset, template, [sort:'id'])}" var="field">
                                        <g:set var="fieldLabel" value="${field.label?:field?.fieldtype.label}"/>
                                        <g:set var="fieldName" value="recordValues.${i}.${field?.fieldType.name()}"/>
                                        <label for="${fieldName}">${fieldLabel}</label>
                                        <g:textField name="${fieldName}" value="${recordValues?.get(i)?.get(field?.fieldType.name())}"/></br/>
                                    </g:each>
                                </td>
                            </tr>
                        </g:each>
                    </tbody>
                </table>
            </div>
            <div class="fields" id="journalNotes" style="width:${(validator) ? '100%' : '50%'}">
                <table style="width: 100%">
                    <thead>
                    <tr><th><h3>Notes</h3> &ndash; Record any comments here that may assist in validating this task </th></tr>
                    </thead>
                    <tbody>
                        <tr class="prop">
                            <td class="name">${(validator) ? 'Transcriber' : 'Your'} Notes</td>
                            <td class="value"><g:textArea name="recordValues.0.transcriberNotes" value="${recordValues?.get(0)?.transcriberNotes}"
                                id="transcriberNotes" rows="5" cols="40" style="width: 100%"/></td>
                        </tr>
                        <g:if test="${validator}">
                            <tr class="prop">
                            <td class="name">Validator Notes</td>
                            <td class="value"><g:textArea name="recordValues.0.validatorNotes" value="${recordValues?.get(0)?.validatorNotes}"
                                id="transcriberNotes" rows="5" cols="40" style="width: 100%"/></td>
                        </tr>
                        </g:if>
                    </tbody>
                </table>
            </div>

            <div class="fields">
                <cl:taskComments task="${taskInstance}" />
            </div>

            <g:if test="${!isReadonly}">
                <div class="buttons" style="clear: both">
                    <g:hiddenField name="id" value="${taskInstance?.id}"/>
                    <g:if test="${validator}">
                        <span class="button"><g:actionSubmit class="validate" action="validate"
                                 value="${message(code: 'default.button.validate.label', default: 'Validate')}"/></span>
                        <span class="button"><g:actionSubmit class="dontValidate" action="dontValidate"
                                 value="${message(code: 'default.button.dont.validate.label', default: 'Dont validate')}"/></span>
                        <span class="button"><button id="showNextFromProject" class="skip">Skip</button></span>
                        <cl:validationStatus task="${taskInstance}" />
                    </g:if>
                    <g:else>
                        <span class="button"><g:actionSubmit class="save" action="save"
                                 value="${message(code: 'default.button.save.label', default: 'Submit for validation')}"/></span>
                        <span class="button"><g:actionSubmit class="savePartial" action="savePartial"
                                 value="${message(code: 'default.button.save.partial.label', default: 'Save unfinished record')}"/></span>
                        <span class="button">
                            %{--<g:actionSubmit class="skip" action="showNextFromProject" params="[id: ${taskInstance?.project?.id}]"--}%
                                 %{--value="${message(code: 'default.button.skip.label', default: 'Skip')}"/>--}%
                            <cl:isLoggedIn>
                                <button id="showNextFromProject" class="skip">Skip</button>
                            </cl:isLoggedIn>
                        </span>
                    </g:else>
                </div>
            </g:if>
            <a href="#promptUser" id="promptUserLink" style="display: none">show prompt to save</a>
            <div style="display: none">
                <div id="promptUser">
                    <h2>Lock has Expired</h2>
                    The lock on this record is about to expire.<br/>
                    Please either save your changes:<br/>
                    <span class="button"><g:actionSubmit class="savePartial" action="savePartial"
                             value="${message(code: 'default.button.save.partial.label', default: 'Save unfinished record')}"/></span>
                    <br>
                    Or reload the page (Note: any changes you may have made will be lost)
                    <br/>
                    <input type="button" value="Reload Page" onclick="window.location.reload()"/>
                    <br/>
                    NOTE: the page will be automatically saved in <span id="reloadCounter">5</span> minutes if no action if taken
                </div>
            </div>
        </g:form>
    </g:if>
    <g:else>
        No tasks loaded for this project !
    </g:else>
  </div>
</body>
</html>
