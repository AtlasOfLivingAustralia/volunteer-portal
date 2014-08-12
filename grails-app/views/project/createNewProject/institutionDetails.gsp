<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    %{--<meta name="layout" content="ala-bootstrap"/>--}%
    <title>Create a new Expedition - Expedition sponsor</title>

    <r:script type="text/javascript">

        bvp.bindTooltips();
        bvp.suppressEnterSubmit();

        $(document).ready(function() {

            $("#btnNext").click(function(e) {
                e.preventDefault();
                bvp.submitWithWebflowEvent($(this));
            });

            setupAutocomplete($("#featuredOwner"), "${createLink(controller: 'project', action:'ajaxFeaturedOwnerList')}");

        });

        var institutions = <cl:json value="${institutions}" />;
        var nameToId = <cl:json value="${institutionsMap}" />;

        function onAutocompleteSelect(event, ui) {
            if (ui && ui.item && nameToId[ui.item.label]) {
                var ownerId = nameToId[ui.item.label];
                $('#featuredOwnerId').val(ownerId);
            } else {
                $('#featuredOwnerId').val('');
            }
        }

        function setupAutocomplete(jqElement, url) {
            var inputElement = $(jqElement);

            var autoCompleteOptions = {
                change: onAutocompleteSelect,
                disabled: false,
                minLength: 1,
                delay: 200,
                select: onAutocompleteSelect,
                source: institutions
            };
            inputElement.change(onAutocompleteSelect)
            inputElement.autocomplete(autoCompleteOptions);
        }


    </r:script>

    <style type="text/css">
    </style>

</head>
<body>

<cl:headerContent title="Create a new Expedition - Expedition sponsor" selectedNavItem="expeditions">
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
                <label class="control-label" for="featuredOwner">Expedition sponsor</label>
                <div class="controls">
                    <g:textField name="featuredOwner" value="${project.featuredOwner}" />
                    <cl:helpText>This may be the name of an institution, or a specific department or collection within an institution</cl:helpText>
                    <g:hiddenField name="featuredOwnerId" value="${project.featuredOwnerId}" />
                </div>
            </div>

            <div class="control-group">
                <div class="controls">
                    <g:link class="btn" event="cancel">Cancel</g:link>
                    <g:link class="btn" event="back"><i class="icon-chevron-left"></i>&nbsp;Back</g:link>
                    <button id="btnNext" event="continue" class="btn btn-primary">Next&nbsp;<i class="icon-chevron-right icon-white"></i></button>
                </div>
            </div>

        </div>
    </g:uploadForm>
</div>
</body>
</html>