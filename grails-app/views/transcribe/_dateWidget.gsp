<%@ page import="au.org.ala.volunteer.DateRange; au.org.ala.volunteer.WebUtils; au.org.ala.volunteer.DateComponents" %>
<%

    DateRange dateRange = WebUtils.parseDateRange(value as String)

    def dateLayout = "YMD"
    if (field.layoutClass?.contains("DMY")) {
        dateLayout = "DMY"
    } else if (field.layoutClass?.contains("MDY")) {
        dateLayout = "MDY"
    } else if (field.layoutClass?.contains("YMD")) {
        dateLayout = "YMD"
    }

%>
<div class="dateWidget" targetField="${field.fieldType}" >

    <div class="row-fluid control-group" >
        <div class="span2">
            (from)
        </div>
        <g:each var="letter" in="${dateLayout}">
            <g:if test="${letter == 'Y'}">
                <div class="span3">
                    <g:textField name="${field.fieldType}.startYear" placeholder="Year" class="span12 startYear year" value="${dateRange.startDate?.year}" />
                </div>
            </g:if>
            <g:elseif test="${letter == 'M'}">
                <div class="span2">
                    <g:textField name="${field.fieldType}.startMonth" placeholder="M" class="span12 startMonth month" value="${dateRange.startDate?.month}" />
                </div>
            </g:elseif>
            <g:elseif test="${letter == 'D'}">
                <div class="span2">
                    <g:textField name="${field.fieldType}.startDay" placeholder="D" class="span12 startDay day" value="${dateRange.startDate?.day}" />
                </div>
            </g:elseif>
        </g:each>
    </div>
    <div class="row-fluid control-group">
        <div class="span2">
            (to)
        </div>

        <g:each var="letter" in="${dateLayout}">
            <g:if test="${letter == 'Y'}">
                <div class="span3">
                    <g:textField name="${field.fieldType}.endYear" placeholder="Year" class="span12 endYear year" value="${dateRange.endDate?.year}" />
                </div>
            </g:if>
            <g:elseif test="${letter == 'M'}">
                <div class="span2">
                    <g:textField name="${field.fieldType}.endMonth" placeholder="M" class="span12 endMonth month" value="${dateRange.endDate?.month}" />
                </div>
            </g:elseif>
            <g:elseif test="${letter == 'D'}">
                <div class="span2">
                    <g:textField name="${field.fieldType}.endDay" placeholder="D" class="span12 endDay day" value="${dateRange.endDate?.day}" />
                </div>
            </g:elseif>
        </g:each>
    </div>
    <g:hiddenField id="recordValues.0.${field.fieldType}" name="recordValues.0.${field.fieldType}" value="${value}" validationRule="${field.validationRule}" />
</div>
