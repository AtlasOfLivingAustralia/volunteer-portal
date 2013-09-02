<%@ page import="au.org.ala.volunteer.WebUtils; java.util.regex.Pattern" %>
<%
    def values = WebUtils.parseLatLong(value as String)
%>
<div class="row-fluid latLongWidget" targetField="${field.fieldType}">
    <div class="span3">
        <g:textField name="${field.fieldType}.degrees" placeholder="D" class="span12 degrees" value="${values.degrees}" />
    </div>
    <div class="span2">
        <g:textField name="${field.fieldType}.minutes" placeholder="M" class="span12 minutes" value="${values.minutes}" />
    </div>
    <div class="span2">
        <g:textField name="${field.fieldType}.seconds" placeholder="S" class="span12 seconds" value="${values.seconds}"/>
    </div>
    <div class="span1">
        (or)
    </div>
    <div class="span4">
        <g:textField name="${field.fieldType}.decimalDegrees" class="span12 decimalDegrees" placeholder="Decimal" value="${values.decimalDegrees}"/>
    </div>
    <g:hiddenField id="recordValues.0.${field.fieldType}" name="recordValues.0.${field.fieldType}" value="${value}" />
</div>
%{--<div class="row-fluid">--}%
    %{--<div class="span12">--}%
        %{--<small class="muted">${value}</small>--}%
    %{--</div>--}%
%{--</div>--}%