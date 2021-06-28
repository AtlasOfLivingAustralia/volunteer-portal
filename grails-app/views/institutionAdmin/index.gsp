<%@ page import="au.org.ala.volunteer.Institution" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'institution.label', default: 'Institution')}"/>
    <title><g:message code="default.list.label" args="[entityName]"/></title>
</head>

<body class="admin">

<cl:headerContent title="${message(code: 'default.institutions.label', default: 'Manage Institutions')}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')]
        ]

    %>

    <cl:ifSiteAdmin>
        <div class="btn-group">
            <a class="btn btn-success dropdown-toggle" data-toggle="dropdown" href="#">
                <i class="fa fa-cog"></i> Tools
                <span class="caret"></span>
            </a>
            <ul class="dropdown-menu">
                <li>
                    <a href="${createLink(action: "create")}"><i class="fa fa-plus"></i>&nbsp;Add Institution</a>
                </li>
                <li class="divider"></li>
                <li>
                    <a href="${createLink(action: "applications")}"><i class="fa fa-inbox"></i>&nbsp;Manage Applications</a>
                </li>
                <li class="divider"></li>
                <li>
                    <a href="${createLink(action: "apply")}" target="_blank"><i class="fa fa-share-square-o"></i>&nbsp;Application Form</a>
                </li>
            </ul>
        </div>
    </cl:ifSiteAdmin>
</cl:headerContent>

<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <cl:ifSiteAdmin>
            <div class="row">
                <div class="col-md-3">
                    <g:select class="form-control statusFilter" name="statusFilter" from="${[[key: 'active', value: 'Active Institutions'], [key: 'inactive', value: 'Inactive Institutions']]}"
                              optionKey="key"
                              optionValue="value"
                              value="${params?.statusFilter}"
                              noSelection="['':'- Filter by Status -']" />
                </div>
            </div>
            </cl:ifSiteAdmin>
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <table class="table table-striped table-hover">
                        <thead>
                        <cl:ifSiteAdmin>
                        <tr>
                            <g:sortableColumn property="name"
                                              title="${message(code: 'institution.name.label', default: 'Name')}"
                                              params="${params}"/>
                            <g:sortableColumn property="contactName"
                                              title="${message(code: 'institution.contactName.label', default: 'Contact Name')}"
                                              params="${params}"/>
                            <g:sortableColumn property="contactEmail"
                                              title="${message(code: 'institution.contactEmail.label', default: 'Contact Email')}"
                                              params="${params}"/>
                            <g:sortableColumn property="dateCreated"
                                              title="${message(code: 'institution.dateCreated.label', default: 'Date Created')}"
                                              params="${params}"/>
                            <th/>
                        </tr>
                        </cl:ifSiteAdmin>
                        <cl:ifNotSiteAdmin>
                            <tr>
                                <th>${message(code: 'institution.name.label', default: 'Name')}</th>
                                <th>${message(code: 'institution.contactName.label', default: 'Contact Name')}</th>
                                <th>${message(code: 'institution.contactEmail.label', default: 'Contact Email')}</th>
                                <th>${message(code: 'institution.dateCreated.label', default: 'Date Created')}</th>
                            </tr>
                        </cl:ifNotSiteAdmin>
                        </thead>
                        <tbody>
                        <g:each in="${institutionInstanceList}" status="i" var="institutionInstance">
                            <tr class="${(i % 2) == 0 ? 'even' : 'odd'}">

                                <td width="35%"><g:link action="edit"
                                            id="${institutionInstance.id}">${fieldValue(bean: institutionInstance, field: "name")}</g:link>
                                    <g:if test="${institutionInstance.isInactive}"><i>(inactive)</i></g:if>
                                </td>

                                <td>${fieldValue(bean: institutionInstance, field: "contactName")}</td>

                                <td>${fieldValue(bean: institutionInstance, field: "contactEmail")}</td>

                                <td><g:formatDate format="yyyy-MM-dd" date="${institutionInstance.dateCreated}"/></td>

                                <td>
                                    <g:form url="[action: 'delete', id: institutionInstance.id]" id="delete-${institutionInstance.id}" method="DELETE">

                                        <a class="btn btn-xs btn-default"
                                           href="${createLink(controller: 'institution', action: 'index', id: institutionInstance.id)}"><i
                                                class="fa fa-home"></i></a>
                                        <a class="btn btn-xs btn-default"
                                           href="${createLink(controller: 'institutionAdmin', action: 'edit', id: institutionInstance.id)}"><i
                                                class="fa fa-edit"></i></a>
                                        <cl:ifSiteAdmin>
                                            <g:if test="${institutionInstance.getProjectCount() == 0}">
                                                <a class="btn btn-xs btn-danger delete-institution" alt="Delete" title="Delete"><i class="fa fa-times"></i></a>
                                            </g:if>
                                            <g:else>
                                                <button class="btn btn-xs btn-danger delete-institution" alt="Delete" title="You cannot delete an institution that has projects." disabled>
                                                    <i class="fa fa-times"></i>
                                                </button>
                                            </g:else>
                                        </cl:ifSiteAdmin>
                                    </g:form>
                                </td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>
                    <g:if test="${institutionInstanceCount > 20}">
                    <div class="pagination">
                        <g:paginate total="${institutionInstanceCount ?: 0}"/>
                    </div>
                    </g:if>
                </div>
            </div>
        </div>
    </div>
</div>

<div id="quick-create-modal" class="modal fade">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>

                <h3>Quick Create Institution</h3>
            </div>

            <div class="modal-body">
                <form id="quick-create-form" action="${createLink(controller: 'institutionAdmin', action: 'quickCreate')}"
                      method="POST">
                    <select name="cid" id="cid" class="form-control">
                    </select>
                </form>
            </div>

            <div class="modal-footer">
                <a href="#" class="btn btn-default" data-dismiss="modal">Close</a>
                <a href="#" class="btn btn-primary" id="quick-create-button">Create Institution</a>
            </div>
        </div>
    </div>
</div>
<asset:script>
    $(function($) {
        var api = "${createLink(controller: 'ajax', action: 'availableCollectoryProviders')}";
        $('#quick-create-modal').on('shown.bs.modal', function (e) {
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

        $('.delete-institution').on('click', function(e) {
            e.preventDefault();
            var self = this;
            bootbox.confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}', function(result) {
                if (result) {
                    $(self).closest('form').submit();
                }
            });
        });

        $('.statusFilter').change(function() {
            let filter = $(this).val();

            var url = "${createLink(controller: 'institutionAdmin', action: 'index')}" +

                "?statusFilter=" + filter;
            window.location = url;
        });
    });
</asset:script>
</body>
</html>
