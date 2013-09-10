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
<div class="row-fluid dateWidget control-group" targetField="${field.fieldType}">
    <g:each var="letter" in="${dateLayout}">
        <g:if test="${letter == 'Y'}">
            <div class="span3">
                <g:textField name="${field.fieldType}.Year" placeholder="Year" class="span12 year" value="${values.year}" validationRule="${field.validationRule}" />
            </div>
        </g:if>
        <g:elseif test="${letter == 'M'}">
            <div class="span2">
                <g:textField name="${field.fieldType}.Month" placeholder="M" class="span12 month" value="${values.month}" validationRule="${field.validationRule}" />
            </div>
        </g:elseif>
        <g:elseif test="${letter == 'D'}">
            <div class="span2">
                <g:textField name="${field.fieldType}.Day" placeholder="D" class="span12 day" value="${values.day}" validationRule="${field.validationRule}" />
            </div>
        </g:elseif>
    </g:each>

    <g:hiddenField id="recordValues.0.${field.fieldType}" name="recordValues.0.${field.fieldType}" value="${value}" />
</div>
