<%@ page import="au.org.ala.volunteer.Project" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'record.label', default: 'Record')}"/>
    <title>CSV Image Upload</title>
    <r:require modules="qtip"/>
    <r:script type="text/javascript">
        $(document).ready(function () {
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
            }).bind('click', function (e) {
                e.preventDefault();
                return false;
            });
        });
    </r:script>
</head>

<body class="two-column-right">
<div class="nav">
    <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a>
    </span>
    <g:if test="${params.id}">
        <span class="menuButton"><a class="home"
                                    href="${createLink(controller: 'project', action: 'edit', id: params.id)}">Edit project</a>
        </span>
    </g:if>
</div>

<div class="inner">
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
                                  optionValue="name" value="${params.id}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="csv">
                            <g:message code="record.csv.label" default="Paste CSV here"/>
                            <a href="#" class="btn btn-default btn-xs fieldHelp"
                               title="identifier, imageUrl [,institutionCode, catalogNumber, scientificName]"><i
                                    class="fa fa-question help-container"></i></a>
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
            Duplicate handling mode:
            <select name="duplicateMode">
                <option value="skip">Skip duplicates</option>
                <option value="replace">Replace duplicates</option>
            </select>
            <span class="button"><g:actionSubmit class="submit" action="loadCSVAsync"
                                                 value="${message(code: 'default.button.submit.label', default: 'Submit')}"/></span>
            <span class="button"><g:actionSubmit class="cancel" action="list"
                                                 value="${message(code: 'default.button.cancel.label', default: 'Cancel')}"/></span>
        </div>
    </g:form>
</div>

</body>
</html>
