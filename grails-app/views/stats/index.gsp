<<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
    <head>
        <title>Volunteer Portal - Atlas of Living Australia</title>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <script type="text/javascript" src="https://www.google.com/jsapi"></script>

        <r:script type="text/javascript">
            // Load the Visualization API and the piechart package.
            google.load('visualization', '1.0', {'packages': ['corechart']});

            $(document).ready(function (e) {

                $("a[data-toggle='tab']").on("shown", function(e) {
                    var target = $(e.target).attr('href');
                    if (target == '#transcriptionsByMonth') {
                        transcriptionsByMonth();
                    } else if (target == '#validationsByMonth') {
                        validationsByMonth();
                    }
                });

                $("a[href='#transcriptionsByMonth']").tab('show');
            });

            function transcriptionsByMonth() {
                $.ajax("${createLink(controller:'ajax', action:'statsTranscriptionsByMonth')}").done(function (data) {
                    // Create the data table.
                    var table = new google.visualization.DataTable();
                    table.addColumn('string', 'Month');
                    table.addColumn('number', 'Transcriptions');
                    for (key in data) {
                        var value = data[key]
                        table.addRow([value.month, value.count])
                    }

                    // Set chart options
                    var options = {
                        'title': 'Transcriptions by month',
                        backgroundColor: '#F5F2E3',
                        vAxis: {title: "Transcriptions"},
                        hAxis: {title: "Month"}
                    };

                    // Instantiate and draw our chart, passing in some options.
                    var chart = new google.visualization.ColumnChart(document.getElementById('transcriptionsByMonth')).draw(table, options);
                });
            }

            function validationsByMonth() {
                $.ajax("${createLink(controller:'ajax', action:'statsValidationsByMonth')}").done(function (data) {
                    // Create the data table.
                    var table = new google.visualization.DataTable();
                    table.addColumn('string', 'Month');
                    table.addColumn('number', 'Validations');
                    for (key in data) {
                        var value = data[key]
                        table.addRow([value.month, value.count])
                    }

                    // Set chart options
                    var options = {
                        'title': 'Validations by month',
                        backgroundColor: '#F5F2E3',
                        vAxis: {title: "Validations"},
                        hAxis: {title: "Month"}
                    };

                    // Instantiate and draw our chart, passing in some options.
                    var chart = new google.visualization.ColumnChart(document.getElementById('validationsByMonth')).draw(table, options);
                });
            }



        </r:script>
    </head>

    <body>

        <sitemesh:parameter name="useFluidLayout" value="${true}" />

        <cl:headerContent title="Statistics">
            <%
                pageScope.crumbs = [
                    [link: createLink(controller: 'admin', action: 'index'), label: "Administration"]
                ]
            %>
        </cl:headerContent>

        <div class="row-fluid">
            <div class="span12">
                <div class="tabbable">
                    <ul class="nav nav-tabs">
                        <li>
                            <a href="#transcriptionsByMonth" data-toggle="tab" >Transcriptions by month</a>
                        </li>
                        <li>
                            <a href="#validationsByMonth" data-toggle="tab" >Validations by month</a>
                        </li>
                    </ul>
                    <div class="tab-content">
                        <div class="tab-pane" id="transcriptionsByMonth" style="margin-right: 15px">
                        </div>
                        <div class="tab-pane" id="validationsByMonth" style="margin-right: 15px">
                        </div>

                    </div>
                </div>
            </div>
        </div>
    </body>
</html>