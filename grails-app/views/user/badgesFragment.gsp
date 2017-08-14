<style>

.bvpBadge {
    text-align: center;
}

.bvpBadge img {
    width: 140px;
    height: 140px;
}

.bvpBadge h3 {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.bvpBadge p {
    height: 4em;
}

.bvpBadge.unawarded img {
    opacity: 0.5;
    -webkit-filter: blur(3px);
    filter: blur(3px);
}

.itemgrid {
    overflow: hidden;
}

.itemgrid .item {
    float: left;
    width: 160px;
}
</style>

<div>

    <div class="itemgrid">
        <g:each in="${achievements}" var="ach" status="i">
            <div class="item bvpBadge">
                <img src="${cl.achievementBadgeUrl(achievement: ach.achievement)}"
                     title="${ach.achievement.i18nDescription}" alt="${ach.achievement.i18nName}"/>

                <h3 title="${ach.achievement.i18nName}">${ach.achievement.i18nName}</h3>

                <p>${ach.achievement.i18nDescription}</p>

                <div><em><g:message code="badged.badgesFragment.awarded"/> <prettytime:display date="${ach.awarded}"/></em></div>
            </div>
        </g:each>
        <g:each in="${allAchievements}" var="ach" status="i">
            <div class="item bvpBadge unawarded">
                <img src="${cl.achievementBadgeUrl(achievement: ach)}" title="${ach.i18nDescription}" alt="${ach.i18nName}"
                     class="grayscale"/>

                <h3 title="${ach.i18nName}">${ach.i18nName}</h3>

                <p>${ach.i18nDescription}</p>

                <div><em><g:message code="badged.badgesFragment.not_yet_awarded"/></em></div>
            </div>
        </g:each>
    </div>
</div>