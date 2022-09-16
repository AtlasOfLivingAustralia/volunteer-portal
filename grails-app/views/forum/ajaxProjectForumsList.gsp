<%@ page import="au.org.ala.volunteer.ProjectStatusFilterType; au.org.ala.volunteer.ProjectActiveFilterType" %>
<style>

[inactive=true] {
    background-color: #F0F0E8;
    opacity: 0.5;
}

.project-type {
    text-align: center;
}

</style>

<div style="margin-bottom: 15px">
    <table class="table expedition-forum" style="margin-bottom: 5px">
        <colgroup>
            <col style="width:165px"/>
        </colgroup>
        <thead>
        <tr>
            <td>
                <div class="row">
                    <div class="col-sm-8"></div>

                    <div class="col-sm-4">
                        <div class="pull-right">
                            <div class="card-filter">
                                <div class="custom-search-input body">
                                    <div class="input-group">
                                        <g:textField class="form-control input-lg" id="searchbox"
                                                     value="${params.q}" name="searchbox" placeholder="Search expeditions…"/>
                                        <span class="input-group-btn">
                                            <button id="btnSearch" class="btn btn-info btn-lg" type="button">
                                                <i class="glyphicon glyphicon-search"></i>
                                            </button>
                                        </span>
                                    </div>
                                </div>
                            </div>


                        </div>
                    </div>
                </div>

                <div class="row" id="project-forums-btn-bar">
                    <div class="col-sm-2">
                    </div>

                    <div class="col-sm-5">
                        <a href="?sort=name&order=${params.sort == 'name' && params.order != 'desc' ? 'desc' : 'asc'}&offset=0&q=${params.q}&selectedTab=${params.selectedTab}"
                           class="btn ${params.sort == 'name' ? 'current' : ''}">Name</a>
                    </div>

                    <div class="col-sm-2 project-type">
                        <a href="?sort=type&order=${params.sort == 'type' && params.order != 'desc' ? 'desc' : 'asc'}&offset=0&q=${params.q}&selectedTab=${params.selectedTab}"
                           class="btn ${params.sort == 'type' ? 'current' : ''}">Type</a>
                    </div>

                    <div class="col-sm-3">
                    </div>
                </div>
            </td>
        </tr>
        </thead>
        <tbody>
        <g:each in="${projectSummaryList.projectRenderList}" status="i" var="projectSummary">
            <tr inactive="${projectSummary.project.inactive}">
                <td>
                    <div class="row expedition-details">
                        <%-- Project thumbnail --%>
                        <div class="col-sm-2">
                            <a href="${createLink(controller: 'forum', action: 'projectForum', params: [projectId: projectSummary.project.id])}">
                                <cl:featuredImage project="${projectSummary.project}" width="147" height="81" style="padding-top: 5px" />
                            </a>
                        </div>
                        <%-- Name and progress bar --%>
                        <div class="col-sm-5">
                            <h3><a href="${createLink(controller: 'forum', action: 'projectForum', params: [projectId: projectSummary.project.id])}">${projectSummary.project.featuredLabel}</a>
                            </h3>
                            <g:render template="/project/projectSummaryProgressBar"
                                      model="${[projectSummary: projectSummary]}"/>
                        </div>
                        <%-- Project type --%>
                        <div class="col-sm-2 project-type">
                            <img src="${projectSummary.iconImage}" width="40" height="36" alt="">
                            <br/>
                            <span>${projectSummary.iconLabel}</span>
                        </div>

                        <div class="col-sm-3">
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
