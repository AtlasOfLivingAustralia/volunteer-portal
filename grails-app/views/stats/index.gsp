<<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <title><cl:pageTitle title="Admin Stats" /></title>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <asset:stylesheet src="admin-stats" />
    <script src="https://www.gstatic.com/charts/loader.js"></script>

</head>

<body class="admin" data-ng-app="statApp">

<cl:headerContent title="Statistics" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin', action: 'index'), label: "Administration"]
        ]
    %>
</cl:headerContent>

<cl:ifAdmin>
    <div class="container">
        <div>
            <p>Statistics for transcriptions and validations for <cl:ifNotSiteAdmin>your Institution(s)</cl:ifNotSiteAdmin><cl:ifSiteAdmin>DigiVol</cl:ifSiteAdmin>.</p>
        </div>
    </div>
</cl:ifAdmin>

<section id="admin-stats" class="in-body">

    <div ng-controller="StatsCtrl as statsCtrl" ng-cloak>
        <uib-tabset active="statsCtrl.active" template-url="notebookTabSet.html">
            <uib-tab heading="Reports By Date">
                <div class="row">
                    <div class="col-md-12">
                        <date-range start-date="statsCtrl.startDate" end-date="statsCtrl.endDate" institution-id="statsCtrl.institutionId" on-dates-confirmed="statsCtrl.setDateRange()"></date-range>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-4">
                        <div class="panel panel-default">
                            <div class="panel-heading"><h4>DigiVol Volunteers</h4></div>
                            <div class="panel-body">
                                <span data-ng-if="statsCtrl.loadingVolunteerData"><cl:spinner/></span>
                                <span data-ng-if="!statsCtrl.loadingVolunteerData">
                                    <table width="100%">
                                        <tr data-ng-if="statsCtrl.showInstitutionCounts">
                                            <td><b>New Volunteers<cl:ifNotSiteAdmin> for this Institution</cl:ifNotSiteAdmin>*:</b></td>
                                            <td class="text-right">{{ statsCtrl.newVolunteers }}</td>
                                        </tr>
                                        <tr>
                                            <td><b>Total New Volunteers for DigiVol*:</b></td>
                                            <td class="text-right">{{ statsCtrl.cachedNewVolunteers }}</td>
                                        </tr>
                                        <tr data-ng-if="statsCtrl.showInstitutionCounts">
                                            <td><b>Total Volunteers<cl:ifNotSiteAdmin> for this Institution</cl:ifNotSiteAdmin></b>*:</td>
                                            <td class="text-right">{{ statsCtrl.totalVolunteers }}</td>
                                        </tr>
                                        <tr>
                                            <td><b>Total DigiVol Volunteers:</b></td>
                                            <td class="text-right">{{ statsCtrl.cachedTotalVolunteers }}</td>
                                        </tr>
                                    </table>
                                    <p>* Volunteers with a volunteer score.</p>
                                </span>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="panel panel-default">
                            <div class="panel-heading"><h4>Historical Honourboard</h4></div>
                            <div class="panel-body">
                                <span data-ng-if="statsCtrl.loadingHonourBoard"><cl:spinner/></span>
                                <span data-ng-if="!statsCtrl.loadingHonourBoard">
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
                                <span data-ng-if="statsCtrl.loadingActiveTranscribers"><cl:spinner/></span>
                                <span data-ng-if="!statsCtrl.loadingActiveTranscribers">
                                    <div tablechart data="statsCtrl.getActiveTranscribers()" title="" width="100%" height="100%" searchdate="{{statsCtrl.searchDate}}"></div>
                                    <button type="button" class="btn btn-default btn-sm" ng-click="statsCtrl.exportToCSV(statsCtrl.activeTranscribers, 'activeTranscribers')">
                                        <span class="glyphicon glyphicon-download-alt"></span> Download
                                    </button>
                                </span>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-12">
                        <div class="panel panel-default">
                            <div class="panel-heading"><h4>Transcriptions By Day</h4></div>
                            <div class="panel-body">
                                <span data-ng-if="statsCtrl.loadingTranscriptionsByDay"><cl:spinner/></span>
                                <span data-ng-if="!statsCtrl.loadingTranscriptionsByDay">
                                    <div barchart data="statsCtrl.getTranscriptionsByDay()" title="" width="100%" height="350" yaxis="Transcriptions count"
                                         xaxis="Day" searchdate="{{statsCtrl.searchDate}}"></div>
                                    <button type="button" class="btn btn-default btn-sm" ng-click="statsCtrl.exportToCSV(statsCtrl.transcriptionsByDay, 'transcriptionsByDay')">
                                        <span class="glyphicon glyphicon-download-alt"></span> Download
                                    </button>
                                </span>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-12">
                        <div class="panel panel-default">
                            <div class="panel-heading"><h4>Validations By Day</h4></div>
                            <div class="panel-body">
                                <span data-ng-if="statsCtrl.loadingValidationsByDay"><cl:spinner/></span>
                                <span data-ng-if="!statsCtrl.loadingValidationsByDay">
                                    <div barchart data="statsCtrl.getValidationsByDay()" title="" width="100%" height="350" yaxis="Validations count"
                                         xaxis="Day" searchdate="{{statsCtrl.searchDate}}"></div>
                                    <button type="button" class="btn btn-default btn-sm" ng-click="statsCtrl.exportToCSV(statsCtrl.validationsByDay, 'validationsByDay')">
                                        <span class="glyphicon glyphicon-download-alt"></span> Download
                                    </button>
                                </span>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-12">
                        <div class="panel panel-default">
                            <div class="panel-heading"><h4>Transcriptions By Volunteer And Project</h4></div>
                            <div class="panel-body">
                                <span data-ng-if="statsCtrl.loadingTranscriptionsByVolunteerProject"><cl:spinner/></span>
                                <span data-ng-if="!statsCtrl.loadingTranscriptionsByVolunteerProject">
                                    <div tablechart data="statsCtrl.getTranscriptionsByVolunteerAndProject()" title="" width="100%" height="100%" searchdate="{{statsCtrl.searchDate}}"></div>
                                    <button type="button" class="btn btn-default btn-sm" ng-click="statsCtrl.exportToCSV(statsCtrl.transcriptionsByVolunteerAndProject, 'transcriptionsByVolunteerAndProject')">
                                        <span class="glyphicon glyphicon-download-alt"></span> Download
                                    </button>
                                </span>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-12">
                        <div class="panel panel-default">
                            <div class="panel-heading"><h4>Hourly Contributions</h4></div>
                            <div class="panel-body">
                                <span data-ng-if="statsCtrl.loadingHourlyContributions"><cl:spinner/></span>
                                <span data-ng-if="!statsCtrl.loadingHourlyContributions">
                                    <div linechart data="statsCtrl.getHourlyContributions()" title="" width="100%" height="350" xaxis="Hour"
                                         yaxis="Contributions" searchdate="{{statsCtrl.searchDate}}"></div>
                                    <button type="button" class="btn btn-default btn-sm" ng-click="statsCtrl.exportToCSV(statsCtrl.hourlyContributions, 'hourlyContributions')">
                                        <span class="glyphicon glyphicon-download-alt"></span> Download
                                    </button>
                                </span>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-12">
                        <div class="panel panel-default">
                            <div class="panel-heading"><h4>Average Transcription Time by Project Type</h4></div>
                            <div class="panel-body">
                                <span data-ng-if="statsCtrl.loadingTimeByProjectType"><cl:spinner/></span>
                                <span data-ng-if="!statsCtrl.loadingTimeByProjectType">
                                    <div barchart data="statsCtrl.getTranscriptionTimeByProjectType()" title="" width="100%" height="350" xaxis="Project Type"
                                         yaxis="Transcription Time" searchdate="{{statsCtrl.searchDate}}"></div>
                                    <button type="button" class="btn btn-default btn-sm" ng-click="statsCtrl.exportToCSV(statsCtrl.transcriptionTimeByProjectType, 'transcriptionTimeByProjectType')">
                                        <span class="glyphicon glyphicon-download-alt"></span> Download
                                    </button>
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            </uib-tab>
            <cl:ifSiteAdmin>
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
            </cl:ifSiteAdmin>

            <uib-tab heading="Downloads">
                <div class="row">
                    <div class="col-md-12">
                        <div class="panel panel-default">
                            <div class="panel-heading"><h4>Institution Data Downloads</h4></div>
                            <div class="panel-body">
                                <p>Below is a list of the Institutions you have been assigned Institution Admin. Clicking on a link will download a CSV
                                of all task data for that institution.<br />
                                Data includes:
                                <ul>
                                    <li>Institution ID and name</li>
                                    <li>Project ID and name</li>
                                    <li>Task ID, external URL, validation status, transcriber and validator ID</li>
                                    <li>Date of transcription and validation</li>
                                </ul></p>
                                <b>Institutions</b><br />
                                <ul style="list-style-type: none;">
                                <g:each in="${institutionList}" var="institution">
                                    <li style="padding-top: 5px;"><g:link action="institutionStatsDownload" id="${institution.id}">${institution.name}</g:link><br /></li>
                                </g:each>
                                </ul>
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
        <label>From:
            <div class="input-group">
                <input type="text" class="form-control" uib-datepicker-popup="{{$ctrl.format}}" name="fromDate" ng-model="$ctrl.startDate" is-open="$ctrl.fromDatePopupOpened" />
                <span class="input-group-btn"><button type="button" class="btn btn-default" ng-click="$ctrl.fromDatePopupOpened = true"><i class="glyphicon glyphicon-calendar"></i></button></span>
            </div>
        </label>
    </div>
    <div class="form-group">
        <label>To:
            <div class="input-group">
                <input type="text" class="form-control" uib-datepicker-popup="{{$ctrl.format}}" name="toDate" ng-model="$ctrl.endDate" is-open="$ctrl.toDatePopupOpened" />
                <span class="input-group-btn"><button type="button" class="btn btn-default" ng-click="$ctrl.toDatePopupOpened = true"><i class="glyphicon glyphicon-calendar"></i></button></span>
            </div>
        </label>
    </div>
    <div class="form-group">
        <label>Institution:
            <div class="input-group">
                <select name="institutionId" id="institutionId" class="form-control" ng-model="$ctrl.institutionId">
                    <option value="0">- All Institutions -</option>
                    <g:each in="${institutionList}" var="institution">
                        <option value="${institution.id}"
                                <g:if test="${params?.institutionId == institution.id}">selected</g:if>
                        >${institution.name}</option>
                    </g:each>
                </select>
            </div>
        </label>
    </div>
    <button class="search btn btn-primary" ng-click="$ctrl.confirm()">Search</button>
</div>
</script>
<g:render template="/common/angularBootstrapTabSet" />
<asset:javascript src="livestamp" asset-defer=""/>
<asset:script type="text/javascript">
    google.charts.load('current', {packages: ['corechart', 'table', 'bar']});
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