<div>
    <table class="table table-bordered table-condensed table-striped">
        <thead style="background-color: #f0f0e8">
        <tr>
            <td colspan="2" style="vertical-align: middle">
                <h3 style="margin: 0; display: inline-block">${institutionInstance ? institutionInstance.acronym + " " : ""}Honour Board</h3>
            </td>
        </tr>
        </thead>
        <tbody>
        <g:each in="${leaderBoardSections}" var="section">
            <tr>
                <th colspan="2">
                    ${section.label}
                    <a class="btn btn-small pull-right"
                       href="${createLink(controller: 'leaderBoard', action: 'topList', params: [category: section.category, institutionId: institutionInstance?.id])}">View Top 20</a>
                </th>
            </tr>
            <tr resultLink="${createLink(action: 'ajaxLeaderBoardCategoryWinner', params: [category: section.category, institutionId: institutionInstance?.id])}">
                <td><img src="${resource(dir: 'images', file: 'spinner.gif')}"/></td>
                <td></td>
            </tr>
        </g:each>
        </tbody>
    </table>
</div>

<script type="text/javascript">
    $("tr[resultLink]").each(function (index, element) {
        var link = $(this).attr("resultLink");
        var target = $(this);
        if (link) {
            $.ajax(link).done(function (data) {
                var label = data.score == 0 ? 'No activity recorded' : data.name;
                var score = data.score == 0 ? '' : data.score;
                var labelClass = data.score == 0 ? 'muted' : '';

                target.html('<td><span class="' + labelClass + '">' + label + '</span></td><td>' + score + '</td>');
            });
        }

    });
</script>