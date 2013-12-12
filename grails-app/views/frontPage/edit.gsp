<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <title><g:message code="frontPage.label" default="Front Page Configuration"/></title>
    </head>

    <body>

        <cl:headerContent title="${message(code:'default.frontpageoptions.label', default:'Front Page Options')}">
            <%
                pageScope.crumbs = [
                    [link:createLink(controller:'admin'),label:message(code:'default.admin.label', default:'Admin')]
                ]
            %>
        </cl:headerContent>

        <div class="row">
            <div class="span12">
                <g:hasErrors bean="${frontPage}">
                    <div class="errors">
                        <g:renderErrors bean="${frontPage}" as="list"/>
                    </div>
                </g:hasErrors>
                <g:form action="save">
                    <div class="dialog">
                        <table style="width:100%">
                            <tbody>
                                <tr class="prop">
                                    <td valign="top" class="name">
                                        <label for="projectOfTheDay"><g:message code="frontPage.projectOfTheDay.label" default="Project of the day"/></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: frontPage, field: 'projectOfTheDay', 'errors')}">
                                        <g:select name="projectOfTheDay" from="${au.org.ala.volunteer.Project.list()}" optionKey="id" optionValue="name" value="${frontPage.projectOfTheDay?.id}"/>
                                        <g:link class="btn btn-small btn-warning" action="edit" controller="project" id="${frontPage.projectOfTheDay?.id}">Edit&nbsp;project</g:link>
                                    </td>
                                </tr>

                                <tr class="prop">
                                    <td valign="top" class="name">
                                        <label for="featuredProject1"><g:message code="frontPage.featuredProject1.label" default="Featured Project 1"/></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: frontPage, field: 'featuredProject1', 'errors')}">
                                        <g:select name="featuredProject1" from="${au.org.ala.volunteer.Project.list()}" optionKey="id" optionValue="name" value="${frontPage.featuredProject1?.id}"/>
                                        <g:link class="btn btn-small btn-warning" action="edit" controller="project" id="${frontPage.featuredProject1?.id}">Edit&nbsp;project</g:link>
                                    </td>
                                </tr>

                                <tr class="prop">
                                    <td valign="top" class="name">
                                        <label for="featuredProject2"><g:message code="frontPage.featuredProject2.label" default="Featured Project 2"/></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: frontPage, field: 'featuredProject2', 'errors')}">
                                        <g:select name="featuredProject2" from="${au.org.ala.volunteer.Project.list()}" optionKey="id" optionValue="name" value="${frontPage.featuredProject2?.id}"/>
                                        <g:link class="btn btn-small btn-warning" action="edit" controller="project" id="${frontPage.featuredProject2?.id}">Edit&nbsp;project</g:link>
                                    </td>
                                </tr>

                                <tr class="prop">
                                    <td valign="top" class="name">
                                        <label for="featuredProject3"><g:message code="frontPage.featuredProject3.label" default="Featured Project 3"/></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: frontPage, field: 'featuredProject3', 'errors')}">
                                        <g:select name="featuredProject3" from="${au.org.ala.volunteer.Project.list()}" optionKey="id" optionValue="name" value="${frontPage.featuredProject3?.id}"/>
                                        <g:link class="btn btn-small btn-warning" action="edit" controller="project" id="${frontPage.featuredProject3?.id}">Edit&nbsp;project</g:link>
                                    </td>
                                </tr>
                                
                                <tr class="prop">
                                    <td valign="top" class="name">
                                        <label for="featuredProject4"><g:message code="frontPage.featuredProject4.label" default="Featured Project 4"/></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: frontPage, field: 'featuredProject4', 'errors')}">
                                        <g:select name="featuredProject4" from="${au.org.ala.volunteer.Project.list()}" optionKey="id" optionValue="name" value="${frontPage.featuredProject4?.id}"/>
                                        <g:link class="btn btn-small btn-warning" action="edit" controller="project" id="${frontPage.featuredProject4?.id}">Edit&nbsp;project</g:link>
                                    </td>
                                </tr>
                                <tr class="prop">
                                    <td valign="top" class="name">
                                        <label for="featuredProject5"><g:message code="frontPage.featuredProject5.label" default="Featured Project 5"/></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: frontPage, field: 'featuredProject5', 'errors')}">
                                        <g:select name="featuredProject5" from="${au.org.ala.volunteer.Project.list()}" optionKey="id" optionValue="name" value="${frontPage.featuredProject5?.id}"/>
                                        <g:link class="btn btn-small btn-warning" action="edit" controller="project" id="${frontPage.featuredProject5?.id}">Edit&nbsp;project</g:link>
                                    </td>
                                </tr>
                                <tr class="prop">
                                    <td valign="top" class="name">
                                        <label for="featuredProject6"><g:message code="frontPage.featuredProject6.label" default="Featured Project 6"/></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: frontPage, field: 'featuredProject6', 'errors')}">
                                        <g:select name="featuredProject6" from="${au.org.ala.volunteer.Project.list()}" optionKey="id" optionValue="name" value="${frontPage.featuredProject6?.id}"/>
                                        <g:link class="btn btn-small btn-warning" action="edit" controller="project" id="${frontPage.featuredProject6?.id}">Edit&nbsp;project</g:link>
                                    </td>
                                </tr>
                                

                                <tr class="prop">
                                    <td valign="top" class="name">
                                        <label for="useGlobalNewsItem"><g:message code="frontPage.useGlobalNewsItem.label" default="Use global news item"/></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: frontPage, field: 'useGlobalNewsItem', 'errors')}">
                                        <g:checkBox name="useGlobalNewsItem" value="${frontPage.useGlobalNewsItem}"/>
                                        <div style="color: #808080;">If unchecked the most recent project news item will be used instead</div>
                                    </td>
                                </tr>

                                <tr class="prop">
                                    <td valign="top" class="name">
                                        <label for="newsTitle"><g:message code="frontPage.newsTitle.label" default="News title"/></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: frontPage, field: 'newsTitle', 'errors')}">
                                        <g:textField class="input-xxlarge" name="newsTitle" value="${frontPage?.newsTitle}"/>
                                    </td>
                                </tr>

                                <tr class="prop">
                                    <td valign="top" class="name">
                                        <label for="newsBody"><g:message code="frontPage.newsBody.label" default="News text"/></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: frontPage, field: 'newsBody', 'errors')}">
                                        <g:textArea class="input-xxlarge" cols="50" rows="4" name="newsBody" value="${frontPage?.newsBody}"/>
                                    </td>
                                </tr>

                                <tr class="prop">
                                    <td valign="top" class="name">
                                        <label for="newsCreated"><g:message code="frontPage.newsCreated.label" default="News date"/></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: frontPage, field: 'newsCreated', 'errors')}">
                                        <g:datePicker name="newsCreated" precision="day" value="${frontPage?.newsCreated}"/>
                                    </td>
                                </tr>

                                <tr class="prop">
                                    <td valign="top" class="name">
                                        <label for="systemMessage"><g:message code="frontPage.systemMessage.label" default="System message"/></label>

                                        <div style="color: #808080;">(Displayed on every page)</div>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: frontPage, field: 'systemMessage', 'errors')}">
                                        <g:textArea class="input-xxlarge" cols="50" rows="4" name="systemMessage" value="${frontPage?.systemMessage}"/>
                                    </td>
                                </tr>

                                <tr class="prop">
                                    <td valign="top" class="name">
                                        <label for="showAchievements"><g:message code="frontPage.showAchievements.label" default="Show achievements on User stats page"/></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: frontPage, field: 'showAchievements', 'errors')}">
                                        <g:checkBox name="showAchievements" value="${frontPage.showAchievements}"/>
                                    </td>
                                </tr>

                                <tr class="prop">
                                    <td valign="top" class="name">
                                        <label for="enableTaskComments"><g:message code="frontPage.enableTaskComments.label" default="Enable task commenting"/></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: frontPage, field: 'enableTaskComments', 'errors')}">
                                        <g:checkBox name="enableTaskComments" value="${frontPage.enableTaskComments}"/>
                                    </td>
                                </tr>

                                <tr class="prop">
                                    <td valign="top" class="name">
                                        <label for="enableForum"><g:message code="frontPage.enableForum.label" default="Enable the BVP Forum"/></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: frontPage, field: 'enableForum', 'errors')}">
                                        <g:checkBox name="enableForum" value="${frontPage.enableForum}"/>
                                    </td>
                                </tr>

                            </tbody>
                        </table>
                    </div>

                    <div class="buttons">
                        <g:submitButton name="save" class="save btn btn-primary" value="${message(code: 'default.button.save.label', default: 'Save')}"/>
                    </div>

                </g:form>
            </div>
        </div>
    </body>
</html>
