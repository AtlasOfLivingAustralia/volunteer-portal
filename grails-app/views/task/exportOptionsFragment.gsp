<div>
    <h3>Select an export format</h3>

    <div class="control-group">
        <label class="radio">
            <input type="radio" name="optionsExport" id="optionsExportCSV" value="csv" checked>
            <strong>Single de-normalised CSV file</strong>
            <br/>
            Repeating fields will get a column each with a record index suffix (e.g. recordedBy_0, recordedBy_1). This is probably the most appropriate choice for specimen label transcriptions.
        </label>
        <label class="radio">
            <input type="radio" name="optionsExport" id="optionsExportZip" value="zip">
            <strong>ZIP file</strong>
            <br/>
            A compressed archive of multiple flat CSV files, one for each one-to-many relationship. Files are linked by a task id. Suitable for field diaries and notebooks with large numbers of repeating fields.
        </label>
    </div>

    <div class="control-group">
        <div class="controls">
            <button id="btnCancelExport" class="btn">Cancel</button>
            <button id="btnExportTasks" class="btn btn-primary">Export</button>
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