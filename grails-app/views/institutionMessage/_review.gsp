<%@ page import="au.org.ala.volunteer.InstitutionMessage" %>

<style type="text/css">
    .message a {
        text-decoration: underline;
    }
</style>

<div class="form-group">
    <label class="control-label col-md-3" for="institution">
        <g:message code="institution.label" default="Institution"/>
    </label>
    <div class="col-md-6" style="padding-top: 0.5em;">
        ${institutionMessageInstance?.institution?.name}
    </div>
</div>
<div class="form-group">
    <label class="control-label col-md-3" for="createdBy">
        <g:message code="institutionMessage.createdBy.label" default="Created By"/>
    </label>
    <div class="col-md-6" style="padding-top: 0.5em;">
        ${institutionMessageInstance?.createdBy?.displayName}
    </div>
</div>
<div class="form-group">
    <label class="control-label col-md-3" for="recipient">
        <g:message code="institutionMessage.recipient.label" default="Recipient"/>
    </label>
    <div class="col-md-6" style="padding-top: 0.5em;">
        <g:if test="${institutionMessageInstance.getRecipientType() == InstitutionMessage.RECIPIENT_TYPE_USER}">
            <i class="fa fa-user"  title="Recipient Type: User"></i> <span class="message-recipient">${institutionMessageInstance.getRecipientUser()?.displayName}</span>
        </g:if>
        <g:elseif test="${institutionMessageInstance.getRecipientType() == InstitutionMessage.RECIPIENT_TYPE_PROJECT}">
            <i class="fa fa-folder" title="Recipient Type: Expedition"></i>
            <g:if test="${institutionMessageInstance.getRecipientProjectList().size() > 1}">
                <g:set var="projectListOut" value="${institutionMessageInstance.getRecipientProjectList()*.name.join(',\n')}" />
                <span class="message-recipient" title="${projectListOut}">
                    ${institutionMessageInstance.getRecipientProjectList().size()} Expeditions
                </span>
            </g:if>
            <g:else>
                <g:set var="project" value="${institutionMessageInstance.getRecipientProjectList()?.first()}"/>
                <span class="message-recipient">${project?.name}</span>
            </g:else>
        </g:elseif>
        <g:else>
            <i class="fa fa-building" title="Recipient Type: Institution"></i> Institution
        </g:else>
    </div>
</div>
<div class="form-group">
    <label class="control-label col-md-3" for="dateCreated">
        <g:message code="institutionMessage.dateCreated.label" default="Created By"/>
    </label>
    <div class="col-md-6" style="padding-top: 0.5em;">
        <g:formatDate format="yyyy-MM-dd HH:mm"
                      date="${institutionMessageInstance.dateCreated}"/>
    </div>
</div>
<div class="form-group">
    <label for="includeContact" class="control-label col-md-3">
        <g:message code="institutionMessage.includeContact.label" default="Include Institution Contact" /><br />
        <small id="includeContactHelp" class="form-text text-muted"><g:message code="institutionMessage.includeContact.help" default="Include Contact Details in Message" /></small>
    </label>
    <div class="col-md-6" style="padding-top: 0.5em;">
        ${(institutionMessageInstance?.includeContact) ? "Yes" : "No"}
        <g:if test="${institutionMessageInstance?.includeContact}">
            - ${institutionMessageInstance.institution.contactName} (${institutionMessageInstance.institution.contactEmail})
        </g:if>
    </div>
</div>
<div class="form-group">
    <label class="control-label col-md-3" for="subject">
        <g:message code="institutionMessage.subject.label" default="Subject"/>
    </label>
    <div class="col-md-6" style="padding-top: 0.5em;">
        <strong>${institutionMessageInstance?.subject}</strong>
    </div>
</div>
<div class="form-group">
    <label class="control-label col-md-3" for="body">
        <g:message code="institutionMessage.body.label" default="Message Body"/>
    </label>
    <div class="col-md-9" style="margin-top: 0.5em; margin-bottom: 2em;">
            <div class="message">
                <%=institutionMessageInstance?.body%>
            </div>
    </div>
</div>

<asset:javascript src="tinymce-simple" asset-defer=""/>