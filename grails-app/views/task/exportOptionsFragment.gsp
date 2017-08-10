<div>
    <h3><g:message code="task.exportOptionsFragment.select"/></h3>

    <div class="control-group">
        <label class="radio">
            <input type="radio" name="optionsExport" id="optionsExportCSV" value="csv" checked>
            <strong><g:message code="task.exportOptionsFragment.csv"/></strong>
            <br/>
            <g:message code="task.exportOptionsFragment.csv.description"/>
        </label>
        <label class="radio">
            <input type="radio" name="optionsExport" id="optionsExportZip" value="zip">
            <strong><g:message code="task.exportOptionsFragment.zip"/></strong>
            <br/>
            <g:message code="task.exportOptionsFragment.zip.description"/>
        </label>
    </div>

    <div class="control-group">
        <div class="controls">
            <button id="btnCancelExport" class="btn"><g:message code="default.cancel"/></button>
            <button id="btnExportTasks" class="btn btn-primary"><g:message code="task.exportOptionsFragment.export"/></button>
        </div>
    </div>

</div>

<script type="text/javascript">

    $("#btnCancelExport").click(function (e) {
        e.preventDefault();
        bvp.hideModal();
    });

    $("#btnExportTasks").click(function (e) {
        e.preventDefault();
        var format = $("input:radio[name='optionsExport']:checked").val();
        var url = "${createLink(controller:'project', action:'exportCSV', id: projectId, params:[validated: exportCriteria == 'validated', transcribed: exportCriteria=='transcribed'])}&exportFormat=" + format;
        window.location = url;
    });

</script>