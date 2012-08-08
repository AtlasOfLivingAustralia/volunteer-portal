<<%@ page contentType="text/html;charset=UTF-8" import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
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

        .screenshot {
          /*width: 50%;*/
        }

    .tutorialText {
      font-size: 1.2em;
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
            <li><a href="${createLink(uri: '/tutorials.gsp')}"><g:message code="default.tutorials.label" default="Tutorials"/></a></li>
            <li class="last"><g:message code="default.aniccockroaches.label" default="Tutorials - ANIC Cockroaches Tutorial" /></li>
          </ol>
        </nav>
        <h1>ANIC Cockroaches Tutorial</h1>
      </div>
    </header>
    <div>
      <div class="inner">
        <t:p>When latitude and longitude are provided on the label please copy them as written into the Verbatim Latitude and Verbatim Longitude fields. </t:p>
        <ul>
          <li>There is no need to enter a collection event in this case</li>
        </ul>
        <t:screenshot file="cockroach_01.png" />
        <t:p>The diagrams below provide a general guide to what information goes into what fields in the template.</t:p>
        <ol>
          <li><t:screenshot file="cockroach_02.png" /></li>
          <li><t:screenshot file="cockroach_03.png" /></li>
          <li><t:screenshot file="cockroach_04.png" /></li>
        </ol>
      </div>
    </div>
  </body>
</html>