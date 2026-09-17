<%@ page import="org.grails.web.json.JSONArray; au.org.ala.volunteer.Project" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <title><g:message code="admin.label" default="Administration"/></title>

    <asset:script type='text/javascript'>

            $(document).ready(function() {
                $(".btnEditSetting").click(function(e) {
                    e.preventDefault();
                    var key = $(this).parents("tr[settingKey]").attr("settingKey");
                    if (key) {
                        window.location = "${createLink(controller: 'setting', action: 'editSetting')}?settingKey=" + key;
                    }
                });
            });

    </asset:script>
</head>

<body class="admin">

<cl:headerContent title="${message(code: 'default.advancedSettings.label', default: 'Advanced Settings')}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin', action: 'index'), label: 'Administration']
        ]
    %>
</cl:headerContent>

<div class="container">
    <div class="card">
        <div class="card-body">
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <table class="table table-hover table-striped">
                        <thead>
                        <tr>
                            <th>Key</th>
%{--                            <th>Default Value</th>--}%
                            <th>Value</th>
                            <th>Description</th>
                            <th></th>
                        </tr>
                        </thead>
                        <tbody>
                        <g:each in="${settings}" var="setting">
                            <tr settingKey="${setting.key}">
                                <td>
                                    ${setting.key}
                                    <cl:helpText>
                                        <g:message code="settings.description.${key}" default="${setting.description}"/>
                                    </cl:helpText>
                                </td>
                                <td><strong>${values[setting] instanceof JSONArray ? values[setting].join(', ') : values[setting]}</strong></td>
                                <td><button class="btn btn-secondary btnEditSetting">Edit</button></td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <g:form action="sendTestEmail" class="form-horizontal">
                        <label class="form-label col-md-1" for="to">To:</label>
                        <div class="col-md-5">
                            <g:textField class="form-control" name="to"/>
                        </div>

                        <button class="btn btn-secondary" type="submit">Send test email</button>
                    </g:form>
                </div>
            </div>
        </div>
    </div>
</div>

<asset:script type="text/javascript">

    $(document).ready(function() {
        bvp.bindTooltips();
    });
</asset:script>

</body>
</html>
