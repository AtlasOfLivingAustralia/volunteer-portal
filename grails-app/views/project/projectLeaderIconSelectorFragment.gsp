<div class="row-fluid">
    <div class="span12">
        <p class="lead">
            As expedition leader you have the privilege of selecting the icon for the expedition leader of the project
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
                        <a href="${selectUrl}" class="btn">Select</a>
                    </div>
                </div>
            </div>
        </div>
    </g:each>

</div>
