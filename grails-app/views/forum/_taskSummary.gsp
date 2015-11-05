<%@ page import="au.org.ala.volunteer.Field; au.org.ala.volunteer.TemplateField" %>
<r:require module="jquery"/>
<r:require module="imageViewer"/>

<div class="row">

    <div class="col-md-6">
        <div class="well well-small">
            <g:set var="multimedia" value="${taskInstance.multimedia.first()}"/>
            <g:imageViewer multimedia="${multimedia}" preserveWidthWhenPinned="true" hideShowInOtherWindow="${true}"/>
        </div>
    </div>

    <div class="col-md-6">
        <g:set var="templateFields"
               value="${TemplateField.findAllByTemplate(taskInstance?.project?.template)?.collectEntries {
                   [it.fieldType.toString(), it]
               }}"/>
        <g:set var="fields" value="${Field.findAllByTask(taskInstance)}"/>
        <div class="task-summary thumbnail">
            <table class="table table-condensed table-striped table-hover">
                <thead>
                <tr>
                    <th>Field</th>
                    <th>Name</th>
                </tr>
                </thead>
                <tbody>
                <g:each in="${fields.sort { it.name }}" var="field">
                    <g:if test="${!field.superceded && field.value}">
                        <tr>
                            <td>${templateFields[field.name]?.label ?: field.name}</td>
                            <td>${field.value}</td>
                        </tr>
                    </g:if>
                </g:each>
                </tbody>
            </table>
        </div>
    </div>

</div>

<r:script>

    $(document).ready(function () {
        setupPanZoom();
    });



</r:script>
