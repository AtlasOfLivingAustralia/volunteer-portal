<%@ page import="au.org.ala.volunteer.Picklist" %>
<g:set var="picklists" value="${Picklist.list()}"/>
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
    <label class="col-md-3 form-label" for="jumpNTasks"><g:message code="template.cameratrap.jump.label"
                                                             default="Number of tasks to jump on save / skip"/></label>

    <div class="col-md-6">
        <g:field type="number" name="jumpNTasks" min="1" max="10" data-default="6" class="form-control"/>
    </div>
</div>

<div class="form-group">
    <label class="col-md-3 form-label" for="animalsPicklistId"><g:message code="template.cameratrap.animals.label"
                                                                    default="All Animals Picklist"/></label>

    <div class="col-md-6">
        <g:select from="${picklists}" name="animalsPicklistId" optionKey="id" optionValue="uiLabel"
                  class="form-select"/>
    </div>
    <div class="col-md-3">
        <button type="button" class="btn btn-sm btn-outline-secondary btn-view-ct-picklist">
            Manage Wildcount Animals</button>
    </div>
</div>

<script>
    $('.btn-view-ct-picklist').click(function () {
        var url = '${g.createLink(controller: 'picklist', action: 'wildcount')}/' + $('#animalsPicklistId').val();
        window.open(url);
    });
</script>