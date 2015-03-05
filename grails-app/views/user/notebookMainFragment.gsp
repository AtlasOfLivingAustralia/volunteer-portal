<style>

    .userScore {
        font-size: 2em;
    }

    .recentAcheivement {
        text-align: center;
    }

    .recentAcheivement img {
        width: 140px;
        height: 140px;
    }

    .recentAchievementDate {
        font-style: italic;
    }

    .achievmentDescription {
    }

    .recentAcheivementLabel {
        font-weight: bold;
    }

</style>
<div class="row-fluid">
    <div class="span6">
        <h3>Your Score</h3>
        <div class="userScore">${score}</div>
        <h3>Your transcription stats:</h3>
        <strong>${userInstance.transcribedCount}</strong> tasks transcribed
        <br />
        <strong>${expeditionCount}</strong> Expeditions
        <g:if test="${recentAchievement}">
            <h3>Latest Achievement</h3>
            <div class="recentAcheivement">
                <img src='${cl.achievementBadgeUrl(achievement: recentAchievement.achievement)}' alt="${recentAchievement.achievement.name}" title="${recentAchievement.achievement.description}"/>
                <div class="recentAcheivementLabel">${recentAchievement.achievement.name}</div>
                <div class="achievmentDescription">${recentAchievement.achievement.description}</div>
                <div class="recentAchievementDate">Awarded on ${recentAchievement.awarded?.format("dd MMM, yyyy")}</div>

            </div>
        </g:if>
        <g:if test="${topSpecies}">
            <h3>Your top transcribed species</h3>
            <ul>
                <g:each in="${topSpecies}" var="species">
                    <li>
                        <span><a href="http://bie.ala.org.au/species/${species[0]}">${species[0]}</a></span>&nbsp;
                        <span>(${species[1]})</span>
                    </li>
                </g:each>

            </ul>
        </g:if>
    </div>
    <div class="span6">
        <h3>Recent transcriptions</h3>
        <div id="recentTranscriptions">
            <cl:spinner />
        </div>
    </div>
</div>

<script type="text/javascript">

    $.ajax("${createLink(controller:'user', action:'recentTasksFragment', id:userInstance.id)}").done(function(content) {
        $("#recentTranscriptions").html(content);
    });

</script>