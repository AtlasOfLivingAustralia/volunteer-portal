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

    <a class="btn btn-success" href="${createLink(action: "create")}"><i
            class="icon-plus icon-white"></i>&nbsp;Add Institution</a>
    <a id="quick-create" role="button" class="create btn btn-default" href="javascript:void(0)" data-target="#quick-create-modal"
       data-toggle="modal"><g:message code="quick.new.label" default="Create from Atlas Collectory"
                                      args="[entityName]"/></a>
</cl:headerContent>

<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <table class="table table-striped table-hover">
                        <thead>
                        <tr>
                            <g:sortableColumn property="name" title="${message(code: 'institution.name.label', default: 'Name')}" mapping="institutionAdmin"/>
                            <g:sortableColumn property="contactName"
                                              title="${message(code: 'institution.contactName.label', default: 'Contact Name')}" mapping="institutionAdmin"/>
                            <g:sortableColumn property="contactEmail"
                                              title="${message(code: 'institution.contactEmail.label', default: 'Contact Email')}" mapping="institutionAdmin"/>
                            <g:sortableColumn property="dateCreated"
                                              title="${message(code: 'institution.dateCreated.label', default: 'Date Created')}" mapping="institutionAdmin"/>
                            <th/>
                        </tr>
                        </thead>
                        <tbody>
                        <g:each in="${institutionInstanceList}" status="i" var="institutionInstance">
                            <tr class="${(i % 2) == 0 ? 'even' : 'odd'}">

                                <td><g:link action="edit"
                                            id="${institutionInstance.id}">${fieldValue(bean: institutionInstance, field: "name")}</g:link></td>

                                <td>${fieldValue(bean: institutionInstance, field: "contactName")}</td>

                                <td>${fieldValue(bean: institutionInstance, field: "contactEmail")}</td>

                                <td><g:formatDate date="${institutionInstance.dateCreated}"/></td>

                                <td>
                                    <g:form url="[action: 'delete', id: institutionInstance.id]" method="DELETE">
                                        <g:actionSubmit class="btn btn-danger delete-institution"
                                                        value="${message(code: 'default.button.delete.label', default: 'Delete')}"/>
                                        <a class="btn btn-default"
                                           href="${createLink(controller: 'institution', action: 'index', id: institutionInstance.id)}"><i
                                                class="fa fa-home"></i></a>
                                        <a class="btn btn-default"
                                           href="${createLink(controller: 'institutionAdmin', action: 'edit', id: institutionInstance.id)}"><i
                                                class="fa fa-edit"></i></a>
                                    </g:form>
                                </td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>

                    <div class="pagination">
                        <g:paginate total="${institutionInstanceCount ?: 0}"/>
                    </div>
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
<r:script>
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
            });
</r:script>
</body>
</html>
