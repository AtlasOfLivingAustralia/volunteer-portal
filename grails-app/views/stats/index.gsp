<<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <title><g:message code="default.application.name"/> - Atlas of Living Australia</title>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <gvisualization:apiImport/>

    <r:script type="text/javascript">
            // Load the Visualization API and the piechart package.
            google.load('visualization', '1.0', {'packages': ['corechart']});

            $(document).ready(function (e) {

                $("a[data-toggle='tab']").on("shown.bs.tab", function(e) {
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
                $.ajax("${createLink(controller: 'ajax', action: 'statsTranscriptionsByMonth')}").done(function (data) {
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
                        hAxis: {title: "Month"},
                        height: 400
                    };

                    // Instantiate and draw our chart, passing in some options.
                    var chart = new google.visualization.ColumnChart(document.getElementById('transcriptionsByMonth')).draw(table, options);
                });
            }

            function validationsByMonth() {
                $.ajax("${createLink(controller: 'ajax', action: 'statsValidationsByMonth')}").done(function (data) {
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
                        hAxis: {title: "Month"},
                        height: 400
                    };

                    // Instantiate and draw our chart, passing in some options.
                    var chart = new google.visualization.ColumnChart(document.getElementById('validationsByMonth')).draw(table, options);
                });
            }

    </r:script>
</head>

<body class="admin">


<cl:headerContent title="Statistics" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin', action: 'index'), label: "Administration"]
        ]
    %>
</cl:headerContent>

<div class="row">
    <div class="col-md-12">
        <div class="container">
            <ul class="nav nav-tabs">
                <li>
                    <a href="#transcriptionsByMonth" data-toggle="tab">Transcriptions by month</a>
                </li>
                <li>
                    <a href="#validationsByMonth" data-toggle="tab">Validations by month</a>
                </li>
            </ul>
        </div>
        <div class="tab-content-bg">
            <!-- Tab panes -->
            <div class="container">
                <div class="tab-content">
                    <div class="tab-pane" id="transcriptionsByMonth">
                        <p><strong><i class="fa fa-cog fa-spin fa-2x"></i> Loading ...</strong></p>
                    </div>

                    <div class="tab-pane" id="validationsByMonth">
                        <p><strong><i class="fa fa-cog fa-spin fa-2x"></i> Loading ...</strong></p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

</body>
</html>