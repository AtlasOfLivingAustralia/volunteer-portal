<style>

    .bvpBadge {
        text-align: center;
    }

    .bvpBadge img {
        width: 100px;
    }
</style>
<div>
    <g:if test="${achievements.size() > 0}">
        <ul class="thumbnails">
            <g:each in="${allAchievements}" var="ach" status="i">
                <li>
                    <div class="bvpBadge">
                    <g:set value="${achievements.find({ it.name == ach.name })}" var="userAchievement" />
                    <g:if test="${userAchievement}">
                        <img src='<g:resource file="${ach.icon}"/>' alt="${ach.label}" title="${ach.description}"/>
                        <div>${ach.label}</div>
                    </g:if>
                    <g:else>
                        <img src='<g:resource dir="/images/achievements" file="blank.png"/>' alt="${ach.label}" title="You have not yet achieved this badge"/>
                        <div>${ach.label}</div>
                    </g:else>
                    </div>
                </li>
            </g:each>
        </ul>
    </g:if>
    <g:else>
        <p>You don't seem to have any badges :(</p>
    </g:else>

</div>