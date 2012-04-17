<%@ page contentType="text/html;charset=UTF-8" import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<!DOCTYPE html>
<html>
  <head>
      <title>Volunteer Portal - Atlas of Living Australia</title>
      <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
      <link rel="stylesheet" href="${resource(dir:'css',file:'vp.css')}" />
      %{--<link rel="icon" type="image/x-icon" href="${ConfigurationHolder.config.ala.baseURL}/wp-content/themes/ala/images/favicon.ico"/>--}%
      %{--<g:javascript library="jquery-1.5.1.min"/>--}%
      <g:javascript library="jquery.tools.min"/>
      <style type="text/css">

        div#wrapper > div#content {
            background-color: transparent !important;
        }

        .volunteerportal #page-header {
        	background:#f0f0e8 url(${resource(dir:'images/vp',file:'bg_volunteerportal.jpg')}) center top no-repeat;
        	padding-bottom:12px;
        	border:1px solid #d1d1d1;
        }

      </style>

  </head>
  <body class="sublevel sub-site volunteerportal">

    <cl:navbar selected="submitexpedition" />

    <header id="page-header">      
      <div class="inner">
        <g:if test="${flash.message}">
          <div class="message">${flash.message}</div>
        </g:if>
        <nav id="breadcrumb">
          <ol>
            <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
            <li class="last"><g:message code="default.submit.label" default="Submit an Expedition" /></li>
          </ol>
        </nav>
        <h1>Submit an Expedition</h1>
      </div>
    </header>
    <div>
      <div class="inner">
        <p style="font-size: 1.2em">
        The Biodiversity Volunteer Portal is open to any institution or individual who has suitable biodiversity
        information that needs transcribing, whether that be in the form of specimen labels, field notes, survey sheets
        or something similar.
        </p>

        <p>
        Any proposed expedition will need to conform to an existing transcription task template, be suitable for an
        existing template with some minor adjustment, or have sufficient funds to enable the development of a new
        transcription task template.
        </p>
        So if you think you have some material that would be suitable for creating an expedition in the Biodiversity
        Volunteer Portal please get in touch with me paul.flemons at austmus.gov.au
      </div>
    </div>
  </body>
</html>
