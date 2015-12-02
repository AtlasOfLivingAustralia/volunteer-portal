<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="leaderBoardAdmin.label" default="Honour Board Configuration"/></title>
    <r:require modules="labelAutocomplete"/>
    <r:style>
        li.user > span {
            margin-right: 5px;
        }
        i.icon-remove {
            cursor: pointer;
        }
    </r:style>
</head>

<body class="admin">
<div class="container">
    <cl:headerContent title="${message(code: 'default.leaderboardadmin.label', default: 'Honour Board Configuration')}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')]
            ]
        %>
    </cl:headerContent>

    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <div class="row">
                        <div class="col-md-12">
                            <h4>Ineligible Honour Board users <r:img dir="images" file="spinner.gif" height="16px" width="16px"
                                                            id="ajax-spinner" class="hidden"/></h4>
                            <hr/>
                        </div>
                    <hr/>
                    <div class="row">
                        <div class="col-md-offset-1 col-md-8">
                            <ul id="user-list">
                                <g:each in="${users}" var="user">
                                    <li class="user">
                                        <span class="pointer">${user.displayName}</span><i data-user-id="${user.userId}" class="fa fa-times pointer"></i>
                                    </li>
                                </g:each>
                            </ul>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-2 text-right">
                            <label for="add-user">Add User:</label>
                        </div>
                        <div class="col-md-4">
                            <input id="add-user" type="text" autocomplete="off" class="form-control typeahead"
                                   user-search-url="${createLink(controller: 'leaderBoardAdmin', action: 'findEligibleUsers')}"
                                   user-add-url="${createLink(controller: 'leaderBoardAdmin', action: 'addIneligibleUser')}"
                                   user-remove-url="${createLink(controller: 'leaderBoardAdmin', action: 'removeIneligibleUser')}"/>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<r:script>



    $(function ($) {
        labelAutocomplete("#add-user", $("#add-user").attr('user-search-url'), '#ajax-spinner', function(item) {
                var updateUrl = $("#add-user").attr('user-add-url');
                $.ajax(updateUrl, {type: 'POST', data: { id: item.userId }})
                    .done(function(data) {
                        $( "<li>" )
                                .append(
                                $( "<span>" )
                                        .text(item.displayName)
                        )
                                .append(
                                $( "<i>" )
                                        .attr("data-user-id", item.userId)
                                        .addClass("fa fa-times")
                        )
                                .addClass("user")
                                .appendTo(
                                $( "#user-list" )
                        );

                        $("#add-user").val('');
                    })
                    .fail(function() { alert("Couldn't add user")});
                return null;
        }, 'displayName');

        function showSpinner() {
            $('#ajax-spinner').removeClass('hidden');
        }

        function hideSpinner() {
            $('#ajax-spinner').addClass('hidden');
        }

        function onDeleteClick(e) {
            showSpinner();
            $.ajax($('#add-user').attr('user-remove-url'), {type: 'POST', data: { id: e.target.dataset.userId }})
            .done(function (data) {
                var t = $(e.target);
                var p = t.parent("li");

                p.remove();
                $("#add-user").val('');
            })
            .fail(alert("Couldn't remove user"))
            .always(hideSpinner);
        }

        $('#user-list').on('click', 'li.user i.fa-times', onDeleteClick);
    });

</r:script>

</body>
</html>
