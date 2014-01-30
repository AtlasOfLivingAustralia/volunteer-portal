%{--<h3>Project Specific Forums</h3>--}%
<div style="margin-bottom: 15px">
    <table class="table table-striped" style="margin-bottom: 5px">
        <colgroup>
            <col style="width:165px"/>
        </colgroup>
        <thead>
            <tr>
                <th></th>
                <th>
                    <a href="?sort=name&order=${params.sort == 'name' && params.order != 'desc' ? 'desc' : 'asc'}&offset=0&q=${params.q}&selectedTab=${params.selectedTab}" class="btn ${params.sort == 'name' ? 'current' : ''}">Name</a>
                </th>
                <th>
                    <a href="?sort=type&order=${params.sort == 'type' && params.order != 'desc' ? 'desc' : 'asc'}&offset=0&q=${params.q}&selectedTab=${params.selectedTab}" class="btn ${params.sort == 'type' ? 'current' : ''}">Type</a>
                </th>
                <th style="text-align: right">
                    <span>
                        <a style="vertical-align: middle;" href="#" class="fieldHelp" title="Enter search text here to find expeditions"><span class="help-container">&nbsp;</span>
                        </a>
                    </span>
                    <g:textField style="margin-top: 10px; margin-bottom: 10px" id="searchbox" value="${params.q}" name="searchbox"/>
                    <button class="btn btn-primary" id="btnSearch">Search</button>
                </th>
            </tr>
        </thead>
        <tbody>
            <g:each in="${projectSummaryList.projectRenderList}" status="i" var="projectSummary">
                <tr inactive="${projectSummary.project.inactive}">
                    <%-- Project thumbnail --%>
                    <td>
                        <a href="${createLink(controller: 'forum', action: 'projectForum', params: [projectId: projectSummary.project.id])}">
                        <img src="${projectSummary.project.featuredImage}" width="147" height="81" style="padding-top: 5px"/>
                    </a>
                    </td>
                    <%-- Progress bar --%>
                    <td>
                        <h3><a href="${createLink(controller: 'forum', action: 'projectForum', params: [projectId: projectSummary.project.id])}">${projectSummary.project.featuredLabel}</a></h3>
                    </td>
                    <%-- Project type --%>
                    <td class="type">
                        <img src="${projectSummary.iconImage}" width="40" height="36" alt="">
                    </td>
                    <td style="text-align: right">
                        <a href="${createLink(controller:"forum", action:"projectForum", params:[projectId: projectSummary.project.id])}"><b>${forumStats[projectSummary.project].projectTopicCount}</b> Expedition Topics and <b>${forumStats[projectSummary.project].taskTopicCount ?: '0'}</b> Task Topics</a>
                        %{--<a class="button orange" style="font-size: 1.1em" href="${createLink(controller:"forum", action:"projectForum", params:[projectId: projectSummary.project.id])}">Visit Forum</a>--}%
                    </td>
                </tr>
            </g:each>
        </tbody>
    </table>
    <div class="pagination">
        <g:paginate controller="forum" action="index" total="${projectSummaryList.matchingProjectCount}" prev="" next="" params="${params}"/>
    </div>
</div>

<script type="text/javascript">

    $("#searchbox").keydown(function(e) {
        if (e.keyCode == 13) {
            doSearch();
        }
    });

    $("#btnSearch").click(function(e) {
        e.preventDefault();
        doSearch();
    });

    function doSearch() {
        var q = $("#searchbox").val();
        var url = "${createLink(controller: 'forum', action:'index')}?q=" + encodeURIComponent(q);
        window.location = url;
    }

</script>
