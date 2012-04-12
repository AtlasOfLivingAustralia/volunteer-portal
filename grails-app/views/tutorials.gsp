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
        <g:if test="${flash.message}">
          <div class="message">${flash.message}</div>
        </g:if>

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
    <div class="body">
      <div class="inner">
        <table class="bvp-expeditions">
          <tr>
            <td>
              <A href="${org.codehaus.groovy.grails.commons.ConfigurationHolder.config.server.url}/video/Introduction.swf"><g:message code="default.tutorial.introduction.label" default="Introduction"/></a>
            </td>
          </tr>
          <tr>
            <td>
              <A href="${org.codehaus.groovy.grails.commons.ConfigurationHolder.config.server.url}/video/Mapping_Tool2.swf"><g:message code="default.tutorial.introduction.label" default="Mapping tool"/></a>
            </td>
          </tr>
          <tr>
            <td>
              <A href="${org.codehaus.groovy.grails.commons.ConfigurationHolder.config.server.url}/video/Transcribing.swf"><g:message code="default.tutorial.introduction.label" default="Transcribing"/></a>
            </td>
          </tr>
        </table>
      </div>

    </div>


  </body>
</html>
