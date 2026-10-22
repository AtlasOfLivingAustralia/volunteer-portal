<%@ page import="au.org.ala.volunteer.WebUtils" %>
<!-- FULL ACHIEVEMENT POPUP MODAL WINDOW -->
<div class="modal fade" id="achievementModal" tabindex="-1" aria-labelledby="achievementModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content shadow-lg border-0">

            <!-- Modal Header -->
            <div class="modal-header bg-dark text-white py-3">
                <h5 class="modal-title d-flex align-items-center text-white" id="achievementModalLabel">
                    <i class="fa fa-trophy me-2"></i> Achievement Badges
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <!-- Modal Body Containing Expanded Accordion Timeline -->
            <div class="modal-body p-0">
                <div class="accordion accordion-flush overflow-auto" style="max-height: 600px;" id="achievementAccordion">
                    <g:each in="${achievementList}" status="i" var="achievementRow">
                        <g:set var="achievement" value="${achievementRow.achievement}" />
                        <g:set var="achievementAwarded" value="${achievementRow.awarded}" />
                        <g:set var="achievementStatus" value="${(achievementRow.status ? achievementRow.status : "-")}" />
                    <!-- ACCORDION ITEM 1: AUSTRALIAN EXPLORER -->
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="heading${i}">
                            <button class="accordion-button collapsed d-flex align-items-center justify-content-between pe-4" type="button" data-bs-toggle="collapse" data-bs-target="#collapse${i}" aria-expanded="false" aria-controls="collapse${i}">
                                <span class="d-flex align-items-center flex-grow-1">
                                    <div class="p-2 me-3 d-flex align-items-center justify-content-center" style="width: 60px; font-size: 1.3rem;">
                                        <img src='<cl:achievementBadgeUrl achievement="${achievement}"/>'
                                             width="60px" alt="${achievement.name}"
                                             title="${achievement.description}" class="img-fluid w-100"/>
                                    </div>
                                    <span>
                                        <strong class="d-block text-dark">${achievement.name}</strong>
                                        <small class="text-muted">${achievement.description}</small>
                                    </span>
                                </span>

                                <g:if test="${achievementAwarded}">
                                <span class="badge text-bg-success ms-auto me-2 px-3 py-2">
                                    <i class="fa fa-check-circle me-1"></i> Achieved
                                </span>
                                </g:if>
                                <g:else>
                                <span class="badge text-bg-light ms-auto me-2 px-3 py-2">
                                    <i class="fa fa-hourglass-half me-1"></i> In Progress
                                </span>
                                </g:else>
                            </button>
                        </h2>
                        <div id="collapse${i}" class="accordion-collapse collapse" aria-labelledby="heading${i}" data-bs-parent="#achievementAccordion">

                        <g:if test="${achievementAwarded}">
                            <div class="accordion-body bg-light">
                                <p class="mb-1 text-secondary"><strong>Unlocked:</strong> ${achievementAwarded.format("dd-MMM-yyyy")}</p>
                                <p class="mb-0 text-muted small">Percentage of volunteers achieved: ${achievementRow.awardedPercentage}% - ${WebUtils.getAchievementPopularity(achievementRow.awardedPercentage)}</p>
                            </div>
                        </g:if>
                        <g:else>
                            <g:if test="${achievementStatus == '-'}">
                            <div class="accordion-body bg-light">
                                <p class="mb-0 text-muted small">You have not been awarded this achievement yet.</p>
                                <p class="mb-0 text-muted small">Percentage of volunteers achieved: ${achievementRow.awardedPercentage}% - ${WebUtils.getAchievementPopularity(achievementRow.awardedPercentage)}</p>
                            </div>
                            </g:if>
                            <g:else>
                            <div class="accordion-body bg-light">
                                <div class="d-flex justify-content-between small text-muted mb-2">
                                    <span>Current progress: ${(achievement.count - achievementStatus.toInteger())} / ${achievement.count} Transcribed Tasks</span>

                                </div>
                                <div class="progress" style="height: 8px;">
                                    <g:set var="progressPercentage" value="${((achievement.count - achievementStatus.toInteger()) / achievement.count) * 100}" />
                                    <div class="progress-bar bg-info progress-bar-striped progress-bar-animated" role="progressbar" style="width: ${progressPercentage}%" aria-valuenow="${progressPercentage}" aria-valuemin="0" aria-valuemax="100"></div>
                                </div>
                                <p class="mb-0 text-muted small">Percentage of volunteers achieved: ${achievementRow.awardedPercentage}% - ${WebUtils.getAchievementPopularity(achievementRow.awardedPercentage)}</p>
                            </div>
                            </g:else>
                        </g:else>

                        </div>
                    </div>
                    </g:each>

                </div>
            </div>

            <!-- Modal Footer -->
            <div class="modal-footer bg-light py-2">
                <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Close Window</button>
            </div>

        </div>
    </div>
</div>