<%@ page import="au.org.ala.volunteer.Task; au.org.ala.volunteer.Field; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.Project; au.org.ala.volunteer.Template; au.org.ala.volunteer.DarwinCoreField;" %>

<p><i>Last Modified By: ${recordValues?.entrySet()[0]?.getValue().lastModifiedBy}</i> </p>

<div class="table-responsive">
    <table class="table table-striped table-hover">
        <thead>
            <tr>
                <td style="color:#307991"><g:message code='What has changed?' /></td>
                <td style="color:#307991"><g:message code="Previous Values"/></td>
                <td style="color:#307991"><g:message code="Recent changes"/></td>
            </tr>
            </thead>
        <tbody>
            <g:each in="${recordValues.entrySet()}" status="i" var="recordValue">
               <g:if test="${(recordValue.getValue()?.oldValue != '') || (recordValue.getValue()?.newValue != '')}">
                    <tr>
                        <td>${TemplateField.findAllByTemplateAndFieldType(Project.findAllById(task.projectId).template, recordValue.getKey())?.uiLabel?.toString().replace('[','').replace(']', '')?:(DarwinCoreField.(recordValue.getKey())).label}</td>

                        <td><g:message code="${recordValue.getValue()?.oldValue.toString().replaceAll('\n','<br/>\n')}" encodeAs="raw"></g:message></td>

                        <td><g:message code="${recordValue.getValue()?.newValue.toString().replaceAll('\n','<br/>\n')}" encodeAs="raw"></g:message></td>
                    </tr>
                </g:if>
            </g:each>
        </tbody>
    </table>
</div>

