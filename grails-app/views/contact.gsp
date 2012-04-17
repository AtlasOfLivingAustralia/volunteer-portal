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

      </style>

  </head>
  <body class="sublevel sub-site volunteerportal">

    <cl:navbar selected="contact" />

    <header id="page-header">      
      <div class="inner">
        <g:if test="${flash.message}">
          <div class="message">${flash.message}</div>
        </g:if>
        <nav id="breadcrumb">
          <ol>
            <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
            <li class="last"><g:message code="default.contact.label" default="Contact Us" /></li>
          </ol>
        </nav>
        <h1>Contact Us</h1>
      </div>
    </header>
    <div>
      <div class="inner">
        <h2>Help in using the BVP and reporting issues</h2>
        <b>E</b> paul.flemons at austmus.gov.au<br/>
        <b>T</b> (02) 9320 6343<br/>
        Australian Museum<br/>
        Sydney NSW 2010
        <p/>
        <h2>Help in using the Atlas</h2>
        <b>E</b> <a href="mailto:support@ala.org.au">support@ala.org.au</a><br/>
        <b>T</b> (02) 6246 4108<br/>
        GPO Box 1700<br/>
        Canberra ACT 2601
      </div>
    </div>
  </body>
</html>
