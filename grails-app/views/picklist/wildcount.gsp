<%@ page import="grails.converters.JSON; au.org.ala.volunteer.Project; au.org.ala.volunteer.Picklist" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <g:set var="entityName" value="${message(code: 'picklist.label', default: 'Picklist')}"/>
    <title><g:message code="default.list.label" args="[entityName]"/></title>
    <style>
    .picklist-item-row input[type="text"] {
        border: none;
        user-select: none;
        width: 100%;
        padding: 0;
    }

    .picklist-item-row input:focus {
        box-shadow: none;
        outline: none;
    }
    </style>
</head>

<body>

<cl:headerContent title="${message(code: 'default.picklists.label', default: 'Manage Wildcount Picklist')}">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Admin')],
                [link: createLink(controller: 'picklist', action: 'manage'), label: message(code: 'default.picklist.manage.label', default: 'Bulk manage picklists')]
        ]
    %>
</cl:headerContent>

<div class="card">
    <div class="card-body">
        <h1>Image Search</h1>
        <label class="visually-hidden" for="q">Search images</label>
        <div class="input-group">
            <input type="text" id="q" name="q" class="form-control">
            <button type="button" class="btn btn-sm btn-primary" id="search">Search</button>
        </div>
    </div>
</div>

<div class="card">
    <div class="card-body">
        <p><strong>Upload CSV</strong></p>
        <g:if test="${flash.message}">
            <div class="alert alert-info">
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                ${flash.message}
            </div>
        </g:if>
        <div>
            <label class="form-label" for="csv-input">CSV file</label>
            <input type="file" class="form-control" id="csv-input" accept=".csv,text/csv">
        </div>

        <div id="upload-div"><button type="button" class="btn btn-primary" id="upload">Do it</button></div>

        <div id="progress-div" class="d-none">
            <div class="progress">
                <div class="progress-bar progress-bar-striped progress-bar-animated" role="progressbar"
                     style="width: 0;" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"
                     aria-label="CSV upload progress"></div>
            </div>
        </div>
        <g:form name="upload-form" action="loadWildcount" id="${picklistInstance.id}">
            <g:hiddenField name="instCode" value="${institutionCode}"/>
            <g:hiddenField name="csv"/>
        </g:form>
    </div>
</div>
</div>
<div class="container-fluid">
    <table class="table table-condensed table-bordered">
                <thead>
                <tr>
                    <th style="width: 300px;">Value</th>
                    <th>Reference</th>
                    <th style="width: 300px;">Black and White</th>
                    <th style="width: 300px;">Colour</th>
                    <th>Tags</th>
                    <th>Similar Species</th>
                    <th style="width: 50px;">Controls</th>
                </tr>
                </thead>
                <tbody>
                <g:each in="${picklistItems}" status="i" var="item">
                    <g:set var="obj" value="${grails.converters.JSON.parse(item.key)}"/>
                    <tr class="picklist-item-row">
                        <td>
                            <input type="text" id="key-${i}" name="key-${i}" value="${item.value}">
                        </td>
                        <td>
                            <g:checkBox name="reference-${i}" checked="${obj.reference}"/>
                        </td>
                        <td>
                            <g:each in="${obj.nightImages}" var="img">
                                <img src="${imageMap[img].squareThumbUrl}"/>
                            </g:each>
                            <g:hiddenField name="nightImages-${i}" value="${obj.nightImages}"/>
                        </td>
                        <td>
                            <g:each in="${obj.dayImages}" var="img">
                                <img src="${imageMap[img].squareThumbUrl}"/>
                            </g:each>
                            <g:hiddenField name="dayImages-${i}" value="${obj.dayImages}"/>
                        </td>
                        <td>
                            <g:textField name="tags-${i}" value="${obj.tags}"/>
                        </td>
                        <td>
                            <g:textField name="similarSpecies-${i}" value="${obj.similarSpecies}"/>
                        </td>
                        <td>
                            <div class="btn-group">
                                <button type="button" class="btn btn-sm btn-outline-secondary"><i class="fa fa-arrow-up"></i></button>
                                <button type="button" class="btn btn-sm btn-outline-secondary"><i class="fa fa-arrow-down"></i></button>
                            </div>
                        </td>
                    </tr>
                </g:each>
                </tbody>
            </table>
    <asset:javascript src="underscore" asset-defer=""/>
    <asset:script>
        jQuery(function ($) {

            var reader = new FileReader();

            reader.onprogress = function (e) {
                var percentage = Math.round((e.loaded * 100) / e.total);
                $('#progress-div .progress-bar').css('width', percentage + '%').attr('aria-valuenow', percentage);
            };

            reader.onload = function (e) {
                var text = reader.result;
                $('#progress-div .progress-bar').css('width', '100%').attr('aria-valuenow', 100);
                $('#csv').val(text);
                $('#upload-form').submit();
            };

            $('#upload').click(function (e) {

                $('#progress-div,#upload-div').toggleClass('d-none');

                var files = $('#csv-input')[0].files;

                reader.readAsText(files[0]);
            });

        });
    </asset:script>
</body>
</html>