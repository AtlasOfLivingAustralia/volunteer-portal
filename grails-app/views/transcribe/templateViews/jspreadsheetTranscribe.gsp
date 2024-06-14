<%@ page import="au.org.ala.volunteer.FieldType; groovy.json.StringEscapeUtils; au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<%@ page import="au.org.ala.volunteer.PicklistService" %>
<%@ page contentType="text/html;charset=UTF-8" %>

<sitemesh:parameter name="useFluidLayout" value="${true}"/>
<g:applyLayout name="digivol-task" model="${pageScope.variables}">
<head>
    <title><cl:pageTitle title="${(validator) ? 'Validate' : 'Expedition'} ${taskInstance?.project?.name}" /></title>
    <asset:stylesheet src="jspreadsheet-ce.css"/>
    <link rel="stylesheet" href="https://jsuites.net/v4/jsuites.css"/>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Material+Icons" />
    <script src="https://jsuites.net/v4/jsuites.js"></script>
</head>

<g:set var="fieldList"
       value="${TemplateField.findAllByCategoryAndTemplate(FieldCategory.dataset, template, [sort: 'displayOrder'])}"/>

<content tag="templateView">

    <div class="row">
        <div class="col-md-12">
            <div>
                <g:set var="multimedia" value="${taskInstance.multimedia.first()}"/>
                <g:imageViewer multimedia="${multimedia}"/>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-md-12">
            <div class="well well-sm transcribeSection" style="margin-top: 10px">
                <span class="transcribeSectionHeaderLabel"><g:sectionNumber />. ${template.viewParams?.datasetSectionHeader ?: 'Specimen details'}</span>

                <div class="row" style="margin-top: 10px">
                    <div class="col-md-12">
                        <div id="spreadsheet"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</content>

<asset:javascript src="jspreadsheet.js" asset-defer=""/>
<asset:script type="text/javascript" asset-defer="">
    var fieldList = <cl:json value="${fieldList}"/>;



    var options = {
        tableWidth: "100%",

        data: []
    }


    $(document).ready(function() {
        $('#spreadsheet').jspreadsheet(options);
    });

    function initSpreadsheet() {

    }


/*
    jspreadsheet(document.getElementById('spreadsheet'), {
        tableWidth: "100%",
        columns:<cl:json value="${fieldList}"/>,
        data: []
    });*/
</asset:script>
</g:applyLayout>