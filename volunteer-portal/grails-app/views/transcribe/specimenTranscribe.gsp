<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="layout" content="main"/>
  <title>Transcribe Task ${taskInstance?.id} : ${taskInstance?.project?.name}</title>
  <script language="JavaScript" type="text/javascript" src="${resource(dir: 'js', file: 'jquery.jqzoom-core-pack.js')}"></script>
  <link rel="stylesheet" href="${resource(dir: 'css', file: 'jquery.jqzoom.css')}"/>
  <script language="JavaScript" type="text/javascript">
    $(document).ready(function(){
        jQuery("input.scientificName").autocomplete('http://bie.ala.org.au/search/auto.jsonp', {
          extraParams: {limit: 100},
          dataType: 'jsonp',
          parse: function(data) {
            var rows = new Array();
            data = data.autoCompleteList;
            for (var i = 0; i < data.length; i++) {
              rows[i] = {
                data:data[i],
                value: data[i].matchedNames[0],
                result: data[i].matchedNames[0]
              };
            }
            return rows;
          },
          matchSubset: true,
          formatItem: function(row, i, n) {
            return row.matchedNames[0];
          },
          cacheLength: 10,
          minChars: 3,
          scroll: false,
          max: 10,
          selectFirst: false
        }).result(function(event, item) {
          // user has selected an autocomplete item
          $('input.taxonConceptID').val(item.guid);
        });
        
        var options = {
            zoomType: 'drag',
            lens: true,
            preloadImages: true,
            alwaysOn:false,
            zoomWidth: 300,
            zoomHeight: 300,
            imageOpacity: 0.7,
            title: false
            //xOffset:90,
            //yOffset:30,
            //position:'right'
        };  
        $('.taskImage').jqzoom(options);
    });
  </script>
</head>
<body class="two-column-right">
<div id="content">
  <div class="section">
    <div class="body">
      <g:if test="${validator}">
        <h1>Validate Task ${taskInstance?.id} : ${taskInstance?.project?.name}</h1>
      </g:if>
      <g:else>
        <h1>Transcribe Task ${taskInstance?.id} : ${taskInstance?.project?.name}</h1>
      </g:else>

      <g:if test="${taskInstance}">
      <g:form controller="transcribe" action="saveTranscription">
        <g:hiddenField name="recordId" value="${taskInstance?.id}"/>
      <div class="dialog">
        <g:each in="${taskInstance.multimedia}" var="m">
          <img src="${ConfigurationHolder.config.server.url}${m.filePath}" alt="specimen image"/>
          %{--<div style="min-height: 300px;">
            <a href="${m.filePath}" class="taskImage" title="${taskInstance?.project?.name}">
              <img src="${m.filePath}" style="width: 350px;" title="image: ${taskInstance?.project?.name}">
            </a>
          </div>--}%

        </g:each>
        <div style="clear:both;">&nbsp;</div>
        <h3>Identification</h3>
        <table>
          <thead/>
          <tbody>
            <tr class="prop">
              <td valign="top" class="name"><g:message code="record.scientificName.label" default="Scientific name"/></td>
              <td valign="top" class="value">
              <g:textField name="recordValues.0.scientificName" maxlength="200" value="${recordValues?.get(0)?.scientificName}" class="scientificName"/>
              </td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name"><g:message code="record.taxonConceptID.label" default="Taxon Concept ID"/></td>
              <td valign="top" class="value">
              <g:textField name="recordValues.0.taxonConceptID" maxlength="200" value="${recordValues?.get(0)?.taxonConceptID}" class="taxonConceptID"/>
              </td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name"><g:message code="record.scientificNameAuthorship.label" default="Authorship"/></td>
              <td valign="top" class="value">
              <g:textField name="recordValues.0.scientificNameAuthorship" maxlength="200" value="${recordValues?.get(0)?.scientificNameAuthorship}" class="scientificNameAuthorship"/>
              </td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name"><g:message code="record.identifiedBy.label" default="Identified By"/></td>
              <td valign="top" class="value">
              <g:textField name="recordValues.0.identifiedBy" maxlength="200" value="${recordValues?.get(0)?.identifiedBy}" class="identifiedBy"/>
              </td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name"><g:message code="record.dateIdentified.label" default="Date Identified"/></td>
              <td valign="top" class="value">
              <g:textField name="recordValues.0.dateIdentified" maxlength="200" value="${recordValues?.get(0)?.dateIdentified}" class="dateIdentified"/>
              </td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name"><g:message code="record.identificationRemarks.label" default="Identification Remarks"/></td>
              <td valign="top" class="value">
              <g:textField name="recordValues.0.identificationRemarks" maxlength="200" value="${recordValues?.get(0)?.identificationRemarks}" class="identificationRemarks"/>
              </td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name"><g:message code="record.typeStatus.label" default="Type Status"/></td>
              <td valign="top" class="value">
              <g:textField name="recordValues.0.typeStatus" maxlength="200" value="${recordValues?.get(0)?.typeStatus}" class="typeStatus"/>
              </td>
            </tr>
          </tbody>
        </table>
        <h3>Dataset</h3>
        <table>
          <thead/>
          <tbody>
            <tr class="prop">
              <td valign="top" class="name">
                <g:message code="record.catalogNumber.label" default="Catalog Number"/>
              </td>
              <td valign="top" class="value">
                <g:textField name="recordValues.0.catalogNumber" maxlength="200" value="${recordValues?.get(0)?.catalogNumber}" class="catalogNumber"/>
              </td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">
                <g:message code="record.institution.label" default="Institution"/>
              </td>
              <td valign="top" class="value">
                <g:textField name="recordValues.0.institution" maxlength="200" value="${recordValues?.get(0)?.institution}" class="institution"/>
              </td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">
                <g:message code="record.eventDate.label" default="Date"/>
              </td>
              <td valign="top" class="value">
                <g:textField name="recordValues.0.eventDate" maxlength="200" value="${recordValues?.get(0)?.eventDate}" class="eventDate"/>
              </td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">
                <g:message code="record.recordedBy.label" default="Collector"/>
              </td>
              <td valign="top" class="value">
                <g:textField name="recordValues.0.recordedBy" maxlength="200" value="${recordValues?.get(0)?.recordedBy}" class="recordedBy"/>
              </td>
            </tr>
          </tbody>
        </table>
        <h3>Location</h3>
        <table>
          <thead/>
          <tbody>
            <tr class="prop">
              <td valign="top" class="name"><g:message code="record.country.label" default="Country"/></td>
              <td valign="top" class="value">
              <g:textField name="recordValues.0.country" maxlength="200" value="${recordValues?.get(0)?.country}" class="country"/>
              </td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name"><g:message code="record.stateProvince.label" default="State"/></td>
              <td valign="top" class="value">
              <g:textField name="recordValues.0.stateProvince" maxlength="200" value="${recordValues?.get(0)?.stateProvince}" class="stateProvince"/>
              </td>
            </tr>
            <tr class="prop">
              <td valign="top" class="value"><g:message code="record.locality.label" default="Locality" class="locality"/></td>
              <td valign="top" class="value"><g:textField name="recordValues.0.locality" maxlength="200" value="${recordValues?.get(0)?.locality}"/></td>
            </tr>
            <tr class="prop">
              <td valign="top" class="value"><g:message code="record.locationRemarks.label" default="Location Remarks" class="locationRemarks"/></td>
              <td valign="top" class="value"><g:textField name="recordValues.0.locationRemarks" maxlength="200" value="${recordValues?.get(0)?.locationRemarks}"/></td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name"><g:message code="record.latitude.label" default="Latitude"/></td>
              <td valign="top" class="value"><g:textField name="recordValues.0.latitude" maxlength="200" value="${recordValues?.get(0)?.latitude}"/></td>
            </tr>
            <tr class="prop">
              <td valign="top" class="value"><g:message code="record.longitude.label" default="Longitude"/></td>
              <td valign="top" class="value"><g:textField name="recordValues.0.longitude" maxlength="200" value="${recordValues?.get(0)?.longitude}"/></td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name"><g:message code="record.verbatimLatitude.label" default="Verbatim Latitude"/></td>
              <td valign="top" class="value"><g:textField name="recordValues.0.verbatimLatitude" maxlength="200" value="${recordValues?.get(0)?.verbatimLatitude}"/></td>
            </tr>
            <tr class="prop">
              <td valign="top" class="value"><g:message code="record.verbatimLongitude.label" default="verbatimLongitude"/></td>
              <td valign="top" class="value"><g:textField name="recordValues.0.verbatimLongitude" maxlength="200" value="${recordValues?.get(0)?.verbatimLongitude}"/></td>
            </tr>
            <tr class="prop">
              <td valign="top" class="value"><g:message code="record.coordinatePrecision.label" default="Coordinate Precision"/></td>
              <td valign="top" class="value"><g:textField name="recordValues.0.coordinatePrecision" maxlength="200" value="${recordValues?.get(0)?.coordinatePrecision}"/></td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="buttons">
          <g:hiddenField name="id" value="${taskInstance?.id}"/>
          <g:if test="${validator}">
            <span class="button"><g:actionSubmit class="validate" action="validate" value="${message(code: 'default.button.validate.label', default: 'Validate')}"/></span>
            <span class="button"><g:actionSubmit class="dontValidate" action="dontValidate" value="${message(code: 'default.button.dont.validate.label', default: 'Dont validate')}"/></span>
          </g:if>
          <g:else>
            <span class="button"><g:actionSubmit class="save" action="save" value="${message(code: 'default.button.save.label', default: 'Save')}"/></span>
            <span class="button"><g:actionSubmit class="savePartial" action="savePartial" value="${message(code: 'default.button.save.partial.label', default: 'Save partially complete')}"/></span>
            <span class="button"><g:actionSubmit class="skip" action="showNextFromAny" value="${message(code: 'default.button.skip.label', default: 'Skip')}"/></span>
          </g:else>
      </div>
      </g:form>
      </g:if>
      <g:else>
        No tasks loaded for this project !
      </g:else>
    </div>
  </div>
</div>
</body>
</html>
