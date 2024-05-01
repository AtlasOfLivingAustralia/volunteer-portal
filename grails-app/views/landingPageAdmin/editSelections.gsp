<%@ page import="au.org.ala.volunteer.LabelColour" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="digivol-landingPage"/>
    <title><g:message code="landingPageAdmin.label" default="Landing Page Configuration"/></title>
    <asset:stylesheet src="bootstrap-select.css" />
    <asset:javascript src="bootstrap-select.js" asset-defer="" />
</head>

<body class="admin">

<content tag="pageTitle">Additional Tags</content>

<g:form action="saveProjectLabels" class="form-horizontal" method="POST" >
    <g:hiddenField name="id" value="${landingPageInstance?.id}" />
    <g:hiddenField name="labelIds" value="${landingPageInstance.label*.toMap()?.id?.toString().replaceAll("\\[", "").replaceAll("\\]","")}" />

    <table class="table">
        <thead>

            <th><span>
                Select a Category filter for tags
                <g:select name="tagCategory" from="${labelCats}" class="selectpicker form-control" noSelection="${['all': '--- All Categories ---']}"/>
            </span></th>
            <th><span>
                Select Tag
                <g:select name="tag" from="${labels}" optionKey="id" class="selectpicker form-control"
                          optionValue="value" data-live-search="true"/></span></th>
            <th/>

            <th><g:actionSubmit class="save btn btn-primary" action="saveProjectLabels"
                            value="${message(code: 'default.button.save.label', default: 'Add Tag')}"/></th>
        </thead>

    </table>

    <div id="labels">
        <b>Selected tags:</b><br/>
        <g:each in="${landingPageInstance.label}" var="l">
            <g:set var="labelClassName" value="${l.category.labelColour ?: 'base'}"/>
            <span class="label label-${labelClassName}"> ${l.category.name}/${l.value} <i class="fa fa-times-circle delete-label" data-label-id="${l.id}"></i> </span>
        </g:each>
    </div>
</g:form>

<asset:script type="text/javascript" asset-defer="">
    $(function() {
        $("#tagCategory").change(function() {
            var selectedCategory = $(this).children("option:selected").val();
             $.ajax({
                type: 'GET',
                dataType: 'json',
                cache: false,
                url: '${createLink(controller: "landingPageAdmin", action: "filterLabelCategory")}?category=' + selectedCategory,
                //url: '/landingPageAdmin/filterLabelCategory?category=' + selectedCategory,
                success: function (data) {

                   if (data) {
                       $('#tag option').remove();
                       for (var o in data) {
                            if (data[o].value !== undefined) {
                                $('#tag').append('<option value="' + data[o].id + '">' + ("" + data[o].value) + '</option>');
                            }
                        }
                       $('#tag').selectpicker('refresh');
                   }

                },
                error: function (jqXHR, textStatus, errorThrown) {
                    console.log('landingPageAdmin/filterLabelCategory: Error - ' + errorThrown);
                }
            });
        });

        function onDeleteLabelClick (e) {
            e.preventDefault();
            var landingPageId = $('#id').val();
            var labelIdToRemove = e.target.dataset.labelId

            $.ajax({
                type: 'POST',
                dataType: 'json',
                cache: false,
                url: '${createLink(controller: "landingPageAdmin", action: "deleteLabel")}?selectedLabelId=' + labelIdToRemove + '&landingPageId=' + landingPageId,
                //url: '/landingPageAdmin/deleteLabel?selectedLabelId=' + labelIdToRemove + '&landingPageId=' + landingPageId,
                success: function (data) {
                    var t = $(e.target);
                    var p = t.parent("span");
                    p.remove();
                },  error: function (jqXHR, textStatus, errorThrown) {
                    console.log('landingPageAdmin/deleteLabel: Error - ' + errorThrown);
                }
            });
        }

        $('#labels').on('click', 'i.delete-label', onDeleteLabelClick);
    });

</asset:script>

</body>
</html>
