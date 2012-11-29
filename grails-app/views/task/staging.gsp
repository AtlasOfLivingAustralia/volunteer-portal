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

        .section {
            border: 1px solid #a9a9a9;
            padding: 10px;
            margin-bottom: 10px;
        }
        .section h4 {
            margin-bottom: 5px;
        }

        </style>
        <script type='text/javascript'>

            $(document).ready(function () {

                $(".btnDeleteImage").click(function(e) {
                    var imageName = $(this).attr("imageName");
                    if (imageName) {
                        window.location = "${createLink(controller:'task', action:'unstageImage', params:[projectId: projectInstance.id])}&imageName=" + imageName;
                    }
                });

                $("#btnAddFieldDefinition").click(function(e) {

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
                        <li><a class="home" href="${createLink(controller: 'project', action: 'edit', id: projectInstance.id)}">Edit Project</a>
                        </li>
                        <li class="last">Task Load Staging</li>
                    </ol>
                </nav>
                <hgroup>
                    <h1>Project Task Staging</h1>
                </hgroup>
            </div>
        </header>

        <div>
            <div class="inner">
                <cl:messages/>

                <div id="fieldDefinitionsSection" class="section">
                    <table style="width: 100%">
                        <tr>
                            <td>
                                <h4>Imported Field Definitions</h4>
                            </td>
                            <td>
                                <g:select name="fieldType" from="${au.org.ala.volunteer.FieldDefinitionType.values()}"/>
                                <button class="button" id="btnAddFieldDefinition">Add field</button>
                            </td>
                        </tr>
                    </table>

                    <table class="bvp-expeditions">
                        <thead>
                            <tr>
                                <th style="text-align: left">Field</th>
                                <th style="text-align: left">Field Type</th>
                                <th style="text-align: left">Field Value definition</th>
                            </tr>
                        </thead>
                        <tbody>
                            <g:each in="${profile.fieldDefinitions}" var="field">
                                <tr>
                                    <td>${field.fieldName}</td>
                                    <td><g:select name="fieldType" from="${au.org.ala.volunteer.FieldDefinitionType.values()}"/></td>
                                    <td>
                                        <g:if test="${field.fieldDefinitionType != FieldDefinitionType.Literal}">
                                            <g:textField name="fieldValue" value="${field.format}"/>
                                        </g:if>
                                    </td>
                                </tr>
                            </g:each>
                        </tbody>
                    </table>

                </div>

                <div id="uploadImagesSection" class="section">
                    <h4>Upload task images to staging area</h4>
                    <g:form controller="task" action="stageImage" method="post" enctype="multipart/form-data">
                        %{--<label for="imageFile"><strong>Upload task image file:</strong></label>--}%
                        <input type="file" name="imageFile" id="imageFile" multiple="multiple"/>
                        <g:hiddenField name="projectId" value="${projectInstance.id}"/>
                        <g:submitButton name="Stage images"/>
                    </g:form>
                    <div>
                    </div>
                </div>

                <div id="imagesSection" class="section">
                    <h4>Staged images (${images.size()})</h4>
                    <table class="bvp-expeditions">
                        <thead>
                            <tr>
                                <th style="text-align: left">Image file</th>
                                <g:each in="${profile.fieldDefinitions}" var="field">
                                    <th style="text-align: left">${field.fieldName}</th>
                                </g:each>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <g:each in="${images}" var="image">
                                <tr>
                                    <td><a href="${image.url}">${image.name}</a></td>
                                    <g:each in="${profile.fieldDefinitions}" var="field">
                                        <td>${image.valueMap[field.fieldName]}</td>
                                    </g:each>
                                    <td>
                                        <button class="button btnDeleteImage" imageName="${image.name}">Delete</button>
                                    </td>
                                </tr>
                            </g:each>
                        </tbody>
                    </table>
                </div>

            </div>
        </div>
    </body>
</html>
