%{--<style>--}%

    %{--.bvpBadge {--}%
        %{--text-align: center;--}%
    %{--}--}%

    %{--.bvpBadge img {--}%
        %{--width: 140px;--}%
        %{--height: 140px;--}%
    %{--}--}%

    %{--.itemgrid { overflow: hidden; }--}%
    %{--.itemgrid .item { float: left; width: 160px; }--}%
%{--</style>--}%
<div>
    <ul class="thumbnails">
        <g:each in="${achievements}" var="ach" status="i">
            <li class="span3">
                <div class="thumbnail">
                    <img src="${cl.achievementBadgeUrl(achievement: ach.achievement)}" title="${ach.achievement.description}" alt="${ach.achievement.name}"/>
                    <h3>${ach.achievement.name}</h3>
                    <p>${ach.achievement.description}</p>
                    <p><em>Awarded <prettytime:display date="${ach.awarded}" /></em></p>
                </div>
            </li>
        </g:each>
        <g:each in="${allAchievements}" var="ach" status="i">
            <li class="span3">
                <div class="thumbnail">
                    <img src="${cl.achievementBadgeUrl(achievement: ach)}" title="${ach.description}" alt="${ach.name}" class="grayscale"/>
                    <h3>${ach.name}</h3>
                    <p>${ach.description}</p>
                    <p><em>Not yet awarded</em></p>
                </div>
            </li>
        </g:each>
    </ul>
    %{--<div class="itemgrid">--}%
        %{--<g:each in="${achievements}" var="ach" status="i">--}%
            %{--<div class="item bvpBadge">--}%
                %{--<img src="${cl.achievementBadgeUrl(achievement: ach.achievement)}" title="${ach.achievement.description}" alt="${ach.achievement.name}"/>--}%
                %{--<div>${ach.achievement.name}</div>--}%
                %{--<div>Awarded <prettytime:display date="${ach.awarded}" /></div>--}%
            %{--</div>--}%
        %{--</g:each>--}%
        %{--<g:each in="${allAchievements}" var="ach" status="i">--}%
            %{--<div class="item bvpBadge">--}%
                %{--<img src="${cl.achievementBadgeUrl(achievement: ach)}" title="${ach.description}" alt="${ach.name}" class="grayscale"/>--}%
                %{--<div>${ach.name}</div>--}%
                %{--<div>Not yet awarded</div>--}%
            %{--</div>--}%
        %{--</g:each>--}%
    %{--</div>--}%
</div>