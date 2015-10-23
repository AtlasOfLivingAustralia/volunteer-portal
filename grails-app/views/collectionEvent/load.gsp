<%@ page import="au.org.ala.volunteer.Project" %>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'record.label', default: 'Record')}"/>
    <title>Load Collection Events</title>
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
                        <td colspan="3">Enter a name (collection code) for your collection events list to identify it clearly. This is the name you will choose when selecting a collection event picklist when creating a new expedition. For eg AM_Entomology or ANIC or Smithsonian_MarineInverts</td>
                    </tr>
                    <tr>
                        <td>Collection code:</td>
                        <td><g:textField name="collectionCode"/></td>
                        <td>Existing codes: ${collectionCodes}</td>
                    </tr>
                    <tr>
                        <td>File:</td>
                        <td><input type="file" name="csvfile"/></td>
                    </tr>
                    <tr>
                        <td colspan="3">
                            <b>Note:</b> Your upload file should be a comma separated value file, with the following columns defined in the first line:<b/>
                            <pre>collevent_irn,LocCountry,LocProvinceStateTerritory,LocTownship,LocPreciseLocation,LatLatitude,LatLongitude,LatLatitudeDecimal,LatLongitudeDecimal,NamBriefName,ColDateVisitedFrom,site_irn</pre>
                            <table class="table table-bordered table-condensed">
                                <tr><td>Field Name</td><td>Description</td></tr>
                                <tr><td>collevent_irn</td><td>Collection Event internal record number. Institution specific identifier for the event</td>
                                </tr>
                                <tr><td>LocCountry</td><td>The name of the country e.g. 'Australia'</td></tr>
                                <tr><td>LocProvinceStateTerritory</td><td>The name of the State or Territory or Province e.g. 'New South Wales'</td>
                                </tr>
                                <tr><td>LocTownship</td><td>The name of the city, township, village etc e.g. 'Wagga Wagga'</td>
                                </tr>
                                <tr><td>LocPreciseLocation</td><td>Textual description of the locality. e.g. 3 km north of Sandy Creek</td>
                                </tr>
                                <tr><td>LatLatitude</td><td>Latitude formatted as degrees minutes seconds</td></tr>
                                <tr><td>LatLongitude</td><td>Longitude formatted as degress minutes seconds</td></tr>
                                <tr><td>LatLatitudeDecimal</td><td>Latitude as decimal degrees</td></tr>
                                <tr><td>LatLongitudeDecimal</td><td>Longitude as decimal degrees</td></tr>
                                <tr><td>NamBriefName</td><td>Names of collectors (e.g. A.N.Smith)</td></tr>
                                <tr><td>ColDateVisitedFrom</td><td>The date of the collection event in the format YYYY-MM-DD (YYYY-MM if day is missing, or YYYY if both day and month are missing)</td>
                                </tr>
                                <tr><td>site_irn</td><td>The internal record number for the location of the event. Institution specific identifier for the site.</td>
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
