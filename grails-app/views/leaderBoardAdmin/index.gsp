<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="leaderBoardAdmin.label" default="Leaderboard Configuration"/></title>
    <r:require modules="bvp-js"/>
    <r:style>
        #ajax-spinner.disabled {
          display: none;
        }
        li.user > span {
            margin-right: 5px;
        }
        i.icon-remove {
            cursor: pointer;
        }
    </r:style>
</head>

<body>

<cl:headerContent title="${message(code: 'default.leaderboardadmin.label', default: 'Leaderboard Configuration')}">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Admin')]
        ]
    %>
</cl:headerContent>

<div class="row">
    <div class="span12">
        <legend>Ineligible leaderboard users <r:img dir="images" file="spinner.gif" height="16px" width="16px"
                                                    id="ajax-spinner" class="disabled"/></legend>

        <div class="row-fluid">
            <ul id="user-list">
                <g:each in="${users}" var="user">
                    <li class="user">
                        <span>${user.displayName}</span><i data-user-id="${user.userId}" class="icon-remove"></i>
                    </li>
                </g:each>
            </ul>
            <label for="add-user">Add User:</label>
            <input id="add-user" type="text" autocomplete="off" data-provide="typeahead"
                   data-source="typeahead" data-updater="typeaheadUpdate"/>
        </div>
    </div>
</div>

<r:script>

jQuery(function ($) {
    var url = "${createLink(controller: 'leaderBoardAdmin', action: 'findEligibleUsers')}";
    var updateUrl = "${createLink(controller: 'leaderBoardAdmin', action: 'addIneligibleUser')}";
    var deleteUrl = "${createLink(controller: 'leaderBoardAdmin', action: 'removeIneligibleUser')}";

    function showSpinner() {
        $('#ajax-spinner').removeClass('disabled')
    }
    function hideSpinner() {
        $('#ajax-spinner').addClass('disabled')
    }

    function typeahead(query, process) {
        showSpinner();
        $.getJSON(url, {term: query})
        .done(function(data) {
            var toString = function() {
                return JSON.stringify(this);
            };
            for (var i = 0; i < data.length; ++i) {
                data[i].toString = toString;
            }
            process(data);
        })
        .fail(function(e) {
            ajaxFail();
            process([]);
        })
        .always(hideSpinner);
    }

    function ajaxFail() {
        alert("Failure contacting server, please refresh and try again");
    }

    function typeaheadHighlighter(item) {
      var query = this.query.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, '\\$&');
      return item.displayName.replace(new RegExp('(' + query + ')', 'ig'), function ($1, match) {
        return '<strong>' + match + '</strong>';
      }) + ' (' + item.email.replace(new RegExp('(' + query + ')', 'ig'), function ($1, match) { return '<strong>' + query + '</strong>'; }) + ')';
    }

    function typeaheadSorter(items) {
        return items;
    }

    function typeaheadMatcher(item) {
        return true;
    }

    function typeaheadUpdate(item) {
        var obj = JSON.parse(item);
        showSpinner();
        $.ajax(updateUrl, {type: 'POST', data: { id: obj.userId }})
        .done(function(data) {
          $( "<li>" )
          .append(
            $( "<span>" )
            .text(obj.displayName)
          )
          .append(
            $( "<i>" )
            .attr("data-user-id", obj.userId)
            .addClass("icon-remove")
          )
          .addClass("user")
          .appendTo(
            $( "#user-list" )
          );
        })
        .fail(ajaxFail)
        .always(hideSpinner);
        return null;
    }

    function onDeleteClick(e) {
        showSpinner();
        $.ajax(deleteUrl, {type: 'POST', data: { id: e.target.dataset.userId }})
        .done(function (data) {
            var t = $(e.target);
            var p = t.parent("li");

            p.remove();
        })
        .fail(ajaxFail)
        .always(hideSpinner);
    }

    $('#add-user').typeahead({
        source: typeahead,
        minLength: 2,
        highlighter: typeaheadHighlighter,
        matcher: typeaheadMatcher,
        sorter: typeaheadSorter,
        updater: typeaheadUpdate
    });
    $('#user-list').on('click', 'li.user i.icon-remove', onDeleteClick);
});

</r:script>

</body>
</html>
