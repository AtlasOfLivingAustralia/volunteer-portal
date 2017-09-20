<%@ page contentType="text/html; charset=UTF-8" %>

<table class="table table-striped table-condensed">
    <g:each in="${projectList}" var="project">
        <tr projectId="${project.id}">
            <td style="width: 125px"><img src="${project.featuredImage}" style="height: 75px"/></td>
            <td>
                <strong>${project.i18nName}</strong>
                <br/>
                <small>${project.featuredOwner}</small>
            </td>


            <td>${project.i18nShortDescription}</td>
            <td width="80px">
                <button class="btnSelectProject btn pull-right"><g:message code="default.select.label"/></button>
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