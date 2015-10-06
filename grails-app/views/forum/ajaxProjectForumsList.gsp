<%@ page import="au.org.ala.volunteer.ProjectStatusFilterType; au.org.ala.volunteer.ProjectActiveFilterType" %>
<style>

.expedition-details h3 {
    /*background-color: white;*/
}

[inactive=true] {
    background-color: #F0F0E8;
    opacity: 0.5;
}

.project-type {
    text-align: center;
}

</style>

<div style="margin-bottom: 15px">
    <table class="table" style="margin-bottom: 5px">
        <colgroup>
            <col style="width:165px"/>
        </colgroup>
        <thead>
        <tr>
            <td>
                <div class="row-fluid">
                    <div class="span8">
                    </div>

                    <div class="span4">
                        <div class="pull-right">
                            <span>
                                <a style="vertical-align: middle;" href="#" class="fieldHelp"
                                   title="Enter search text here to find expeditions"><span
                                        class="help-container">&nbsp;</span>
                                </a>
                            </span>
                            <g:textField style="margin-top: 10px; margin-bottom: 10px" id="searchbox"
                                         value="${params.q}" name="searchbox"/>
                            <button class="btn btn-primary" id="btnSearch">Search</button>
                        </div>
                    </div>
                </div>

                <div class="row-fluid" id="project-forums-btn-bar">
                    <div class="span2">
                    </div>

                    <div class="span5">
                        <a href="?sort=name&order=${params.sort == 'name' && params.order != 'desc' ? 'desc' : 'asc'}&offset=0&q=${params.q}&selectedTab=${params.selectedTab}"
                           class="btn ${params.sort == 'name' ? 'current' : ''}">Name</a>
                    </div>

                    <div class="span2 project-type">
                        <a href="?sort=type&order=${params.sort == 'type' && params.order != 'desc' ? 'desc' : 'asc'}&offset=0&q=${params.q}&selectedTab=${params.selectedTab}"
                           class="btn ${params.sort == 'type' ? 'current' : ''}">Type</a>
                    </div>

                    <div class="span3">
                    </div>
                </div>
            </td>
        </tr>
        </thead>
        <tbody>
        <g:each in="${projectSummaryList.projectRenderList}" status="i" var="projectSummary">
            <tr inactive="${projectSummary.project.inactive}">
                <td>
                    <div class="row-fluid expedition-details">
                        <%-- Project thumbnail --%>
                        <div class="span2">
                            <a href="${createLink(controller: 'forum', action: 'projectForum', params: [projectId: projectSummary.project.id])}">
                                <img src="${projectSummary.project.featuredImage}" width="147" height="81"
                                     style="padding-top: 5px"/>
                            </a>
                        </div>
                        <%-- Name and progress bar --%>
                        <div class="span5">
                            <h3><a href="${createLink(controller: 'forum', action: 'projectForum', params: [projectId: projectSummary.project.id])}">${projectSummary.project.featuredLabel}</a>
                            </h3>
                            <g:render template="../project/projectSummaryProgressBar"
                                      model="${[projectSummary: projectSummary]}"/>
                        </div>
                        <%-- Project type --%>
                        <div class="span2 project-type">
                            <img src="${projectSummary.iconImage}" width="40" height="36" alt="">
                            <br/>
                            <span>${projectSummary.iconLabel}</span>
                        </div>

                        <div class="span3">
                            <a href="${createLink(controller: "forum", action: "projectForum", params: [projectId: projectSummary.project.id])}"><b>${forumStats[projectSummary.project].projectTopicCount}</b> Expedition Topics and <b>${forumStats[projectSummary.project].taskTopicCount ?: '0'}</b> Task Topics
                            </a>
                        </div>
                    </div>
                </td>
            </tr>
        </g:each>
        </tbody>
    </table>

    <div class="pagination">
        <g:paginate controller="forum" action="index" total="${projectSummaryList.matchingProjectCount}" prev="" next=""
                    params="${params}"/>
    </div>
</div>

<script type="text/javascript">

    $("#searchbox").keydown(function (e) {
        if (e.keyCode == 13) {
            doSearch();
        }
    });

    $("#btnSearch").click(function (e) {
        e.preventDefault();
        doSearch();
    });

    function doSearch() {
        var q = $("#searchbox").val();
        var url = "${createLink(controller: 'forum', action:'index', params:[selectedTab: params.selectedTab])}&q=" + encodeURIComponent(q);
        window.location = url;
    }

</script>
