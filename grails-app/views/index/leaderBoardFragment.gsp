<%@ page import="au.org.ala.volunteer.User" %>
<div style="margin-top: 10px">
    <table class="table table-bordered table-condensed" style="background-color: white">
        <thead style="background-color: #f0f0e8">
        <tr>
            <td colspan="2" style="vertical-align: middle">
                <h3 style="margin: 0; display: inline-block">Honour Board</h3>
                <a class="btn btn-small pull-right"
                   href="${createLink(controller: 'user', action: 'list')}">View all</a>
            </td>
        </tr>
        </thead>
        <tbody>
        <g:each in="${results}" var="userScore">
            <tr>
                <g:set var="user" value="${User.findByUserId(userScore.username)}"/>
            <td>
                <g:if test="${user}">
                    <g:link controller="user" action="show" id="${user?.id}"><cl:userDetails id="${user?.userId}"
                                                                                             displayName="true"/></g:link></td>
                </g:if>
                <g:else>
                    &nbsp;
                </g:else>
                <td>
                    <g:if test="${user && userScore.score > 0}">
                        ${userScore.score}
                    </g:if>
                </td>
            </tr>
        </g:each>
        </tbody>
    </table>
</div>
