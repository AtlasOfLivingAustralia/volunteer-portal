<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title><g:message code="default.application.name"/> - Atlas of Living Australia</title>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    %{--<link rel="stylesheet" href="${resource(dir: 'css', file: 'vp.css')}"/>--}%
    <link rel="stylesheet" href="${resource(dir: 'css', file: 'forum.css')}"/>

    <style type="text/css">
    </style>

</head>

<body class="forum">

<r:script type="text/javascript">

    $(document).ready(function () {
    });

</r:script>

<cl:headerContent title="Search results: '${query}'" selectedNavItem="forum">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'forum', action: 'index'), label: 'Forum']
        ]
    %>
</cl:headerContent>

<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <p>
                        <strong>${results.totalCount} matching message${results.totalCount == 1 ? '' : 's'} found.</strong>
                    </p>
                    <section id="searchResults">
                        <vpf:messagesTable messages="${results}"/>
                        %{--<vpf:searchResultsTable searchResults="${results}"/>--}%
                    </section>
                </div>
            </div>
        </div>
    </div>
</div>

</body>
</html>
