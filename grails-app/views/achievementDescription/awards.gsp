<%@ page import="au.org.ala.volunteer.AchievementDescription" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="digivol-achievementSettings">
    <g:set var="entityName" value="${message(code: 'achievementDescription.label', default: 'Badge Description')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>
    <r:require modules="labelAutocomplete"/>
</head>

<body>
<content tag="pageTitle">Awards</content>

<content tag="adminButtonBar">
    <g:form class="form-inline" style="display: inline-block; padding-right: 10px;" action="awardAll"
            id="${achievementDescriptionInstance?.id}" method="post">
        <input type="submit" class="btn btn-default"
               value="${message(code: 'default.button.awardAll.label', default: 'Award All Eligible')}"/>
    </g:form>
    <g:form class="form-inline" style="display: inline-block" action="unawardAll"
            id="${achievementDescriptionInstance?.id}" method="post">
        <input type="submit" class="btn btn-danger"
               value="${message(code: 'default.button.unawardAll.label', default: 'Remove all awards')}"/>
    </g:form>
</content>

<div id="edit-achievementDescription" class="content scaffold-edit" role="main">
    %{--<g:if test="${flash.message}">--}%
    %{--<div class="message" role="status">${flash.message}</div>--}%
    %{--</g:if>--}%
    <table class="table table-striped table-hover">
        <thead>
        <tr>
            <th>User</th>
            <th>Awarded</th>
            <th>Notified</th>
            <th>Currently Eligible</th>
            <th class="text-center">Actions</th>
        </tr>
        </thead>
        <tbody>
        <g:each in="${achievementDescriptionInstance.awards}" var="award">
            <tr data-user-id="${award.user.userId}" data-award-id="${award.id}">
                <td>${award.user.displayName}</td>
                <td>${award.awarded}</td>
                <td>${award.userNotified}</td>
                <td class="eligible-column"><i class="fa fa-cog fa-spin ajax-spinner"></i></td>
                <td class="text-center">
                    <button class="btn btn-xs btn-danger rmAward"><i class="fa fa-times"></i></button>
                </td>
            </tr>
        </g:each>
        </tbody>
    </tabLe>

    <div class="well">
        <h4>Grant achievement</h4>
        <g:form class="form-horizontal" action="award" id="${achievementDescriptionInstance?.id}" method="POST">
            <div class="form-group">
                <label class="control-label col-md-3" for="user">
                    <g:message code="user.label" default="User"/>
                </label>

                <div class="col-md-6">
                    <input class="form-control" id="user" type="text" value="${displayName}" autocomplete="off"/>
                    <input id="userId" name="userId" type="hidden" value="${userId}"/>
                </div>

                <div class="col-md-3">
                    <i id="ajax-spinner" class="fa fa-cog fa-spin hidden"></i>
                </div>
            </div>

            <div class="form-group">
                <div class="col-md-offset-3 col-md-9">
                    <input type="submit" class="save btn btn-default" id="awardButton"
                           value="${message(code: 'default.button.award.label', default: 'Award')}"/>
                </div>
            </div>
        </g:form>
    </div>
</div>

<r:script>
$(function($) {

    var ids = <cl:json value="${achievementDescriptionInstance.awards*.user*.id}"/>;

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

    labelAutocomplete("#user", url, '#ajax-spinner', function(item) {
        $('#userId').val(item.userId);
        $('#awardButton').click();
        return null;
    }, 'displayName');
});
</r:script>
</body>
</html>
