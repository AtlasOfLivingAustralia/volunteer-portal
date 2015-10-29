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
<content tag="pageTitle">Tester</content>

<content tag="adminButtonBar">
    %{--This is just for formatting purposes--}%
    <div style="height: 40px;">&nbsp;</div>
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
            <h4>Check User</h4>
            <div class="form-group">
                <label class="control-label col-md-3" for="user">
                    <g:message code="user.label" default="User"/>
                    <r:img dir="images" file="spinner.gif" height="16px" width="16px" id="ajax-spinner"
                           class="hidden"/>
                </label>

                <div class="col-md-6">
                    <input id="user" class="form-control" type="text" value="${displayName}" autocomplete="off"/>
                    <input id="userId" name="userId" type="hidden" value="${userId}"/>
                </div>
            </div>

            <div class="form-group">
                <div class="col-md-offset-3 col-md-9">
                    <input type="submit" class="save btn btn-default" id="testButton"
                           value="${message(code: 'default.button.test.label', default: 'Test')}"/>
                </div>
            </div>
        </div>
    </g:form>
</div>
<r:script>
    $(function($) {
        var url = "${createLink(controller: 'leaderBoardAdmin', action: 'findEligibleUsers')}";


        labelAutocomplete("#user", url, '#ajax-spinner', function(item) {
            $('#userId').val(item.userId);
            $('#testButton').click();
            return null;
        }, 'displayName');
    });
</r:script>
</body>
</html>
