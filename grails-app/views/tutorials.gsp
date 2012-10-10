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

    <cl:navbar selected="tutorials" />

    <header id="page-header">      
      <div class="inner">
        <cl:messages />
        <nav id="breadcrumb">
          <ol>
            <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
            <li class="last"><g:message code="default.tutorials.label" default="Tutorials" /></li>
          </ol>
        </nav>
        <hgroup>
          <h1>Tutorials</h1>
        </hgroup>
      </div>
    </header>
    <div>
      <div class="inner">
        <table class="bvp-expeditions">
          <tr>
            <td>
              <A href="${resource(dir: 'pdf', file: 'fieldNotesTutorial.pdf')}"><g:message code="default.tutorial.fieldnotes.label" default="Transcribing Field Notes"/></a>
            </td>
          </tr>
          <tr>
            <td>
              <A href="${createLink(controller: 'tutorials', action: 'transcribingSpecimenLabels')}"><g:message code="default.tutorial.specimenlabels.label" default="Transcribing Specimen Labels"/></a>
            </td>
          </tr>
          <tr>
            <td>
              <A href="${createLink(controller: 'tutorials', action: 'transcribingAnicCockroaches')}"><g:message code="default.tutorial.specimenlabels.label" default="Transcribing ANIC Cockroaches - supplemental"/></a>
            </td>
          </tr>

          <tr>
            <td>
              <A href="${resource(dir:'pdf', file:'whaleSharkTutorial.pdf')}"><g:message code="default.tutorial.whalesharks.label" default="Transcribing Whaleshark observations - supplemental"/></a>
            </td>
          </tr>

          <tr>
            <td>
              <A href="${resource(dir:'pdf', file:'whaleSharkMap.pdf')}"><g:message code="default.tutorial.whalesharksmap.label" default="Whaleshark area map - supplemental"/></a>
            </td>
          </tr>

          <tr>
            <td>
              <A href="${resource(dir:'pdf', file:'kershawDiariesSupplement.pdf')}"><g:message code="default.tutorial.whalesharksmap.label" default="Kershaw Diaries - supplemental"/></a>
            </td>
          </tr>

          <tr>
            <td>
              <A href="${resource(dir:'pdf', file:'Finnish specimen supplement.pdf')}"><g:message code="default.tutorial.finnish.label" default="Finnish specimens - supplemental"/></a>
            </td>
          </tr>

        </table>
      </div>

    </div>


  </body>
</html>
