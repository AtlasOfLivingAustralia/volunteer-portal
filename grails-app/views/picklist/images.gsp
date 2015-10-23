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

<cl:headerContent title="${message(code: 'default.picklists.label', default: 'Manage Image Picklists')}">
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
            <input type="text" id="q" name="q" class="input-block-level">
        </div>
    </div>
</div>

</div>

<div class="container-fluid">
    <div class="row-fluid">
        <div class="span12">
            <table class="table table-condensed table-bordered">
                <thead>
                <tr>
                    <th style="width: 300px;">Value</th>
                    <th>Images</th>
                    <th style="width: 50px;">Controls</th>
                </tr>
                </thead>
                <tbody>
                <g:each in="${picklistItems}" status="i" var="item">
                    <tr class="picklist-item-row">
                        <td>
                            <input type="text" id="key-${i}" name="key-${i}" value="${item.value}">
                        </td>
                        <td>

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