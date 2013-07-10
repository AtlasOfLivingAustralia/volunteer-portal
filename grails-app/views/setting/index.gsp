<%@ page import="au.org.ala.volunteer.Project" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <title><g:message code="admin.label" default="Administration"/></title>
        <style type="text/css">

            #buttonBar {
                margin-bottom: 10px;
            }

            .bvp-expeditions td button {
                margin-top: 5px;
            }

        </style>
        <script type='text/javascript'>

            $(document).ready(function() {
                $(".btnEditSetting").click(function(e) {
                    e.preventDefault();
                    var key = $(this).parents("tr[settingKey]").attr("settingKey");
                    if (key) {
                        window.location = "${createLink(controller:'setting', action:'editSetting')}?settingKey=" + key;
                    }
                });
            });

        </script>
    </head>

    <body>

        <cl:headerContent title="${message(code: 'default.advancedSettings.label', default: 'Advanced Settings')}">
           <%
               pageScope.crumbs = [
                   [link: createLink(controller: 'admin', action: 'index'), label: 'Administration']
               ]
           %>
       </cl:headerContent>

        <div class="row">
            <div class="span12">
                <table class="table table-bordered table-striped">
                    <thead>
                        <tr>
                            <th style="text-align: left">Key</th>
                            <th style="text-align: left">Default Value</th>
                            <th style="text-align: left">Value</th>
                            <th style="text-align: left">Description</th>
                            <th></th>
                        </tr>
                    </thead>
                    <g:each in="${settings}" var="setting">
                        <tr settingKey="${setting.key}">
                            <td>${setting.key}</td>
                            <td>${setting.defaultValue}</td>
                            <td><strong>${values[setting]}</strong></td>
                            <td>${setting.description}</td>
                            <td><button class="btn btnEditSetting">Change</button></td>
                        </tr>
                    </g:each>
                </table>
            </div>
        </div>

        <div class="row">
            <div class="span12">
                <g:form action="sendTestEmail">
                    To: <g:textField style="margin-bottom: 0" name="to"/>
                    <button class="btn" type="submit">Send test email</button>
                </g:form>
            </div>
        </div>

    </body>
</html>
