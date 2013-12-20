<g:set var="includeParams" value="${params.findAll { it.key != 'selectedTab' }}"/>
<g:include action="taskListFragment" params="${includeParams}"/>