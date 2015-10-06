<div class="alert alert-danger" id="dialogMessageDiv" style="display: none">
</div>

<div class="form-horizontal">
    <div class="control-group">
        <label class="control-label" for="newCollectionCode">Collection code:</label>

        <div class="controls">
            <g:textField name="newCollectionCode"/>
        </div>
    </div>

    <div class="control-group">
        <div class="controls">
            <button type="button" class="btn" id="btnCancelCreateCollectionCode">Cancel</button>
            <button type="button" class="btn btn-primary" id="btnCreateNewCollectionCode">Create</button>
        </div>
    </div>
</div>

<script>

    $("#btnCancelCreateCollectionCode").click(function (e) {
        e.preventDefault();
        bvp.hideModal();
    });

    $("#btnCreateNewCollectionCode").click(function (e) {
        e.preventDefault();
        var code = $("#newCollectionCode").val();
        if (code) {
            $.ajax("${createLink(action:'ajaxCreateNewCollectionCode')}?code=" + code).done(function (result) {
                if (result.success) {
                    bvp.newCollectionCode = code;
                    bvp.hideModal();
                } else {
                    $("#dialogMessageDiv").html(result.message).css("display", "block");
                }
            });
        }
    });

</script>