<div class="form-check">
        <div class="checkbox">
            <g:checkBox class="form-check-input" name="exportGroupByIndex" data-default="true"/>
            <label class="form-label" for="exportGroupByIndex">
                <g:message code="template.exportGroupByIndex.label" default="Group fields by index in CSV export"/>
            </label>
        </div>
</div>

<div class="form-check">
    <div class="checkbox">
        <g:checkBox class="form-check-input" name="hideNames" data-default="false"/>
        <label class="form-label" for="hideNames">
                <g:message code="template.hideNames.label" default="Hide Individual Fields Section"/>
            </label>
        </div>
    </div>
</div>

<div class="form-check">
    <div class="checkbox">
        <g:checkBox class="form-check-input" name="doublePage" data-default="false"/>
            <label for="doublePage">
                <g:message code="template.doublePage.label" default="Double page"/>
            </label>
        </div>
    </div>
</div>

<div class="form-group">
    <div class="form-label col-md-3">
        <label for="transcribeSectionHeader"><g:message code="template.transcribeSectionHeader.label" default="Transcribe Section Header Label" /></label>
    </div>
    <div class="col-md-6">
        <g:textArea name="transcribeSectionHeader" class="form-control" data-default="Where a species or common name appears in the text please enter any relevant information into the fields below" />
    </div>
</div>