<%@ page import="au.org.ala.volunteer.Picklist" %>
<g:set var="picklists" value="${Picklist.list()}"/>
<div class="form-group">
    <div class="col-md-offset-3 col-md-6">
        <div class="checkbox">
            <label>
                <g:checkBox name="hideDefaultButtons" data-default="true"/>
                <g:message code="template.hideDefaultButtons.label" default="Hide Default Buttons"/>
            </label>
        </div>
    </div>
</div>

<div class="form-group">
    <div class="col-md-offset-3 col-md-6">
        <div class="checkbox">
            <label>
                <g:checkBox name="hideSectionNumbers" data-default="true"/>
                <g:message code="template.hideSectionNumbers.label" default="Hide Section Numbers"/>
            </label>
        </div>
    </div>
</div>

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
    <label class="col-md-3 control-label" for="jumpNTasks"><g:message code="template.cameratrap.jump.label"
                                                             default="Number of tasks to jump on save / skip"/></label>

    <div class="col-md-6">
        <g:field type="number" name="jumpNTasks" min="1" max="10" data-default="6" class="form-control"/>
    </div>
</div>

<div class="form-group">
    <label class="col-md-3 control-label" for="animalsPicklistId"><g:message code="template.cameratrap.animals.label"
                                                                    default="All Animals Picklist"/></label>

    <div class="col-md-6">
        <g:select from="${picklists}" name="animalsPicklistId" optionKey="id" optionValue="uiLabel"
                  class="form-control"/>
    </div>
    <div class="col-md-3">
        <button type="button" class="btn btn-primary btn-view-ct-picklist"><i
                class="fa fa-eye"></i></button>
    </div>
</div>

<script>
    $('.btn-view-ct-picklist').click(function () {
        var url = '${g.createLink(controller: 'picklist', action: 'wildcount')}/' + $('#animalsPicklistId').val();
        window.open(url);
    });
</script>