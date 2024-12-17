<div class="form-group">
    <div class="col-md-offset-3 col-md-6">
        <div class="checkbox">
            <g:checkBox name="hideDefaultButtons" data-default="true"/>
            <label for="hideDefaultButtons">
                <g:message code="template.hideDefaultButtons.label" default="Hide Default Buttons"/>
            </label>
        </div>
    </div>
</div>

<div class="form-group">
    <div class="col-md-offset-3 col-md-6">
        <div class="checkbox">
            <g:checkBox name="hideSectionNumbers" data-default="true"/>
            <label for="hideSectionNumbers">
                <g:message code="template.hideSectionNumbers.label" default="Hide Section Numbers"/>
            </label>
        </div>
    </div>
</div>

<div class="form-group">
    <div class="col-md-offset-3 col-md-6">
        <div class="checkbox">
            <g:checkBox name="exportGroupByIndex" data-default="true"/>
            <label for="exportGroupByIndex">
                <g:message code="template.exportGroupByIndex.label" default="Group fields by index in CSV export"/>
            </label>
        </div>
    </div>
</div>

<div class="form-group">
    <label class="col-md-3 control-label" for="jumpNTasks"><g:message code="template.wildlifeSpotter.jump.label"
                                                             default="Number of tasks to jump on save / skip"/></label>

    <div class="col-md-6">
        <g:field type="number" name="jumpNTasks" min="1" max="10" data-default="6" class="form-control"/>
    </div>
</div>
<div class="form-group">
    <div class="col-sm-offset-3 col-sm-9">
        <g:link class="btn btn-primary" controller="template" action="spotterTemplateConfig" id="${templateInstance.id}">Configure Audio Entries</g:link>
    </div>
</div>
