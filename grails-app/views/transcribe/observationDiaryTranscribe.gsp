<html>
<%@ page import="javax.swing.text.html.HTML; au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.TemplateField" %>
<%@ page import="au.org.ala.volunteer.field.*" %>
<%@ page import="au.org.ala.volunteer.FieldCategory" %>
<%@ page import="au.org.ala.volunteer.DarwinCoreField" %>
<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<%@ page contentType="text/html; UTF-8" %>

<g:set var="viewParams" value="${taskInstance.project.template?.viewParams}" />

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
<meta name="viewport" content="initial-scale=1.0, user-scalable=no"/>
<title>Transcribe Task ${taskInstance?.id} : ${taskInstance?.project?.name}</title>
<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.mousewheel.min.js')}"></script>
<script type="text/javascript" src="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.pack.js')}"></script>
<link rel="stylesheet" href="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.css')}"/>
<script type="text/javascript" src="${resource(dir: 'js', file: 'ui.core.js')}"></script>
<script type="text/javascript" src="${resource(dir: 'js', file: 'ui.datepicker.js')}"></script>
<link rel="stylesheet" href="${resource(dir: 'css/smoothness', file: 'ui.all.css')}"/>
<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.validationEngine.js')}"></script>
<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.validationEngine-en.js')}"></script>
<link rel="stylesheet" href="${resource(dir: 'css', file: 'validationEngine.jquery.css')}"/>
<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.qtip-1.0.0-rc3.min.js')}"></script>
<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.cookie.js')}"></script>
<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.scrollview.js')}"></script>
<script src="http://cdn.jquerytools.org/1.2.6/all/jquery.tools.min.js"></script>
<link rel="stylesheet" type="text/css" href="${resource(dir: 'css', file: 'rangeSlider.css')}"/>

<script type="text/javascript">
    // global Object 
    var VP_CONF = {
        isReadonly: "${isReadonly}",
        isValid: ${(taskInstance?.isValid) ? "true" : "false"},
        validator: "${validator}"
    };

    <g:set var="entriesField" value="${TemplateField.findByFieldTypeAndTemplate(DarwinCoreField.sightingCount, template)}"/>
    <g:set var="numItems" value="${(recordValues?.get(0)?.get(entriesField.fieldType.name())?:entriesField.defaultValue).toInteger()}" />
    <g:set var="fieldList" value="${TemplateField.findAllByCategoryAndTemplate(FieldCategory.dataset, template, [sort:'id'])}" />

    var numItems = ${numItems};

    var entries = [

    <g:if test="${numItems > 0}">
        <g:each in="${0..numItems-1}" var="i">
            [
            <g:each in="${fieldList}" var="field" status="fieldIndex">
                <g:set var="fieldLabel" value="${field.label?:field.fieldType.label}"/>
                <g:set var="fieldName" value="${field.fieldType.name()}"/>
                <g:set var="fieldValue" value="${recordValues?.get(i)?.get(field.fieldType.name())?.encodeAsHTML()?.replaceAll('\\\'', '&#39;')}" />
                {name:'${fieldName}', label:'${fieldLabel}', value: "${fieldValue}"}<g:if test="${fieldIndex < fieldList.size()- 1 }">,</g:if>
            </g:each>
            ]<g:if test="${i < (numItems - 1)}">,</g:if>
        </g:each>
    </g:if>
    ];

    function renderEntries() {
      try {
        var htmlStr ="";
        var itemCount = 0;

        var entry = [
        <g:each in="${fieldList}" var="field" status="fieldIndex">
            <g:set var="fieldLabel" value="${field.label?:field.fieldType.label}"/>
            <g:set var="fieldName" value="${field.fieldType.name()}"/>
            {name:'${fieldName}', label:'${fieldLabel}', value: ''}<g:if test="${fieldIndex < fieldList.size() - 1}">,</g:if>
        </g:each>
        ];

        htmlStr += '<tr class="newRow"><td><strong>New row<strong></td>'
        var first = true;
        for (fieldIndex in entry) {
          var e = entry[fieldIndex]
          if (e.name == 'verbatimLocality' && ${viewParams?.hideLocality ?: false} == true) {
            // skip
            continue;
          }

          var name = e.name;
          htmlStr += '<td class="value td_' + e.name
          if (first) {
            first = false;
            htmlStr += ' firstInput';
          }
          htmlStr  += '">'
          if (e.name != "occurrenceRemarks") {
            htmlStr += '<input type="text" name="' + name + '" value="' + e.value + '" id="' + name + '" class="' + e.name + '">';
          } else {
            htmlStr += '<textarea rows="4" name="' + name + '" id="' + name + '" class="' + e.name + '">' + e.value + '</textarea>';
          }
          htmlStr += '</td>';
        }
        htmlStr += '<td><button id="addRowButton">Add row</button></td></tr>';

        for (entryIndex in entries) {
          htmlStr += '<tr class="observationFields"><td><strong>' + (parseInt(entryIndex) + 1) + '.</strong></td>'
          for (fieldIndex in entries[entryIndex]) {
            var e = entries[entryIndex][fieldIndex];
            if (e.name == 'verbatimLocality' && ${viewParams?.hideLocality ?: false} == true) {
              // skip
              continue;
            }

            var name = "recordValues." + entryIndex + "." + e.name;


            htmlStr += '<td class="value td_' + e.name + '">'
            if (e.name != "occurrenceRemarks") {
              htmlStr += '<input type="text" name="' + name + '" value="' + e.value + '" id="' + name + '" class="' + e.name + '">';
            } else {
              htmlStr += '<textarea rows="4" name="' + name + '" id="' + name + '" class="' + e.name + '">' + e.value + '</textarea>';
            }
            htmlStr += '</td>';
          }

          htmlStr += '<td><button style="margin-left: 10px" onclick="deleteEntry(' + entryIndex + '); return false;">Delete</button></td>';
          htmlStr += "</tr>"

          itemCount++;
        }
        $("#observation_fields").html(htmlStr);
        $("#noOfEntries").attr('value', itemCount);

        $("#addRowButton").click(function(e) {
          e.preventDefault();
          addEntry();
        });

      } catch (e) {
        alert(e)
      }
    }

    function syncEntries() {
      for (entryIndex in entries) {
        for (fieldIndex in entries[entryIndex]) {
          var e = entries[entryIndex][fieldIndex];
          e.value = $('#recordValues\\.' + entryIndex + '\\.' + e.name).val();
        }
      }
    }

    function addEntry(e) {
      try {

        // first we need to save any edits to the entry list
        syncEntries();
        var entry = [
        <g:each in="${fieldList}" var="field" status="fieldIndex">
            <g:set var="fieldLabel" value="${field.label?:field.fieldType.label}"/>
            <g:set var="fieldName" value="${field.fieldType.name()}"/>
            {name:'${fieldName}', label:'${fieldLabel}', value: $('#${fieldName}').val()}<g:if test="${fieldIndex < fieldList.size() - 1}">,</g:if>
        </g:each>
        ];
        entries.push(entry);
        renderEntries();
        $('.firstInput input').focus();
      } catch (e) {
        alert(e)
      }

    }

    function deleteEntry(index) {
      syncEntries()
      if (index >= 0 && index <= entries.length) {
        entries.splice(index, 1);
        renderEntries();
      }
      return false;
    }

    $(document).ready(function() {

        // prevent enter key submitting form
        $(window).keydown(function(event) {
            if (event.keyCode == 13 && event.target.nodeName != "TEXTAREA") {
                event.preventDefault();
                return false;
            }
        });

        // display previous journal page in new window
        $("#showPreviousJournalPage").click(function(e) {
            e.preventDefault();
            <g:if test="${prevTask}">
              var uri = "${createLink(controller: 'task', action:'showImage', id: prevTask.id)}"
              newwindow = window.open(uri,'journalWindow','directories=no,titlebar=no,toolbar=no,location=no,status=no,menubar=no,height=600,width=1000');
          	  if (window.focus) {newwindow.focus()}
            </g:if>
        });

        // display next journal page in new window
        $("#showNextJournalPage").click(function(e) {
            e.preventDefault();
            <g:if test="${nextTask}">
              var uri = "${createLink(controller: 'task', action:'showImage', id: nextTask.id)}"
              newwindow = window.open(uri,'journalWindow','directories=no,titlebar=no,toolbar=no,location=no,status=no,menubar=no,height=600,width=1000');
              if (window.focus) {newwindow.focus()}
            </g:if>
        });

        renderEntries();

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

        $(":range").rangeinput({
            onSlide: zoomJournalImage
        }).change(zoomJournalImage);

        $("#imagePane").scrollview({
            grab:"${resource(dir: 'images', file: 'openhand.cur')}",
            grabbing:"${resource(dir: 'images', file: 'closedhand.cur')}"
        });

        var isReadonly = VP_CONF.isReadonly;
        if (isReadonly) {
            // readonly more
            $(":input").not('.skip,.comment-control :input').hover(function(e){alert('You do not have permission to edit this task.')}).attr('disabled','disabled').attr('readonly','readonly');
        }

        <cl:timeoutScriptFragment />

      $("#imagePane").scrollTop(0);

    });

    function zoomJournalImage(event, value) {
        $("#journalPageImg").css("height", value + "%");
    }

</script>

  <style type="text/css">

    button:disabled {
      opacity : 0.4;
      filter: alpha(opacity=40); // msie
    }

    button[disabled]:hover {
      opacity : 0.4;
      filter: alpha(opacity=40); // msie
    }

    .value input {
      width: auto;
    }

    /*.observationFields .value input {*/
        /*width: 100%;*/
    /*}*/

    td .catalogNumber {
      width: 100%;
    }

    .td_catalogNumber {
      width: 100px;
    }

    td .verbatimLocality {
      width: 100%;
    }

    td .occurrenceRemarks {
      width: 100%;
    }

    #imagePane {
      width: 972px;
      height: 300px;
      clear: left;
    }

    .pageDetails, .observationFields {
      /* float: right; */
    }

    .newRow {
      background: #F0F0E8
    }

  </style>
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
        <g:form controller="${validator ? "transcribe" : "validate"}" class="transcribeForm">
            <g:hiddenField name="recordId" value="${taskInstance?.id}"/>
            <g:hiddenField name="redirect" value="${params.redirect}"/>
            <div style="float:left;margin-top:5px;">Zoom image:&nbsp;</div>
            <g:set var="defaultWidthPercent" value="400" />
            <input type="range" name="width" min="200" max="600" value="${defaultWidthPercent}" />

            <span id="journalPageButtons">
                <button id="showPreviousJournalPage" title="displays page in new window" ${prevTask ? '' : 'disabled="true"'}><img src="${resource(dir:'images',file:'left_arrow.png')}"> show previous journal page</button>
                <button id="showNextJournalPage" title="displays page in new window" ${nextTask ? '' : 'disabled="true"'}>show next journal page <img src="${resource(dir:'images',file:'right_arrow.png')}"></button>
                %{--<button id="rotateImage" title="Rotate the page 180 degrees">Rotate&nbsp;<img style="vertical-align: middle; margin: 0 !important;" src="${resource(dir:'images',file:'rotate.png')}"></button>--}%
            </span>

            <div class="" id="imagePane">
                <g:set var="imageIndex" value="0"/>
                <g:each in="${taskInstance.multimedia}" var="m" status="i">
                  <g:if test="${!m.mimeType || m.mimeType.startsWith('image/')}">
                    <g:set var="imageUrl" value="${ConfigurationHolder.config.server.url}${m.filePath}"/>
                    <div class="pageViewer" id="journalPageImg" style="width:972px;height:${defaultWidthPercent}%;">
                        <div><img id="image_${imageIndex++}" src="${imageUrl}" style="height:100%;"/></div>
                    </div>
                  </g:if>
                </g:each>
            </div>
            <div class="pageDetails">
                <g:set var="entriesField" value="${TemplateField.findByFieldTypeAndTemplate(DarwinCoreField.sightingCount, template)}"/>
                <g:hiddenField name="recordValues.0.${entriesField.fieldType}" id="noOfEntries" value="${recordValues?.get(0)?.get(entriesField.fieldType.name())?:entriesField.defaultValue}"/>
            </div>
          
            <g:if test="${viewParams?.showMonth}">
              <div class="fields">
                  <table style="width: 100%; margin-top: 10px;">
                      <thead>
                        <tr>
                          <th style="width: 250px">
                            <h3>Enter the month from the top of the page</h3>
                          </th>
                          <th style="text-align: right"><strong>Month</strong></th>
                          <th><g:textField id="recordValues.0.verbatimEventDate" name="recordValues.0.verbatimEventDate" value="${recordValues?.get(0)?.get(DarwinCoreField.verbatimEventDate)}" /></th>
                        </tr>
                      </thead>
                  </table>
              </div>
            </g:if>

            <div class="observationFields">
                <table style="width: 100%; margin-top: 10px;">
                    <thead>
                        <tr>
                          <th colspan="5">
                            <h3>Transcribe each record as follows: Enter the number into the “CatalogNumber “ field. Enter the text into the “Transcribe All text” field.</h3>
                          </th>
                        </tr>
                        <tr>
                            <th></th>
                            <th>CatalogNumber</th>
                            <th>Transcribe All text</th>
                            <g:if test="${!viewParams?.hideLocality}">
                              <th>Verbatim Locality</th>
                            </g:if>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody id="observation_fields">
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
                                id="transcriberNotes" rows="10" cols="40" style="width: 100%"/></td>
                        </tr>
                        <g:if test="${validator}">
                            <tr class="prop">
                            <td class="name">Validator Notes</td>
                            <td class="value"><g:textArea name="recordValues.0.validatorNotes" value="${recordValues?.get(0)?.validatorNotes}" id="transcriberNotes" rows="10" cols="40" style="width: 100%"/></td>
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
            <cl:timeoutPopup />
        </g:form>
    </g:if>
    <g:else>
        No tasks loaded for this project !
    </g:else>
  </div>
</body>
</html>
