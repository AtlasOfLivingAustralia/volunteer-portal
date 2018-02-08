<%@ page contentType="text/html; charset=UTF-8" %>
<div>

    <g:if test="${taskCount}">
        <div class="alert alert-danger">
            <g:message code="project.delete_expedition_fragment.overview" args="${ [projectInstance.i18nName, taskCount] }" />
        </div>
    </g:if>

    <div class="alert alert-danger">
        <g:message code="project.delete_expedition_fragment.confirmation"/>
    </div>

    <div class="form-horizontal">
        <div class="control-group">
            <div class="controls">
                <g:form controller="project" action="delete" id="${projectInstance.id}">
                    <button class="btn" id="btnCancelDeleteExpedition"><g:message code="default.cancel"/></button>
                    <button class="btn btn-primary" type="submit"><g:message code="project.delete_expedition"/></button>
                </g:form>
            </div>
        </div>
    </div>

</div>

<script>

    $("#btnCancelDeleteExpedition").click(function (e) {
        e.preventDefault();
        bvp.hideModal();
    });

</script>
