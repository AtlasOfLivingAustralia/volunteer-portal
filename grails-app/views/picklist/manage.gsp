<%@ page import="au.org.ala.volunteer.Picklist" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'picklist.label', default: 'Picklist')}"/>
        <title><g:message code="default.list.label" args="[entityName]"/></title>
    </head>

    <body>

        <cl:headerContent title="${message(code:'default.picklists.label', default:'Manage Picklists')}">
            <%
                pageScope.crumbs = [
                    [link:createLink(controller:'admin'),label:message(code:'default.admin.label', default:'Admin')]
                ]
            %>
        </cl:headerContent>

        <div class="row">
            <div class="span12">
                <g:form controller="picklist" action="manage">

                    <div style="vertical-align: bottom">
                        <g:select name="picklistId" from="${picklistInstanceList}" optionKey="id" optionValue="name" value="${id}"/>
                        <g:actionSubmit class="btn" name="download.picklist" value="${message(code: 'download.picklist.label', default: 'Download')}" action="download"/>
                        <g:actionSubmit class="btn" name="load.textarea" value="${message(code: 'loadtextarea.label', default: 'Load items into text area')}" action="loadcsv"/>
                    </div>
                    <br/>

                    <p>
                        <g:message code="picklist.paste.here.label" default="Paste csv list here. Each line should take the format '&lt;value&gt;'[,&lt;optional key&gt;]"/>
                    </p>
                    <g:textArea name="picklist" rows="25" cols="40" value="${picklistData}"/>
                    <br>
                    <g:actionSubmit class="btn btn-primary" name="upload.picklist" value="${message(code: 'upload.picklist.label', default: 'Upload')}" action="uploadCsvData"/>
                </g:form>

            </div>
        </div>

    </body>
</html>
