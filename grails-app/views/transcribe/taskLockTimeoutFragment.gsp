<div>
    <div class="text-center">
        <g:message code="transcribe.taskLockTimeout.title"/>
    </div>

    <div class="text-center">
        <g:if test="${isValidator}">
            <g:message code="transcribe.taskLockTimeout.in_order_to_preserve_unsaved_work"/>
        </g:if>
        <g:else>
            <g:message code="transcribe.taskLockTimeout.please_save_your_changes"/>
        </g:else>
    </div>
    <br/>

    <g:if test="${isValidator}">
        <div class="text-center">
            <g:message code="transcribe.taskLockTimeout.task_identifier"/> <div class="label">${taskInstance.externalIdentifier}</div>
            <br/>
            <small>
                <g:message code="transcribe.taskLockTimeout.copy_and_paste_this_into_the_search_box"/>
            </small>
        </div>
        <br/>
    </g:if>

    <div class="text-center">
        <g:set var="buttonCaption" value="${isValidator ? message(code: 'transcribe.taskLockTimeout.mark_task_as_invalid') : message(code: 'transcribe.taskLockTimeout.save_task')}"/>
        <button type="button" id="btnDefaultSaveTask" class="btn btn-primary">${buttonCaption}</button>
    </div>
    <br/>

    <div class="text-center">
        <small>
            <g:if test="${isValidator}">
                <g:message code="transcribe.taskLockTimeout.note.task_will_be_marked_invalid"/>
            </g:if>
            <g:else>
                <g:message code="transcribe.taskLockTimeout.note.task_will_be_saved"/>
            </g:else>
        </small>
    </div>

</div>
<script>

    var i = 5; // minutes to countdown before reloading page
    var countdownInterval = 60 * 1000; // One minute intervals

    function countDownByOne() {
        $("#reloadCounter").html(--i);
        if (i > 0) {
            window.setTimeout(countDownByOne, countdownInterval);
        } else {
            defaultSaveAction();
        }
    }
    window.setTimeout(countDownByOne, countdownInterval);

    $("#btnDefaultSaveTask").click(function (e) {
        e.preventDefault();
        defaultSaveAction();
    });

    function defaultSaveAction() {
        <g:if test="${isValidator}">
        $("#btnDontValidate").click();
        </g:if>
        <g:else>
        $("#btnSavePartial").click();
        </g:else>
    }

</script>