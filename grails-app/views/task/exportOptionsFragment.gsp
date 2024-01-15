<div class="row">
    <div class="col-md-12">
        <strong>Select an export format</strong>

        <div class="input-group">
            <label class="radio" style="margin-left: 20px;">
                <input type="radio" name="optionsExport" id="optionsExportCSV" value="csv" checked>
                <strong>Single de-normalised CSV file</strong>
            </label>
            <p>
                Export will be a single CSV file. Repeating fields will have their own column each with a record index
                suffix (e.g. recordedBy_0, recordedBy_1).
                This is probably the most appropriate choice for <b>specimen label</b> transcriptions.
            </p>

            <label class="radio" style="margin-left: 20px;">
                <input type="radio" name="optionsExport" id="optionsExportZip" value="zip">
                <strong>ZIP file</strong>
            </label>
            <p>
                A compressed archive of multiple flat CSV files, one for each one-to-many relationship. Files are linked
                by a task id. This would be most suitable for <b>field diaries</b> and <b>notebooks</b> with large
                numbers of repeating fields.
            </p>
        </div>

        <div class="input-group">
            <div class="controls">
                <button id="btnExportTasks" class="btn btn-primary">Export</button>&nbsp;&nbsp;
                <button id="btnCancelExport" class="btn">Close</button>
            </div>
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
        var url = "${createLink(controller:'project', action:'exportCSV', id: projectId, params:[validated: exportCriteria == 'validated', transcribed: exportCriteria=='transcribed']).encodeAsJavaScript()}&exportFormat=" + format;
        window.location = url;
    });

</script>