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
    <label class="col-md-3 form-label" for="jumpNTasks"><g:message code="template.wildlifeSpotter.jump.label"
                                                             default="Number of tasks to jump on save / skip"/></label>

    <div class="col-md-6">
        <g:field type="number" name="jumpNTasks" min="1" max="10" data-default="6" class="form-control"/>
    </div>
</div>
<div class="form-group">
    <div class="col-sm-offset-3 col-sm-9">
        <g:link class="btn btn-sm btn-outline-secondary" controller="template" action="spotterTemplateConfig" id="${templateInstance.id}">Configure Audio Entries</g:link>
    </div>
</div>
