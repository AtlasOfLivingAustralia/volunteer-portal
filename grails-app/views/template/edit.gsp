<%@ page import="au.org.ala.volunteer.Template" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'template.label', default: 'Template')}" />
        <title><g:message code="default.edit.label" args="[entityName]" /></title>

        <r:require module="underscore" />
        <r:script>

            $(document).ready(function() {

                $("#btnPreview").click(function(e) {
                    e.preventDefault();
                    window.open("${createLink(controller:'template', action:'preview', id:templateInstance.id)}", "TemplatePreview");
                });

                $("#btnEditFields").click(function(e) {
                    e.preventDefault();
                    window.location = "${createLink(controller: 'template',action:'manageFields', id:templateInstance.id)}";
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
                    var params = JSON.parse(str);
                    _.extend(params, formObj);
                    var jsonString = JSON.stringify(params);
                    $viewParamsJSON.val(jsonString);
                });

                function syncParamsFields() {
                    var str = $('#viewParamsJSON').val();
                    var params = JSON.parse(str);
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
                    var p = $.ajax('${createLink(controller: 'template', action:'viewParamsForm')}?view=' + encodeURIComponent($this.val()));
                    p.done(function(data, textStatus, jqXHR) {
                        $('#row-view-params-form').css('display', 'initial').html(data);
                        syncParamsFields();
                    });

                    p.fail(function(jqXHR, textStatus, errorThrown) {
                      $('#row-view-params-form').css('display', 'none');
                    });
                }).change();

            });


        </r:script>

    </head>
    <body>

        <cl:headerContent title="${message(code: 'default.edit.label', args: [entityName])} - ${templateInstance.name}">
           <%
               pageScope.crumbs = [
                   [link: createLink(controller: 'admin', action: 'index'), label: 'Administration'],
                   [link: createLink(controller: 'template', action: 'list'), label: message(code: 'default.list.label', args: [entityName])]
               ]
           %>
            <div>
                <a href="${createLink(action:'create')}" class="btn">Create new template</a>
            </div>
       </cl:headerContent>

        <div class="row">
            <div class="span12">
                <g:hasErrors bean="${templateInstance}">
                <div class="errors">
                    <g:renderErrors bean="${templateInstance}" as="list" />
                </div>
                </g:hasErrors>
                <g:form method="post" class="form-horizontal">
                    <g:hiddenField name="id" value="${templateInstance?.id}" />
                    <g:hiddenField name="version" value="${templateInstance?.version}" />

                    <div class="control-group ${hasErrors(bean: templateInstance, field: 'name', 'error')}">
                        <label class="control-label" for="name"><g:message code="template.name.label" default="Name" /></label>
                        <div class="controls">
                            <g:textField name="name" maxlength="200" value="${templateInstance?.name}" />
                        </div>
                    </div>

                    <div class="control-group ${hasErrors(bean: templateInstance, field: 'viewName', 'error')}">
                        <label class="control-label" for="viewName"><g:message code="template.viewName.label" default="View Name" /></label>
                        <div class="controls">
                            <g:if test="${availableViews}">
                                <g:select from="${availableViews}" name="viewName" value="${templateInstance?.viewName}" />
                            </g:if>
                            <g:else>
                                <g:textField name="viewName" value="${templateInstance?.viewName}" />
                            </g:else>
                        </div>
                    </div>

                    <div id="row-view-params-form" style="display: none;">

                    </div>

                    <div id="row-view-params-json" class="control-group ${hasErrors(bean: templateInstance, field: 'viewParams', 'error')}">
                        <label class="control-label" for="viewParamsJSON"><g:message code="template.viewparams.label" default="Template View Parameters:" /></label>
                        <div class="controls">
                            <g:textArea name="viewParamsJSON" rows="4" cols="40" value="${templateInstance.viewParams as grails.converters.JSON}"></g:textArea>
                        </div>
                    </div>

                    <div id="row-view-params-json" class="control-group">
                        <label class="control-label" for="project"><g:message code="template.project.label" default="Projects that use this template:" /></label>
                        <div class="controls">
                            <g:each in="${templateInstance?.project?}" var="p">
                                <li><g:link controller="project" action="show" id="${p.id}">${p?.encodeAsHTML()}</g:link></li>
                            </g:each>
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label"></label>
                        <div class="controls">
                            <button class="btn" id="btnEditFields">Edit Fields</button>
                            <button class="btn" id="btnPreview">Preview Template</button>
                        </div>
                    </div>

                    <div class="buttons">
                        <g:actionSubmit class="btn save" action="update" value="${message(code: 'default.button.update.label', default: 'Update')}" />
                        <g:actionSubmit class="btn btn-danger delete" action="delete" value="${message(code: 'default.button.delete.label', default: 'Delete')}" onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');" />
                    </div>
                </g:form>
            </div>
        </div>
    </body>
</html>
