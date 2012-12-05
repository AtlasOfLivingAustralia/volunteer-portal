<%@ page import="au.org.ala.volunteer.FieldDefinitionType; au.org.ala.volunteer.Project" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <title><g:message code="admin.label" default="Administration"/></title>
        <style type="text/css">

        .bvp-expeditions td button {
            margin-top: 5px;
        }

        .bvp-expeditions th {
            text-align: left;
        }

        .bvp-expeditions tbody tr td table {
            margin: 0px;
        }


        .bvp-expeditions tbody tr td table tr td {
            vertical-align: top;
            border-bottom: none;
            padding: 2px;
        }

        .bvp-expeditions tbody tr td table tr td button {
            margin-top: 0px;
        }

        table.bvp-expeditions .btn img, .imageButton {
            padding-left: 0;
        }
        .section h4 {
            margin-bottom: 5px;
        }

        #buttonBar {
            margin-bottom: 6px;
        }

        </style>
        <script type='text/javascript'>

            $(document).ready(function() {

                $(".btnMoveFieldUp").click(function(e) {
                    e.preventDefault();
                    var fieldId = $(this).parents("[fieldId]").attr('fieldId');
                    if (fieldId) {
                        window.location = "${createLink(controller: 'template', action:'moveFieldUp')}?fieldId=" + fieldId;
                    }
                });

                $(".btnMoveFieldDown").click(function(e) {
                    e.preventDefault();
                    var fieldId = $(this).parents("[fieldId]").attr('fieldId');
                    if (fieldId) {
                        window.location = "${createLink(controller: 'template', action:'moveFieldDown')}?fieldId=" + fieldId;
                    }
                });

                $("#btnCleanUpOrdering").click(function(e) {
                    e.preventDefault();
                    window.location = "${createLink(controller:'template', action:'cleanUpOrdering', id:templateInstance.id)}";
                });

                $("#btnAddField").click(function(e) {
                    e.preventDefault();
                    var fieldType = encodeURIComponent($("#fieldName").val());
                    if (fieldType) {
                        window.location = "${createLink(controller:'template', action:'addField', id:templateInstance.id)}?fieldType=" + fieldType;
                    }
                });

                $(".btnDeleteField").click(function(e) {
                    e.preventDefault();
                    var fieldId = $(this).parents("[fieldId]").attr("fieldId");
                    if (fieldId) {
                        window.location = "${createLink(controller:'template', action:'deleteField', id: templateInstance.id)}?fieldId=" + fieldId;
                    }
                });

                $(".btnEditField").click(function(e) {
                    e.preventDefault();
                    var fieldId = $(this).parents("[fieldId]").attr("fieldId");
                    if (fieldId) {
                        window.location = "${createLink(controller:'templateField', action:'edit')}/" + fieldId;
                    }
                });

            });

        </script>
    </head>

    <body class="sublevel sub-site volunteerportal">

        <cl:navbar/>

        <header id="page-header">
            <div class="inner">
                <cl:messages/>
                <nav id="breadcrumb">
                    <ol>
                        <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
                        <li><a class="home" href="${createLink(controller: 'template', action: 'list')}">Templates</a>
                        <li><a class="home" href="${createLink(controller: 'template', action: 'edit', id: templateInstance.id)}">Edit ${templateInstance.name}</a></li>
                        <li class="last">Manage Template Fields</li>
                    </ol>
                </nav>
                <hgroup>
                    <h1>Template Fields - ${templateInstance.name}</h1>
                </hgroup>
            </div>
        </header>

        <div>
            <div class="inner">
                <div id="buttonBar">
                    <button class="button" id="btnCleanUpOrdering">Clean up ordering</button>
                    Field Type:
                    <g:select name="fieldName" from="${au.org.ala.volunteer.DarwinCoreField.values().sort({ it.name() })}"/>
                    <button class="button" id="btnAddField">Add field</button>
                </div>
                <table class="bvp-expeditions">
                    <thead>
                        <tr>
                            <th>Order</th>
                            <th>DwC Field</th>
                            <th>Form type</th>
                            <th>Label</th>
                            <th>Category</th>
                            <th>Help text</th>
                            <th style="width:100px"></th>
                        </tr>
                    </thead>
                    <tbody>

                        <g:each in="${fields}" var="field">
                            <tr fieldId="${field.id}">
                                <td>${field.displayOrder}</td>
                                <td><strong>${field.fieldType}</strong></td>
                                <td>${field.type}</td>
                                <td>${field.label}</td>
                                <td>${field.category}</td>
                                <td><small>${field.helpText}</small></td>
                                <td style="padding:0px">
                                    <table style="display:inline-block;">
                                        <tr>
                                            <td><button class="button btnMoveFieldUp imageButton"><img src="${resource(dir:'/images', file:'up_arrow.png')}" alt=""></button></td>
                                            <td><button class="button btnDeleteField">Delete</button></td>
                                            <td><button class="button btnEditField">Edit</button></td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <button class="button btnMoveFieldDown imageButton"><img src="${resource(dir:'/images', file:'down_arrow.png')}" alt=""></button>
                                            </td>
                                            <td></td>
                                            <td></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </g:each>
                    </tbody>
                </table>
            </div>
        </div>
    </body>
</html>
