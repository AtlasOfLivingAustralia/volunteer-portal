
<g:hiddenField name="selectedUserRoleId" value="" id="selectedUserRoleId"/>
<g:hiddenField name="selectedUserRoleAction" value="" id="selectedUserRoleAction"/>

<g:if test="${userInstance.userRoles?.size() == 0}">
    This user has no roles currently. Click 'Add role' to create a new role
</g:if>

<div class="panel">
    <table class="table table-hover table-striped sortable">
        <thead>
        <tr>
            <th class="sortable">Role</th>
            <th class="sortable">Institution</th>
            <th class="sortable">Project</th>
        </tr>
        </thead>
        <g:each in="${userInstance.userRoles}" var="userRole" status="i">
            <tr id="userRole_${userRole.id}">

                <td width="20%">${userRole.role?.name}</td>

                <td width="50%">
                    ${userRole.institution?.name}
                </td>
                <td width="50%">
                    ${userRole.project?.featuredLabel}</td>
                <td witdth="20%">
                    <button class="btn btn-danger deleteRole" userRoleId="${userRole.id}">
                        <i class="icon-remove icon-white"></i>&nbsp;Delete
                    </button>
                </td>

            </tr>
        </g:each>
    </table>
</div>
