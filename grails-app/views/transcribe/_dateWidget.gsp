<%@ page import="au.org.ala.volunteer.WebUtils; au.org.ala.volunteer.DateComponents" %>
<%

    DateComponents values = WebUtils.parseDate(value)

    def dateLayout = "YMD"
    if (field.layoutClass?.contains("DMY")) {
        dateLayout = "DMY"
    } else if (field.layoutClass?.contains("MDY")) {
        dateLayout = "MDY"
    } else if (field.layoutClass?.contains("YMD")) {
        dateLayout = "YMD"
    }

%>
<div class="row-fluid dateWidget" targetField="${field.fieldType}">

    <g:set var="datePart" value="Year" />
    <g:set var="datePartValue" value="" />
    <g:set var="datePartSpan" value="span3" />

    <g:each var="letter" in="${dateLayout}">
        <g:if test="${letter == 'Y'}">
            <g:set var="datePart" value="Year" />
            <g:set var="datePartValue" value="${values.year}" />
            <g:set var="datePartSpan" value="span4" />
        </g:if>
        <g:elseif test="${letter == 'M'}">
            <g:set var="datePart" value="Month" />
            <g:set var="datePartValue" value="${values.month}" />
        </g:elseif>
        <g:elseif test="${letter == 'D'}">
            <g:set var="datePart" value="Day" />
            <g:set var="datePartValue" value="${values.day}" />
        </g:elseif>

        <div class="${datePartSpan}">
            <g:textField name="${field.fieldType}.${datePart?.toLowerCase()}" placeholder="${datePart}" class="span12 ${datePart?.toLowerCase()}" value="${datePartValue}" />
        </div>

    </g:each>

    <g:hiddenField id="recordValues.0.${field.fieldType}" name="recordValues.0.${field.fieldType}" value="${value}" />
</div>
