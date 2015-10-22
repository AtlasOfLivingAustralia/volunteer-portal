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
                                Posted by: ${topic.creator.displayName}
                                <br/>
                                On: <g:formatDate date="${topic.dateCreated}"
                                                  format="${au.org.ala.volunteer.DateConstants.DATE_TIME_FORMAT}"/>
                                <br/>
                                <g:if test="${topic.instanceOf(au.org.ala.volunteer.ProjectForumTopic)}">
                                    Project: <strong>${topic.project?.featuredLabel}</strong>
                                </g:if>
                                <g:if test="${topic.instanceOf(au.org.ala.volunteer.TaskForumTopic)}">
                                    Project: <strong>${topic.task?.project?.featuredLabel}</strong>
                                    <br/>
                                    Task: <strong>${topic.task?.externalIdentifier}</strong>
                                </g:if>

                            </small>
                        </div>
                    </td>
                    <td>${topic.views}</td>
                    <td>${topic.messages.size() - 1}</td>
                    <td><g:formatDate date="${topic.lastReplyDate}"
                                      format="${au.org.ala.volunteer.DateConstants.DATE_TIME_FORMAT}"/></td>
                    <td>
                        <button class="btn btn-small btnViewTopic">View topic</button>
                        <button class="btn btn-small btnUnwatchTopic">Stop watching topic</button>
                    </td>
                </tr>
            </g:each>
            </tbody>
        </table>
    </g:if>
    <g:else>
        <div class="alert alert-info">
            You have no watched topics.
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