<%@ page import="au.org.ala.volunteer.DarwinCoreField" %>
<div class="collectorColumnWidget control-group ${cssClass}">

    <div class="row-fluid" style="vertical-align: bottom">
        <div class="span2">
            (from)
        </div>
        <div class="span3">
            <g:textField name="recordValues.0.${minFieldType.toString()}" class="span12 ${minFieldType.toString()}" value="${recordValues.get(0)?.get(minFieldType.toString())}" />
        </div>
        <div class="span2">
            (to)
        </div>
        <div class="span3">
            <g:textField name="recordValues.0.${maxFieldType.toString()}" class="span12 ${maxFieldType.toString()}" value="${recordValues.get(0)?.get(maxFieldType.toString())}" />
        </div>
    </div>

</div>