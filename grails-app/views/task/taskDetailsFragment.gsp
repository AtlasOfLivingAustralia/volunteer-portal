<%@ page import="au.org.ala.volunteer.DateConstants" %>


<style type="text/css">
.task_summary {
    text-align: left;
}

.task_summary h3 {
    font-size: 1.1em;
    font-weight: bold;
    color: #718804;
}

.task_summary table {
    margin-bottom: 10px;
    background-color: #F0F0E8;
    -moz-border-radius: 8px;
    -webkit-border-radius: 8px;
    -o-border-radius: 8px;
    -icab-border-radius: 8px;
    -khtml-border-radius: 8px;
    border-radius: 8px;
}
</style>

<div style="overflow: auto; height: 250px">
    <div style="float:right;">
        <g:each in="${taskInstance.multimedia}" var="m">
            <g:set var="imageUrl" value="${grailsApplication.config.server.url}${m.filePath}"/>
            <img src="${imageUrl.replaceFirst(/\.([a-zA-Z]*)$/, '_small.$1')}" width="200" style="padding-right: 10px"/>
        </g:each>
        <table>
            <g:if test="${catalogNumber}">
                <tr>
                    <td>Catalog No.</td>
                    <td style="text-align: left"><b>${catalogNumber}</b></td>
                </tr>
            </g:if>
            <tr>
                <td>Transcribed</td>
                <td style="text-align: left"><b>${formatDate(date: dateTranscribed, format: DateConstants.DATE_TIME_FORMAT)}</b>
                </td>
            </tr>
        </table>
    </div>

    <div class="task_summary">

        <g:each in="${sortedCategories}" var="category" status="i">
            <g:if test="${fieldMap[category]}">
                <table style="width: 400px">
                    <thead>
                    <tr>
                        <th colspan="2"><h3>${i + 1}. ${category.displayName()}</h3></th>
                    </tr>
                    </thead>
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
            </g:if>
        </g:each>
    </table>
    </div>
</div>