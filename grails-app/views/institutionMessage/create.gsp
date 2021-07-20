<%@ page import="org.springframework.validation.FieldError; au.org.ala.volunteer.InstitutionMessage" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'institutionMessage.default.label', default: 'Institution Message')}"/>
    <title><cl:pageTitle title="${g.message(code: "default.new.label", args: [entityName], default:"Create Institution Message")}" /></title>
    <asset:stylesheet src="bootstrap-select.css" asset-defer="" />
    <asset:javascript src="bootstrap-select.js" asset-defer="" />
    <g:set var="disableEdit" value="${false}"/>
</head>

<body class="admin">
<cl:headerContent title="${message(code: 'default.new.label', args: [entityName])}" selectedNavItem="bvpadmin">
    <%
        def institution = (params.institution ?: 0) as int
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
                [link: (institution > 0 ? createLink(controller: 'institutionMessage', params: [institution: institution]) :
                        createLink(controller: 'institutionMessage')),
                    label: message(code: 'institutionMessage.list.label', default: 'Institution Messages')]

        ]
    %>
</cl:headerContent>
<div id="create-institution" class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <g:form action="save" class="form-horizontal">
                        <g:render template="form"/>
                        <div class="form-group">
                            <div class="col-md-offset-3 col-md-9">
                                <small id="includeContactHelp" class="form-text text-muted" style="margin-bottom: 2em;">Note: Creating this message does not send immediately to volunteers. Messages must be approved by DigiVol Administrators before messages are sent.</small><br />
                                <br />
                                <g:submitButton name="create" class="save btn btn-primary"
                                                value="${message(code: 'default.button.create.label', default: 'Create')}"/>
                            </div>
                        </div>
                    </g:form>
                </div>
            </div>
        </div>
    </div>
</div>

<asset:script type="text/javascript">
    $(document).ready(function() {
        const _params = new URLSearchParams(window.location.search);

        function initForm() {
            $('#recipient').prop('disabled', false);

        <g:if test="${params.projectId}">
            $('.institution').val(${institutionId});
            const recipientType = "${InstitutionMessage.RECIPIENT_TYPE_PROJECT}";
            $('.recipient-type').val(recipientType);
        </g:if>
        <g:else>
            if (getQueryStringParam('institution')) {
                $('.institution').val(getQueryStringParam('institution'));
            }

            const recipientType = "${institutionMessageInstance?.getRecipientType() ?: InstitutionMessage.RECIPIENT_TYPE_USER}";
        </g:else>

            console.log("Init recipient");
            getRecipientData(recipientType);
            $('#recipient').selectpicker();
        }

        function getQueryStringParam(key) {
            return _params.get(key);
        }

        initForm();

        $('.recipient-type').change(function() {
            console.log("recipient type change");
            $('#recipient').prop('disabled', false);
            getRecipientData(this.value);
        });

        $('.institution').change(function() {
            const recipientType = $('.recipient-type').val();
            $('#recipient option:selected').prop('selected', false)
                .val("");
            getRecipientData(recipientType);
        });

        function getRecipientData(recipientType) {
            $('.loading-recipient').removeClass('hidden');
            if (recipientType === 'user') {
                getUserList();
            } else if (recipientType === 'project') {
                getProjectList();
            } else {
                updateRecipient(recipientType, null);
            }
        }

        function updateRecipient(type, data) {
            const emptyOption = "<option value=''>- Select a recipient -</option>";
            let selectList = "";

            if (type === 'user') {
                // build user select
                const selectedValue = ${(institutionMessageInstance?.getRecipientUser()?.id ?: 0)};
                $.each(data, function(idx, u) {
                    let selectedAttr = "";
                    let disabledOption = "";
                    let optOutStr = "";

                    if (u.id === selectedValue) selectedAttr = " selected='selected'";
                    if (u.optOut) {
                        optOutStr = " (Opted Out)";
                        disabledOption = " disabled";
                    }
                    selectList += "<option value='" + u.id + "'" + selectedAttr + disabledOption + ">";
                    selectList += u.lastName + ", " + u.firstName + optOutStr;
                    selectList += "</option>";
                });

                $('#recipient').selectpicker('destroy');
                $('#recipient').empty()
                    .removeAttr("multiple")
                    .removeAttr("data-selected-text-format")
                    .removeAttr("data-count-selected-text")
                    .append(emptyOption + selectList);
                $('#recipient').selectpicker();

            } else if (type === 'project') {
                // build project select
                let selectedValues = "";
                if (getQueryStringParam('projectId')) {
                    selectedValues = getQueryStringParam('projectId');
                } else {
                    selectedValues = "${(institutionMessageInstance?.getRecipientProjectList()) ? institutionMessageInstance.getRecipientProjectList()*.id.join(",") : ""}";
                }

                console.log("Selected Value: " + selectedValues);
                $.each(data, function(idx, p) {
                    selectList += "<option value='" + p.id + "'>" + p.name + "</option>";
                });

                $('#recipient').selectpicker('destroy');
                $('#recipient').empty()
                    .attr("multiple", "true")
                    .append(emptyOption + selectList)

                // Set selected attributes
                $.each(selectedValues.split(","), function(idx, e) {
                     $("#recipient option[value='" + e + "']").prop("selected", true);
                });

                $('#recipient').selectpicker({
                    selectedTextFormat: 'count > 1',
                    countSelectedText: "{0} expeditions selected"
                });
            } else {
                $('#recipient').selectpicker('destroy');
                $('#recipient').empty()
                    .removeAttr("multiple")
                    .removeAttr("data-selected-text-format")
                    .removeAttr("data-count-selected-text")
                    .append("<option>- Institution; no recipient required -</option>");
                $('#recipient').attr("disabled", true);
                $('#recipient').selectpicker();
            }

            $('#recipient').selectpicker('refresh');
            $('.loading-recipient').addClass('hidden');
        }

        function getUserList() {
            const institutionId = $('.institution').val();
            const url = "${createLink(controller: 'institutionAdmin', action: 'getUsersForInstitution')}" + "/" + institutionId;
            $.get({
                url: url,
                dataType: 'json'
            }).done(function(data) {
                //console.log(data)
                updateRecipient('user', data);
            });
        }

        function getProjectList() {
            const institutionId = $('.institution').val();
            const url = "${createLink(controller: 'institutionAdmin', action: 'getActiveProjectsForInstitution')}" + "/" + institutionId;
            $.get({
                url: url,
                dataType: 'json'
            }).done(function(data) {
                //console.log(data)
                updateRecipient('project', data);
            });
        }
    });
</asset:script>

</body>
</html>
