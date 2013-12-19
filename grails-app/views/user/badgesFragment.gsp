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
            <g:each in="${achievements}" var="ach" status="i">
                <li>
                    <div class="bvpBadge">
                        <img src='<g:resource file="${ach.icon}"/>' alt="${ach.label}" title="${ach.description}"/>
                        <div>${ach.label}</div>
                    </div>
                </li>
            </g:each>
        </ul>
    </g:if>

</div>