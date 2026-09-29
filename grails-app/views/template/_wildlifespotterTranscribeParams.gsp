<%@ page import="au.org.ala.volunteer.AutoValidationType" %>
<div class="form-check">
        <div class="checkbox">
            <g:checkBox class="form-check-input" name="hideDefaultButtons" data-default="true"/>
            <label class="form-label" for="hideDefaultButtons">
                <g:message code="template.hideDefaultButtons.label" default="Hide Default Buttons"/>
            </label>
        </div>
</div>

<div class="form-check">
    <div class="checkbox">
        <g:checkBox class="form-check-input" name="hideSectionNumbers" data-default="true"/>
        <label class="form-label" for="hideSectionNumbers">
            <g:message code="template.hideSectionNumbers.label" default="Hide Section Numbers"/>
        </label>
    </div>
</div>

<div class="form-check">
    <div class="checkbox">
        <g:checkBox class="form-check-input" name="exportGroupByIndex" data-default="true"/>
        <label class="form-label" for="exportGroupByIndex">
            <g:message code="template.exportGroupByIndex.label" default="Group fields by index in CSV export"/>
        </label>
    </div>
</div>

<div class="form-group">
    <label class="col-md-3 form-label" for="autoValidationType">
        <g:message code="template.autoValidationType.label" default="System Validation Type"/>&nbsp;&nbsp;
        <cl:helpText>
            <g:message code="template.autoValidationType.helptext"
                       default="Select the field combination that the System will use for comparison when auto-validating."/>
        </cl:helpText>
    </label>
    <div class="col-md-6">
        <g:select class="form-select"
                  name="autoValidationType"
                  from="${AutoValidationType.values()}"
                  optionValue="label"
                  value="${AutoValidationType.getDefault()}" />
    </div>
</div>

<div class="form-group">
    <label class="col-md-3 form-label" for="jumpNTasks">
        <g:message code="template.wildlifeSpotter.jump.label" default="Number of tasks to jump on save / skip"/>
    </label>
    <div class="col-md-6">
        <g:field type="number" name="jumpNTasks" min="1" max="10" data-default="6" class="form-control"/>
    </div>
</div>

<div class="form-group">
    <div class="col-md-offset-3 col-md-9" style="padding-bottom: 5px;">
        <g:link class="btn btn-sm btn-outline-secondary" controller="template" action="wildlifeTemplateConfig" id="${templateInstance.id}">Configure Wildlife Spotter Entries</g:link>
    </div>
</div>
