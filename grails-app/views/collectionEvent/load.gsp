<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="au.org.ala.volunteer.Project" %>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'record.label', default: 'Record')}"/>
    <title><g:message code="collectionEvent.title.label"/></title>
</head>

<body>

<cl:headerContent title="${message(code: 'default.loadevents.label', default: 'Load Collection Events')}">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Admin')]
        ]
    %>
</cl:headerContent>

<div class="row">
    <div class="span12">
        <div class="buttons">
            <g:uploadForm action="loadCSV" controller="collectionEvent">
                <table>
                    <tr>
                        <td colspan="3"><g:message code="collectionEvent.upload.description"/></td>
                    </tr>
                    <tr>
                        <td><g:message code="collectionEvent.upload.collection_code"/></td>
                        <td><g:textField name="collectionCode"/></td>
                        <td><g:message code="collectionEvent.upload.existing_codes"/> ${collectionCodes}</td>
                    </tr>
                    <tr>
                        <td>File:</td>
                        <td><input type="file" name="csvfile"/></td>
                    </tr>
                    <tr>
                        <td colspan="3">
                            <g:message code="collectionEvent.upload.note"/><b>Note:</b> Your upload file should be a comma separated value file, with the following columns defined in the first line:
                            <pre>collevent_irn,LocCountry,LocProvinceStateTerritory,LocTownship,LocPreciseLocation,LatLatitude,LatLongitude,LatLatitudeDecimal,LatLongitudeDecimal,NamBriefName,ColDateVisitedFrom,site_irn</pre>
                            <table class="table table-bordered table-condensed">
                                <tr><td><g:message code="collectionEvent.upload.field_name"/></td>
                                    <td><g:message code="collectionEvent.upload.description.label"/></td></tr>
                                <tr><td><g:message code="collectionEvent.upload.collevent_irn"/></td>
                                    <td><g:message code="collectionEvent.upload.collevent_irn.description"/></td>
                                </tr>
                                <tr><td><g:message code="collectionEvent.upload.LocCountry"/></td>
                                    <td><g:message code="collectionEvent.upload.LocCountry.description"/></td></tr>
                                <tr><td><g:message code="collectionEvent.upload.LocProvinceStateTerritory"/></td>
                                    <td><g:message code="collectionEvent.upload.LocProvinceStateTerritory.description"/></td>
                                </tr>
                                <tr><td><g:message code="collectionEvent.upload.LocTownship"/></td>
                                    <td><g:message code="collectionEvent.upload.LocTownship.description"/></td>
                                </tr>
                                <tr><td><g:message code="collectionEvent.upload.LocPreciseLocation"/></td>
                                    <td><g:message code="collectionEvent.upload.LocPreciseLocation.description"/></td>
                                </tr>
                                <tr><td><g:message code="collectionEvent.upload.LatLatitude"/></td>
                                    <td><g:message code="collectionEvent.upload.LatLatitude.description"/></td></tr>
                                <tr><td><g:message code="collectionEvent.upload.LatLongitude"/></td>
                                    <td><g:message code="collectionEvent.upload.LatLongitude.description"/></td></tr>
                                <tr><td><g:message code="collectionEvent.upload.LatLatitudeDecimal"/></td>
                                    <td><g:message code="collectionEvent.upload.LatLatitudeDecimal.description"/></td></tr>
                                <tr><td><g:message code="collectionEvent.upload.LatLongitudeDecimal"/></td>
                                    <td><g:message code="collectionEvent.upload.LatLongitudeDecimal.description"/></td></tr>
                                <tr><td><g:message code="collectionEvent.upload.NamBriefName"/></td>
                                    <td><g:message code="collectionEvent.upload.NamBriefName.description"/></td></tr>
                                <tr><td><g:message code="collectionEvent.upload.ColDateVisitedFrom"/></td>
                                    <td><g:message code="collectionEvent.upload.ColDateVisitedFrom.description"/></td>
                                </tr>
                                <tr><td><g:message code="collectionEvent.upload.site_irn"/></td>
                                    <td><g:message code="collectionEvent.upload.site_irn.description"/></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>

                <div class="button"><g:actionSubmit class="submit" action="loadCSV"
                                                    value="${message(code: 'default.button.submit.label', default: 'Submit')}"/></div>
            </g:uploadForm>
        </div>
    </div>

</body>
</html>
