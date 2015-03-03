<%@ page import="au.org.ala.volunteer.AchievementDescription" %>
<!DOCTYPE html>
<html>
	<head>
		<meta name="layout" content="achievementSettingsLayout">
		<g:set var="entityName" value="${message(code: 'achievementDescription.label', default: 'Achievement Description')}" />
		<title><g:message code="default.edit.label" args="[entityName]" /></title>
        <r:style>
            #ajax-spinner.disabled, .ajax-spinner.disabled {
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
        <content tag="pageTitle">Awards</content>

        <content tag="adminButtonBar">
            <g:form class="form-inline" style="display: inline-block; padding-right: 10px;" action="awardAll" id="${achievementDescriptionInstance?.id}" method="post">
                <input type="submit" class="btn" value="${message(code: 'default.button.awardAll.label', default: 'Award All Eligible')}"/>
            </g:form>
            <g:form class="form-inline" style="display: inline-block" action="unawardAll" id="${achievementDescriptionInstance?.id}" method="post">
                <input type="submit" class="btn btn-danger" value="${message(code: 'default.button.unawardAll.label', default: 'Remove all awards')}"/>
            </g:form>
        </content>
		<div id="edit-achievementDescription" class="content scaffold-edit" role="main">
			%{--<g:if test="${flash.message}">--}%
			%{--<div class="message" role="status">${flash.message}</div>--}%
			%{--</g:if>--}%
            <table class="table">
                <thead>
                    <tr>
                        <th>User</th>
                        <th>Awarded</th>
                        <th>Notified</th>
                        <th>Currently Eligible</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                <g:each in="${achievementDescriptionInstance.awards}" var="award">
                    <tr data-user-id="${award.user.userId}" data-award-id="${award.id}">
                        <td>${award.user.displayName}</td>
                        <td>${award.awarded}</td>
                        <td>${award.userNotified}</td>
                        <td class="eligible-column"><r:img dir="images" file="spinner.gif" height="16px" width="16px" class="ajax-spinner" /></td>
                        <td>
                            %{--<button class="btn btn-small btn-warning"><i class="icon-refresh icon-white"></i></button>--}%
                            <button class="btn btn-small btn-danger rmAward"><i class="icon-remove icon-white"></i></button>
                        </td>
                    </tr>
                </g:each>
                </tbody>
            </tabLe>
            <div class="well">
                <legend>Grant achievement</legend>
                <g:form class="form-horizontal" action="award" id="${achievementDescriptionInstance?.id}" method="POST" >
                    <fieldset class="form">
                        <div class="control-group">
                            <label class="control-label" for="user">
                                <g:message code="user.label" default="User" />
                            </label>
                            <div class="controls">
                                <input id="user" type="text" value="${displayName}" autocomplete="off" />
                                <r:img dir="images" file="spinner.gif" height="16px" width="16px" id="ajax-spinner" class="disabled" />
                                <input id="userId" name="userId" type="hidden" value="${userId}"/>
                            </div>
                        </div>
                        <div class="control-group">
                            <div class="controls">
                                <input type="submit" class="save" value="${message(code: 'default.button.award.label', default: 'Award')}"/>
                            </div>
                        </div>
                    </fieldset>
                </g:form>
            </div>
		</div>
<r:script>
jQuery(function($) {

    var ids = <cl:json value="${achievementDescriptionInstance.awards*.user*.id}" />;

    var checkAwardUrl = "${createLink(controller: 'achievementDescription', action: 'checkAward', id: achievementDescriptionInstance.id)}";

    var i, j, temparray, chunk = 20;
    for (i=0,j=ids.length; i<j; i+=chunk) {
        temparray = ids.slice(i,i+chunk);
        $.getJSON(checkAwardUrl, {ids: temparray})
        .done(function(data) {
            for (var k in data){
                if (data.hasOwnProperty(k)) {
                    var val = data[k];
                    var selector = '[data-user-id="'+k+'"] td.eligible-column';
                    var selection = $(selector);
                    selection.html(val.toString());
                }
            }
        });
    }

    var removeAwardUrl = "${createLink(controller: 'achievementDescription', action: 'unaward', id: achievementDescriptionInstance.id)}";

    $('[data-award-id]').on('click', 'button.rmAward', function(event) {
        console.log(event);
        $.ajax(removeAwardUrl, {
            type: 'post',
            data: {
                ids: [ event.delegateTarget.dataset.awardId ]
            }
        }).done(function (data) {
            event.delegateTarget.remove();
        }).fail(function (e) {
            alert("Couldn't remove award, please refresh the page and try again.");
        });
    });

    var url = "${createLink(controller: 'achievementDescription', action: 'findEligibleUsers', id: achievementDescriptionInstance.id)}";
    function showSpinner() {
        $('#ajax-spinner').removeClass('disabled');
    }
    function hideSpinner() {
        $('#ajax-spinner').addClass('disabled');
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
