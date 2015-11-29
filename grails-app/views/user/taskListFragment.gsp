<%@ page contentType="text/html;charset=UTF-8" %>
<div class="tab-pane-header">
    <div class="row">
        <div class="col-sm-4 search-results-count">
            <g:if test="${!totalMatchingTasks}">
                <p><strong>${totalMatchingTasks} Tasks Found</strong></p>
            </g:if>
            <g:else>
                <p><strong>
                ${totalMatchingTasks} Tasks Found
                <g:if test="${projectInstance}">
                    for ${projectInstance.featuredLabel}
                </g:if>
                </strong></p>
            </g:else>
        </div>
        <div class="col-sm-8 text-right">

            <div class="custom-search-input body">
                <div class="input-group">
                    <input type="text" id="searchbox" value="${params.q}" name="searchbox" class="form-control input-lg" placeholder="Search by ..." />
                    <span class="input-group-btn">
                        <button class="btn btn-info btn-lg" type="button" onclick="doSearch();">
                            <i class="glyphicon glyphicon-search"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="pull-right search-help">
                <button class="btn btn-info pull-right"
                        data-tooltip="Enter search text here to show only tasks matching values in the ImageID, CatalogNumber, Expedition and Transcribed columns"><span
                        class="help-container"><i class="fa fa-question"></i></span>
                </button>
            </div>
        </div>
    </div>
</div>
<div class="table-responsive">
<table class="table table-striped table-hover">
    <thead>
    <tr class="sorting-header">

        <g:set var="pageParams" value="${params}"/>

        <g:sortableColumn style="text-align: left" property="id"
                          title="${message(code: 'task.id.label', default: 'Id')}" params="${pageParams}"
                          action="show" controller="user" />

        <g:sortableColumn style="text-align: left" property="externalIdentifier"
                          title="${message(code: 'task.externalIdentifier.label', default: 'Image ID')}"
                          params="${pageParams}" action="show" controller="user"/>

        <g:sortableColumn style="text-align: left" property="catalogNumber"
                          title="${message(code: 'task.catalogNumber.label', default: 'Catalog&nbsp;Number')}"
                          params="${pageParams}" action="show" controller="user"/>

        <g:sortableColumn style="text-align: left" property="projectName"
                          title="${message(code: 'task.project.name', default: 'Expedition')}"
                          params="${pageParams}" action="show" controller="user"/>

        <g:sortableColumn property="dateTranscribed"
                          title="${message(code: 'task.transcribed.label', default: 'Transcribed')}"
                          params="${pageParams}" action="show" controller="user" style="text-align: left;"/>

        <g:sortableColumn property="dateValidated"
                          title="${message(code: 'task.validated.label', default: 'Validated')}"
                          params="${pageParams}" action="show" controller="user" style="text-align: left;"/>

        <g:sortableColumn property="status" title="${message(code: 'task.isValid.label', default: 'Status')}"
                          params="${pageParams}" action="show" controller="user" style="text-align: center;"/>

        <th style="text-align: center; vertical-align: middle;">Action</th>

    </tr>
    </thead>
    <tbody>
    <g:each in="${viewList}" status="i" var="taskInstance">
        <tr>

            <td><g:link class="listLink" controller="task" action="show"
                        id="${taskInstance.id}">${taskInstance.id}</g:link></td>

            <td>${taskInstance.externalIdentifier}</td>

            <td>${taskInstance.catalogNumber}</td>

            <td><g:link class="listLink" controller="project" action="index"
                        id="${taskInstance.projectId}">${taskInstance.project}</g:link></td>

            <td>
                <g:formatDate date="${taskInstance.dateTranscribed}" format="dd MMM, yyyy HH:mm:ss"/>
            </td>

            <td>
                <g:formatDate date="${taskInstance.dateValidated}" format="dd MMM, yyyy HH:mm:ss"/>
            </td>

            <td style="text-align: center;">
                ${taskInstance.status}
            </td>

            <td style="text-align: center; width: 120px;">
                <span>
                    <g:if test="${taskInstance.fullyTranscribedBy}">
                        <button class="btn btn-default btn-xs"
                                onclick="location.href = '${createLink(controller:'task', action:'show', id:taskInstance.id)}'">View</button>
                        <cl:ifValidator project="${taskInstance.project}">
                            <g:if test="${taskInstance.status?.equalsIgnoreCase('validated')}">
                                <button class="btn btn-default btn-xs"
                                        onclick="location.href = '${createLink(controller:'validate', action:'task', id:taskInstance.id)}'">Review</button>
                            </g:if>
                            <g:else>
                                <button class="btn btn-default btn-xs"
                                        onclick="location.href = '${createLink(controller:'validate', action:'task', id:taskInstance.id)}'">Validate</button>
                            </g:else>
                        </cl:ifValidator>
                    </g:if>
                    <g:else>
                        <button class="btn btn-small"
                                onclick="location.href = '${createLink(controller:'transcribe', action:'task', id:taskInstance.id)}'">Transcribe</button>
                    </g:else>
                </span>
            </td>

        </tr>
    </g:each>
    </tbody>
</table>
</div>
<div class="pagination">
    <g:paginate total="${totalMatchingTasks}" id="${userInstance?.id}"
                params="${params + [selectedTab: selectedTab]}" action="show" controller="user" fragment="profileTabs"/>
</div>

<script>

    $("th > a").addClass("btn");
    $("th.sorted > a").addClass("active");

    doSearch = function () {
        var searchTerm = $('#searchbox').val()
        var link = "${createLink(controller: 'user', action: 'show', id: userInstance?.id)}?q=" + searchTerm + "&selectedTab=${selectedTab ?: 0}&projectId=${projectInstance?.id ?: ''}"
        window.location.href = link;
    };


    $('#searchbox').bind('keypress', function (e) {
        var code = (e.keyCode ? e.keyCode : e.which);
        if (code == 13) {
            doSearch();
        }
    });

    $('[data-tooltip!=""]').qtip({ // Grab all elements with a non-blank data-tooltip attr.
        content: {
            attr: 'data-tooltip' // Tell qTip2 to look inside this attr for its content
        }
    });

    $('.sorting-header a').each(function() {
        $(this).attr('href', $(this).attr('href') + '#profileTabs');
    });
</script>
