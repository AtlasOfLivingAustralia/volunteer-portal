<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <title><g:message code="leaderBoardAdmin.label" default="Honour Board Configuration"/></title>
    <asset:stylesheet src="label-autocomplete"/>
    <style>
        li.user > span {
            margin-right: 5px;
        }
        i.icon-remove {
            cursor: pointer;
        }
    </style>
</head>

<body class="admin">
<cl:headerContent title="${message(code: 'default.leaderboardadmin.label', default: 'Honour Board Configuration')}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')]
        ]
    %>
</cl:headerContent>

<div class="container">
    <div class="card">
        <div class="card-body">
            <div class="row">
                <div class="col-md-12">
                    <h3>Honour Board Configuration</h3>
                    <hr/>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <p>Use this page to manage users who should not appear in the Honour Board.</p>
                </div>
            </div>
            <div class="row">
                <div class="col-12">
                    <label class="form-label" for="add-user">Add User:</label>
                    <input id="add-user" type="text" autocomplete="off" class="form-control typeahead"
                           user-search-url="${createLink(controller: 'leaderBoardAdmin', action: 'findEligibleUsers')}"
                           user-add-url="${createLink(controller: 'leaderBoardAdmin', action: 'addIneligibleUser')}"
                           user-remove-url="${createLink(controller: 'leaderBoardAdmin', action: 'removeIneligibleUser')}"
                            placeholder="Joe Bloggs" aria-describedby="add-user-help-block"/>
                    <div id="add-user-help-block" class="form-text">
                        Start typing the name of the user you wish to add to the ineligible list. Select the user if they appear in the suggestions.
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-body">
            <div class="row">
                <div class="col-md-12">
                    <h3>Ineligible Honour Board users <asset:image src="spinner.gif" height="16px" width="16px" id="ajax-spinner" class="d-none"/></h3>
                    <hr/>
                    <div class="row">
                        <div class="col-12 table-responsive">
                            <table class="table table-striped table-hover">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>User</th>
                                        <th class="text-end">Action</th>
                                    </tr>
                                </thead>
                                <tbody id="user-list">
                                    <g:each in="${users}" var="user">
                                        <tr class="user">
                                            <td>${user.userId}</td>
                                            <td>${user.displayName}</td>
                                            <td class="text-end">
                                                <g:set var="actionLabel" value="${(user.userId == 'system') ? 'System user cannot be removed' : 'Remove user from ineligible list'}"/>
                                                <button type="button" class="btn btn-sm btn-danger" data-user-id="${user.userId}" ${ (user.userId == 'system') ? 'disabled' : '' } title="${actionLabel}" aria-label="${actionLabel}">
                                                    <i  class="fa fa-times"></i>
                                                </button>

                                            </td>
                                        </tr>
                                    </g:each>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                <div class="col-4 float-end">

                </div>
            </div>
            <button class="btn btn-sm btn-outline-secondary float-end" onclick="window.scrollTo({ top: 0, behavior: 'smooth' });"><i class="fa fa-arrow-up"></i> Return to top</button>
        </div>
    </div>
</div>
<asset:javascript src="label-autocomplete" asset-defer=""/>
<asset:script>
    $(function ($) {
        labelAutocomplete("#add-user", $("#add-user").attr('user-search-url'), '#ajax-spinner', function(item) {
                var updateUrl = $("#add-user").attr('user-add-url');
                $.ajax(updateUrl, {type: 'POST', data: { id: item.userId }})
                    .done(function(data) {
                        $("<tr>", { class: "user" })
                            .append($("<td>").text(item.userId))
                            .append($("<td>").text(item.displayName))
                            .append(
                                $("<td>", { class: "text-end" }).append(
                                    $("<button>", {
                                        type: "button",
                                        class: "btn btn-sm btn-danger",
                                        "data-user-id": item.userId,
                                        title: "Remove user from ineligible list",
                                        "aria-label": "Remove user from ineligible list"
                                    }).append($("<i>", { class: "fa fa-times" }))
                                )
                            )
                            .appendTo("#user-list");

                        $("#add-user").val('');
                        bvp.alert("User successfully added to the ineligible list");
                    })
                    .fail(function() { bvp.alert("Couldn't add user to the ineligible list"); });
                return null;
        }, 'displayName');

        function showSpinner() {
            $('#ajax-spinner').removeClass('d-none');
        }

        function hideSpinner() {
            $('#ajax-spinner').addClass('d-none');
        }

        function onDeleteClick(e) {
            showSpinner();
            var button = $(e.currentTarget);
            $.ajax($('#add-user').attr('user-remove-url'), {type: 'POST', data: { id: button.attr('data-user-id') }})
            .done(function (data) {
                button.closest("tr").remove();
                $("#add-user").val('');
                bvp.alert("User successfully removed from the ineligible list");
            })
            .fail(function() { bvp.alert("Couldn't remove user from the ineligible list"); })
            .always(hideSpinner);
        }

        $('#user-list').on('click', '.user button', onDeleteClick);
    });

</asset:script>

</body>
</html>
