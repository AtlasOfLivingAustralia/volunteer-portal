<table class="table table-striped table-condensed">
    <g:each in="${projectList}" var="project">
        <tr projectId="${project.id}">
            <td style="width: 125px"><cl:featuredImage project="${project}" style="height: 75px;"/></td>
            <td>
                <strong>${project.name}</strong>
                <br/>
                <small>${project.featuredOwner}</small>
            </td>


            <td>${project.shortDescription}</td>
            <td width="80px">
                <button class="btnSelectProject btn pull-right">Select</button>
            </td>
        </tr>
    </g:each>
</table>

<g:hiddenField name="selectedProjectId" value=""/>

<script>

    $(".btnSelectProject").click(function (e) {
        e.preventDefault();
        var projectId = $(this).closest("[projectId]").attr("projectId");
        $("#selectedProjectId").val(projectId);
        bvp.hideModal();
    });

</script>