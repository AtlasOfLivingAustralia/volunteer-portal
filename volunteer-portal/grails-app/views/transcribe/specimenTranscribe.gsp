<html>
<%@ page import="au.org.ala.volunteer.Template; au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Picklist" %>
<%@ page import="au.org.ala.volunteer.PicklistItem" %>
<%@ page import="au.org.ala.volunteer.TemplateField" %>
<%@ page import="au.org.ala.volunteer.field.*" %>
<%@ page import="au.org.ala.volunteer.FieldCategory" %>
<%@ page import="au.org.ala.volunteer.DarwinCoreField" %>
<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<%@ page contentType="text/html; UTF-8" %>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
<meta name="viewport" content="initial-scale=1.0, user-scalable=no"/>
<title>${(validator) ? 'Validate' : 'Transcribe'} Task ${taskInstance?.id} : ${taskInstance?.project?.name}</title>
<!--  <script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.jqzoom-core-pack.js')}"></script>
  <link rel="stylesheet" href="${resource(dir: 'css', file: 'jquery.jqzoom.css')}"/>-->
<script type="text/javascript" src="${resource(dir: 'js', file: 'mapbox.min.js')}"></script>
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
<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
<script type="text/javascript">
    // global Object 
    var VP_CONF = {
        taskId: "${taskInstance?.id}",
        picklistAutocompleteUrl: "${createLink(action:'autocomplete', controller:'picklistItem')}",
        updatePicklistUrl: "${createLink(controller:'picklistItem', action:'updateLocality')}",
        nextTaskUrl:  "${createLink(controller:(validator) ? "validate" : "transcribe", action:'showNextFromProject', id:taskInstance?.project?.id)}",
        isReadonly: "${isReadonly}",
        isValid: ${(taskInstance?.isValid) ? "true" : "false"}
    };
</script>
<script type="text/javascript" src="${resource(dir: 'js', file: 'specimenTranscribe.js')}"></script>
</head>

<body class="two-column-right">
<div class="nav">
    <a class="crumb" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a>
    %{--<g:link controller="project" action="list" class="crumb">Projects</g:link>--}%
    <g:link controller="project" action="index" id="${taskInstance?.project?.id}" class="crumb">${taskInstance?.project?.name}</g:link>
    ${(validator) ? 'Validate' : 'Transcribe'} Task - ${(recordValues?.get(0)?.catalogNumber) ? recordValues?.get(0)?.catalogNumber : taskInstance?.id}
</div>

<div class="body">
    <g:hasErrors bean="${taskInstance}">
    <div class="errors">
        There was a problem saving your edit: <g:renderErrors bean="${taskInstance}" as="list" />
    </div>
    </g:hasErrors>
    <g:if test="${flash.message}">
        <div class="errors">${flash.message}</div>
    </g:if>
    <h1>${(validator) ? 'Validate' : 'Transcribe'} Task: ${taskInstance?.project?.name} (ID: ${taskInstance?.externalIdentifier})</h1>
    <div id="videoLinks" style="padding-top: 6px; float: right;">
        ${taskInstance?.project?.tutorialLinks}
    </div>
    <g:if test="${taskInstance}">
        <g:form controller="${validator ? "transcribe" : "validate"}" class="transcribeForm">
            <g:hiddenField name="recordId" value="${taskInstance?.id}"/>
            <g:hiddenField name="redirect" value="${params.redirect}"/>
            <div class="dialog" style="clear: both">
                <g:each in="${taskInstance.multimedia}" var="m">
                    <g:set var="imageUrl" value="${ConfigurationHolder.config.server.url}${m.filePath}"/>
                    <div class="imageWrapper">
                        <div id="viewport">
                            <div style="background: url(${imageUrl.replaceFirst(/\.([a-zA-Z]*)$/, '_small.$1')}) no-repeat; width: 600px; height: 400px;">
                                <!--top level map content goes here-->
                            </div>
                            <div style="height: 1280px; width: 1920px;">
                                <img src="${imageUrl.replaceFirst(/\.([a-zA-Z]*)$/, '_medium.$1')}" alt=""/>
                                <div class="mapcontent"><!--map content goes here--></div>
                            </div>
                            <div style="height: 2000px; width: 3000px;">
                                <img src="${imageUrl.replaceFirst(/\.([a-zA-Z]*)$/, '_large.$1')}" alt=""/>
                                <div class="mapcontent"><!--map content goes here--></div>
                            </div>
                            <div style="height: 3168px; width: 4752px;">
                                <img src="${imageUrl}" alt=""/>
                                <div class="mapcontent"><!--map content goes here--></div>
                            </div>
                        </div>
                        <div class="map-control">
                            <a href="#left" class="left">Left</a>
                            <a href="#right" class="right">Right</a>
                            <a href="#up" class="up">Up</a>
                            <a href="#down" class="down">Down</a>
                            <a href="#zoom" class="zoom">Zoom</a>
                            <a href="#zoom_out" class="back">Back</a>
                        </div>
                    </div>

                </g:each>
                <div id="taskMetadata">
                    <div id="institutionLogo"></div>
                    <h3>Specimen Information</h3>
                    <ul>
                        <li><div>Institution:</div> <span id="institutionCode">${recordValues?.get(0)?.institutionCode}</span></li>
                        <li><div>Project:</div> ${taskInstance?.project?.name}</li>
                        <li><div>Catalogue No.:</div> ${recordValues?.get(0)?.catalogNumber}</li>
                        <li><div>Taxa:</div> ${recordValues?.get(0)?.scientificName}</li>
                        <g:hiddenField name="recordValues.0.basisOfRecord" class="basisOfRecord" id="recordValues.0.basisOfRecord"
                                       value="${recordValues?.get(0)?.basisOfRecord?:TemplateField.findByFieldType(DarwinCoreField.basisOfRecord)?.defaultValue}"/>
                    </ul>
                    <table>
                        <thead>
                        <tr><th><h3>1. Transcribe All Text</h3> &ndash; Record exactly what appears in the
                            labels so we have a searchable reference for them
                            <input type="button" id="copyAllTextButton" value="Copy text from previous task"/>
                            <a href="#" class="fieldHelp" title="Click on the 'Copy text from previous task' button to populate the box with the text from the previous task"><span class="help-container">&nbsp;</span></a></th></tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>
                                    <g:textArea name="recordValues.0.occurrenceRemarks" value="${recordValues?.get(0)?.occurrenceRemarks}"
                                              id="transcribeAllText" rows="12" cols="40" style="width: 100%"/>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div style="clear:both;"></div>

                <div id="transcribeFields">

                    <table style="width: 100%">
                        <thead>
                        <tr><th><h3>2. Collection Event</h3> &ndash; This records information directly from the label
                            about when, where and by whom the specimen was collected. Only fill in fields for which
                            information appears in the labels</th></tr>
                        </thead>
                        <tbody>
                        <g:each in="${TemplateField.findAllByCategoryAndTemplate(FieldCategory.collectionEvent, template, [sort:'displayOrder'])}" var="field">
                            <g:fieldFromTemplateField templateField="${field}" recordValues="${recordValues}"/>
                        </g:each>
                            <tr class='prop' style="width:950px;border-top:2px solid white;padding-top:5px;">
                                <td class='name'>
                                    <yield>Verbatim Locality</yield>
                                    </td>
                                <td class='value'>
                                    <textarea name="recordValues.0.verbatimLocality" rows="4" class="verbatimLocality" id="recordValues.0.verbatimLocality">${recordValues?.get(0)?.verbatimLocality}</textarea><a href='#' class='fieldHelp' title='Start typing the locality description. Any matches in the existing list will be selectable from a dropdown list. Choose the appropriate entry. If no existing entry exists then please enter the locality description as it appears in the label'><span class='help-container'>&nbsp;</span></a></td>
                            </tr>
                        </tbody>
                    </table>

                    <table style="width: 100%">
                        <thead>
                        <tr>
                            <th><h3>3. Interpreted Location</h3>
                                <button id="geolocate" href="#mapWidgets" title="Show geolocate tools popup">Use
                                mapping tool</button>
                                &ndash; Use the mapping tool before attempting to enter values manually
                            </th>
                        </tr>
                        </thead>
                        <tbody>
                        <g:each in="${TemplateField.findAllByCategoryAndTemplate(FieldCategory.location, template, [sort:'displayOrder'])}" var="field">
                            <g:fieldFromTemplateField templateField="${field}" recordValues="${recordValues}"/>
                        </g:each>
                        </tbody>
                    </table>

                    <div style="display:none">
                        <div id="mapWidgets">
                            <div id="mapWrapper">
                                <div id="mapCanvas"></div>
                                <div class="searchHint">Hint: you can also drag & drop the marker icon to set the location data</div>
                            </div>
                            <div id="mapInfo">
                                <div id="sightingAddress">
                                    <h3>Locality Search</h3>
                                    %{--<label for="address">Locality/Coodinates: </label>
                                    <input type="button" value="Copy verbatim locality into search box" onclick="$(':input#address').val($(':input.verbatimLocality').val())"/>
                                    <br/>--}%
                                    <textarea name="address" id="address" size="32" rows="2" value=""></textarea>
                                    <input id="locationSearch" type="button" value="Search" style="display:table-cell;vertical-align: top;"/>
                                    <div class="searchHint">Interpret the
                                        locality information in the labels into a form that is most likely to result in as accurate
                                        geographic coordinates as possible. Expand abbreviations, and remove unnecessary words and
                                        punctuation. Eg. &quot;Stott&apos;s Is. Tweed R. near Tumbulgum NSW&quot; would become
                                        &quot;Stott&apos;s Island, Tweed River, Tumbulgum, NSW&quot;. If that doesn&apos;t map
                                        correctly then try breaking the description up into single words to see if the map tool
                                        can find a location. Where the map tool cant find a location simply fill in the State/territory
                                        and Country fields</div>
                                </div>
                                <h3>Coordinate Uncertainty</h3>
                                <div>Adjust Uncertainty (in metres):
                                    <select id="infoUncert">
                                        <g:set var="coordinateUncertaintyPL" value="${Picklist.findByName('coordinateUncertaintyInMeters')}"/>
                                        <g:each in="${PicklistItem.findAllByPicklist(coordinateUncertaintyPL)}" var="item">
                                            <g:set var="isSelected"><g:if test="${(item.value == '1000')}">selected='selected'</g:if></g:set>
                                            <option ${isSelected}>${item.value}</option>
                                        </g:each>
                                    </select>
                                    <div class="searchHint">Please choose an uncertainty value from the list that best represents the area
                                        described by a circle with radius of that value from the given location. This can be seen as the
                                        circle around the point on the map <a href="#" class="fieldHelp" title="If in doubt
                                        choose a larger area. For example if the location is simply a small town then
                                        choose an uncertainty value that encompasses the town and some surrounding area.
                                        The larger the town the larger the uncertainty would need to be. If the locality
                                        description (verbatim locality) is quite detailed and you can find that location
                                        accurately then the uncertainty value can be smaller"><span class="help-container">&nbsp;</span></a>
                                    </div>
                                </div>
                                <h3>Location Data</h3>
                                <div>Latitude: <span id="infoLat"></span></div>
                                <div>Longitude: <span id="infoLng"></span></div>
                                <div>Location: <span id="infoLoc"></span></div>
                                <div style="text-align: center; padding: 10px; font-size: 12px;">
                                    <input id="setLocationFields" type="button" value="Copy values to main form"/>
                                </div>
                            </div>
                        </div>
                    </div>
                    <table style="width: 100%">
                        <thead>
                        <tr><th><h3>4. Identification</h3> &ndash; If a label contains information on the name of the organism then record the name and associated information in this section </th></tr>
                        </thead>
                        <tbody>
                        <g:each in="${TemplateField.findAllByCategoryAndTemplate(FieldCategory.identification, template, [sort:'displayOrder'])}" var="field">
                            <g:fieldFromTemplateField templateField="${field}" recordValues="${recordValues}"/>
                        </g:each>
                        </tbody>
                    </table>
                    <table style="width: 100%">
                        <thead>
                        <tr><th><h3>Notes</h3> &ndash; Record any comments here that may assist in validating this specimen </th></tr>
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
                                <td class="value"><g:textArea name="recordValues.0.validatorNotes" value="${recordValues?.get(0)?.validatorNotes}"
                                    id="transcriberNotes" rows="10" cols="40" style="width: 100%"/></td>
                            </tr>
                            </g:if>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="vp-buttons" style="clear: both">
                <g:hiddenField name="id" value="${taskInstance?.id}"/>
                <g:if test="${validator}">
                    <span class="button"><g:actionSubmit class="validate" action="validate"
                             value="${message(code: 'default.button.validate.label', default: 'Validate')}"/></span>
                    <span class="button"><g:actionSubmit class="dontValidate" action="dontValidate"
                             value="${message(code: 'default.button.dont.validate.label', default: 'Dont validate')}"/></span>
                    <span class="button"><button id="showNextFromProject" class="skip">Skip</button></span>
                    <span style="color:gray;">&nbsp;&nbsp;<g:link controller="task" action="projectAdmin" id="${taskInstance?.project?.id}">Validation List</g:link></span>
                    <span style="color:gray;">&nbsp;&nbsp;[is valid: ${taskInstance?.isValid} | validatedBy:  ${taskInstance?.fullyValidatedBy}]</span>
                </g:if>
                <g:else>
                    <span class="button"><g:actionSubmit class="save" action="save"
                             value="${message(code: 'default.button.save.label', default: 'Submit for validation')}"/></span>
                    <span class="button"><g:actionSubmit class="savePartial" action="savePartial"
                             value="${message(code: 'default.button.save.partial.label', default: 'Save unfinished record')}"/></span>
                    <span class="button"><button id="showNextFromProject" class="skip">Skip</button></span>
                </g:else>
            </div>
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
