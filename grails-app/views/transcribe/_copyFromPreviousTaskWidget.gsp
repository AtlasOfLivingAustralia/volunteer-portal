<div class="row ${cssClass}" style="margin-bottom: 10px">

    <div class="col-md-10">
        <button type="button" class="btn btn-info btnCopyFromPreviousTask pull-right" href="#task_selector"
                style="">${field.label ?: message(code: 'transcribe.copyFromPreviousTask.copy_values_from_a_previous')}</button>
    </div>

    <div class="col-md-2">
        <g:fieldHelp field="${field}"/>
    </div>

</div>


