
<%@ page import="au.org.ala.volunteer.Institution" %>
<!DOCTYPE html>
<html>
	<head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
		<g:set var="entityName" value="${message(code: 'institution.label', default: 'Institution')}" />
        <title><g:message code="default.list.label" args="[entityName]"/></title>
	</head>
	<body>

        <cl:headerContent title="${message(code:'default.institutions.label', default:'Manage Institutions')}">
            <%
                pageScope.crumbs = [
                        [link:createLink(controller:'admin'),label:message(code:'default.admin.label', default:'Admin')]
                ]
            %>
        </cl:headerContent>

		<div class="nav" role="navigation">
			<ul>
				<li><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
				<li><g:link class="create" action="create"><g:message code="default.new.label" args="[entityName]" /></g:link></li>
                <li><a id="quick-create" role="button" class="create" href="javascript:void(0)" data-target="#quick-create-modal" data-toggle="modal"><g:message code="quick.new.label" default="Quick Create" args="[entityName]" /></a></li>
			</ul>
		</div>
		<div id="list-institution" class="content scaffold-list" role="main">
			<h1><g:message code="default.list.label" args="[entityName]" /></h1>
			<g:if test="${flash.message}">
				<div class="message" role="status">${flash.message}</div>
			</g:if>
			<table>
    			<thead>
					<tr>

                        <g:sortableColumn property="name" title="${message(code: 'institution.name.label', default: 'Name')}" />

                        <g:sortableColumn property="contactName" title="${message(code: 'institution.contactName.label', default: 'Contact Name')}" />

                        <g:sortableColumn property="contactEmail" title="${message(code: 'institution.contactEmail.label', default: 'Contact Email')}" />

						<g:sortableColumn property="dateCreated" title="${message(code: 'institution.dateCreated.label', default: 'Date Created')}" />
					
					</tr>
				</thead>
				<tbody>
				<g:each in="${institutionInstanceList}" status="i" var="institutionInstance">
					<tr class="${(i % 2) == 0 ? 'even' : 'odd'}">

                        <td><g:link action="show" id="${institutionInstance.id}">${fieldValue(bean: institutionInstance, field: "name")}</g:link></td>

                        <td>${fieldValue(bean: institutionInstance, field: "contactName")}</td>

                        <td>${fieldValue(bean: institutionInstance, field: "contactEmail")}</td>

						<td><g:formatDate date="${institutionInstance.dateCreated}" /></td>

					</tr>
				</g:each>
				</tbody>
			</table>
			<div class="pagination">
				<g:paginate total="${institutionInstanceCount ?: 0}" />
			</div>
		</div>
        <div id="quick-create-modal" class="modal hide fade">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h3>Quick Create Institution</h3>
            </div>
            <div class="modal-body">
                <form id="quick-create-form" action="${createLink(controller: 'institution', action: 'quickCreate')}" method="POST">
                    <select name="cid" id="cid" class="input-block-level">
                    </select>
                </form>
            </div>
            <div class="modal-footer">
                <a href="#" class="btn" data-dismiss="modal">Close</a>
                <a href="#" class="btn btn-primary" id="quick-create-button">Create Institution</a>
            </div>
        </div>
        <r:script>
            jQuery(function($) {
                var api = "${createLink(controller: 'ajax', action: 'newCis')}";
                $('#quick-create-modal').on('show', function (e) {
                    loadQuickCreateData();
                })
                $('#quick-create-button').click(function (e) {
                    $('#quick-create-form').submit();
                });
                function loadQuickCreateData() {
                    removeOptions(document.getElementById("cid"));
                    $('#quick-create-button').button('loading');
                    $.getJSON(api, function(data) {
                        var cid = document.getElementById('cid')
                        var i;
                        for (i = 0; i < data.length; ++i) {
                               var o = new Option(data[i].name,data[i].id);
                               o.innerHTML = data[i].name; // required for IE 8
                               cid.appendChild(o);
                        }
                        $('#quick-create-button').button('reset');
                    });
                };
                function removeOptions(selectbox)
                {
                    var i;
                    for(i=selectbox.options.length-1;i>=0;i--)
                    {
                        selectbox.remove(i);
                    }
                }
            });
        </r:script>
	</body>
</html>
