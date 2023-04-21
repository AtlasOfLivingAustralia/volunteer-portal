<%@ page import="au.org.ala.volunteer.User" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}">
    <g:set var="entityName" value="${message(code: 'user.label', default: 'Volunteer')}"/>
    <title><cl:pageTitle title="${g.message(code:"institutionMessage.optout.title", default:"Opt out of Institution Communications")}" /></title>
    <asset:stylesheet src="label-autocomplete"/>
</head>

<body class="admin">
<cl:headerContent title="${message(code: 'institutionMessage.optout.title', default: 'Opt out of Institution Communications')}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')]
        ]
    %>

</cl:headerContent>
<div class="container" role="main">
    <div class="panel panel-default">
        <div class="panel-body">
            <h3 style="margin-block-start: 0.5em;">Add User Opt-out</h3>
        <g:form controller="user" class="form-horizontal" action="addUserOptOut" method="POST">
            <div class="form-group">
                <label class="control-label col-md-1" for="user">
                    Add User:
                </label>
                <div class="col-md-4">
                    <input class="form-control" id="user" type="text" placeholder="Enter user's name" value="${displayName}" required autocomplete="off"/>
                    <i id="ajax-spinner" class="fa fa-cog fa-spin hidden"></i>
                    <input id="userId" name="userId" type="hidden" value="${userId}"/>
                </div>
                <div class="col-md-1">
                    <input type="submit" class="save btn btn-default" id="addButton"
                           value="${message(code: 'default.button.add.label', default: 'Add')}"/>
                </div>
            </div>
        </g:form>
        </div>
    </div>

    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <table class="table table-striped table-hover">
                        <thead>
                        <tr>
                            <g:sortableColumn property="user.displayName"
                                              title="${message(code: 'user.displayName.label')}"
                                              params="${params}"/>

                            <g:sortableColumn property="dateCreated"
                                              title="${message(code: 'optout.dateCreated.label')}"
                                              params="${params}"/>

                            <th>Action</th>
                        </tr>
                        </thead>
                        <tbody>
                        <g:each in="${userList}" status="i" var="userOptOut">
                            <tr class="${(i % 2) == 0 ? 'even' : 'odd'}">
                                <td style="vertical-align: middle;">
                                    ${userOptOut.user.displayName} <span style="color: #bbbbbb;">(${userOptOut.user.email})</span>
                                </td>
                                <td style="vertical-align: middle;"><g:formatDate type="date" style="medium"
                                                          date="${userOptOut.dateCreated}"/></td>

                                <td>
                                <!-- Delete Record -->
                                    <button role="button" class="btn btn-danger btn-xs delete-optout"
                                            data-user-name="${userOptOut.user.displayName}"
                                            data-href="${createLink(controller: "user", action: "deleteOptOut", id: userOptOut.id, params: params)}"
                                            title="Delete opt-out request"><i class="fa fa-times"></i></button>
                                </td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>

                    <div class="pagination">
                        <g:paginate total="${userListCount ?: 0}" action="listOptOut" params="${params}"/>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<asset:javascript src="label-autocomplete" asset-defer=""/>
<asset:script type="text/javascript">
    jQuery(function($) {
        $.extend({
            postGo: function(url, params) {
                var $form = $("<form>")
                    .attr("method", "post")
                    .attr("action", url);
                $.each(params, function(name, value) {
                    $("<input type='hidden'>")
                        .attr("name", name)
                        .attr("value", value)
                        .appendTo($form);
                });
                $form.appendTo("body");
                $form.submit();
            }
        });

        const url = "${createLink(controller: 'user', action: 'listUsersForJson')}";
        labelAutocomplete("#user", url, '#ajax-spinner', function(item) {
            $('#userId').val(item.userId);
            return null;
        }, 'displayName');

        $('.delete-optout').click(function(e) {
            var $this = $(this);
            var href = $this.data('href');
            var name = $this.data('user-name');
            bootbox.confirm("Are you sure you wish to delete the opt-out request for \"" + name + "\"?", function(result) {
                if (result) {
                    $.postGo(href);
                }
            });
        });

        $("#btnAddOptOut").click(function(e) {
            e.preventDefault();
            bvp.newOptoutUser = "";
            bvp.showModal({
                title:'Add Opt-out request',
                url: "addOptOutFragment",
                onClose: function() {
                    if (bvp.newOptoutUser) {
                        // refresh page
                        location.reload();
                    }
                }
            });
        });
    });
</asset:script>
</body>
</html>
