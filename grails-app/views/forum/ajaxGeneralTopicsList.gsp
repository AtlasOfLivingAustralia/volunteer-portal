<div>
    <div class="buttonBar" style="margin-bottom: 10px">
        <button id="btnNewSiteTopic" class="btn">Create a new topic&nbsp;<img src="${resource(dir: 'images', file: 'newTopic.png')}"/></button>
    </div>
    <g:if test="${!topics}">
        <strong>No forum topics have yet been created. Click on the 'Create a new topic' button above to add a discussion topic.</strong>
    </g:if>
    <g:else>
        <vpf:topicTable topics="${topics}" totalCount="${totalCount}" paginateAction="index" />
    </g:else>
</div>

<r:script type="text/javascript">

    $(document).ready(function() {
        $("#btnNewSiteTopic").click(function(e) {
            e.preventDefault();
            window.location = "${createLink(controller: 'forum', action:'addForumTopic')}";
        });
    });

</r:script>
