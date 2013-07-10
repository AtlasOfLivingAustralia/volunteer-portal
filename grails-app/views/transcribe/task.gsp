<%@ page import="au.org.ala.volunteer.Template; au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Picklist" %>
<%@ page import="au.org.ala.volunteer.PicklistItem" %>
<%@ page import="au.org.ala.volunteer.TemplateField" %>
<%@ page import="au.org.ala.volunteer.field.*" %>
<%@ page import="au.org.ala.volunteer.FieldCategory" %>
<%@ page import="au.org.ala.volunteer.DarwinCoreField" %>
<%@ page contentType="text/html; UTF-8" %>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<meta name="layout" content="${grailsApplication.config.ala.skin}"/>
<meta name="viewport" content="initial-scale=1.0, user-scalable=no"/>
<title>${(validator) ? 'Validate' : 'Transcribe'} Task ${taskInstance?.id} : ${taskInstance?.project?.name}</title>
%{--<script type="text/javascript" src="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.pack.js')}"></script>--}%
%{--<link rel="stylesheet" href="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.css')}"/>--}%
<link rel="stylesheet" href="${resource(dir: 'css', file: 'validationEngine.jquery.css')}"/>
%{--<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.validationEngine.js')}"></script>--}%
%{--<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.validationEngine-en.js')}"></script>--}%
<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.qtip-1.0.0-rc3.min.js')}"></script>
<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.cookie.js')}"></script>
<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=true"></script>
<script type="text/javascript" src="${resource(dir: 'js', file: 'gmaps.js')}"></script>
<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.jqzoom-core.js')}"></script>
<link rel="stylesheet" href="${resource(dir: 'css', file: 'jquery.jqzoom.css')}"/>
<r:require module="bootstrap-js" />
%{--<script type="text/javascript" src="${resource(dir: 'js', file: 'specimenTranscribe.js')}"></script>--}%

<r:require module="panZoom" />

<script type="text/javascript">

    // global Object
    var VP_CONF = {
        taskId: "${taskInstance?.id}",
        picklistAutocompleteUrl: "${createLink(action:'autocomplete', controller:'picklistItem')}",
        updatePicklistUrl: "${createLink(controller:'picklistItem', action:'updateLocality')}",
        nextTaskUrl: "${createLink(controller:(validator) ? "validate" : "transcribe", action:'showNextFromProject', id:taskInstance?.project?.id)}",
        isReadonly: "${isReadonly}",
        isValid: ${(taskInstance?.isValid) ? "true" : "false"}
    };

    $(document).ready(function () {

        $(window).scroll(function (e) {
            if ($("#floatingImage").is(":visible")) {
                var parent = $("#floatingImage").parents('.ui-dialog');
                var position = parent.position();
                var top = position.top - $(window).scrollTop();
                if (top < 0) {
                    $("#floatingImage").dialog("option", "position", [position.left, 10]);
                } else if (top + parent.height() > $(window).height()) {
                    $("#floatingImage").dialog("option", "position", [position.left, $(window).scrollTop() + $(window).height() - (parent.height() + 20) ]);
                }
            }
        });

        $("#pinImage").click(function (e) {
            e.preventDefault();
            if ($(".pan-image").css("position") == 'fixed') {
                $(".pan-image").css({"position": "relative", top: 'inherit', left: 'inherit', 'border': 'none' });
                $(".new-window-control").css({'background-image': "url(${resource(dir:'images', file:'pin-image.png')})"});
                $(".pan-image a").attr("title", "Fix the image in place in the browser window");
            } else {
                $(".pan-image").css({"position": "fixed", top: 10, left: 10, "z-index": 600, 'border': '2px solid #535353' });
                $(".new-window-control").css("background-image", "url(${resource(dir:'images', file:'unpin-image.png')})");
                $("#imageContainer").css("background", "darkgray");
                $(".pan-image a").attr("title", "Return the image to its normal position");
            }

        });

        $(".insert-symbol-button").each(function (index) {
            $(this).html($(this).attr("symbol"));
        });

        $(".insert-symbol-button").click(function (e) {
            e.preventDefault();
            var input = $("#recordValues\\.0\\.occurrenceRemarks");
            $(input).insertAtCaret($(this).attr('symbol'));
            $(input).focus();
        });

        // display previous journal page in new window
        $("#showImageButton").click(function (e) {
            e.preventDefault();
            var uri = "${createLink(controller: 'task', action:'showImage', id: taskInstance.id)}"
            newwindow = window.open(uri, 'journalWindow', 'directories=no,titlebar=no,toolbar=no,location=no,status=no,menubar=no,height=600,width=1000');
            if (window.focus) {
                newwindow.focus()
            }
        });


        $(".closeSection").click(function (e) {
            e.preventDefault();
            var body = $(this).closest("table").find('tbody');
            if (body.css('display') == 'none') {
                body.css('display', 'block');
                $(this).text("Shrink")
            } else {
                body.css('display', 'none');
                $(this).text("Expand")
            }
        });

    });

    function disableSection(classSelector) {
        $(classSelector + " :input").attr("disabled", "true");
        $(classSelector).css("opacity", "0.5");
    }

    function enableSection(classSelector) {
        $(classSelector + " :input").removeAttr("disabled");
        $(classSelector).css("opacity", "1");
    }

    function setFieldValue(fieldName, value) {
        var id = "recordValues\\.0\\." + fieldName;
        $("#" + id).val(value);
    }

    function getFieldValue(fieldName) {
        var id = "recordValues\\.0\\." + fieldName;
        return $("#" + id).val();
    }

    function showModal(options) {

        var opts = {
            url: options.url ? options.url : false,
            id: options.id ? options.id : 'modal_element_id',
            height: options.height ? options.height : 500,
            width: options.width ? options.width : 600,
            title: options.title ? options.title : 'Modal Title',
            hideHeader: options.hideHeader ? options.hideHeader : false,
            onClose: options.onClose ? options.onClose : null
        }

        var html = "<div id='" + opts.id + "' class='modal hide fade' role='dialog' aria-labelledby='modal_label_" + opts.id + "' aria-hidden='true' style='height: " + opts.height + "px;width: " + opts.width + "px; overflow: hidden'>";
        if (!opts.hideHeader) {
            html += "<div class='modal-header'><button type='button' class='close' data-dismiss='modal' aria-hidden='true'>x</button><h3 id='modal_label_" + opts.id + "'>" + opts.title + "</h3></div>";
        }
        html += "<div class='modal-body' style='max-height: " + opts.height + "px'>Loading...</div></div>";

        $("body").append(html);

        var selector = "#" + opts.id;

        $(selector).on("hidden", function() {
            $(selector).remove();
            if (opts.onClose) {
                opts.onClose();
            }
        });

        $(selector).modal({
            remote: opts.url
        });
    }

    function hideModal() {
        $("#modal_element_id").modal('hide');
    }


</script>

<style type="text/css">

.insert-symbol-button {
    font-family: courier;
    color: #DDDDDD;
    background: #4075C2;
    -moz-border-radius: 4px;
    -webkit-border-radius: 4px;
    -o-border-radius: 4px;
    -icab-border-radius: 4px;
    -khtml-border-radius: 4px;
    border-radius: 4px;
}

.insert-symbol-button:hover {
    background: #0046AD;
    color: #DDDDDD;
}


#collectionEventFields table tr.columnLayout {
    width: 450px;
    min-height: 34px;
    float: left;
}

.imageviewer-controls {
    position: absolute;
    top: 330px;
    left: 10px;
    background: url(${resource(dir:'/images', file:'map-control.png')}) no-repeat;
    height: 63px;
    width: 100px;
    opacity: 0.9;
}

.imageviewer-controls a {
    height: 18px;
    width: 18px;
    display: block;
    text-indent: -999em;
    position: absolute;
    outline: none;
}

.imageviewer-controls a:hover {
    background: #535353;
    opacity: 0.4;
    filter: alpha(opacity=40);
}

.imageviewer-controls a.left {
    left: 39px;
    top: 22px;
}

.imageviewer-controls a.right {
    left: 79px;
    top: 22px;
}

.imageviewer-controls a.up {
    left: 59px;
    top: 2px;
}

.imageviewer-controls a.down {
    left: 59px;
    top: 42px;
}

.imageviewer-controls a.zoom {
    left: 2px;
    top: 8px;
    height: 21px;
    width: 21px;
}

.imageviewer-controls a.back {
    left: 2px;
    top: 31px;
    height: 21px;
    width: 21px;
}

.pin-image-control {
    position: absolute;
    top: 370px;
    right: 7px;
    background: url(${resource(dir:'images', file:'pin-image.png')}) no-repeat;
    height: 24px;
    width: 24px;
    opacity: 0.9;
}

.pin-image-control a {
    height: 24px;
    width: 24px;
    display: block;
    text-indent: -999em;
    position: absolute;
    outline: none;
}

.pin-image-control a:hover {
    background: #535353;
    opacity: 0.4;
    filter: alpha(opacity=40);
}

#taskMetadata h3 {
    margin-bottom: 0;
    margin-top: 0;
}

#taskMetadata ul {
    margin:0;
    padding:0;
}

#taskMetadata ul li {
    list-style: none;
    margin:0;
    padding:0;
}

#taskMetadata .metaDataLabel {
    font-weight: bold;
}

</style>
</head>

<body>

    <cl:headerContent title="${(validator) ? 'Validate' : 'Transcribe'} Task: ${taskInstance?.project?.name} (ID: ${taskInstance?.externalIdentifier})">
        <%
            pageScope.crumbs = [
                [link: createLink(controller: 'project', action: 'list'), label: message(code: 'default.expeditions.label', default: 'Expeditions')],
                [link: createLink(controller: 'project', action: 'show'), label: taskInstance?.project.featuredLabel]
            ]
        %>

        <div>
            <vpf:taskTopicButton task="${taskInstance}"/>
            <g:if test="${taskInstance?.project?.tutorialLinks}">
                ${taskInstance.project.tutorialLinks}
            </g:if>
        </div>
    </cl:headerContent>

    <div class="row">
        <div class="span12">
            <g:hasErrors bean="${taskInstance}">
                <div class="errors">
                    There was a problem saving your edit: <g:renderErrors bean="${taskInstance}" as="list"/>
                </div>
            </g:hasErrors>
        </div>
    </div>
    <g:if test="${taskInstance}">
        <g:form class="transcribeForm">
            <g:hiddenField name="recordId" value="${taskInstance?.id}"/>
            <g:hiddenField name="redirect" value="${params.redirect}"/>

            <g:render template="/transcribe/${template.viewName}" model="${[taskInstance: taskInstance, recordValues: recordValues, isReadonly: isReadonly, template: template, nextTask: nextTask, prevTask: prevTask, sequenceNumber: sequenceNumber, imageMetaData: imageMetaData]}" />

        </g:form>
    </g:if>
    <g:else>
        <div class="row">
            <div class="span12">
                <div class="alert">
                    No tasks loaded for this project !
                </div>
            </div>
        </div>
    </g:else>
    <cl:timeoutPopup/>
    <div id="floatingImage" style="display:none"></div>
</body>
</html>
