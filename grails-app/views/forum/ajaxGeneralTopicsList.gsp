<div>
    <div class="buttonBar" style="margin-bottom: 10px">
        <button id="btnNewSiteTopic" class="btn btn-primary"><g:message code="forum.topic_list.create_a_topic"/></button>
    </div>
    <g:if test="${!topics}">
        <strong><g:message code="forum.topic_list.no_topics"/></strong>
    </g:if>
    <g:else>
        <vpf:topicTable topics="${topics}" totalCount="${totalCount}" paginateAction="index"/>
    </g:else>
</div>

<script type="text/javascript">

    $(document).ready(function () {
        $("#btnNewSiteTopic").click(function (e) {
            e.preventDefault();
            window.location = "${createLink(controller: 'forum', action:'addForumTopic')}";
        });
    });

</script>
