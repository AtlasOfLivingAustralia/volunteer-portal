<<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <title><cl:pageTitle title="Admin Stats" /></title>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <asset:stylesheet src="admin-stats" />
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

<section id="admin-stats" class="in-body">
    <div ng-controller="StatsCtrl as statsCtrl" ng-cloak>
        <uib-tabset active="statsCtrl.active" template-url="notebookTabSet.html">
            <uib-tab heading="Reports By Date">
                <div class="row">
                    <div class="col-md-12">
                        <date-range start-date="statsCtrl.startDate" end-date="statsCtrl.endDate" on-dates-confirmed="statsCtrl.setDateRange()"></date-range>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-4">
                        <div class="panel panel-default">
                            <div class="panel-heading"><h4>DigiVol Volunteers</h4></div>
                            <div class="panel-body">
                                <h4>New Volunteers: {{ statsCtrl.newVolunteers }} <span class="text-muted">({{ statsCtrl.cachedNewVolunteers }} with a volunteer score)</span></h4>
                                <h4>Total Volunteers: {{ statsCtrl.totalVolunteers }} <span class="text-muted">({{ statsCtrl.cachedTotalVolunteers }} with a volunteer score)</span></h4>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="panel panel-default">
                            <div class="panel-heading"><h4>Historical Honourboard</h4></div>
                            <div class="panel-body">
                                <span data-ng-if="statsCtrl.loading"><cl:spinner/></span>
                                <span data-ng-if="!statsCtrl.loading">
                                    <div tablechart data="statsCtrl.getHistoricalHonourBoard()" title="" width="100%" height="100%" searchdate="{{statsCtrl.searchDate}}"></div>
                                    <button type="button" class="btn btn-default btn-sm" ng-click="statsCtrl.exportToCSV(statsCtrl.historicalHonourBoard, 'historicalHonourBoard')">
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
                                <div tablechart data="statsCtrl.getActiveTranscribers()" title="" width="100%" height="100%" searchdate="{{statsCtrl.searchDate}}"></div>
                                <button type="button" class="btn btn-default btn-sm" ng-click="statsCtrl.exportToCSV(statsCtrl.activeTranscribers, 'activeTranscribers')">
                                    <span class="glyphicon glyphicon-download-alt"></span> Download
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-12">
                        <div class="panel panel-default">
                            <div class="panel-heading"><h4>Transcriptions By Day</h4></div>
                            <div class="panel-body">
                                <div barchart data="statsCtrl.getTranscriptionsByDay()" title="" width="100%" height="350" yaxis="Transcriptions count"
                                     xaxis="Day" searchdate="{{statsCtrl.searchDate}}"></div>
                                <button type="button" class="btn btn-default btn-sm" ng-click="statsCtrl.exportToCSV(statsCtrl.transcriptionsByDay, 'transcriptionsByDay')">
                                    <span class="glyphicon glyphicon-download-alt"></span> Download
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-12">
                        <div class="panel panel-default">
                            <div class="panel-heading"><h4>Validations By Day</h4></div>
                            <div class="panel-body">
                                <div barchart data="statsCtrl.getValidationsByDay()" title="" width="100%" height="350" yaxis="Validations count"
                                     xaxis="Day" searchdate="{{statsCtrl.searchDate}}"></div>
                                <button type="button" class="btn btn-default btn-sm" ng-click="statsCtrl.exportToCSV(statsCtrl.validationsByDay, 'validationsByDay')">
                                    <span class="glyphicon glyphicon-download-alt"></span> Download
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-12">
                        <div class="panel panel-default">
                            <div class="panel-heading"><h4>Transcriptions By Volunteer And Project</h4></div>
                            <div class="panel-body">
                                <div tablechart data="statsCtrl.getTranscriptionsByVolunteerAndProject()" title="" width="100%" height="100%" searchdate="{{statsCtrl.searchDate}}"></div>
                                <button type="button" class="btn btn-default btn-sm" ng-click="statsCtrl.exportToCSV(statsCtrl.transcriptionsByVolunteerAndProject, 'transcriptionsByVolunteerAndProject')">
                                    <span class="glyphicon glyphicon-download-alt"></span> Download
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-12">
                        <div class="panel panel-default">
                            <div class="panel-heading"><h4>Hourly Contributions</h4></div>
                            <div class="panel-body">
                                <div linechart data="statsCtrl.getHourlyContributions()" title="" width="100%" height="350" xaxis="Hour"
                                     yaxis="Contributions" searchdate="{{statsCtrl.searchDate}}"></div>
                                <button type="button" class="btn btn-default btn-sm" ng-click="statsCtrl.exportToCSV(statsCtrl.hourlyContributions, 'hourlyContributions')">
                                    <span class="glyphicon glyphicon-download-alt"></span> Download
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-12">
                        <div class="panel panel-default">
                            <div class="panel-heading"><h4>Average Transcription Time by Project Type</h4></div>
                            <div class="panel-body">
                                <div barchart data="statsCtrl.getTranscriptionTimeByProjectType()" title="" width="100%" height="350" xaxis="Project Type"
                                     yaxis="Transcription Time" searchdate="{{statsCtrl.searchDate}}"></div>
                                <button type="button" class="btn btn-default btn-sm" ng-click="statsCtrl.exportToCSV(statsCtrl.transcriptionTimeByProjectType, 'transcriptionTimeByProjectType')">
                                    <span class="glyphicon glyphicon-download-alt"></span> Download
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </uib-tab>
            <uib-tab heading="Reports by Month" select="statsCtrl.loadMonthlyStats()">
                <div class="row">
                    <div class="col-md-12">
                        <div class="panel panel-default">
                            <div class="panel-heading"><h4>Transcriptions By Month</h4></div>
                            <div class="panel-body">
                                <div id="transcriptionsByMonth">
                                    <div ng-show="statsCtrl.transcriptionsByMonth.loaded" google-chart chart="statsCtrl.transcriptionsByMonth" style="height: 400px; width: 100%" ></div>
                                    <div ng-show="!statsCtrl.transcriptionsByMonth.loaded"><cl:spinner /></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-12">
                        <div class="panel panel-default">
                            <div class="panel-heading"><h4>Validations By Month</h4></div>
                            <div class="panel-body">
                                <div id="validationsByMonth">
                                    <div ng-show="statsCtrl.validationsByMonth.loaded" google-chart chart="statsCtrl.validationsByMonth" style="height: 400px; width: 100%" ></div>
                                    <div ng-show="!statsCtrl.validationsByMonth.loaded"><cl:spinner /></div>
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
                                <div tablechart data="statsCtrl.getTranscriptionsByInstitution()" title="" width="100%" height="100%" xaxis="Institution"
                                     yaxis="Number of Transcriptions"></div>
                                <button type="button" class="btn btn-default btn-sm" ng-click="statsCtrl.exportToCSV(statsCtrl.transcriptionsByInstitution, 'transcriptionsByInstitution')">
                                    <span class="glyphicon glyphicon-download-alt"></span> Download
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-12">
                        <div class="panel panel-default">
                            <div class="panel-heading"><h4>Validations By Institution</h4></div>
                            <div class="panel-body">
                                <div tablechart data="statsCtrl.getValidationsByInstitution()" title="" width="100%" height="100%" xaxis="Institution"
                                     yaxis="Number of Validations"></div>
                                <button type="button" class="btn btn-default btn-sm" ng-click="statsCtrl.exportToCSV(statsCtrl.validationsByInstitution, 'validationsByInstitution')">
                                    <span class="glyphicon glyphicon-download-alt"></span> Download
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-12">
                        <div class="panel panel-default">
                            <div class="panel-heading"><h4>Transcriptions By Institution By Month</h4></div>
                            <div class="panel-body">
                                <div tablechart data="statsCtrl.getTranscriptionsByInstitutionByMonth()" title="" width="100%" height="100%" xaxis="Institution"
                                     yaxis="Month"></div>
                                <button type="button" class="btn btn-default btn-sm" ng-click="statsCtrl.exportToCSV(statsCtrl.transcriptionsByInstitutionByMonth, 'transcriptionsByInstitutionByMonth')">
                                    <span class="glyphicon glyphicon-download-alt"></span> Download
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </uib-tab>
        </uib-tabset>
    </div>
</section>
<script type="text/ng-template" id="dateRange.html">
<div class="form-inline">
    <div class="form-group">
        <label>From
            <div class="input-group">
                <input type="text" class="form-control" uib-datepicker-popup="{{$ctrl.format}}" name="fromDate" ng-model="$ctrl.startDate" is-open="$ctrl.fromDatePopupOpened" />
                <span class="input-group-btn"><button type="button" class="btn btn-default" ng-click="$ctrl.fromDatePopupOpened = true"><i class="glyphicon glyphicon-calendar"></i></button></span>
            </div>
        </label>
    </div>
    <div class="form-group">
        <label>to
            <div class="input-group">
                <input type="text" class="form-control" uib-datepicker-popup="{{$ctrl.format}}" name="toDate" ng-model="$ctrl.endDate" is-open="$ctrl.toDatePopupOpened" />
                <span class="input-group-btn"><button type="button" class="btn btn-default" ng-click="$ctrl.toDatePopupOpened = true"><i class="glyphicon glyphicon-calendar"></i></button></span>
            </div>
        </label>
    </div>
    <button class="search btn btn-primary" ng-click="$ctrl.confirm()">Search</button>
</div>
</script>
<g:render template="/common/angularBootstrapTabSet" />
<asset:javascript src="livestamp" asset-defer=""/>
<asset:script type="text/javascript">
    // Load the Visualization API and the piechart package.
    google.load('visualization', '1.0', {'packages': ['corechart']});
    google.load('visualization', '1.0', {'packages': ['table']});
    google.load('visualization', '1.0', {'packages':['bar']});
</asset:script>
<asset:javascript src="admin-stats" asset-defer=""/>
<asset:script type="text/javascript">
    adminStats({
        volunteerStatsURL: "${createLink(controller: 'stats', action: 'volunteerStats')}",
        activeTranscribersURL: "${createLink(controller: 'stats', action: 'activeTranscribers')}",
        transcriptionsByVolunteerProject: "${createLink(controller: 'stats', action: 'transcriptionsByVolunteerAndProject')}",
        transcriptionsByDay: "${createLink(controller: 'stats', action: 'transcriptionsByDay')}",
        validationsByDay: "${createLink(controller: 'stats', action: 'validationsByDay')}",
        transcriptionTimeByProjectType: "${createLink(controller: 'stats', action: 'transcriptionTimeByProjectType')}",
        transcriptionsByInstitution: "${createLink(controller: 'stats', action: 'transcriptionsByInstitution')}",
        transcriptionsByInstitutionByMonth: "${createLink(controller: 'stats', action: 'transcriptionsByInstitutionByMonth')}",
        validationsByInstitution: "${createLink(controller: 'stats', action: 'validationsByInstitution')}",
        hourlyContributions: "${createLink(controller: 'stats', action: 'hourlyContributions')}",
        historicalHonourBoard: "${createLink(controller: 'stats', action: 'historicalHonourBoard')}",
        transcriptionsByMonth: "${createLink(controller: 'ajax', action: 'statsTranscriptionsByMonth')}",
        validationsByMonth: "${createLink(controller: 'ajax', action: 'statsValidationsByMonth')}",
        exportCSVReport: "${createLink(controller: 'stats', action: 'exportCSVReport')}"
    });
</asset:script>
</body>
</html>