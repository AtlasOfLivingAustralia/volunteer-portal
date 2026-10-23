<%@ page import="au.org.ala.volunteer.DateConstants; au.org.ala.volunteer.User" %>
<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Project" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <g:set var="entityName" value="${message(code: 'user.label')}"/>
    <g:if test="${project}">
        <title><cl:pageTitle title="${message(code: 'user.notebook.titleProject', args: [cl.displayNameForUserId(id: userInstance.userId), project?.name ?: 'Unknown project'])}"/></title>
    </g:if>
    <g:else>
        <title><cl:pageTitle title="${message(code: 'user.notebook.title', args: [cl.displayNameForUserId(id: userInstance.userId)])}"/></title>
    </g:else>
</head>
<body class="bg-light-subtle py-4">

<cl:headerContent crumbLabel="${cl.displayNameForUserId(id: userInstance.userId)}"
                  title="User Notebook for ${cl.displayNameForUserId(id: userInstance.userId)}"
                  hideTitle="true"
                  selectedNavItem="userDashboard">

    <!-- Header / Profile Title -->
    <div class="d-flex align-items-center">
        <g:if test="${userInstance.userId == currentUser}">
            <cl:gravatarImage user="${userInstance}" size="53" cssClass="rounded me-3 img-fluid" addLink="true"/>
        </g:if>
        <g:else>
            <cl:gravatarImage user="${userInstance}" size="53" cssClass="rounded me-3 img-fluid" />
        </g:else>

        <h1 class="mb-0 fw-bold text-dark">
            ${cl.displayNameForUserId(id: userInstance.userId)}
        <cl:ifSiteAdmin>
            <a href="#" class="text-muted ms-2 fs-6" title="Administrator: Edit User" aria-label="Administrator: Edit User"><i class="fa fa-external-link"></i></a>
        </cl:ifSiteAdmin>
        </h1>
    </div>

</cl:headerContent>

<div class="container">
    <!-- 1. Modern Clean Panel: Stats Grid -->
    <div class="row row-cols-1 row-cols-sm-2 row-cols-xl-4 g-3 mt-1 mb-4">

        <!-- Total Contribution Card -->
        <div class="col">
            <div class="card h-100 border-0 shadow-sm text-white bg-digivol">
                <div class="card-body">
                    <h6 class="text-uppercase text-white-50 fs-7 fw-bold mb-1">Total Contribution</h6>
                    <div class="display-6 fw-bold my-1">${score} <span class="fs-6 text-white-50 fw-normal">tasks</span></div>
                    <div class="fs-7 text-white-50 mt-2">
                        Transcribed: <span class="fw-semibold">${transcribedScore}</span> <span class="text-white-50">/</span> Validated: <span class="fw-semibold text-white-50">${validatedScore}</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Expeditions Card -->
        <div class="col">
            <div class="card h-100 border-0 shadow-sm text-white bg-digivol">
                <div class="card-body">
                    <h6 class="text-uppercase text-white-50 fs-7 fw-bold mb-1">Expeditions</h6>
                    <div class="display-6 fw-bold my-1">${expeditionCount}</div>
                    <div class="fs-7 text-white-50 mt-2">Contributed to actively</div>
                </div>
            </div>
        </div>

        <!-- Species Added Card -->
        <div class="col">
            <div class="card h-100 border-0 shadow-sm text-white bg-digivol">
                <div class="card-body">
                    <h6 class="text-uppercase text-white-50 fs-7 fw-bold mb-1">Species Added to ALA</h6>
                    <div class="display-6 fw-bold my-1">${totalSpeciesCount}</div>
                    <div class="fs-7 text-white-50 mt-2">Verified entries</div>
                </div>
            </div>
        </div>

        <!-- Leaderboard Position Card -->
        <div class="col">
            <div class="card h-100 border-0 shadow-sm text-white bg-digivol">
                <div class="card-body">
                    <h6 class="text-uppercase text-white-50 fs-7 fw-bold mb-1">Leaderboard Position</h6>
                    <div class="display-6 fw-bold my-1">
                    <g:if test="${userRank == "0"}">
                        <span class="fs-6 text-white-50 fw-normal">Not ranked</span>
                    </g:if>
                    <g:else>
                        ${userRank} <span class="fs-6 text-white-50 fw-normal">/ ${totalUsers}</span>
                    </g:else>
                    </div>
                    <div class="fs-7 text-white-50 mt-2"><cl:rankPercentile rank="${userRank}" total="${totalUsers}"/></div>
                </div>
            </div>
        </div>

    </div>
    <!-- End of Stats Grid -->

    <!-- PROFILE CARD BADGES SECTION BLOCK -->
    <div class="card shadow-sm border-0 mb-4">
        <div class="card-body">
            <h6 class="text-muted text-uppercase small tracking-wider mb-3">Your Progress & Achievements</h6>

            <!-- "At-A-Glance" Profile Summary Bar (Clickable Trigger) -->
            <!-- PROFILE CARD BADGES SECTION BLOCK -->
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-body text-start"> <!-- Explicit left alignment -->

                <!-- Categorised Meta Headings Stack -->
                    <div class="mb-3">
                        <h6 class="text-dark fw-bold mb-1" style="font-size: 0.95rem; tracking-wide;">Badges</h6>
                        <div class="d-flex gap-2 text-muted small">
                            <span class="badge text-bg-success"><i class="fa fa-trophy me-1"></i><strong>${achievements.size()}</strong> Earned</span>
                            <span>•</span>
                            <span class="badge text-bg-light"><i class="fa fa-hourglass-half me-1"></i><strong>${achievementList.size() - achievements.size()}</strong> In Progress</span>
                        </div>
                    </div>

                    <!-- "At-A-Glance" Left-Aligned Wrapped Clickable Area -->
                    <div class="card card-body bg-light border-dashed p-3" data-bs-toggle="modal" data-bs-target="#achievementModal" style="${userInstance.userId == currentUser ? 'cursor: pointer;' : ''}border-style: dashed !important;">
                        <div class="row align-items-center g-3">

                            <!-- Left-Aligned Grid: Handles up to 17 Badges with Seamless Wrapping -->
                            <div class="col-12 col-md-9">
                                <!-- flex-wrap manages row overflow automatically when items expand -->
                                <div class="d-flex flex-wrap align-items-center gap-2" id="badgeContainerRing">
                                <g:if test="${achievements.size() == 0}">
                                    <span class="text-muted small">No badges earned yet. Start <g:link controller="project" action="list">transcribing</g:link>!</span>
                                </g:if>
                                <g:else>
                                    <g:each in="${achievements}" var="ach" status="i">
                                    <!-- Badge 1 -->
                                    <div class="bg-white rounded-circle border border-muted shadow-sm d-flex align-items-center justify-content-center text-center"
                                         style="width: 38px; height: 38px; font-size: 1.15rem;" title="${ach.achievement.name}">
                                        <img src='<cl:achievementBadgeUrl achievement="${ach.achievement}"/>'
                                             width="38px" alt="${ach.achievement.name}"
                                             title="${ach.achievement.description}" class="img-fluid w-100"/>
                                    </div>
                                    </g:each>
                                    <!-- [Placeholder slot for 14 additional badges to hit the 17 maximum cap] -->
                                    <!-- They will fill horizontally and break down cleanly line-by-line -->
                                </g:else>
                                </div>
                            </div>

                            <!-- Call-to-action Button Trigger (Pushed neatly to the right grid or inline stack) -->
                            <g:if test="${userInstance.userId == currentUser}">
                            <div class="col-12 col-md-3 text-md-end text-primary small fw-semibold">
                                <span>View Progress Details <i class="bi bi-arrow-right-short ms-1"></i></span>
                            </div>
                            </g:if>
                        </div>
                    </div>

                </div>
            </div>

        </div>
    </div>
    <!-- End of Profile Card Badges Section Block -->

    <g:if test="${userInstance.userId == currentUser}">
        <!-- FULL ACHIEVEMENT POPUP MODAL WINDOW ONLY FOR LOGGED-IN USER-->
        <g:render template="notebookBadgeModal" model="[achievementList: achievementList]"/>
        <!-- End of Full Achievement Popup Modal Window -->
        <g:render template="notebookTaskImageModal" />
        <g:render template="notebookTaskHistory" model="[userInstance: userInstance, currentUser: currentUser, viewTaskList: viewTaskList, totalMatchingTasks: totalMatchingTasks]"/>
    </g:if>




</div>
<asset:script type="text/javascript">
    $(document).ready(function () {
        // Initialise tooltips
        bvp.bindTooltips("");

        $('.open-full-image').on('click', function() {
            const fullImageUrl = $(this).data('full-src');
            // Get the task name from the data attribute
            const taskName = $(this).data('task-name');
            // Open the full image in a modal
            $('#taskImageDisplay').attr('src', fullImageUrl);
            $('#taskImageModalTitle').text(taskName);
            $('#taskImageModalTitle').attr('title', taskName);
            $('#taskImageModalTitle').attr('aria-label', taskName);
            const imageModal = document.querySelector('#imageModal')
            const modal = bootstrap.Modal.getOrCreateInstance(imageModal) // Returns a Bootstrap modal instance
            modal.show();
        });

    });
</asset:script>
</body>
</html>
