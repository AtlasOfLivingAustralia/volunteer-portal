<%
    def dateLayout = "YMD"
    if (field.layoutClass?.contains("DMY")) {
        dateLayout = "DMY"
    } else if (field.layoutClass?.contains("MDY")) {
        dateLayout = "MDY"
    } else if (field.layoutClass?.contains("YMD")) {
        dateLayout = "YMD"
    }

%>
<div class="dateWidget" targetField="${field.fieldType}">

    <div class="row form-group">
        <div class="col-md-3">
            (from)
        </div>
        <g:set var="count" value="${0}"/>

        <g:each var="letter" in="${dateLayout}">

            <g:set var="ti" value="${tabindex ? tabindex + count : null}"/>

            <g:if test="${letter == 'Y'}">
                <div class="col-md-3">
                    <g:textField tabindex="${ti}" name="${field.fieldType}.startYear" placeholder="Year"
                                 class="form-control startYear year" value=""/>
                </div>
            </g:if>
            <g:elseif test="${letter == 'M'}">
                <div class="col-md-3">
                    <g:textField tabindex="${ti}" name="${field.fieldType}.startMonth" placeholder="MM"
                                 class="form-control startMonth month" value=""/>
                </div>
            </g:elseif>
            <g:elseif test="${letter == 'D'}">
                <div class="col-md-3">
                    <g:textField tabindex="${ti}" name="${field.fieldType}.startDay" placeholder="DD"
                                 class="form-control startDay day" value=""/>
                </div>
            </g:elseif>
            <g:set var="count" value="${count + 1}"/>
        </g:each>
    </div>

    <div class="row form-group">
        <div class="col-md-3">
            (to)
        </div>

        <g:each var="letter" in="${dateLayout}">
            <g:set var="ti" value="${tabindex ? tabindex + count : null}"/>

            <g:if test="${letter == 'Y'}">
                <div class="col-md-3">
                    <g:textField tabindex="${ti}" name="${field.fieldType}.endYear" placeholder="Year"
                                 class="form-control endYear year" value=""/>
                </div>
            </g:if>
            <g:elseif test="${letter == 'M'}">
                <div class="col-md-3">
                    <g:textField tabindex="${ti}" name="${field.fieldType}.endMonth" placeholder="MM"
                                 class="form-control endMonth month" value=""/>
                </div>
            </g:elseif>
            <g:elseif test="${letter == 'D'}">
                <div class="col-md-3">
                    <g:textField tabindex="${ti}" name="${field.fieldType}.endDay" placeholder="DD"
                                 class="form-control endDay day" value=""/>
                </div>
            </g:elseif>
            <g:set var="count" value="${count + 1}"/>
        </g:each>
    </div>
    <g:hiddenField id="recordValues.0.${field.fieldType}" name="recordValues.0.${field.fieldType}" value="${value}"
                   validationRule="${field.validationRule}"/>
</div>
