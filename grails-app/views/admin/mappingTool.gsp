<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="au.org.ala.volunteer.Project" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="admin.mappingtool.label" default="Administration - Mapping tool"/></title>
    <cl:googleMapsScript callback="onGmapsReady"/>
</head>

<body class="admin">

<cl:headerContent title="${message(code: 'default.tools.label', default: 'Mapping tool')}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
                [link: createLink(controller: 'admin', action: 'tools'), label: message(code: 'default.tools.label', default: 'Tools')]
        ]
    %>
</cl:headerContent>
<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <h4><g:message code="admin.mapping_tool.description" /></h4>
                    <hr/>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <div class="well well-small" id="mappingToolContent">
                        <g:render template="/transcribe/geolocationTool" />
                    </div>
                </div>

                <div class="col-md-12 form-horizontal">
                    <table class="table">
                        <tr>
                            <td><g:message code="admin.mapping_tool.locality" /></td>
                            <td><g:message code="admin.mapping_tool.state" /></td>
                            <td><g:message code="admin.mapping_tool.country" /></td>
                            <td><g:message code="admin.mapping_tool.latitude" /></td>
                            <td><g:message code="admin.mapping_tool.longitude" /></td>
                        </tr>
                        <tr>
                            <td>
                                <span class="geocoded-value" id="gc_locality"></span>
                            </td>
                            <td>
                                <span class="geocoded-value" id="gc_state"></span>
                            </td>
                            <td>
                                <span class="geocoded-value" id="gc_country"></span>
                            </td>
                            <td>
                                <span class="geocoded-value" id="gc_latitude"></span>
                            </td>
                            <td>
                                <span class="geocoded-value" id="gc_longitude"></span>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <button class="btn btn-default" id="btnToggleFullData"><g:message code="admin.mapping_tool.toggle_geolocate_data" /></button>

            <div class="row">
                <div class="col-md-12 form-horizontal" style="display: none" id="allDataDiv">
                    <pre>
                        <code id="geocodeAllData" class="prettyprint"></code>
                    </pre>
                </div>
            </div>
        </div>
    </div>
</div>


<asset:script type='text/javascript'>

    $(function() {
        $("#btnToggleFullData").click(function(e) {
            e.preventDefault();
            $("#allDataDiv").toggle();
        });
    });

    var geocodeCallback = function(results) {

        // clear all values
        $(".geocoded-value").html("");

        if (!results) {
            return;
        }

        var locationObj = results.address_components;

        // $('#infoLat').html() && $('#infoLng').html()
        $("#gc_latitude").html($('#infoLat').html());
        $("#gc_longitude").html($('#infoLng').html());

        for (var i = 0; i < locationObj.length; i++) {
            var name = locationObj[i].long_name;
            var type = locationObj[i].types[0];
            // go through each avail option
            if (type == 'country') {
                $('#gc_country').html(name);
            } else if (type == 'locality') {
                $("#gc_locality").html(name);
            } else if (type == 'administrative_area_level_1') {
                $('#gc_state').html(name);
            }
        }

        if (JSON) {
            var allData = JSON.stringify(results, null, 4);
            $("#geocodeAllData").html(allData);
        }

    }

</asset:script>
</body>
</html>
