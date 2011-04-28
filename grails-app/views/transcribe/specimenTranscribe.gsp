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
        <table>
          <tbody>

          <tr class="prop">
            <td valign="top" class="name"><g:message code="record.scientificName.label" default="Scientific name"/></td>
            <td valign="top" class="value">
              <g:textField name="recordValues.0.scientificName" maxlength="200" value="${recordValues?.get(0)?.scientificName}" class="scientificName"/>
            </td>
          </tr>

          <tr class="prop">
            <td valign="top" class="name"><g:message code="record.latitude.label" default="Latitude"/></td>
            <td valign="top" class="value"><g:textField name="recordValues.0.latitude" maxlength="200" value="${recordValues?.get(0)?.latitude}"/></td>
          </tr>

          <tr>
            <td valign="top" class="value"><g:message code="record.longitude.label" default="Longitude"/></td>
            <td valign="top" class="value"><g:textField name="recordValues.0.longitude" maxlength="200" value="${recordValues?.get(0)?.longitude}"/></td>
          </tr>

          <tr>
            <td valign="top" class="value"><g:message code="record.locality.label" default="Locality" class="locality"/></td>
            <td valign="top" class="value"><g:textField name="recordValues.0.locality" maxlength="200" value="${recordValues?.get(0)?.locality}"/></td>
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
