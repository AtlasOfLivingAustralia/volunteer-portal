<%@ page import="au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}" />

<div class="container-fluid">
    <div class="row-fluid">
        <div class="span12">
            <div>
                <g:set var="multimedia" value="${taskInstance.multimedia.first()}" />
                <g:imageViewer multimedia="${multimedia}" />
            </div>
        </div>
    </div>

    <H1>Work in progress - do not use!</H1>

    <div class="well well-small transcribeSection">
        <div class="row-fluid" style="margin-top: 10px">

            <div class="span12">
                <table style="width:100%" id="dataGrid"></table>
            </div>
        </div>

    </div>

</div>

<r:script>

    $(document).ready(function() {

        $(".tutorialLinks a").each(function(index, element) {
            $(this).addClass("btn").attr("target", "tutorialWindow");
        });

    });

</r:script>