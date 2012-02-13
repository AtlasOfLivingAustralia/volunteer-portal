<%@ page import="au.org.ala.volunteer.Project" %>
<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<html>
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
<div class="nav">
    <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a>
    </span>
</div>

<div class="body">
    <h1>Load CSV</h1>

    <g:form method="post">
        <div class="dialog">
            <table>
                <tbody>
                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="projectId"><g:message code="record.projectId.label" default="Project Id"/></label>
                    </td>
                    <td valign="top" class="value">
                        <g:select name="projectId" id="projectId" from="${projectList}" optionKey="id"
                                  optionValue="name"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="csv">
                            <g:message code="record.csv.label" default="Paste CSV here"/>
                            <a href="#" class="fieldHelp"
                               title="identifier, imageUrl [,institutionCode, catalogNumber, scientificName]"><span
                                    class="help-container">&nbsp;</span></a>
                        </label>
                    </td>
                    <td valign="top" class="value">
                        <g:textArea name="csv" value="" cols="100" rows="50" style="width:100%;"/>
                    </td>
                </tr>

                </tbody>
            </table>
        </div>

        <div class="buttons">
            <span class="button"><g:actionSubmit class="submit" action="loadCSV"
                                                 value="${message(code: 'default.button.submit.label', default: 'Submit')}"/></span>
            <span class="button"><g:actionSubmit class="cancel" action="list"
                                                 value="${message(code: 'default.button.cancel.label', default: 'Cancel')}"/></span>
        </div>
    </g:form>
</div>

</body>
</html>
