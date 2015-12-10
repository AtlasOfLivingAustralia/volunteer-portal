<%@ page import="au.org.ala.volunteer.FieldType; au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}"/>

<style>
</style>

<div class="row">
    <div class="col-md-12">
        <div>
            <g:set var="multimedia" value="${taskInstance.multimedia.first()}"/>
            <g:imageViewer multimedia="${multimedia}"/>
        </div>
    </div>
</div>

<div class="row" style="margin-top: 10px">
    <div class="col-md-9">
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

    <div class="col-md-3">
        <g:if test="${taskInstance?.project?.tutorialLinks}">
            <div class="tutorialLinks" style="text-align: right">
                ${raw(taskInstance?.project?.tutorialLinks)}
            </div>
        </g:if>
    </div>

</div>

<g:set var="columnCount" value="${template.viewParams?.columns ?: 2}"/>
<g:set var="visibleFields"
       value="${TemplateField.findAllByTemplateAndTypeNotEqual(template, FieldType.hidden, [sort: 'displayOrder', order: 'asc'])}"/>
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
<div class="row">
    <div class="col-md-12">
        <div class="panel panel-default transcribeSection">
            <div class="panel-body">
                <div class="row">
                    <div class="col-md-12">
                        <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}. Details</span>
                    </div>
                    <g:set var="spanClass" value="${"col-md-${12 / columnCount}"}"/>
                    <g:each in="${columns}" var="column">
                        <div class="${spanClass}">
                            <g:each in="${column}" var="field">
                                <g:renderFieldBootstrap tabindex="${field.displayOrder}" field="${field}" recordIdx="${0}"
                                                        recordValues="${recordValues}" task="${taskInstance}" labelClass="col-md-4"
                                                        valueClass="col-md-8"/>
                            </g:each>
                        </div>
                    </g:each>
                </div>
            </div>
        </div>
    </div>
</div>



<r:script>

    $(document).ready(function () {
        $(".tutorialLinks a").each(function (index, element) {
            $(this).addClass("btn btn-default").attr("target", "tutorialWindow");
        });
    });

</r:script>