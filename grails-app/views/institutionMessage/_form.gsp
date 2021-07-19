<%@ page import="au.org.ala.volunteer.InstitutionMessage" %>
<style type="text/css">
.loader {
    border: 4px solid #e0e0e0; /* Light grey */
    border-top: 4px solid #000000;
    border-radius: 50%;
    width: 2.475rem;
    height: 2.475rem;
    animation: spin 1s linear infinite;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

.float-right {
    position: absolute;
    z-index: 2;
    display: block;
    /*line-height: 2.375rem;*/
    text-align: center;
    pointer-events: none;
    color: #aaa;
    right:40px;
    top: 4px;
}
</style>

<div class="form-group">
    <label class="control-label col-md-3" for="institution">
        <g:message code="institution.label" default="Institution"/>
    </label>
    <div class="col-md-6">
        <g:select class="form-control institution" name="institution" from="${institutionList}"
                  optionKey="id" optionValue="name"
                  disabled="${(disableEdit || institutionMessageInstance?.institution?.id)}"
                  value="${institutionMessageInstance?.institution?.id}" />
    <g:if test="${(disableEdit || institutionMessageInstance?.institution?.id)}">
        <input type="hidden" name="institution" value="${institutionMessageInstance?.institution?.id}"/>
    </g:if>
    </div>
</div>
<div class="form-group">
    <label class="control-label col-md-3" for="recipientType">
        <g:message code="institutionMessage.recipientType.label" default="Recipient Type"/>
    </label>
    <div class="col-md-6">
        <g:select class="form-control recipient-type" optionKey="key" optionValue="value"
                  disabled="${(disableEdit)}"
                  name="recipientType" from="${recipientTypeList}" value="${recipientType}" />
    </div>
</div>
<div class="form-group">
    <label class="control-label col-md-3" for="recipient">
        <g:message code="institutionMessage.recipient.label" default="Recipient"/>
    </label>
    <div class="col-md-6">
        <div class="clearfix loading-recipient hidden">
            <div class="loader float-right" role="status">
                <span class="sr-only">Loading...</span>
            </div>
        </div>
        <select name="recipient"
                class="form-control selectpicker"
                data-live-search="true"
                id="recipient"><option value="">- Select a recipient -</option></select>
    </div>
</div>
<div class="form-group">
    <label class="control-label col-md-3" for="subject">
        <g:message code="institutionMessage.subject.label" default="Subject"/>
    </label>
    <div class="col-md-6">
        <g:textField class="form-control"
                     name="subject"
                     disabled="${(disableEdit)}"
                     required=""
                     value="${institutionMessageInstance?.subject}"/>
    </div>
</div>
<div class="form-group">
    <label for="includeContact" class="control-label col-md-3">
        <g:message code="institutionMessage.includeContact.label" default="Include Institution Contact" /><br />
        <small id="includeContactHelp" class="form-text text-muted"><g:message code="institutionMessage.includeContact.help" default="Include Contact Details in Message" /></small>
    </label>
    <div class="col-md-6">
        <g:checkBox name="includeContact"
                    class="form-control"
                    id="includeContact"
                    style="margin-top: 9px;"
                    disabled="${(disableEdit)}"
                    value="${institutionMessageInstance?.includeContact}" />
    </div>
</div>
<div class="form-group">
    <label class="control-label col-md-3" for="body">
        <g:message code="institutionMessage.body.label" default="Message Body"/>
    </label>
    <div class="col-md-9">
        <g:if test="${disableEdit}">
            <div style="margin-top: 0.5em; margin-bottom: 2em;">
                <%=institutionMessageInstance?.body%>
            </div>
        </g:if>
        <g:else>
            <g:textArea name="body" rows="10" class="mce form-control" value="${institutionMessageInstance?.body}" />
        </g:else>
    </div>
</div>


<asset:javascript src="tinymce-simple" asset-defer=""/>