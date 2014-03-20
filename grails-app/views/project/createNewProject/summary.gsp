<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title>Create a new Expedition - Summary</title>

    <r:script type="text/javascript">

        $(document).ready(function() {
        });

    </r:script>

    <style type="text/css">
    </style>

</head>
<body>

<cl:headerContent title="Create a new Expedition - Summary" selectedNavItem="expeditions">
    <%
        pageScope.crumbs = [
        ]
    %>
</cl:headerContent>

<div class="well well-small">
    <table class="table table-striped table-bordered table-condensed">
        <tr>
            <td>Expedition name</td>
            <td>${projectName}</td>
        </tr>
    </table>
    <g:link class="btn btn-small" event="cancel">Cancel</g:link>
    <g:link class="btn btn-small" event="back"><i class="icon-chevron-left"></i>&nbsp;Previous</g:link>
    <g:link class="btn btn-small btn-primary" event="continue">Continue&nbsp;<i class="icon-chevron-right icon-white"></i></g:link>
</div>

</body>
</html>