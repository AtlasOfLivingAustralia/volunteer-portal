<head>
    <asset:stylesheet src="bootstrap-switch"/>
    <asset:stylesheet src="bootstrap-select.css" />
    <asset:javascript src="bootstrap-switch" asset-defer=""/>
    <asset:javascript src="bootstrap-select.js" asset-defer="" />
</head>

<g:form action="save" class="form-horizontal" method="POST" >
    <g:hiddenField name="id" value="${landingPageInstance?.id}" />

    <div class="form-group ${hasErrors(bean: landingPageInstance, field: 'title', 'has-error')} required">
       <label for="title" class="control-label col-md-3"><g:message code="landingPage.title.label"
                                                                      default="Title"/></label>
       <div class="col-md-9">
           <g:field name="title" type="text" class="form-control" value="${landingPageInstance.title}"/>
       </div>
    </div>

    <div class="form-group ${hasErrors(bean: landingPageInstance, field: 'enabled', 'has-error')} required">
       <label for="enabled" class="control-label col-md-3"><g:message code="landingPage.enabled.label"
                                                                      default="Is this landing page enabled?"/></label>
        <div class="col-md-9">
            <g:checkBox name="enabled" checked="${landingPageInstance?.enabled}"/>
        </div>
    </div>

    <div class="form-group ${hasErrors(bean: landingPageInstance, field: 'bodyCopy', 'has-error')}">
        <label for="bodyCopy" class="control-label col-md-3"><g:message code="landingPage.bodyCopy.label"
                                                                                    default="Description"/></label>
        <div class="col-md-9">
            <g:textArea name="bodyCopy" rows="10" class="mce form-control" placeholder="Markdown..." value="${landingPageInstance.bodyCopy}"/>
        </div>
    </div>

    %{--<div class="form-group" ${hasErrors(bean: landingPage, field: 'numberOfContributors', 'has-error')}>
        <label for="numberOfContributors" class="control-label col-md-3"><g:message code="landingPage.numberOfContributors.label"
                                                                           default="The number of contributors to show on the landing page"/></label>
        <div class="col-md-6">
            <g:field name="numberOfContributors" type="number" min="0" max="20" class="form-control" value="${landingPage.numberOfContributors}"/>
        </div>
    </div>--}%

   <div class="form-group ${hasErrors(bean: landingPageInstance, field: 'imageAttribution', 'has-error')}">
       <label for="imageAttribution" class="control-label col-md-3">
           <g:message code="landingPage.imageAttribution" default="Image Attribution Text" />
       </label>
       <div class="col-md-9">
           <g:field name="imageAttribution" type="text" class="form-control" value="${landingPageInstance.imageAttribution}" />
       </div>
   </div>

    <div class="form-group"  ${hasErrors(bean: landingPageInstance, field: 'projectType', 'has-error')}>
        <label class="control-label col-md-3" for="projectType"><g:message code="landingPage.projectType.label"
                                                                           default="Description"/></label>

        <div class="col-md-9">
            <g:select name="projectType" from="${projectTypes}" value="${landingPageInstance.projectType?.id}"
                      optionValue="label" optionKey="id" class="selectpicker form-control"/>
        </div>
    </div>

    <div class="form-group">
        <div class="col-md-offset-3 col-md-9">
            <g:actionSubmit class="save btn btn-primary" action="save"
                            value="${message(code: 'default.button.save.label', default: 'Save')}"/>
           %{-- <g:submitButton name="save" class="save btn btn-primary"
                        value="${message(code: 'default.button.save.label', default: 'Save')}"/>--}%
        </div>
    </div>

</g:form>

<asset:javascript src="tinymce-simple" asset-defer=""/>

<asset:script type="text/javascript" asset-defer="">
    $(function() {

        $("[name='enabled']").bootstrapSwitch({
            size: "small",
            onText: "Enabled",
            offText: "Disabled"
        });
    });

</asset:script>

</body>
</html>
