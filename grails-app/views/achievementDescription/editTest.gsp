<%@ page import="au.org.ala.volunteer.AchievementDescription" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="achievementSettingsLayout">
    <g:set var="entityName" value="${message(code: 'achievementDescription.label', default: 'Badge Description')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>
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
<content tag="pageTitle">Tester</content>

<content tag="adminButtonBar">
    %{--<form class="form-inline"><g:checkBox name="enabled" checked="${achievementDescriptionInstance?.enabled}"/></form>--}%
</content>

<div id="edit-achievementDescription" class="content scaffold-edit" role="main">
    %{--<g:if test="${flash.message}">--}%
    %{--<div class="message" role="status">${flash.message}</div>--}%
    %{--</g:if>--}%
    <table class="table">
        <thead>
        <tr>
            <th>User</th>
            <th>Achieved?</th>
        </tr>
        </thead>
        <tbody>
        <g:each in="${cheevMap}" var="cheev">
            <tr>
                <td>
                    ${cheev.key}
                </td>
                <td>
                    ${cheev.value}
                </td>
            </tr>
        </g:each>
        </tbody>
    </tabLe>
    <g:form class="form-horizontal" action="editTest" id="${achievementDescriptionInstance?.id}" method="GET">
        <div class="well">
            <legend>Check User</legend>
            <fieldset class="form">
                <div class="control-group">
                    <label class="control-label" for="user">
                        <g:message code="user.label" default="User"/>
                        <r:img dir="images" file="spinner.gif" height="16px" width="16px" id="ajax-spinner"
                               class="disabled"/>
                    </label>

                    <div class="controls">
                        <input id="user" type="text" value="${displayName}" autocomplete="off"/>
                        <input id="userId" name="userId" type="hidden" value="${userId}"/>
                    </div>
                </div>

                <div class="control-group">
                    <div class="controls">
                        <input type="submit" class="save"
                               value="${message(code: 'default.button.test.label', default: 'Test')}"/>
                    </div>
                </div>
            </fieldset>
        </div>
    </g:form>
</div>
<r:script>
jQuery(function($) {
    var url = "${createLink(controller: 'leaderBoardAdmin', action: 'findEligibleUsers')}";
    function showSpinner() {
        $('#ajax-spinner').removeClass('disabled')
    }
    function hideSpinner() {
        $('#ajax-spinner').addClass('disabled')
    }

    function typeahead(query, process) {
        showSpinner();
        $.getJSON(url, {term: query, filter: false})
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
        $('#userId').val(obj.userId);
        return obj.displayName;
    }

    $('#user').typeahead({
        source: typeahead,
        minLength: 2,
        highlighter: typeaheadHighlighter,
        matcher: typeaheadMatcher,
        sorter: typeaheadSorter,
        updater: typeaheadUpdate
    });
});
</r:script>
</body>
</html>
