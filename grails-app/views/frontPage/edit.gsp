<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="frontPage.label" default="Front Page Configuration"/></title>
    <r:require module="bvp-js"/>
</head>

<body class="admin">
<div class="container">
    <cl:headerContent title="${message(code: 'default.frontpageoptions.label', default: 'Front Page Options')}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')]
            ]
        %>
    </cl:headerContent>
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <g:hasErrors bean="${frontPage}">
                        <div class="errors">
                            <g:renderErrors bean="${frontPage}" as="list"/>
                        </div>
                    </g:hasErrors>
                    <g:form action="save" class="form-horizontal">
                        <div class="form-group">
                            <label for="projectOfTheDay" class="control-label col-md-3"><g:message code="frontPage.projectOfTheDay.label"
                                                                    default="Project of the day"/></label>
                            <div class="col-md-6">
                                <g:select name="projectOfTheDay" class="form-control" from="${au.org.ala.volunteer.Project.listOrderByName()}"
                                          optionKey="id" optionValue="name" value="${frontPage.projectOfTheDay?.id}"/>

                            </div>
                            <div class="col-md-3">
                                <button class="btn btn-default" id="btnFindProject">Find an expedition</button>
                                <g:link class="btn btn-success" action="edit" controller="project"
                                        id="${frontPage.projectOfTheDay?.id}">Edit&nbsp;project</g:link>
                            </div>
                        </div>

                        <div class="form-group" ${hasErrors(bean: frontPage, field: 'useGlobalNewsItem', 'has-error')}>
                            <label for="useGlobalNewsItem" class="control-label col-md-3"><g:message code="frontPage.useGlobalNewsItem.label"
                                                                                                   default="Use global news item"/></label>
                            <div class="col-md-6">
                                <g:checkBox name="useGlobalNewsItem" class="form-control" value="${frontPage.useGlobalNewsItem}"/>
                                <span class="help-block">(If unchecked the most recent project news item will be used instead)</span>
                            </div>
                        </div>

                        <div class="form-group" ${hasErrors(bean: frontPage, field: 'newsTitle', 'has-error')}>
                            <label for="newsTitle" class="control-label col-md-3"><g:message code="frontPage.newsTitle.label"
                                                                                                     default="News title"/></label>
                            <div class="col-md-6">
                                <g:textField class="form-control" name="newsTitle" value="${frontPage?.newsTitle}"/>
                            </div>
                        </div>

                        <div class="form-group" ${hasErrors(bean: frontPage, field: 'newsBody', 'has-error')}>
                            <label for="newsBody" class="control-label col-md-3"><g:message code="frontPage.newsBody.label"
                                                                                             default="News text"/></label>
                            <div class="col-md-6">
                                <g:textArea class="form-control" rows="4" name="newsBody"
                                            value="${frontPage?.newsBody}"/>
                            </div>
                        </div>

                        <div class="form-group" ${hasErrors(bean: frontPage, field: 'newsCreated', 'has-error')}>
                            <label for="newsCreated" class="control-label col-md-3"><g:message code="frontPage.newsCreated.label"
                                                                                            default="News date"/></label>
                            <div class="col-md-6 grails-date">
                                <g:datePicker name="newsCreated" precision="day" value="${frontPage?.newsCreated}"/>
                            </div>
                        </div>

                        <div class="form-group" ${hasErrors(bean: frontPage, field: 'systemMessage', 'has-error')}>
                            <label for="systemMessage" class="control-label col-md-3"><g:message code="frontPage.systemMessage.label"
                                                                                            default="System message"/></label>
                            <div class="col-md-6">
                                <g:textArea class="form-control" rows="4" name="systemMessage"
                                                value="${frontPage?.systemMessage}"/>
                                <span class="help-block">(Displayed on every page)</span>
                            </div>
                        </div>

                        <div class="form-group" ${hasErrors(bean: frontPage, field: 'showAchievements', 'has-error')}>
                            <label for="useGlobalNewsItem" class="control-label col-md-3"><g:message code="frontPage.showAchievements.label"
                                                                                                     default="Show achievements on User stats page"/></label>
                            <div class="col-md-6">
                                <g:checkBox name="showAchievements" class="form-control" value="${frontPage.showAchievements}"/>
                            </div>
                        </div>

                        <div class="form-group" ${hasErrors(bean: frontPage, field: 'enableTaskComments', 'has-error')}>
                            <label for="enableTaskComments" class="control-label col-md-3"><g:message code="frontPage.enableTaskComments.label"
                                                                                                     default="Enable task commenting"/></label>
                            <div class="col-md-6">
                                <g:checkBox name="enableTaskComments" class="form-control" value="${frontPage.enableTaskComments}"/>
                            </div>
                        </div>

                        <div class="form-group" ${hasErrors(bean: frontPage, field: 'enableForum', 'has-error')}>
                            <label for="enableForum" class="control-label col-md-3"><g:message code="frontPage.enableForum.label"
                                                                                                      default="Enable the ${message(code: "default.application.name")} Forum"/></label>
                            <div class="col-md-6">
                                <g:checkBox name="enableForum" class="form-control" value="${frontPage.enableForum}"/>
                            </div>
                        </div>

                        <div class="form-group" ${hasErrors(bean: frontPage, field: 'enableForum', 'has-error')}>
                            <label for="numberOfContributors" class="control-label col-md-3"><g:message code="frontPage.numberOfContributors.label"
                                                                                               default="The number of contributors to show on the front page"/></label>
                            <div class="col-md-6">
                                <g:field name="numberOfContributors" type="number" min="0" max="20" class="form-control" value="${frontPage.numberOfContributors}"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <div class="col-md-offset-3 col-md-9">
                                <g:submitButton name="save" class="save btn btn-primary"
                                            value="${message(code: 'default.button.save.label', default: 'Save')}"/>
                            </div>
                        </div>

                    </g:form>
                </div>
            </div>
        </div>
    </div>
</div>

<r:script>

    $(document).ready(function () {

        $("#btnFindProject").click(function (e) {
            e.preventDefault();
            bvp.selectProjectId(function (projectId) {
                $("#projectOfTheDay").val(projectId);
            });

        });

        $('.grails-date select').each(function() {
            $(this).attr('class', 'form-control');
        });
    });

</r:script>

</body>
</html>
