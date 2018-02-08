<%@ page contentType="text/html; charset=UTF-8" %>
<div class="form-group">
    <div class="col-md-offset-3 col-md-6">
        <div class="checkbox">
            <label>
                <g:checkBox name="exportGroupByIndex" data-default="true"/>
                <g:message code="template.exportGroupByIndex.label" default="Group fields by index in CSV export"/>
            </label>
        </div>
    </div>
</div>

<div class="form-group">
    <div class="col-md-offset-3 col-md-6">
        <div class="checkbox">
            <label>
                <g:checkBox name="hideNames" data-default="false"/>
                <g:message code="template.hideNames.label" default="Hide Individual Fields Section"/>
            </label>
        </div>
    </div>
</div>

<div class="form-group">
    <div class="col-md-offset-3 col-md-6">
        <div class="checkbox">
            <label>
                <g:checkBox name="doublePage" data-default="false"/>
                <g:message code="template.doublePage.label" default="Double page"/>
            </label>
        </div>
    </div>
</div>

<div class="form-group">
    <div class="control-label col-md-3">
        <label for="transcribeSectionHeader"><g:message code="template.transcribeSectionHeader.label" default="Transcribe Section Header Label" /></label>
    </div>
    <div class="col-md-6">
        <g:textArea name="transcribeSectionHeader" class="form-control" data-default="${message(code:'template.fieldNoteBookTranscribe.default_description')}" />
    </div>
</div>