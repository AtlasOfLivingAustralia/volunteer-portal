<div>
    <table class="bvp-expeditions">
        <thead>
            <tr>
                <th>Topic</th>
                <th>Replies</th>
                <th>Views</th>
                <th></th>
            </tr>
        </thead>
        <tbody>
            <g:each in="${watchList?.topics?.sort { it.dateCreated }}" var="topic">
                <tr topicId="${topic.id}">
                    <td>
                        <strong>
                            <a href="${createLink(controller: 'forum', action:'viewForumTopic', id: topic.id)}">${topic.title}</a>
                        </strong>
                        <br/>
                        <div>
                            <small>
                                Posted by: ${topic.creator.displayName}
                                <br/>
                                On: <g:formatDate date="${topic.dateCreated}" format="${au.org.ala.volunteer.DateConstants.DATE_TIME_FORMAT}" />
                            </small>
                        </div>
                    </td>
                    <td>${topic.messages.size() - 1}</td>
                    <td>${topic.views}</td>
                    <td>
                        <button class="btnViewTopic">View topic</button>
                        <button class="btnUnwatchTopic">Stop watching topic</button>
                    </td>
                </tr>
            </g:each>
        </tbody>
    </table>
</div>
<script type="text/javascript">

    $(".btnViewTopic").click(function(e) {
        e.preventDefault();
        var topicId = $(this).parents("tr[topicId]").attr("topicId");
        if (topicId) {
            window.location = "${createLink(controller: 'forum', action:"viewForumTopic")}/" + topicId;
        }
    });

    $(".btnUnwatchTopic").click(function(e) {
        e.preventDefault();
        var topicId = $(this).parents("tr[topicId]").attr("topicId");
        if (topicId) {
            $.ajax("${createLink(controller: 'forum', action:'ajaxWatchTopic', params:[watch:'false'])}&topicId=" + topicId).done(function(results) {
                location = "${createLink(controller: "forum", action:"index", params:[selectedTab: 2 ])}";
            });
        }
    });


</script>