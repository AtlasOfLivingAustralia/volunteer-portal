<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title>Create a new Expedition - Extra Settings</title>
    <r:require module="labelAutocomplete"/>
    <r:script type="text/javascript">

    $(document).ready(function () {
      bvp.bindTooltips();
      bvp.suppressEnterSubmit();

      $("#btnNext").click(function (e) {
        e.preventDefault();
        bvp.submitWithWebflowEvent($(this));
      });

    });

    jQuery(function($) {
      var labelColourMap = <cl:json value="${labelColourMap}"/>;
      labelAutocomplete("#label", "${createLink(controller: 'project', action: 'newLabels')}", '', function(item) {
                var obj = JSON.parse(item);
                var labelsElem = $('#labels');
                $( "<span>" )
                  .addClass("label")
                  .addClass(labelColourMap[obj.category])
                  .attr("title", obj.category)
                  .text(obj.value)
                  .append(
                  $( "<i>" )
                    .attr("data-label-id", obj.id)
                    .addClass("icon-remove")
                    .addClass("icon-white")
                  )
                  .appendTo(
                    labelsElem
                  );

                  $("<input>")
                    .attr("type", "hidden")
                    .attr("id", "hidden-label-" + obj.id)
                    .attr('name', "labelId[]")
                    .attr("value", obj.id)
                    .appendTo(
                      labelsElem
                    );
                return null;
            });

            function onDeleteClick(e) {
                var id = $(e.target).data('labelId');
                var t = $(e.target);
                var p = t.parent("span");
                        p.remove();
                $('#labels').find('#hidden-label-' + id).remove();

            }

            $('#labels').on('click', 'span.label i.icon-remove', onDeleteClick);

    });

    </r:script>

    <style type="text/css">
    </style>
</head>

<body class="content">

<cl:headerContent title="Create a new Expedition - Details" selectedNavItem="expeditions">
    <%
        pageScope.crumbs = [
        ]
    %>
</cl:headerContent>

<g:if test="${errorMessages}">
    <div class="alert alert-danger">
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
    <g:form>
        <div class="form-horizontal">

            <div class="control-group">
                <label class="control-label" for="picklistId"><g:message code="project.picklistInstitutionCode.label"
                                                                         default="Picklist Collection Code"/></label>

                <div class="controls">
                    <g:select name="picklistId" from="${picklists}" value="${project.picklistId}"/>
                    <cl:helpText>Select the picklist to use for this expedition.  A picklist with a specific 'Collection Code' must be loaded first</cl:helpText>
                </div>
            </div>

            <div class="control-group">
                <label class="control-label" for="label">Tags</label>

                <div class="controls">
                    <div id="labels">
                        <g:each in="${labels}" var="l">
                            <span class="label ${labelColourMap[l.category]}" title="${l.category}">${l.value} <i
                                    class="icon-remove icon-white" data-label-id="${l.id}"></i></span>
                            <input type="hidden" id="hidden-label-${l.id}" name="labelId[]" value="${l.id}"/>
                        </g:each>
                    </div>
                </div>

                <div class="controls">
                    <input autocomplete="off" type="text" id="label" class="input-small"/>
                    <cl:helpText>Select all appropriate tags for the expedition.</cl:helpText>
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
    </g:form>
</div>

</body>
</html>
