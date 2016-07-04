<<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <title><g:message code="default.application.name"/> - Atlas of Living Australia</title>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <gvisualization:apiImport/>
</head>

<body class="admin" data-ng-app="statApp">


<cl:headerContent title="Statistics" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin', action: 'index'), label: "Administration"]
        ]
    %>
</cl:headerContent>

<div ng-controller="statsCtrl">
    <div class="row">
        <div class="col-md-12">
            <uib-tabset active="active">
                <uib-tab heading="Reports By Date">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="form-group">
                                <label for="fromDate">From</label>
                                <input type="date" uib-datepicker-popup id="fromDate" name="fromDate" ng-model="startDate">
                                <label for="toDate">to</label>
                                <input type="date" uib-datepicker-popup id="toDate" name="toDate" ng-model="endDate">
                                <button class="search btn btn-primary" ng-click="setDateRange()">Search</button>
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-4">
                            <div class="panel panel-default">
                                <div class="panel-heading"><h4>DigiVol Volunteers</h4></div>
                                <div class="panel-body">
                                    <h4>New Volunteers: {{newVolunteers}}</h4>
                                    <h4>Total Volunteers: {{totalVolunteers}}</h4>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="panel panel-default">
                                <div class="panel-heading"><h4>Historical Honourboard</h4></div>
                                <div class="panel-body">
                                    <span data-ng-if="loading"><cl:spinner/></span>
                                    <span data-ng-if="!loading">
                                        <div tablechart data="getHistoricalHonourBoard()" title="" width="100%" height="100%" searchdate="{{searchDate}}"></div>
                                        <button type="button" class="btn btn-default btn-sm" ng-click="exportToExcel(historicalHonourBoard, 'historicalHonourBoard')">
                                            <span class="glyphicon glyphicon-download-alt"></span> Download
                                        </button>

                                    </span>
                                </div>
                            </div>
                        </div>

                        <div class="col-md-4">
                            <div class="panel panel-default">
                                <div class="panel-heading"><h4>Active Transcribers</h4></div>
                                <div class="panel-body">
                                    <div tablechart data="getActiveTranscribers()" title="" width="100%" height="100%" searchdate="{{searchDate}}"></div>
                                    <button type="button" class="btn btn-default btn-sm" ng-click="exportToExcel(activeTranscribers, 'activeTranscribers')">
                                        <span class="glyphicon glyphicon-download-alt"></span> Download
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default">
                                <div class="panel-heading"><h4>Transcriptions By Day</h4></div>
                                <div class="panel-body">
                                    <div barchart data="getTranscriptionsByDay()" title="" width="100%" height="350" yaxis="Transcriptions count"
                                         xaxis="Day" searchdate="{{searchDate}}"></div>
                                    <button type="button" class="btn btn-default btn-sm" ng-click="exportToExcel(transcriptionsByDay, 'transcriptionsByDay')">
                                        <span class="glyphicon glyphicon-download-alt"></span> Download
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default">
                                <div class="panel-heading"><h4>Validations By Day</h4></div>
                                <div class="panel-body">
                                    <div barchart data="getValidationsByDay()" title="" width="100%" height="350" yaxis="Validations count"
                                         xaxis="Day" searchdate="{{searchDate}}"></div>
                                    <button type="button" class="btn btn-default btn-sm" ng-click="exportToExcel(validationsByDay, 'validationsByDay')">
                                        <span class="glyphicon glyphicon-download-alt"></span> Download
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default">
                                <div class="panel-heading"><h4>Transcriptions By Volunteer And Project</h4></div>
                                <div class="panel-body">
                                    <div tablechart data="getTranscriptionsByVolunteerAndProject()" title="" width="100%" height="100%" searchdate="{{searchDate}}"></div>
                                    <button type="button" class="btn btn-default btn-sm" ng-click="exportToExcel(transcriptionsByVolunteerAndProject, 'transcriptionsByVolunteerAndProject')">
                                        <span class="glyphicon glyphicon-download-alt"></span> Download
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default">
                                <div class="panel-heading"><h4>Hourly Contributions</h4></div>
                                <div class="panel-body">
                                    <div linechart data="getHourlyContributions()" title="" width="100%" height="350" xaxis="Hour"
                                         yaxis="Contributions" searchdate="{{searchDate}}"></div>
                                    <button type="button" class="btn btn-default btn-sm" ng-click="exportToExcel(hourlyContributions, 'hourlyContributions')">
                                        <span class="glyphicon glyphicon-download-alt"></span> Download
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </uib-tab>
                <uib-tab heading="Reports by Month">

                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default">
                                <div class="panel-heading"><h4>Transcriptions By Month</h4></div>
                                <div class="panel-body">
                                    <div class="tab-pane" id="transcriptionsByMonth">
                                        <p><strong><i class="fa fa-cog fa-spin fa-2x"></i> Loading ...</strong></p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default">
                                <div class="panel-heading"><h4>Validations By Month</h4></div>
                                <div class="panel-body">
                                    <div class="tab-pane" id="validationsByMonth">
                                        <p><strong><i class="fa fa-cog fa-spin fa-2x"></i> Loading ...</strong></p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </uib-tab>
                <uib-tab heading="Reports by Institution">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default">
                                <div class="panel-heading"><h4>Transcriptions By Institution</h4></div>
                                <div class="panel-body">
                                    <div tablechart data="getTranscriptionsByInstitution()" title="" width="100%" height="100%" xaxis="Institution"
                                         yaxis="Number of Transcriptions"></div>
                                    <button type="button" class="btn btn-default btn-sm" ng-click="exportToExcel(transcriptionsByInstitution, 'transcriptionsByInstitution')">
                                        <span class="glyphicon glyphicon-download-alt"></span> Download
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default">
                                <div class="panel-heading"><h4>Validations By Institution</h4></div>
                                <div class="panel-body">
                                    <div tablechart data="getValidationsByInstitution()" title="" width="100%" height="100%" xaxis="Institution"
                                         yaxis="Number of Validations"></div>
                                    <button type="button" class="btn btn-default btn-sm" ng-click="exportToExcel(validationsByInstitution, 'validationsByInstitution')">
                                        <span class="glyphicon glyphicon-download-alt"></span> Download
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </uib-tab>
            </uib-tabset>
        </div>
    </div>
</div>
<asset:javascript src="livestamp" asset-defer=""/>
%{-- language="javascript" --}%
<asset:script type="text/javascript">
    %{-- language="javascript" --}%
    // language="javascript"
    // Load the Visualization API and the piechart package.
    google.load('visualization', '1.0', {'packages': ['corechart']});
    google.load('visualization', '1.0', {'packages': ['table']});
    google.load('visualization', '1.0', {'packages':['bar']});

     $(document).ready(function (e) {

            %{--var target = $(e.target).attr('href');--}%
            %{--if (target == '#reportsByMonth') {--}%
                %{--transcriptionsByMonth();--}%
                %{--validationsByMonth();--}%
            %{--}--}%
        %{--});--}%

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
                        //'title': 'Transcriptions by month',
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
                        //'title': 'Validations by month',
                        backgroundColor: '#F5F2E3',
                        vAxis: {title: "Validations"},
                        hAxis: {title: "Month"},
                        height: 400
                    };

                    // Instantiate and draw our chart, passing in some options.
                    var chart = new google.visualization.ColumnChart(document.getElementById('validationsByMonth')).draw(table, options);
                });
            }

</asset:script>
<asset:javascript src="admin-stats" asset-defer=""/>
<asset:script>
    adminStats({
        volunteerStatsURL: "${createLink(controller: 'stats', action: 'volunteerStats')}",
        activeTranscribersURL: "${createLink(controller: 'stats', action: 'activeTranscribers')}",
        transcriptionsByVolunteerProject: "${createLink(controller: 'stats', action: 'transcriptionsByVolunteerAndProject')}",
        transcriptionsByDay: "${createLink(controller: 'stats', action: 'transcriptionsByDay')}",
        validationsByDay: "${createLink(controller: 'stats', action: 'validationsByDay')}",
        transcriptionsByInstitution: "${createLink(controller: 'stats', action: 'transcriptionsByInstitution')}",
        validationsByInstitution: "${createLink(controller: 'stats', action: 'validationsByInstitution')}",
        hourlyContributions: "${createLink(controller: 'stats', action: 'hourlyContributions')}",
        historicalHonourBoard: "${createLink(controller: 'stats', action: 'historicalHonourBoard')}",
        exportCSVReport: "${createLink(controller: 'stats', action: 'exportCSVReport')}"
    });
</asset:script>
</body>
</html>