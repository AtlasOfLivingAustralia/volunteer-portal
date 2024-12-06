<%@ page import="au.org.ala.volunteer.Template" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <g:set var="entityName" value="${message(code: 'template.label', default: 'Template')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>
    <style>
        input[type="checkbox"] {
            margin-left: 0px !important;
        }

        h4.panel-title {
            font-size: 12px;

        }

        .panel-title:hover {
            cursor: pointer;
        }

        .panel {
            margin: 5px !important;
        }

        .collapse-toggle {
            border-radius: 5px;
        }
    </style>
</head>

<body class="admin">
<div class="container">
    <cl:headerContent title="${message(code: 'default.edit.label', args: [entityName])} - ${templateInstance.name}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin', action: 'index'), label: 'Administration'],
                    [link: createLink(controller: 'template', action: 'list'), label: message(code: 'template.manage.label', default: "Manage Templates")]
            ]
        %>
        <div>
            <a href="${createLink(action: 'create')}" class="btn btn-default">Create new template</a>
        </div>
    </cl:headerContent>

    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <g:hasErrors bean="${templateInstance}">
                        <div class="errors">
                            <g:renderErrors bean="${templateInstance}" as="list"/>
                        </div>
                    </g:hasErrors>
                    <g:form method="post" class="form-horizontal">
                        <g:hiddenField name="id" value="${templateInstance?.id}"/>
                        <g:hiddenField name="version" value="${templateInstance?.version}"/>

                        <div class="form-group ${hasErrors(bean: templateInstance, field: 'name', 'has-error')}">
                            <label for="name" class="col-md-3 control-label"><g:message code="template.name.label" default="Name"/></label>
                            <div class="col-md-6">
                                <g:textField name="name" class="form-control" maxlength="200" required="true" value="${templateInstance?.name}"/>
                            </div>
                            <div class="col-md-3">
                                <cl:templateEditableButton template="${templateInstance}" styleClass="btn btn-default" id="btnEditFields" label="Edit Fields"/>
                                <button class="btn btn-default" id="btnPreview">Preview Template</button>
                            </div>
                        </div>

                        <div class="form-group ${hasErrors(bean: templateInstance, field: 'viewName', 'has-error')}">
                            <label for="viewName" class="col-md-3 control-label"><g:message code="template.viewName.label" default="View Name"/></label>
                            <div class="col-md-6">
                                <g:if test="${availableViews}">
                                    <g:select from="${availableViews}" name="viewName" class="form-control" value="${templateInstance?.viewName}"/>
                                </g:if>
                                <g:else>
                                    <g:textField name="viewName" class="form-control" value="${templateInstance?.viewName}"/>
                                </g:else>
                            </div>
                        </div>

                        <div id="row-view-params-form" style="display: none;">
                        </div>

                        <div id="row-view-params-json"
                             class="form-group ${hasErrors(bean: templateInstance, field: 'viewParams', 'error')}">
                            <label class="col-md-3 control-label" for="viewParamsJSON"><g:message code="template.viewparams.label"
                                                                                         default="Template View Parameters:"/></label>

                            <div class="col-md-6">
                                <g:textArea name="viewParamsJSON" rows="4" cols="40" class="form-control"
                                            value="${templateInstance.viewParams as grails.converters.JSON}" />
                            </div>
                        </div>

                        <div class="form-group ${hasErrors(bean: templateInstance, field: 'supportMultipleTranscriptions', 'has-error')}">
                            <label class="col-md-3 control-label" for="supportMultipleTranscriptions">
                                <g:message code="template.multipletanscriptions.label"
                                           default="Support multiple transcriptions per task?"/>

                            </label>
                            <div class="col-md-6">
                                <div style="padding-top: 10px">
                                    <g:checkBox name="supportMultipleTranscriptions"
                                                checked="${templateInstance.supportMultipleTranscriptions}"/>
                                    &nbsp;&nbsp;<a href="#" class="btn btn-default btn-xs fieldHelp"
                                                   title="<g:message code="template.multipletanscriptions.helptext"
                                                                     default="Ignored for Specimen and Fieldnote Expedition types."/>">
                                    <span class="help-container"><i class="fa fa-question"></i></span></a>
                                </div>
                            </div>
                        </div>

                        <cl:ifSiteAdmin>
                        <div class="form-group ${hasErrors(bean: templateInstance, field: 'isGlobal', 'has-error')}">
                            <label class="col-md-3 control-label" for="isGlobal">
                                <g:message code="template.isglobal.label"
                                           default="Is a Global Template?"/>
                            </label>
                            <div class="col-md-6">
                                <div style="padding-top: 10px">
                                    <g:checkBox name="isGlobal"
                                                checked="${templateInstance.isGlobal}"/>
                                    &nbsp;&nbsp;<a href="#" class="btn btn-default btn-xs fieldHelp"
                                                   title="<g:message code="template.globaltemplate.helptext"
                                                                     default="A global template is available to all institutions."/>">
                                    <span class="help-container"><i class="fa fa-question"></i></span></a>
                                </div>
                            </div>
                        </div>

                        <div class="form-group ${hasErrors(bean: templateInstance, field: 'isHidden', 'has-error')}">
                            <label class="col-md-3 control-label" for="isHidden">
                                <g:message code="template.ishidden.label"
                                           default="Hide Template?"/>
                            </label>
                            <div class="col-md-6">
                                <div style="padding-top: 10px">
                                    <g:checkBox name="isHidden"
                                                checked="${templateInstance.isHidden}"/>
                                    &nbsp;&nbsp;<a href="#" class="btn btn-default btn-xs fieldHelp"
                                                   title="<g:message code="template.hidden.helptext"
                                                                     default="Hide this template from all users."/>">
                                    <span class="help-container"><i class="fa fa-question"></i></span></a>
                                </div>
                            </div>
                        </div>
                        </cl:ifSiteAdmin>

                        <div class="form-group">
                            <div class="col-md-offset-3 col-md-9">
                                <g:actionSubmit class="btn btn-primary" action="update"
                                                value="${message(code: 'default.button.update.label', default: 'Update')}"/>
                                <cl:ifSiteAdmin>
                                    <g:actionSubmit class="btn btn-danger delete" action="delete" id="deleteButton"
                                                disabled="${templateInstance.projects?.size() > 0}"
                                                title="${(templateInstance.projects?.size() > 0 ? "Delete is not allowed when template is linked to an existing expedition." : "Delete")}"
                                                value="${message(code: 'default.button.delete.label', default: 'Delete')}"/>
                                </cl:ifSiteAdmin>
                            </div>
                        </div>
                    </g:form>

                    <div class="form-group" style="padding-top: 10px;">
                        <label class="col-md-3 control-label" style="padding-top: 5px;">
                            <g:message code="template.project.label"
                                       default="Projects that use this template:"/>
                            &nbsp;
                            <button class="btn btn-xs btn-default collapse-toggle" id="collapse-all-button"><i id="collapse-all" class="fa fa-expand" title="Expand/Collapse all"></i></button>
                        </label>

                        <div class="col-md-6">
                            %{-- Accordian display --}%
                            <div class="panel-group" id="accordion" role="tablist" aria-multiselectable="true">
                            <g:set var="instCounter" value="0"/>
                            <g:each in="${projectUsageList}" var="institution">
                                <div class="panel panel-default">
                                    <div class="panel-heading" role="tab" id="heading${instCounter}">
                                        <h4 class="panel-title" data-toggle="collapse" data-target="#collapse${instCounter}">
                                            ${(institution.key ? institution.key : "No institution")} ${(institution.value.size() > 0) ? "(${institution.value.size()})" : "" }
                                        </h4>
                                    </div>
                                    <div id="collapse${instCounter}" class="panel-collapse collapse" role="tabpanel" aria-labelledby="heading${instCounter}">
                                        <div class="panel-body">
                                            <ul>
                                                <g:each in="${institution.value}" var="project">
                                                    <li style="font-size: 0.9em;"><g:link controller="project" action="show" id="${project.id}">${project.name}</g:link></li>
                                                </g:each>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                                <%
                                    instCounter++
                                %>
                            </g:each>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<asset:javascript src="underscore" asset-defer=""/>
<asset:javascript src="qtip" asset-defer=""/>
<asset:script type="text/javascript">

    $(document).ready(function() {
        $('#collapse-all-button').on('click', function () {
            $('#accordion .panel-collapse').collapse('toggle');
            if ($('#collapse-all').hasClass('fa-expand')) {
                $('#collapse-all').removeClass('fa-expand').addClass('fa-compress');
            } else {
                $('#collapse-all').removeClass('fa-compress').addClass('fa-expand');
            }
        });

        $("#btnPreview").click(function(e) {
            e.preventDefault();
            window.open("${createLink(controller: 'template', action: 'preview', id: templateInstance.id)}", "TemplatePreview");
        });

        $("#btnEditFields").click(function(e) {
            e.preventDefault();
            window.location = "${createLink(controller: 'template', action: 'manageFields', id: templateInstance.id)}";
        });

        $('#row-view-params-form').on('change', 'input,textarea,select', function(e) {
            var formInputs = $('#row-view-params-form').find('input,textarea,select').filter(function(i,e) { return !e.name.startsWith("_");});
            var formObj = _.reduce(formInputs, function(memo, e) {
                var $e = $(e);
                var v;
                if ($e.attr('type') === 'checkbox') {
                  v = e.checked;
                } else {
                  v = $e.val();
                }
                memo[$e.prop('name')] = v;
                return memo;
            }, {});
            var $viewParamsJSON = $('#viewParamsJSON');
            var str = $viewParamsJSON.val();
            var params = jsonToParams(str);
            _.extend(params, formObj);
            var jsonString = paramsToJson(params);
            $viewParamsJSON.val(jsonString);
        });

        function addDefaults() {
            var $viewParamsJSON = $('#viewParamsJSON');
            var str = $viewParamsJSON.val();
            var params = jsonToParams(str);
            $('#row-view-params-form').find('[data-default]').each(function() {
                var $this = $(this);
                var name = $this.attr('name');
                var p = params[name];
                if (p === undefined) {
                    params[name] = $this.data('default');
                }
            });
            var jsonString = paramsToJson(params);
            $viewParamsJSON.val(jsonString);
        }

        function jsonToParams(json) {
          return JSON.parse(json, function(k,v) {
              if (k === '') { return v; }
              if (v === 'true') { return true; }
              if (v === 'false') { return false; }
              return v;
            });
        }

        function paramsToJson(params) {
            return JSON.stringify(params, function(k,v) {
              if (typeof v === 'boolean') { return v.toString(); }
              return v;
            }, 2);

        }

        function syncParamsFields() {
            var str = $('#viewParamsJSON').val();
            var params = jsonToParams(str);
            var $paramsForm = $('#row-view-params-form');
            _.each(_.keys(params), function(k) {
                $paramsForm.find('[name="'+k+'"]').each(function(i,e) {
                  var $e = $(e);
                  if ($e.attr('type') === 'checkbox') {
                    $(e).prop('checked', params[k]);
                  } else {
                    $e.val(params[k]);
                  }
                });
            });
        }

        $('#viewName').change(function(e) {
            var $this = $(this);
            var p = $.ajax('${createLink(controller: 'template', action: 'viewParamsForm', id: templateInstance.id)}?view=' + encodeURIComponent($this.val()));
            p.done(function(data, textStatus, jqXHR) {
                $('#row-view-params-form').css('display', 'initial').html(data);
                addDefaults();
                updateHelpTips();
                syncParamsFields();
            });

            p.fail(function(jqXHR, textStatus, errorThrown) {
              $('#row-view-params-form').css('display', 'none');
            });
        }).change();

        function updateHelpTips() {
            // Context sensitive help popups
            $("a.fieldHelp").each(function() {
                var self = this;
                $(self).qtip({
                    content: $(self).attr('title'),
                    position: {
                        at: "top left",
                        my: "bottom right"
                    },
                    style: {
                        classes: 'qtip-bootstrap'
                    }
                }).bind('click', function(e) { e.preventDefault(); return false; });
            });
        }

    });

</asset:script>
<asset:script type="text/javascript">
    var _result = false;
    $(function() {
        $('#deleteButton').on('click', function(e) {
            if (!_result) {
                e.preventDefault();
                bootbox.confirm("Are you sure?", function (result) {
                    _result = result;
                    if(result) {
                        $('#deleteButton').click();
                    }
                });
            } else {
                return true;
            }
        });
    });
</asset:script>
</body>
</html>
