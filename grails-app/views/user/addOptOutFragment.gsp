<div class="alert alert-danger" id="dialogMessageDiv" style="display: none">
</div>

<div class="form-horizontal">
    <div class="form-group">
        <label class="control-label col-md-3" for="newUserOptOut">User: </label>

        <div class="col-md-6">
%{--            <g:textField name="newCollectionCode" class="form-control"/>--}%
            <input class="form-control" id="user" type="text" placeholder="Enter user's name" value="${displayName}" required autocomplete="off"/>
            <i id="ajax-spinner" class="fa fa-cog fa-spin hidden"></i>
            <input id="userId" name="userId" type="hidden" value="${userId}"/>
        </div>

    </div>

    <div class="form-group">
        <div class="col-md-offset-3 col-md-9">
            <button type="button" class="btn btn-default" id="btnCancelCreate">Cancel</button>
            <button type="button" class="btn btn-primary" id="btnCreateNew">Create</button>
        </div>
    </div>
</div>

<asset:javascript src="label-autocomplete" asset-defer=""/>
<script type="text/javascript">
    $("#btnCancelCreate").click(function (e) {
        e.preventDefault();
        bvp.hideModal();
    });

    $("#btnCreateNew").click(function (e) {
        e.preventDefault();
        let userid = $("#userId").val();
        if (userid) {
            $.ajax("${createLink(action:'ajaxCreateNewOptOutRequest')}?userid=" + userid).done(function (result) {
                if (result.success) {
                    bvp.newOptoutUser = userid;
                    bvp.hideModal();
                } else {
                    $("#dialogMessageDiv").html(result.message).css("display", "block");
                }
            });
        }
    });

    const url = "${createLink(controller: 'user', action: 'listUsersForJson')}";

    labelAutocomplete("#user", url, '#ajax-spinner', function(item) {
        $('#userId').val(item.userId);
        return null;
    }, 'displayName');
</script>