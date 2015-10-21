<div class="alert alert-danger" id="dialogMessageDiv" style="display: none">
</div>

<div class="form-horizontal">
    <div class="form-group">
        <label class="control-label col-md-3" for="newCollectionCode">Collection code:</label>

        <div class="col-md-6">
            <g:textField name="newCollectionCode" class="form-control"/>
        </div>
    </div>

    <div class="form-group">
        <div class="col-md-offset-3 col-md-9">
            <button type="button" class="btn btn-default" id="btnCancelCreateCollectionCode">Cancel</button>
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