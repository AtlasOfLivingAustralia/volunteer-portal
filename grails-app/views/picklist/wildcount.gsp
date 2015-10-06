<%@ page import="grails.converters.JSON; au.org.ala.volunteer.Project; au.org.ala.volunteer.Picklist" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
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
    <r:require modules="underscore, font-awesome"/>
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

<div class="row">
    <div class="span12">
        <div class="well well-small">
            <h1>Image Search</h1>
            <input type="text" id="q" name="q" class="input-block-level"><button type="button" class="btn btn-primary"
                                                                                 id="search">Search</button>
        </div>
    </div>
</div>

<div class="row">
    <div class="span12">
        <div class="well well-small">
            <p><strong>Upload CSV</strong></p>
            <g:if test="${flash.message}">
                <div class="alert">
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                    ${flash.message}
                </div>
            </g:if>
            <div><input type="file" id="csv-input"></div>

            <div id="upload-div"><button type="button" class="btn btn-primary" id="upload">Do it</button></div>

            <div id="progress-div" class="hidden">
                <div class="progress progress-striped active">
                    <div class="bar" style="width: 0;"></div>
                </div>
            </div>
            <g:form name="upload-form" action="loadWildcount" id="${picklistInstance.id}">
                <g:hiddenField name="instCode" value="${institutionCode}"/>
                <g:hiddenField name="csv"/>
            </g:form>
        </div>
    </div>
</div>

<r:script>
    jQuery(function ($) {

        var reader = new FileReader();

        reader.onprogress = function (e) {
            var percentage = Math.round((e.loaded * 100) / e.total);
            $('#progress-div .bar').css('width', percentage + '%');
        };

        reader.onload = function (e) {
            var text = reader.result;
            $('#progress-div .bar').css('width', '100%');
            $('#csv').val(text);
            $('#upload-form').submit();
        };

        $('#upload').click(function (e) {

            $('#progress-div,#upload-div').toggleClass('hidden');

            var files = $('#csv-input')[0].files;

            reader.readAsText(files[0]);
        });

    });
</r:script>
</div>
<div class="container-fluid">
    <div class="row-fluid">
        <div class="span12">
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
                            <g:textField name="tags-${i}" class="input-medium" value="${obj.tags}"/>
                        </td>
                        <td>
                            <g:textField name="similarSpecies-${i}" class="input-medium" value="${obj.similarSpecies}"/>
                        </td>
                        <td>
                            <div class="btn-group">
                                <button type="button" class="btn btn-mini"><i class="fa fa-arrow-up"></i></button>
                                <button type="button" class="btn btn-mini"><i class="fa fa-arrow-down"></i></button>
                            </div>
                        </td>
                    </tr>
                </g:each>
                </tbody>
            </table>
        </div>
    </div>

</body>