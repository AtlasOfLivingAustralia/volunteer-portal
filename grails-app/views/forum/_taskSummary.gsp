<%@ page import="au.org.ala.volunteer.Field; au.org.ala.volunteer.TemplateField" %>
<r:require module="jquery" />
<r:require module="imageViewerCss" />

<div class="row">

    <div class="span6">
        <div class="well well-small">
            <g:set var="multimedia" value="${taskInstance.multimedia.first()}" />
            <g:imageViewer multimedia="${multimedia}" />
        </div>
    </div>
    <div class="span6">
        <g:set var="templateFields" value="${TemplateField.findAllByTemplate(taskInstance?.project?.template)?.collectEntries { [it.fieldType.toString(), it] }}" />
        <g:set var="fields" value="${Field.findAllByTask(taskInstance)}" />
        <div style="height: 400px; overflow-y: scroll">
            <table class="table table-condensed table-striped table-bordered">
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

    $(document).ready(function() {
        setupImageViewer();
    });

    function setupImageViewer() {
        var target = $("#image-container img");
        if (target.length > 0) {
            target.panZoom({
                pan_step:10,
                zoom_step:10,
                min_width:200,
                min_height:200,
                mousewheel:true,
                mousewheel_delta:5,
                'zoomIn':$('#zoomin'),
                'zoomOut':$('#zoomout'),
                'panUp':$('#pandown'),
                'panDown':$('#panup'),
                'panLeft':$('#panright'),
                'panRight':$('#panleft')
            });

            target.panZoom('fit');
        }
    }


</r:script>

<style type="text/css">

</style>