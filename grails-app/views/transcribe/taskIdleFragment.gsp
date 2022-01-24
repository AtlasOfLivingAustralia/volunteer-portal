<div>
    <div class="text-center">
        You have been working on this task for a long time.
    </div>

    <div class="text-center">
        <g:if test="${isValidator}">
            In order to preserve unsaved work it is recommended that the task be marked has invalid.
            <br/>
            You can then return and review this task from the admin list.
        </g:if>
        <g:else>
            You can save your work in progress and return to it later or continue working.
        </g:else>
    </div>
    <br/>

    <g:if test="${isValidator}">
        <div class="text-center">
            Task identifier: <div class="label">${taskInstance.externalIdentifier}</div>
            <br/>
            <small>
                Copy and paste this into the search box to easily find the task in the admin list.
            </small>
        </div>
        <br/>
    </g:if>

    <div class="text-center">
        <g:set var="buttonCaption" value="${isValidator ? 'Mark task as invalid' : 'Save task'}"/>
        <button type="button" id="btnDefaultSaveTask" class="btn btn-primary">${buttonCaption}</button>
        <button type="button" id="btnIdleCancelModal" class="btn btn-default">Continue working</button>
    </div>
    <br/>

    <div class="text-center">
        <small>
            <g:if test="${isValidator}">
                NOTE: The task will be automatically marked as invalid in <span
                    id="reloadCounter">5</span> minutes if no action is taken.
            </g:if>
            <g:else>
                NOTE: The task will be automatically saved in <span
                    id="reloadCounter">5</span> minutes if no action is taken.
            </g:else>
        </small>
    </div>

</div>
<script>

    var i = 5; // minutes to countdown before reloading page
    var countdownInterval = 60 * 1000; // One minute intervals
    var countdownTimerId;

    function countDownByOne() {
        $("#reloadCounter").html(--i);
        if (i > 0) {
            countdownTimerId = window.setTimeout(countDownByOne, countdownInterval);
        } else {
            defaultSaveAction();
        }
    }
    window.setTimeout(countDownByOne, countdownInterval);

    $("#btnDefaultSaveTask").click(function (e) {
        e.preventDefault();
        defaultSaveAction();
    });

    $('#btnIdleCancelModal').click(function(e) {
        e.preventDefault();
        window.clearTimeout(countdownTimerId);
        bvp.hideModal();
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