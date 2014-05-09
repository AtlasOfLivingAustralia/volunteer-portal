<!doctype html>
<html>
<head>
    <meta name="layout" content="projectSettingsLayout"/>
</head>

<body>

    <content tag="pageTitle">News items</content>

    <content tag="adminButtonBar">
        <a class="btn btn-primary" href="${createLink(controller:'newsItem', action:'create', params:['project.id': projectInstance.id])}"><i class="icon-plus icon-white"></i> Add news item</a>
    </content>

    <div class="form-horizontal">
        <div class="control-group">
            <label for="enableNewItems">
                News items are <g:checkBox name="enableNewsItems" checked="${!projectInstance.disableNewsItems}" />
            </label>
        </div>
    </div>


    <g:form name="enableNewsItemsForm" action="updateNewsItemsSettings" >

        <g:hiddenField name="id" value="${projectInstance?.id}"/>
        <g:hiddenField name="version" value="${projectInstance?.version}"/>
        <g:hiddenField name="disableNewsItems" value=""/>

    </g:form>

    ${newsItems?.size() ?: 0} news items

    <table class="table table-striped">
        <thead>
            <th>Date</th>
            <th>Content</th>
            <th/>
        </thead>
        <tbody>
            <g:each in="${newsItems}" var="newsItem">
                <tr>
                    <td style="max-width: 40px"><g:formatDate date="${newsItem.created}" format="yyyy-MM-dd HH:mm:ss" /></td>
                    <td>
                        <div>
                            <strong>${newsItem.title}</strong>
                        </div>
                        <div>
                            <em>${newsItem.shortDescription}</em>
                        </div>
                        <div>
                        ${newsItem.body}
                        </div>
                    </td>
                    <td style="max-width: 20px">
                        <div class="pull-right">
                            <a class="btn btn-small btn-danger" href="${createLink(controller:'newsItem', action:'delete', id: newsItem.id)}"><i class="icon-remove icon-white"></i></a>
                            <a class="btn btn-small" href="${createLink(controller:'newsItem', action:'edit', id: newsItem.id)}"><i class="icon-edit"></i></a>
                        </div>
                    </td>
                </tr>
            </g:each>
        </tbody>
    </table>

<script type='text/javascript'>
    $(document).ready(function () {

        $('input:checkbox').bootstrapSwitch({
            size: "small"
        });

        $('input:checkbox').on('switchChange.bootstrapSwitch', function(event, state) {
            $("#disableNewsItems").val(!state);
            $("#enableNewsItemsForm").submit();
        });
    });
</script>
</body>
</html>
