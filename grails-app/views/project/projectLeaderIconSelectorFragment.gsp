<div class="row-fluid">
    <div class="span12">
        <p class="lead">
            <g:message code="project.project_leader_icon.description"/>
        </p>
    </div>
    <g:each in="${role.icons}" var="icon" status="imgIndex">
        <g:set var="selectUrl"
               value="${createLink(controller: 'project', action: 'setLeaderIconIndex', id: projectInstance.id, params: [iconIndex: imgIndex])}"/>
        <div class="table table-striped">
            <div class="row-fluid">
                <div class="span3" style="text-align: center">
                    <a href="${selectUrl}">
                        <img src='<g:resource file="${icon.icon}"/>' alt="${icon.name}">
                    </a>
                </div>

                <div class="span9">
                    <strong>
                        <a href="${selectUrl}">${icon.name}</a>
                    </strong>

                    <div>
                        ${icon.bio}
                    </div>

                    <div>
                        <a href="${selectUrl}" class="btn"><g:message code="default.select.label"/></a>
                    </div>
                </div>
            </div>
        </div>
    </g:each>

</div>
