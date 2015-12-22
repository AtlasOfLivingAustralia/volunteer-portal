<style>

.recentAcheivement img {
    width: 140px;
    height: 140px;
}

@media (max-width: 979px) and (min-width: 768px) {
    #gravatar {
        height: 50px;
        width: 50px;
    }
}

@media (min-width: 768px) {
    #my-difference {
        min-height: 363px;
    }
}

#piechart {
    width: 100%;
    height: 250px;
}

</style>

<div class="span6">
    <div class="row">
        <div class="span6">
            <div class="media">
                <a class="pull-left" href="//en.gravatar.com/" class="external" target="_blank" id="gravitarLink"
                   title="To customise this avatar, register your email address at gravatar.com...">
                    <img id="gravatar"
                         src="//www.gravatar.com/avatar/${userInstance.email.toLowerCase().encodeAsMD5()}?s=125"
                         class="img-polaroid media-object"/> %{-- style="width:150px;" class="avatar" --}%
                </a>

                %{--<g:if test="${userInstance.userId == currentUser}">--}%
                %{--<p>--}%
                %{--<a href="http://en.gravatar.com/" class="external" target="_blank" id="gravitarLink" title="To customise this avatar, register your email address at gravatar.com...">Change avatar</a>--}%
                %{--</p>--}%
                %{--</g:if>--}%
                <div class="media-body">
                    <dl class="dl-horizontal">
                        <dt><g:message code="user.score.label" default="Volunteer score"/></dt>
                        <dd>${score}</dd>
                        <dt><g:message code="user.recordsTranscribedCount.label" default="Tasks transcribed"/></dt>
                        <dd>${userInstance.transcribedCount} (${validatedCount} of which have been validated)</dd>
                        <dt><g:message code="user.transcribedValidatedCount.label" default="Tasks validated"/></dt>
                        <dd>${userInstance.validatedCount}</dd>
                        <dt><g:message code="user.created.label" default="First contribution"/></dt>
                        <dd><prettytime:display date="${userInstance?.created}"/></dd>
                    </dl>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="span6">
            <section>
                <h3>Recent Badges</h3>
                <g:if test="${recentAchievements}">
                    <ul class="thumbnails">
                        <g:each in="${recentAchievements}" var="ach" status="i">
                            <li class="span2">
                                <a href="javascript:void(0)" class="thumbnail" data-switch-tab="badgesTab">
                                    <img src='<cl:achievementBadgeUrl achievement="${ach.achievement}"/>'
                                         alt="${ach.achievement.name}" title="${ach.achievement.description}"/>
                                </a>
                            </li>
                        </g:each>
                    </ul>
                </g:if>
                <g:else>
                    <span>You haven't been awarded any <a href="javascript:void(0)"
                                                          data-switch-tab="badgesTab">badges</a> yet.</span>
                </g:else>
            </section>
        </div>
    </div>
</div>

<div class="span5 pull-right">
    <section id="my-difference" class="well">
        <h1>How you're making a difference!</h1>
        <ul>
            <g:if test="${totalSpeciesCount > 0}">
                <li>
                    <span>You have added ${totalSpeciesCount} species to the ALA</span>

                    <div id="piechart"></div>
                </li>
            </g:if>
            <g:if test="${fieldObservationCount > 0}">
                <li>
                    <span>You have contributed to ${fieldObservationCount} new field observations</span>
                </li>
            </g:if>
            <g:if test="${expeditionCount > 0}">
                <li>
                    <span>You have participated in ${expeditionCount} expeditions</span>
                </li>
            </g:if>
            <g:if test="${userPercent != '0.00'}">
                <li>
                    <span>You have transcribed ${userPercent}% of the total transcriptions on DigiVol</span>
                </li>
            </g:if>
        </ul>
    </section>
    %{--<h3>Recent transcriptions</h3>--}%
    %{--<div id="recentTranscriptions">--}%
    %{--<cl:spinner />--}%
    %{--</div>--}%
</div>

<script type="text/javascript">
    var table = <cl:json value="${speciesList}" />;
    //google.load("visualization", "1", {packages:["corechart"]});
    //    google.setOnLoadCallback(drawChart);
    function drawChart() {

        var data = new google.visualization.DataTable();
        data.addColumn('string', 'Scientific Name');
        data.addColumn('number', 'Transcriptions');
        data.addRows(table);

//        var data = google.visualization.arrayToDataTable(table);
        var options = {
//            'width': 245,
//            'height': 250,
            'chartArea': {'width': '100%', 'height': '80%'},
            'legend': {'position': 'bottom'},
            is3D: true,
            backgroundColor: {fill: 'transparent'}
        };

        var chart = new google.visualization.PieChart(document.getElementById('piechart'));
        chart.draw(data, options);
    }
    drawChart();

    $(window).resize(function () {
        drawChart();
    });

    %{--$.ajax("${createLink(controller:'user', action:'recentTasksFragment', id:userInstance.id)}").done(function(content) {--}%
    %{--$("#recentTranscriptions").html(content);--}%
    %{--});--}%

</script>