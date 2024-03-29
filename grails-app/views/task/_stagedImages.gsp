
<div class="row">
    <div class="col-md-12">
        <h3>Staged <g:if test="${isAudioProject}">audio samples</g:if><g:else>images</g:else> (${images.size()})

            <div class="btn-group pull-right">
                <a class="btn btn-default dropdown-toggle" data-toggle="dropdown" href="#">
                    <i class="fa fa-cog"></i> Actions
                    <span class="caret"></span>
                </a>
                <ul class="dropdown-menu">
                    <g:if test="${!isAudioProject}">
                    <li>
                        <a href="#" class="btnStageAddFieldDefinition"><i
                                class="fa fa-plus"></i>&nbsp;Add a column</a>
                    </li>
                    <li class="divider"></li>
                    </g:if>
                    <li>
                        <a href="#" id="btnExportTasksCSV"><i
                                class="fa fa-file"></i>&nbsp;Export staged tasks as CSV</a>
                    </li>
                    <li class="divider"></li>
                    <li>
                        <a href="#" id="btnClearStagingArea"><i
                                class="fa fa-trash"></i>&nbsp;Delete all <g:if test="${isAudioProject}">audio samples</g:if><g:else>images</g:else></a>
                    </li>
                </ul>
            </div>
        </h3>
    </div>
</div>



<div class="row">
    <div class="col-md-12">
        <table class="table table-striped table-hover">
            <thead>
            <tr>
                <th>
                    <div>&nbsp;</div>
                    Image file
                </th>
                <g:each in="${profile.fieldDefinitions.sort({ it.id })}" var="field">
                    <th fieldDefinitionId="${field.id}" style="vertical-align: bottom;">
                        <div class="text-center display-inline-block">
                            ${field.fieldName}<g:if test="${field.recordIndex}">[${field.recordIndex}]</g:if>
                            <br/>
                            <div class="small">
                                <span style="font-weight: normal">( ${field.fieldDefinitionType}: <b>${field.format}</b> - </span>

                                <button class="btnEditField btn btn-xs btn-default" title="Edit column definition">
                                    <i class="fa fa-edit"></i>
                                </button>
                                <g:if test="${field.fieldName != 'externalIdentifier'}">
                                    <button class="btnDeleteField btn btn-xs btn-danger" title="Remove column">
                                        <i class="fa fa-remove"></i>
                                    </button>
                                </g:if>
                                )
                            </div>
                        </div>
                    </th>
                </g:each>
                <th style="width: 40px">
                </th>
            </tr>
            </thead>
            <tbody>
            <g:each in="${images}" var="image">
                <tr>
                    <td>
                        <a href="${image.url}">${image.name}</a>
                        <g:if test="${image.shadowFiles}">
                            <ul class="nav nav-pills nav-stacked" style="margin-left: 10px">
                                <g:each in="${image.shadowFiles}" var="shadow">
                                    <li>
                                        <div class="label label-default">
                                            <i class="fa fa-chevron-right"></i> <%= shadow.stagedFile.name.replace(shadow.fieldName, "<em>${shadow.fieldName}</em>")%>
                                            <button class="btnDeleteShadowFile btn btn-xs btn-danger"
                                               title="Delete shadow file ${shadow.stagedFile.name}"
                                               filename="${shadow.stagedFile.name}"><i
                                                    class="fa fa-remove"></i></button>
                                        </div>
                                    </li>
                                </g:each>
                            </ul>
                        </g:if>
                    </td>
                    <g:each in="${profile.fieldDefinitions.sort({ it.id })}" var="field">
                        <td>${image.valueMap[field.fieldName + "_" + field.recordIndex]}</td>
                    </g:each>
                    <td>
                        <button title="Delete image" class="btn btn-xs btn-danger btnDeleteImage" imageName="${image.name}"><i
                                class="fa fa-remove"></i></button>
                    </td>
                </tr>
            </g:each>
            </tbody>
        </table>
    </div>
</div>
