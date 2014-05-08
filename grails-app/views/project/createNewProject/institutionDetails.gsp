<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title>Create a new Expedition - Sponsor details</title>

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

        function setupAutocomplete(jqElement, url) {
            var inputElement = $(jqElement);

            var autoCompleteOptions = {
                disabled: false,
                minLength: 1,
                delay: 200,
                select: function(event, ui) {
                },
                source: function(request, response) {
                    var query = url + "&q=" + encodeURIComponent($(jqElement).val());
                    $.ajax(query).done(function(data) {
                        if (response) {
                            response(data);
                        }
                    });
                }
            };
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
                <label class="control-label" for="featuredOwner">Expedition Owner/Sponsor</label>
                <div class="controls">
                    <g:textField name="featuredOwner" value="${project.featuredOwner}" />
                    <cl:helpText>This may be an institution name, or a specific department or collection with an institution.</cl:helpText>
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