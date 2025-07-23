<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}">
    <g:set var="entityName" value="${message(code: 'newsItem.label', default: 'News Item')}" />
    <title><cl:pageTitle title="${g.message(code:"newsItem.manage.label", default:"Manage News Items")}" /></title>

    <style>
    .btn, .custom-search-input {
        border-radius: 4px !important;
    }
    </style>
</head>

<body class="admin">
<cl:headerContent title="${message(code: 'newsItem.manage.label')}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label')]
        ]
    %>

    <a class="btn btn-success" href="${createLink(action: "create")}">
        Add News Item
    </a>

</cl:headerContent>
<div class="container" role="main">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-4">
                    <g:select class="form-control statusFilter" name="statusFilter" from="${statusFilterList}"
                              optionKey="key" optionValue="value"
                              value="${params?.statusFilter}" noSelection="['':'- Filter by Status -']" />
                </div>
                <div class="col-md-4">
                    <div class="custom-search-input body">
                        <div class="input-group">
                            <input type="text" id="searchbox" class="form-control input-lg" value="${params.q}" placeholder="Search News Items..."/>
                            <span class="input-group-btn">
                                <button id="btnSearch" class="btn btn-info btn-lg" type="button">
                                    <i class="glyphicon glyphicon-search"></i>
                                </button>
                            </span>
                        </div>
                    </div>
                </div>

                <div class="col-md-4">
                    <a class="btn btn-default bs3"
                       href="${createLink(controller: 'newsItem', action: 'manage')}">Reset</a>
                </div>

            </div>
            <div class="row">
                <div class="col-md-6" style="margin-top: 20px;margin-left: 5px;">
                    ${newsItemCount ?: 0} News Items found.
                </div>
            </div>
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <table class="table table-striped table-hover admin-data-table">
                        <thead>
                        <tr>
                            <g:sortableColumn property="title"
                                              title="${message(code: 'newsItem.title.label')}"
                                              params="${params}"/>

                            <g:sortableColumn property="status"
                                              title="${message(code: 'newsItem.status.label')}"
                                              params="${params}"/>

                            <g:sortableColumn property="dateCreated" params="${params}"
                                              title="${message(code: 'default.dateCreated.label')}"/>

                            <g:sortableColumn property="lastUpdated" params="${params}"
                                              title="${message(code: 'default.lastUpdated.label')}"/>

                            <g:sortableColumn property="createdBy" params="${params}"
                                              title="${message(code: 'newsItem.createdBy.label')}"/>

                            <th></th>

                        </tr>
                        </thead>
                        <tbody>
                        <g:each in="${newsItemList}" status="i" var="newsItem">
                            <tr class="${(i % 2) == 0 ? 'even' : 'odd'}" data-news-item-id="${newsItem.id}">
                                <td style="vertical-align: middle; width: 45%;">
                                    ${fieldValue(bean: newsItem, field: "title")}
                                </td>

                                <!-- status -->
                                <td style="vertical-align: middle; text-align: right;">
                                    <g:if test="${!newsItem.isActive}">
                                        <i class="fa fa-eye-slash newsItem-status" title="Inactive"></i>
                                    </g:if>
                                    <g:if test="${newsItem.dateExpires < new Date()}">
                                        <i class="fa fa-calendar-times-o newsItem-status" title="Expired"></i>
                                    </g:if>
                                </td>

                                <td style="vertical-align: middle; white-space: nowrap;"><g:formatDate type="date" style="medium" date="${newsItem.dateCreated}"/></td>

                                <td style="vertical-align: middle; white-space: nowrap;"><g:formatDate type="date" style="medium" date="${newsItem.lastUpdated}"/></td>

                                <td style="vertical-align: middle; white-space: nowrap;">${newsItem.createdBy.displayName}</td>

                                <td style="white-space: nowrap;">
                                <!-- Toggle Status -->
                                    <g:if test="${!newsItem.isActive}">
                                        <a class="btn btn-xs btn-default toggle-news-item-status" alt="Activate" title="Activate News Item"><i class="fa fa-toggle-off"></i></a>
                                    </g:if>
                                    <g:else>
                                        <a class="btn btn-xs btn-default toggle-news-item-status" alt="Deactivate" title="Deactivate News Item"><i class="fa fa-toggle-on"></i></a>
                                    </g:else>

                                <!-- Edit -->
                                    <g:link action="edit" id="${newsItem.id}" title="Edit News Item" alt="Edit">
                                        <span class="btn btn-xs btn-default edit-news-item">
                                            <i class="fa fa-pencil"></i>
                                        </span>
                                    </g:link>

                                <!-- Delete -->
                                    <button role="button" class="btn btn-danger btn-xs delete-news-item"
                                            data-news-item-title="${newsItem.title}"
                                            data-href="${createLink(controller: "newsItem", action: "delete", id: newsItem.id)}"
                                            title="Delete News Item"><i class="fa fa-trash"></i></button>
                                </td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>


</div>
<asset:script type="text/javascript">
    jQuery(function($) {
        $.extend({
            postGo: function(url, params) {
                var $form = $("<form>")
                    .attr("method", "post")
                    .attr("action", url);
                $.each(params, function(name, value) {
                    $("<input type='hidden'>")
                        .attr("name", name)
                        .attr("value", value)
                        .appendTo($form);
                });
                $form.appendTo("body");
                $form.submit();
            }
        });

        $('.delete-news-item').click(function(e) {
            var $this = $(this);
            var href = $this.attr('data-href');
            var name = $this.attr('data-news-item-title');
            let warningText = "<b>Warning:</b><br/>Are you sure you wish to delete the news item titled: " + name
                + "?<br/>This action is permanent!"
            bootbox.confirm(warningText, function(result) {
                if (result) {
                    $.postGo(href);
                }
            });
        });

        $("#searchbox").keydown(function(e) {
            if (e.keyCode === 13) {
                doNewsItemSearch();
            }
        });

        $("#btnSearch").click(function(e) {
            e.preventDefault();
            doNewsItemSearch();
        });

        $('.statusFilter').change(function() {
            let filter = $(this).val();
            var url = "${createLink(controller: 'newsItem', action: 'manage')}" +
                "?q=${params.q}&statusFilter=" + filter;
            window.location = url;
        });

        function doNewsItemSearch() {
            var q = $("#searchbox").val();
            var url = "${createLink(controller: 'newsItem', action: 'manage')}" +
                "?statusFilter=${params.statusFilter}&q=" +
                encodeURIComponent(q);
            window.location = url;
        }

        $(".toggle-news-item-status").click(function (e) {
            e.preventDefault();

            const newsItemId = $(this).closest('tr').attr("data-news-item-id");
            let url = "${createLink(controller: 'newsItem', action: 'toggleNewsItemStatus')}/" + newsItemId;
            const paramString = getQueryStringParams();
            if (paramString) url += "?" + paramString;
             console.log("url: " + url);

            $('<form/>', { action: url, method: 'POST' }).append(
                $('<input>', {type: 'hidden', id: 'verifyId', name: 'verifyId', value: newsItemId})
            ).appendTo('body').submit();
        });

        function getQueryStringParams() {
            const params = new URLSearchParams(window.location.search);
            let q = params.get('q');
            let statusFilter = params.get('statusFilter');

            let paramString = "", s = false;
            if (q) {
                paramString += (s ? "&" : "") + "q=" + q;
                s = true;
            }
            if (statusFilter) {
                paramString += (s ? "&" : "") + "statusFilter=" + statusFilter;
            }
            return paramString;
        }

});
</asset:script>

</body>
</html>