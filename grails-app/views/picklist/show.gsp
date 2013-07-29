<%@ page import="au.org.ala.volunteer.Picklist" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'picklist.label', default: 'Picklist')}" />
        <title><g:message code="default.show.label" args="[entityName]" /></title>
        <r:script type="text/javascript">

            $(document).ready(function() {

                $("#searchButton").click(function(e) {
                    e.preventDefault();
                    doSearch();
                });

                $("#q").keypress(function(e) {
                    if (e.keyCode == 13) {
                        e.preventDefault();
                        doSearch();
                    }
                });

                function doSearch() {
                    var query = $("#q").val()
                    location.href="?q=" + query;
                }

                $("#q").focus();

            }); // end .ready()
        </r:script>

    </head>
    <body class="sublevel sub-site volunteerportal">

        <cl:headerContent title="${message(code:"default.show.label", args:[entityName])} - ${picklistInstance.name}">
            <%
                pageScope.crumbs = [
                    [link: createLink(controller: 'picklist', action: 'list'), label: message(code: 'default.list.label', args: [entityName])]
                ]
            %>
        </cl:headerContent>

        <div class="row">
            <div id="content" class="span12">
                <div class="alert alert-info">
                    <input style="margin-bottom: 0px" type="text" name="q" id="q" value="${params.q}" size="40" />
                    <button class="btn btn-small" id="searchButton">search</button>
                </div>
                <table class="table table-condensed table-bordered table-striped">
                    <thead>
                        <tr>
                            <g:sortableColumn property="id" title="${message(code: 'picklistItem.id.label', default: 'Id')}" />
                            <g:sortableColumn property="key" title="${message(code: 'picklistItem.key.label', default: 'Key')}" />
                            <g:sortableColumn property="value" title="${message(code: 'picklistItem.value.label', default: 'Value')}" />
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${picklistItemInstanceList}" status="i" var="picklistItemInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                            <td><g:link controller="picklistItem" action="show" id="${picklistItemInstance.id}">${fieldValue(bean: picklistItemInstance, field: "id")}</g:link></td>
                            <td>${fieldValue(bean: picklistItemInstance, field: "key")}</td>
                            <td>${fieldValue(bean: picklistItemInstance, field: "value")}</td>
                        </tr>
                    </g:each>
                    </tbody>
                </table>
                <div class="pagination">
                    <g:paginate total="${picklistItemInstanceTotal}" id="${picklistInstance.id}"/>
                </div>
            </div>
            <div>
                <g:form>
                    <g:hiddenField name="id" value="${picklistInstance?.id}" />
                    <g:actionSubmit class="edit btn btn-small" action="edit" value="${message(code: 'default.button.edit.label', default: 'Edit')}" />
                    <g:actionSubmit class="delete btn btn-small btn-danger" action="delete" value="${message(code: 'default.button.delete.label', default: 'Delete')}" onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');" />
                </g:form>
            </div>
        </div>
    </body>
</html>
