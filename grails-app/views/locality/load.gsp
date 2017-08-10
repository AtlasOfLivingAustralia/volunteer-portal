<%@ page import="au.org.ala.volunteer.Project" %>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title>Locality Upload</title>
</head>

<body>

<cl:headerContent title="Load Locality Data">
    <%
        pageScope.crumbs = [
                [label: message(code: 'default.admin.label', default: 'Admin'), link: createLink(controller: 'admin', action: 'index')]
        ]
    %>
</cl:headerContent>

<div class="row">
    <div class="span12">

        <g:uploadForm action="loadCSV" controller="locality">
            <table>
                <tr>
                    <td colspan="3"><g:message code="locality.load.enter_a_name"/></td>
                </tr>

                <tr>
                    <td>Collection code:</td>

                    <td>
                        <g:textField name="collectionCode"/>
                        %{--<g:select from="${collectionCodes}" name="collectionCode"/>--}%
                    </td>
                    <td><g:message code="locality.load.existing_collection_codes"/> ${collectionCodes?.join(", ")}</td>
                </tr>
                <tr>
                    <td>File:</td>
                    <td><input type="file" name="csvfile"/></td>
                </tr>
                <tr>

                    <td colspan="3">
                        <g:message code="locality.load.note"/>
                        <pre>site_irn,LocCountry,LocProvinceStateTerritory,LocTownship,LocPreciseLocation,LatLatitude,LatLongitude,LatLatitudeDecimal,LatLongitudeDecimal</pre>
                        <table class="table table-bordered table-striped table-condensed">
                            <tr><td><g:message code="collectionEvent.upload.field_name"/></td><td><g:message code="collectionEvent.upload.description"/></td></tr>
                            <tr><td><g:message code="collectionEvent.upload.site_irn"/></td><td><g:message code="collectionEvent.upload.site_irn.description"/></td>
                            </tr>
                            <tr><td><g:message code="collectionEvent.upload.LocCountry"/></td><td><g:message code="collectionEvent.upload.LocCountry.description"/></td></tr>
                            <tr><td><g:message code="collectionEvent.upload.LocProvinceStateTerritory"/></td><td><g:message code="collectionEvent.upload.LocProvinceStateTerritory.description"/></td>
                            </tr>
                            <tr><td><g:message code="collectionEvent.upload.LocTownship"/></td><td><g:message code="collectionEvent.upload.LocTownship.description"/></td>
                            </tr>
                            <tr><td><g:message code="collectionEvent.upload.LocPreciseLocation"/></td><td><g:message code="collectionEvent.upload.LocPreciseLocation.description"/></td>
                            </tr>
                            <tr><td><g:message code="collectionEvent.upload.LatLatitude"/></td><td><g:message code="collectionEvent.upload.LatLatitude.description"/></td></tr>
                            <tr><td><g:message code="collectionEvent.upload.LatLongitude"/></td><td><g:message code="collectionEvent.upload.LatLongitude.description"/></td>
                            </tr>
                            <tr><td><g:message code="collectionEvent.upload.LatLatitudeDecimal"/></td><td><g:message code="collectionEvent.upload.LatLatitudeDecimal.description"/></td></tr>
                            <tr><td><g:message code="collectionEvent.upload.LatLongitudeDecimal"/></td><td><g:message code="collectionEvent.upload.LatLongitudeDecimal.description"/></td></tr>
                        </table>
                    </td>
                </tr>

            </table>

            <div class="button"><g:actionSubmit class="submit btn btn-primary" action="loadCSV"
                                                value="${message(code: 'default.submit', default: 'Submit')}"/></div>
        </g:uploadForm>
    </div>
</div>
</body>
</html>
