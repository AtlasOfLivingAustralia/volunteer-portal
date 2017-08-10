<%@ page import="au.org.ala.volunteer.DateConstants" %>

<div style="overflow: auto; height: 250px">
    <div class="col-sm-12 col-md-6 col-md-push-6">
        <g:each in="${taskInstance.multimedia}" var="m">
            <g:set var="imageUrl" value="${grailsApplication.config.server.url}${m.filePath}"/>
            <img src="${imageUrl.replaceFirst(/\.([a-zA-Z]*)$/, '_small.$1')}" width="200" style="padding-right: 10px"/>
        </g:each>
        <table>
            <g:if test="${catalogNumber}">
                <tr>
                    <td><g:message code="task.taskDetailsFragment.catalog_no"/></td>
                    <td style="text-align: left"><b>${catalogNumber}</b></td>
                </tr>
            </g:if>
            <tr>
                <td><g:message code="task.taskDetailsFragment.transcribed"/></td>
                <td style="text-align: left"><b>${formatDate(date: dateTranscribed, format: DateConstants.DATE_TIME_FORMAT)}</b>
                </td>
            </tr>
        </table>
    </div>

    <div class="col-sm-12 col-md-6 col-md-pull-6">

        <g:each in="${sortedCategories}" var="category" status="i">
            <g:if test="${fieldMap[category]}">
                <div class="panel panel-success">
                    <div class="panel-heading">
                        <h3 class="panel-title">${i + 1}. ${category.displayName()}</h3></th>
                    </div>
                    <table class="table">
                        <tbody>
                            <g:each in="${fieldMap[category]?.sort { a, b -> (a.name <=> b.name) ?: (a.recordIdx <=> b.recordIdx) }}"
                                    var="field" status="index">
                                <g:if test="${field.value}">
                                    <tr>
                                        <td style="width: 120px">${fieldLabels[field.name]}</td>
                                        <td><b>${field.value}</b></td>
                                    </tr>
                                </g:if>
                            </g:each>
                        </tbody>
                    </table>
                </div>
            </g:if>
        </g:each>
    </div>
</div>