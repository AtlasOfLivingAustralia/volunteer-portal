<%@ page import="au.org.ala.volunteer.Project" %>
<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
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
                    <td>Institution:</td>
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
              </table>

              <div class="button"><g:actionSubmit class="submit" action="loadCSV" value="${message(code: 'default.button.submit.label', default: 'Submit')}"/></div>
          </g:uploadForm>
  </div>

</body>
</html>
