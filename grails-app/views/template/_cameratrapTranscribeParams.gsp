<%@ page import="au.org.ala.volunteer.Picklist" %>
<g:set var="picklists" value="${Picklist.list()}" />
<div class="control-group">
    <div class="controls">
        <label class="checkbox" for="hideDefaultButtons">
            <g:checkBox name="hideDefaultButtons" value="${true}"/>
            <g:message code="template.hideDefaultButtons.label" default="Hide Default Buttons" />
        </label>
    </div>
</div>
<div class="control-group">
    <div class="controls">
        <label class="checkbox" for="hideSectionNumbers">
            <g:checkBox name="hideSectionNumbers" value="${true}"/>
            <g:message code="template.hideSectionNumbers.label" default="Hide Section Numbers" />
        </label>
    </div>
</div>
<div class="control-group">
    <div class="controls">
        <label class="checkbox" for="exportGroupByIndex">
            <g:checkBox name="exportGroupByIndex" value="${true}"/>
            <g:message code="template.exportGroupByIndex.label" default="Group fields by index in CSV export" />
        </label>
    </div>
</div>
<div class="control-group">
    <label class="control-label" for="animalsPicklistId"><g:message code="template.cameratrap.animals.label" default="All Animals Picklist" /></label>
    <div class="controls">
        <g:select from="${picklists}" name="animalsPicklistId" optionKey="id" optionValue="uiLabel" class="input-xlarge" /> <button type="button" class="btn btn-primary btn-view-ct-picklist"><i class="fa fa-eye"></i></button>
    </div>
</div>
%{--<div class="control-group">--}%
    %{--<label class="control-label" for="smallMammalsPicklistId"><g:message code="template.cameratrap.smallmammalspicklist.label" default="Small Mammals Picklist" /></label>--}%
    %{--<div class="controls">--}%
        %{--<g:select from="${picklists}" name="smallMammalsPicklistId" optionKey="id" optionValue="uiLabel" class="input-xlarge" />--}%
    %{--</div>--}%
%{--</div>--}%
%{--<div class="control-group">--}%
    %{--<label class="control-label" for="largeMammalsPicklistId"><g:message code="template.cameratrap.largemammalspicklist.label" default="Large Mammals Picklist" /></label>--}%
    %{--<div class="controls">--}%
        %{--<g:select from="${picklists}" name="largeMammalsPicklistId" optionKey="id" optionValue="uiLabel" class="input-xlarge" />--}%
    %{--</div>--}%
%{--</div>--}%
%{--<div class="control-group">--}%
    %{--<label class="control-label" for="birdsPicklistId"><g:message code="template.cameratrap.birdspicklist.label" default="Birds Picklist" /></label>--}%
    %{--<div class="controls">--}%
        %{--<g:select from="${picklists}" name="birdsPicklistId" optionKey="id" optionValue="uiLabel" class="input-xlarge" />--}%
    %{--</div>--}%
%{--</div>--}%
%{--<div class="control-group">--}%
    %{--<label class="control-label" for="reptilesPicklistId"><g:message code="template.cameratrap.reptilespicklist.label" default="Reptiles Picklist" /></label>--}%
    %{--<div class="controls">--}%
        %{--<g:select from="${picklists}" name="reptilesPicklistId" optionKey="id" optionValue="uiLabel" class="input-xlarge" />--}%
    %{--</div>--}%
%{--</div>--}%
%{--<div class="control-group">--}%
    %{--<label class="control-label" for="othersPicklistId"><g:message code="template.cameratrap.otherspicklist.label" default="Others Picklist" /></label>--}%
    %{--<div class="controls">--}%
        %{--<g:select from="${picklists}" name="othersPicklistId" optionKey="id" optionValue="uiLabel" class="input-xlarge" />--}%
    %{--</div>--}%
%{--</div>--}%
%{--<div class="control-group">--}%
    %{--<label class="control-label" for="unlistedPicklistId"><g:message code="template.cameratrap.otherspicklist.label" default="Others Picklist" /></label>--}%
    %{--<div class="controls">--}%
        %{--<g:select from="${picklists}" name="unlistedPicklistId" optionKey="id" optionValue="uiLabel" class="input-xlarge" />--}%
    %{--</div>--}%
%{--</div>--}%

<script>
    $('.btn-view-ct-picklist').click(function() {
        var url = '${g.createLink(controller: 'picklist', action: 'wildcount')}/' + $('#animalsPicklistId').val();
        window.open(url);
    });
</script>