<%@ page import="au.org.ala.volunteer.User" %>
<table border="0" class="borders">
  <thead>
    <tr>
      <th colspan="2"><h2>Leader board</h2> <a class="button alignright" href="${createLink(controller:'user', action:'list')}">View all</a></th>
    </tr>
  </thead>
  <tbody>
    <g:each in="${results}" var="userScore">
      <tr>
        <g:set var="user" value="${User.findByUserId(userScore.username)}" />
        <td><g:link controller="user" action="show" id="${user?.id}">${user.displayName}</g:link></td>
        <td>
          <g:if test="${userScore.score > 0}">
            ${userScore.score}
          </g:if>
        </td>
      </tr>
    </g:each>
  </tbody>
</table>
