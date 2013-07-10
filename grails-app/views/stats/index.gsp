<<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
    <head>
        <title>Volunteer Portal - Atlas of Living Australia</title>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <script type="text/javascript" src="https://www.google.com/jsapi"></script>

        <script type="text/javascript">
            // Load the Visualization API and the piechart package.
            google.load('visualization', '1.0', {'packages': ['corechart']});

            $(document).ready(function (e) {

                $("#btnTranscriptionsByMonth").click(function (e) {
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
                        var chart = new google.visualization.ColumnChart(document.getElementById('chart_div')).draw(table, options);

                    })

                });
            });

        </script>
    </head>

    <body>

        <sitemesh:parameter name="useFluidLayout" value="${true}" />

        <cl:headerContent title="Volunteer Portal Statistics">
            <%
                pageScope.crumbs = [
                    [link: createLink(controller: 'admin', action: 'index'), label: "Administration"]
                ]
            %>
        </cl:headerContent>

        <div class="row-fluid">
            <div class="span2">
                <ul class="nav nav-tabs nav-stacked">
                    <li>
                        <a href="#" id="btnTranscriptionsByMonth">Transcriptions by month</a>
                    </li>
                </ul>
            </div>
            <div class="span10">
                <div id="chart_div" style="margin-top: 10px;"></div>
            </div>
        </div>
    </body>
</html>