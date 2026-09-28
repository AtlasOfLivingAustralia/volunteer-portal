<g:form action="save" method="POST" >
    <g:hiddenField name="id" value="${landingPageInstance?.id}" />

    <div class="form-group required">
       <label for="title" class="form-label col-md-3"><g:message code="landingPage.title.label"
                                                                      default="Title"/></label>
       <div class="col-md-9">
           <g:field name="title" type="text" class="form-control ${hasErrors(bean: landingPageInstance, field: 'title', 'is-invalid')}" value="${landingPageInstance.title}" required=""/>
           <cl:fieldError bean="${landingPageInstance}" field="title"/>
       </div>
    </div>

    <div class="form-group required">
        <label for="shortUrl" class="form-label col-md-3"><g:message code="landingPage.shortUrl.label"
                                                                     default="Title"/></label>
        <div class="col-md-9">
            <g:field name="shortUrl" type="text" class="form-control ${hasErrors(bean: landingPageInstance, field: 'shortUrl', 'is-invalid')}" value="${landingPageInstance.shortUrl}" required=""/>
            <cl:fieldError bean="${landingPageInstance}" field="shortUrl"/>
        </div>
    </div>

    <div class="form-group">
       <label for="enabled" class="form-label col-md-3"><g:message code="landingPage.enabled.label"
                                                                      default="Is this landing page enabled?"/></label>
        <div class="col-md-9">
            <g:checkBox name="enabled" class="${hasErrors(bean: landingPageInstance, field: 'enabled', 'is-invalid')}" checked="${landingPageInstance?.enabled}"/>
            <cl:fieldError bean="${landingPageInstance}" field="enabled"/>
        </div>
    </div>

    <div class="form-group">
        <label for="bodyCopy" class="form-label col-md-3"><g:message code="landingPage.bodyCopy.label"
                                                                                    default="Description"/></label>
        <div class="col-md-9">
            <g:textArea name="bodyCopy" rows="10" class="mce form-control ${hasErrors(bean: landingPageInstance, field: 'bodyCopy', 'is-invalid')}" placeholder="Markdown..." value="${landingPageInstance.bodyCopy}"/>
            <cl:fieldError bean="${landingPageInstance}" field="bodyCopy"/>
        </div>
    </div>

   <div class="form-group">
       <label for="imageAttribution" class="form-label col-md-3">
           <g:message code="landingPage.imageAttribution" default="Image Attribution Text" />
       </label>
       <div class="col-md-9">
           <g:field name="imageAttribution" type="text" class="form-control ${hasErrors(bean: landingPageInstance, field: 'imageAttribution', 'is-invalid')}" value="${landingPageInstance.imageAttribution}" />
           <cl:fieldError bean="${landingPageInstance}" field="imageAttribution"/>
       </div>
   </div>

    <div class="form-group">
        <label class="form-label col-md-3" for="projectType"><g:message code="landingPage.projectType.label"
                                                                           default="Description"/></label>

        <div class="col-md-9">
            <g:select name="projectType" from="${projectTypes}" value="${landingPageInstance.projectType?.id}"
                      optionValue="label" optionKey="id" class="form-select ${hasErrors(bean: landingPageInstance, field: 'projectType', 'is-invalid')}"/>
            <cl:fieldError bean="${landingPageInstance}" field="projectType"/>
        </div>
    </div>

    <div class="form-group">
        <div class="col-md-offset-3 col-md-9">
            <g:actionSubmit class="save btn btn-primary" action="save"
                            value="${message(code: 'default.button.save.label', default: 'Save')}"/>
        </div>
    </div>

</g:form>

<asset:javascript src="tinymce-simple" asset-defer=""/>
