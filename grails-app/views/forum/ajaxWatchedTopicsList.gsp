<%@ page import="au.org.ala.volunteer.ProjectForumTopic" %>
<div>
    <g:if test="${topics}">
        <table class="table table-striped">
            <thead>
            <tr>
                <g:sortableColumn class="button" property="title" title="Topic" action="index" params="${params}"/>
                <g:sortableColumn class="button" property="views" title="Views" action="index" params="${params}"/>
                <g:sortableColumn class="button" property="id" title="Replies" action="index" params="${params}"/>
                <g:sortableColumn class="button" property="lastReplyDate" title="Last Reply" action="index"
                                  params="${params}"/>
                <th></th>
            </tr>
            </thead>
            <tbody>
            <g:each in="${topics}" var="topic">
                <tr topicId="${topic.id}">
                    <td>
                        <strong>
                            <a href="${createLink(controller: 'forum', action: 'viewForumTopic', id: topic.id)}">${topic.title}</a>
                        </strong>
                        <br/>

                        <div>
                            <small>
                                <g:message code="forum.watched_topics.posted_by" args="${[topic.creator.displayName]}"/>
                                <br/>
                                <g:message code="forum.watched_topics.on"/> <g:formatDate date="${topic.dateCreated}"
                                                  format="${au.org.ala.volunteer.DateConstants.DATE_TIME_FORMAT}"/>
                                <br/>
                                <g:if test="${topic.instanceOf(au.org.ala.volunteer.ProjectForumTopic)}">
                                    <g:message code="forum.watched_topics.project"/> <strong>${topic.project?.i18nName}</strong>
                                </g:if>
                                <g:if test="${topic.instanceOf(au.org.ala.volunteer.TaskForumTopic)}">
                                    <g:message code="forum.watched_topics.project"/> <strong>${topic.task?.project?.i18nName}</strong>
                                    <br/>
                                    <g:message code="forum.watched_topics.task"/> <strong>${topic.task?.externalIdentifier}</strong>
                                </g:if>

                            </small>
                        </div>
                    </td>
                    <td>${topic.views}</td>
                    <td>${topic.messages.size() - 1}</td>
                    <td><g:formatDate date="${topic.lastReplyDate}"
                                      format="${au.org.ala.volunteer.DateConstants.DATE_TIME_FORMAT}"/></td>
                    <td>
                        <button class="btn btn-small btnViewTopic"><g:message code="forum.watched_topics.view_topic"/></button>
                        <button class="btn btn-small btnUnwatchTopic"><g:message code="forum.watched_topics.stop_watching"/></button>
                    </td>
                </tr>
            </g:each>
            </tbody>
        </table>
    </g:if>
    <g:else>
        <div class="alert alert-info">
            <g:message code="forum.watched_topics.you_have_no_watched_topics"/>
        </div>
    </g:else>
</div>
<script type="text/javascript">

    $(".btnViewTopic").click(function (e) {
        e.preventDefault();
        var topicId = $(this).parents("tr[topicId]").attr("topicId");
        if (topicId) {
            window.location = "${createLink(controller: 'forum', action:"viewForumTopic")}/" + topicId;
        }
    });

    $(".btnUnwatchTopic").click(function (e) {
        e.preventDefault();
        var topicId = $(this).parents("tr[topicId]").attr("topicId");
        if (topicId) {
            $.ajax("${createLink(controller: 'forum', action:'ajaxWatchTopic', params:[watch:'false'])}&topicId=" + topicId).done(function (results) {
                location = "${createLink(controller: "forum", action:"index", params:params)}";
            });
        }
    });

</script>