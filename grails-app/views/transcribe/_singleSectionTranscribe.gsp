<%@ page import="au.org.ala.volunteer.FieldType; au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}" />

<style>
</style>

<div class="container-fluid">
    <div class="row-fluid">
        <div class="span12">
            <div>
                <g:set var="multimedia" value="${taskInstance.multimedia.first()}" />
                <g:imageViewer multimedia="${multimedia}" />
            </div>
        </div>
    </div>

    <div class="row-fluid" style="margin-top: 10px">
        <div class="span9">
            <table style="width:100%">
                <tr>
                    <td>
                        <strong>Institution:</strong>
                        <span class="institutionName">${taskInstance?.project?.featuredOwner}</span>
                    </td>
                    <td>
                        <strong>Project:</strong>
                        <span class="institutionName">${taskInstance?.project?.name}</span>
                    </td>
                    <td>
                        <strong>Catalog Number:</strong>
                        <span class="institutionName">${recordValues?.get(0)?.catalogNumber}</span>
                    </td>
                    <td>
                        <strong>Taxa:</strong>
                        <span class="institutionName">${recordValues?.get(0)?.scientificName}</span>
                    </td>
                </tr>
            </table>
        </div>
        <div class="span3">
            <g:if test="${taskInstance?.project?.tutorialLinks}">
                <div class="tutorialLinks" style="text-align: right">
                    ${taskInstance?.project?.tutorialLinks}
                </div>
            </g:if>
        </div>

    </div>

    <g:set var="columnCount" value="${template.viewParams?.columns ?: 2}" />
    <g:set var="visibleFields" value="${TemplateField.findAllByTemplateAndTypeNotEqual(template, FieldType.hidden, [sort:'displayOrder', order:'asc'])}" />
    <%
        def columns = []
        for (int i = 0; i < columnCount; ++i) {
            columns << [];
        }
        for (int i = 0; i < visibleFields.size(); ++i) {
            def field = visibleFields[i]
            columns[i % columnCount] << field;
        }
    %>

    <div class="well well-small transcribeSection">
        <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}. Specimen details</span>
        <div class="row-fluid">
            <g:set var="spanClass" value="${"span${12 / columnCount}"}" />
            <g:each in="${columns}" var="column">
            <div class="${spanClass}">
                <g:each in="${column}" var="field">
                    <g:renderFieldBootstrap tabindex="${field.displayOrder}" fieldType="${field.fieldType}" recordIdx="${0}" recordValues="${recordValues}" task="${taskInstance}" labelClass="span4" valueClass="span8" />
                </g:each>
            </div>
            </g:each>
        </div>
    </div>

</div>


<r:script>

    $(document).ready(function() {
        $(".tutorialLinks a").each(function(index, element) {
            $(this).addClass("btn").attr("target", "tutorialWindow");
        });
    });

</r:script>