<%@ page import="au.org.ala.volunteer.Project" %>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'record.label', default: 'Record')}"/>
    <title>CSV Image Upload</title>
    <script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.qtip-1.0.0-rc3.min.js')}"></script>
    <script type="text/javascript">
        $(document).ready(function() {
            // tootltip on help icon
            $("a.fieldHelp").qtip({
                tip: true,
                position: {
                    corner: {
                        target: 'topMiddle',
                        tooltip: 'bottomLeft'
                    }
                },
                style: {
                    width: 400,
                    padding: 8,
                    background: 'white', //'#f0f0f0',
                    color: 'black',
                    textAlign: 'left',
                    border: {
                        width: 4,
                        radius: 5,
                        color: '#E66542'// '#E66542' '#DD3102'
                    },
                    tip: 'bottomLeft',
                    name: 'light' // Inherit the rest of the attributes from the preset light style
                }
            }).bind('click', function(e) {
                        e.preventDefault();
                        return false;
                    });
        });
    </script>
</head>

<body class="two-column-right">

  <cl:messages />
  <div class="nav">
      <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
      <g:if test="${params.id}">
        <span class="menuButton"><a class="home" href="${createLink(controller: 'project', action:'edit', id: params.id)}">Load localities</a></span>
      </g:if>
  </div>

  <div class="inner">
      <h1>Load Locality data from CSV</h1>

      <div class="buttons">
          <g:uploadForm action="loadCSV" controller="locality">
              <table>
                  <tr>
                    <td colspan="3">Enter a name (collection code) for your locality list to identify it clearly. This is the name you will choose when selecting a locality picklist when creating a new expedition. For eg AM_Entomology or ANIC or Smithsonian_MarineInverts</td>
                  </tr>

                  <tr>
                    <td>Collection code:</td>

                    <td>
                      <g:textField name="collectionCode" />
                      %{--<g:select from="${collectionCodes}" name="collectionCode"/>--}%
                    </td>
                    <td>Existing collection codes: ${collectionCodes?.join(", ")}</td>
                  </tr>
                  <tr>
                      <td>File:</td>
                      <td><input type="file" name="csvfile" /></td>
                  </tr>
                <tr>

                  <td colspan="3">
                  <b>Note:</b> Your upload file should be a comma separated value file, with the following columns defined in the first line:<b/>
                  <pre>site_irn,LocCountry,LocProvinceStateTerritory,LocTownship,LocPreciseLocation,LatLatitude,LatLongitude,LatLatitudeDecimal,LatLongitudeDecimal</pre>
                    <table border="1">
                      <tr><td>Field Name</td><td>Description</td></tr>
                      <tr><td>site_irn</td><td>The internal record number (institution/database specific) for the locality/site.</td></tr>
                      <tr><td>LocCountry</td><td>The name of the country e.g. 'Australia'</td></tr>
                      <tr><td>LocProvinceStateTerritory</td><td>The name of the State or Territory or Province e.g. 'New South Wales'</td></tr>
                      <tr><td>LocTownship</td><td>The name of the city, township, village etc e.g. 'Wagga Wagga'</td></tr>
                      <tr><td>LocPreciseLocation</td><td>Textual description of the locality. e.g. 3 km north of Sandy Creek</td></tr>
                      <tr><td>LatLatitude</td><td>Latitude formatted as degrees minutes seconds</td></tr>
                      <tr><td>LatLongitude</td><td>Longitude formatted as degress minutes seconds</td></tr>
                      <tr><td>LatLatitudeDecimal</td><td>Latitude as decimal degrees</td></tr>
                      <tr><td>LatLongitudeDecimal</td><td>Longitude as decimal degrees</td></tr>
                    </table>
                  </td>
                </tr>

              </table>

              <div class="button"><g:actionSubmit class="submit" action="loadCSV" value="${message(code: 'default.button.submit.label', default: 'Submit')}"/></div>
          </g:uploadForm>
  </div>

</body>
</html>
