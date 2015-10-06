<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title>Create a new Expedition - Expedition institution</title>

    <r:require module="institution-dropdown"/>
    <r:script type="text/javascript">
        var institutions = <cl:json value="${institutions}"/>;
        var nameToId = <cl:json value="${institutionsMap}"/>;
        var baseUrl = "${createLink(controller: 'institution', action: 'index')}";

        bvp.bindTooltips();
        bvp.suppressEnterSubmit();

        $(document).ready(function() {

            $("#btnNext").click(function(e) {
                e.preventDefault();
                bvp.submitWithWebflowEvent($(this));
            });

            setupInstitutionAutocomplete("#featuredOwner", "#featuredOwnerId", "#institution-link-icon", "#institution-link", institutions, nameToId, baseUrl);
        });

    </r:script>

    <style type="text/css">
    </style>

</head>

<body>

<cl:headerContent title="Create a new Expedition - Expedition institution" selectedNavItem="expeditions">
    <% pageScope.crumbs = [] %>
</cl:headerContent>

<g:if test="${errorMessages}">
    <div class="alert alert-error">
        Please correct the following before proceeding:
        <ul>
            <g:each in="${errorMessages}" var="errorMessage">
                <li>
                    ${errorMessage}
                </li>
            </g:each>
        </ul>
    </div>
</g:if>


<div class="well well-small">
    <g:uploadForm name="detailsForm">
        <div class="form-horizontal">
            <div class="control-group">
                <label class="control-label" for="featuredOwner">Expedition institution</label>

                <div class="controls">
                    <g:textField name="featuredOwner" value="${project.featuredOwner}"/>
                    <cl:helpText>This may be the name of an institution, or a specific department or collection within an institution</cl:helpText>
                    <g:hiddenField name="featuredOwnerId" value="${project.featuredOwnerId}"/>
                    <span id="institution-link-icon" class="hidden muted"><small><i class="icon-ok"></i> Linked to <a
                            id="institution-link" href="">institution!</a></small></span>
                </div>
            </div>

            <div class="control-group">
                <div class="controls">
                    <g:link class="btn" event="cancel">Cancel</g:link>
                    <g:link class="btn" event="back"><i class="icon-chevron-left"></i>&nbsp;Back</g:link>
                    <button id="btnNext" event="continue" class="btn btn-primary">Next&nbsp;<i
                            class="icon-chevron-right icon-white"></i></button>
                </div>
            </div>

        </div>
    </g:uploadForm>
</div>
</body>
</html>