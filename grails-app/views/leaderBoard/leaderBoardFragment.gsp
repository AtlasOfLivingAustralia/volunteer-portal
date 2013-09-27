<div style="margin-top: 10px">
    <table class="table table-bordered table-condensed table-striped">
        <thead style="background-color: #f0f0e8">
            <tr>
                <td colspan="2" style="vertical-align: middle">
                    <h3 style="margin: 0; display: inline-block">Leader board</h3>
                </td>
            </tr>
        </thead>
        <tbody>

            <g:each in="${leaderBoardSections}" var="section">
                <tr>
                    <th colspan="2">
                        ${section.key}
                        <button class="btn btn-small pull-right">View All</button>
                    </th>
                </tr>
                <tr resultLink="${section.value}">
                    <td><img src="${resource(dir: 'images', file: 'spinner.gif')}"/></td>
                    <td></td>
                </tr>

            </g:each>

        </tbody>
    </table>
 </div>

<script type="text/javascript">
    $("tr[resultLink]").each(function(index, element) {
        var link = $(this).attr("resultLink");
        var target = $(this);
        if (link) {
            $.ajax(link).done(function(data) {
                target.html("<td>" + data.name + "</td><td>" +  data.score + "</td>");
            });
        }

    });
</script>