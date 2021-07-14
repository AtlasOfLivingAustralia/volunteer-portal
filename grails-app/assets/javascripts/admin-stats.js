//= encoding UTF-8
//  assume jquery
//  ?? require jquery-ui ??
//= require digivol-module
//= require angular/angular-google-charts
//= require angular/angular-ui-bootstrap
//= require_self

function adminStats(config) {

    var app = angular.module('statApp', ['digivol', 'ui.bootstrap', 'googlechart']);

    app.config(['$httpProvider', function ($httpProvider) {
        // enable http caching
        $httpProvider.defaults.cache = true;
    }]);

    app.service('StatsService', ['$http', '$q', function($http, $q) {
        function toLocalDateString(value) {
            var date = new Date(value.getTime());
            date.setMinutes(date.getMinutes() - date.getTimezoneOffset());
            return date.toISOString().substring(0, 10);
        }

        return {
            getVolunteer: function (startDate, endDate, institutionId) {
                return $http.get(config.volunteerStatsURL, {
                    params: {
                        "startDate": toLocalDateString(startDate),
                        "endDate": toLocalDateString(endDate),
                        "institutionId": institutionId
                    }
                })
                    .then(function (response) {
                        return response.data;
                    }, function (response) {
                        $q.reject(response);
                    });
            },

            getActiveTranscribers: function (startDate, endDate, institutionId) {
                return $http.get(config.activeTranscribersURL, {
                    params: {
                        "startDate": toLocalDateString(startDate),
                        "endDate": toLocalDateString(endDate),
                        "institutionId": institutionId
                    }
                }).then(function (response) {
                    return response.data;
                }, function (response) {
                    $q.reject(response);
                });
            },

            getTranscriptionsByVolunteerAndProject: function (startDate, endDate, institutionId) {
                return $http.get(config.transcriptionsByVolunteerProject, {
                    params: {
                        "startDate": toLocalDateString(startDate),
                        "endDate": toLocalDateString(endDate),
                        "institutionId": institutionId
                    }
                }).then(function (response) {
                    return response.data;
                }, function (response) {
                    $q.reject(response);
                });
            },

            getTranscriptionsByDay: function (startDate, endDate, institutionId) {
                return $http.get(config.transcriptionsByDay, {
                    params: {
                        "startDate": toLocalDateString(startDate),
                        "endDate": toLocalDateString(endDate),
                        "institutionId": institutionId
                    }
                }).then(function (response) {
                    return response.data;
                }, function (response) {
                    $q.reject(response);
                });
            },

            getValidationsByDay: function (startDate, endDate, institutionId) {
                return $http.get(config.validationsByDay, {
                    params: {
                        "startDate": toLocalDateString(startDate),
                        "endDate": toLocalDateString(endDate),
                        "institutionId": institutionId
                    }
                }).then(function (response) {
                    return response.data;
                }, function (response) {
                    $q.reject(response);
                });
            },

            getTranscriptionTimeByProjectType: function (startDate, endDate, institutionId) {
                return $http.get(config.transcriptionTimeByProjectType, {
                    params: {
                        'startDate': toLocalDateString(startDate),
                        'endDate': toLocalDateString(endDate),
                        "institutionId": institutionId
                    }
                })
                    .then(function (response) {
                        return response.data;
                    }, function (response) {
                        $q.reject(response);
                    })
            },

            getTranscriptionsByInstitution: function () {
                return $http.get(config.transcriptionsByInstitution).then(function (response) {
                    return response.data;
                }, function (response) {
                    $q.reject(response);
                });
            },

            getTranscriptionsByInstitutionByMonth: function () {
                return $http.get(config.transcriptionsByInstitutionByMonth).then(function (response) {
                    return response.data;
                }, function (response) {
                    $q.reject(response);
                });
            },

            getValidationsByInstitution: function () {
                return $http.get(config.validationsByInstitution).then(function (response) {
                    return response.data;
                }, function (response) {
                    $q.reject(response);
                });
            },

            getHourlyContributions: function (startDate, endDate, institutionId) {
                return $http.get(config.hourlyContributions, {
                    params: {
                        "startDate": toLocalDateString(startDate),
                        "endDate": toLocalDateString(endDate),
                        "institutionId": institutionId
                    }
                }).then(function (response) {
                    return response.data;
                }, function (response) {
                    $q.reject(response);
                });
            },

            getHistoricalHonourBoard: function (startDate, endDate, institutionId) {
                return $http.get(config.historicalHonourBoard, {
                    params: {
                        "startDate": toLocalDateString(startDate),
                        "endDate": toLocalDateString(endDate),
                        "institutionId": institutionId
                    }
                }).then(function (response) {
                    return response.data;
                }, function (response) {
                    $q.reject(response);
                });
            },

            getValidationsByMonth: function () {
                return $http.get(config.validationsByMonth).then(function (response) { return response.data });
            },

            getTranscriptionsByMonth: function () {
                return $http.get(config.transcriptionsByMonth).then(function (response) { return response.data });
            }

        };
    }]);

    app.controller('StatsCtrl', ['$scope', 'StatsService', '$log', function ($scope, StatsService, $log) {

        var self = this;

        self.endDate = new Date();
        self.endDate.setHours(0,0,0,0);
        self.startDate = new Date(self.endDate.getTime());
        self.startDate.setDate(self.startDate.getDate() - 7);

        self.searchDate = [self.startDate, self.endDate];
        self.institutionId = "0";
        self.showInstitutionCounts = false;

        self.active = 0;

        // Used to hold csv data
        self.activeTranscribers = "";
        self.transcriptionsByVolunteerAndProject = "";
        self.transcriptionsByDay ="";
        self.validationsByDay = "";
        self.transcriptionsByInstitution = "";
        self.validationsByInstitution = "";
        self.hourlyContributions = "";
        self.historicalHonourBoard = "";

        var getNewVolunteerData = function () {
            self.loadingVolunteerData = true;
            var stats = StatsService.getVolunteer(self.startDate, self.endDate, self.institutionId);
            stats.then(function(data){
                self.loadingVolunteerData = false;
                if (self.institutionId > 0) {
                    self.showInstitutionCounts = true;
                } else {
                    self.showInstitutionCounts = false;
                }
                angular.extend(self, data);
            }, function (resp) {
                self.loadingVolunteerData = false;
                $log.error("Error from getting data in getVolunteer", resp);
            });
        };

        getNewVolunteerData();

        self.getActiveTranscribers = function () {
            self.loadingActiveTranscribers = true;
            var stats = StatsService.getActiveTranscribers(self.startDate, self.endDate, self.institutionId);
            return stats.then(function(data) {
                self.loadingActiveTranscribers = false;
                self.activeTranscribers = data;
                return data;
            }, function (resp) {
                self.loadingActiveTranscribers = false;
                $log.error("Error from getting data in getActiveTranscriber", resp);
                return "";
            });
        };

        self.getTranscriptionsByVolunteerAndProject = function () {
            self.loadingTranscriptionsByVolunteerProject = true;
            var stat = StatsService.getTranscriptionsByVolunteerAndProject(self.startDate, self.endDate, self.institutionId);
            return stat.then(function(data) {
                self.loadingTranscriptionsByVolunteerProject = false;
                self.transcriptionsByVolunteerAndProject = data;
                return data;
            }, function (resp) {
                self.loadingTranscriptionsByVolunteerProject = false;
                $log.error("Error from getting data in getTranscriptionsByVolunteerAndProject", resp);
                return resp;
            });
        };

        self.getTranscriptionsByDay = function () {
            self.loadingTranscriptionsByDay = true;
            var stat = StatsService.getTranscriptionsByDay(self.startDate, self.endDate, self.institutionId);
            return stat.then(function(data) {
                self.loadingTranscriptionsByDay = false;
                self.transcriptionsByDay = data;
                return data;
            }, function (resp) {
                self.loadingTranscriptionsByDay = false;
                $log.error("Error from getting data in getTranscriptionsByDay", resp);
                return resp;
            });
        };

        self.getValidationsByDay = function () {
            self.loadingValidationsByDay = true;
            var stat = StatsService.getValidationsByDay(self.startDate, self.endDate, self.institutionId);
            return stat.then(function(data) {
                self.loadingValidationsByDay = false;
                self.validationsByDay = data;
                return data;
            }, function (resp) {
                self.loadingValidationsByDay = false;
                $log.error("Error from getting data in getValidationsByDay", resp);
                return resp;
            });
        };

        self.getTranscriptionTimeByProjectType = function() {
            self.loadingTimeByProjectType = true;
            var stat = StatsService.getTranscriptionTimeByProjectType(self.startDate, self.endDate, self.institutionId);
            return stat.then(function(data) {
                self.loadingTimeByProjectType = false;
                self.transcriptionTimeByProjectType = data;
                return data;
            }, function(resp) {
                self.loadingTimeByProjectType = false;
                $log.error("Error from getting data in getValidationsByDay", resp);
                return resp;
            });
        };

        self.getTranscriptionsByInstitution = function () {
            var stat = StatsService.getTranscriptionsByInstitution();
            return stat.then(function(data) {
                self.transcriptionsByInstitution = data;
                return data;
            }, function (resp) {
                $log.error("Error from getting data in getTranscriptionsByInstitution", resp);
                return resp;
            });
        };

        self.getTranscriptionsByInstitutionByMonth = function () {
            var stat = StatsService.getTranscriptionsByInstitutionByMonth();
            return stat.then(function(data) {
                self.transcriptionsByInstitutionByMonth = data;
                return data;
            }, function (resp) {
                $log.error("Error from getting data in getTranscriptionsByInstitution", resp);
                return resp;
            });
        };

        self.getValidationsByInstitution = function () {
            var stat = StatsService.getValidationsByInstitution();
            return stat.then(function(data) {
                self.validationsByInstitution = data;
                return data;
            }, function (resp) {
                $log.error("Error from getting data in getValidationsByInstitution", resp);
                return resp;
            });
        };

        self.getHourlyContributions = function () {
            self.loadingHourlyContributions = true;
            var stat = StatsService.getHourlyContributions(self.startDate, self.endDate, self.institutionId);
            return stat.then(function(data) {
                self.loadingHourlyContributions = false;
                self.hourlyContributions = data;
                return data;
            }, function (resp) {
                self.loadingHourlyContributions = false;
                $log.error("Error from getting data in getHourlyContributions", resp);
                return resp;
            });
        };

        self.getHistoricalHonourBoard = function () {
            self.loadingHonourBoard = true;
            var stat = StatsService.getHistoricalHonourBoard(self.startDate, self.endDate, self.institutionId);
            return stat.then(function(data) {
                self.historicalHonourBoard = data;
                self.loadingHonourBoard = false;
                return data;
            }, function (resp) {
                self.loadingHonourBoard = false;
                $log.error("Error from getting data in getHistoricalHonourBoard", resp);
                return resp;
            });
        };

        self.loadMonthlyStats = function() {
            if (!self.transcriptionsByMonth.loaded) {
                StatsService.getTranscriptionsByMonth().then(function(data) {
                    self.transcriptionsByMonth.data = data;
                    self.transcriptionsByMonth.loaded = true;
                })
            }
            if (!self.validationsByMonth.loaded) {
                StatsService.getValidationsByMonth().then(function(data) {
                    self.validationsByMonth.data = data;
                    self.validationsByMonth.loaded = true;
                })
            }
        };

        self.transcriptionsByMonth = {
            loaded: false,
            data: [],
            type: 'ColumnChart',
            options: {
                hAxis: { slantedText:true },
                lineWidth: 1,
                legend: {position: 'none'},
                colors: ['#76A7FA'],
                chartArea:{left:60,top:10,bottom:60, height: "40%", width: "100%"}
            }
        };

        self.validationsByMonth = {
            loaded: false,
            data: {},
            type: 'ColumnChart',
            options: {
                hAxis: { slantedText:true },
                lineWidth: 1,
                legend: {position: 'none'},
                colors: ['#76A7FA'],
                chartArea:{left:60,top:10,bottom:60, height: "40%", width: "100%"}
            }
        };

        self.setDateRange = function () {
            self.searchDate = [self.startDate, self.endDate];
            getNewVolunteerData();
            self.getActiveTranscribers();
            self.getHistoricalHonourBoard();
            self.getTranscriptionsByDay();
            self.getValidationsByDay();
            self.getTranscriptionsByVolunteerAndProject();
            self.getHourlyContributions();
            self.getTranscriptionTimeByProjectType();
        };

        self.exportToCSV = function (data, reportType) {
            //    var dt = new google.visualization.DataTable(data);
            //    var csv =  dt.toCSV();
            //    if (downloadCSV(csv, reportType) == "failed") {
            //request browser to trigger server api to download
            var startParam = self.startDate != null ? self.startDate.toISOString() : '';
            var endParam = self.endDate != null ? self.endDate.toISOString() : '';
            var institutionParam = self.institutionId;
            var url = config.exportCSVReport + "?reportType=" + reportType + "&startDate=" + encodeURIComponent(startParam) +
                "&endDate=" + encodeURIComponent(endParam) + "&institutionId=" + encodeURIComponent(institutionParam);
            window.open(url, '_blank', '');
            //    };
        }

    }]);

    function drawGoogleChart($scope, jsonString, $elm, type) {
        google.setOnLoadCallback(function() {
            var data = new google.visualization.DataTable(jsonString);
            var chart;
            var options = {};

            if (type === 'table') {
                // Set chart options
                options = {
                    title: $scope.title,
                    width: $scope.width,
                    height: $scope.height,
                    showRowNumber: true,
                    page: 'enable',
                    pageSize: 10,
                    pagingSymbols: {
                        prev: 'prev',
                        next: 'next'
                    }
                };

                chart = new google.visualization.Table($elm[0]);

            } else if (type === "barchart") {

                options = {
                    title: $scope.title,
                    vAxis: {
                        title: $scope.yaxis
                    },
                    hAxis: {title: $scope.xaxis, slantedText: true},
                    width: $scope.width,
                    height: $scope.height,
                    lineWidth: 1,
                    legend: {position: 'none'},
                    colors: ['#76A7FA'],
                    chartArea: {left: 60, top: 10, bottom: 60, height: "40%", width: "100%"}
                };

                chart = new google.visualization.ColumnChart($elm[0]);

            } else if (type === "piechart") {

                options = {
                    title: $scope.title,
                    width: $scope.width,
                    height: $scope.height,
                    pieHole: $scope.pieHole,
                    pieSliceText: 'value',
                    pieSliceTextStyle: {
                        color: 'black'
                    }

                };

                chart = new google.visualization.PieChart($elm[0]);

            } else if (type === 'linechart') {
                options = {
                    hAxis: {title: $scope.xaxis},
                    vAxis: {
                        title: $scope.yaxis
                    },
                    width: $scope.width,
                    height: $scope.height,
                    colors: ['#a52714'],
                    legend: {position: 'none'},
                    lineWidth: 1,
                    chartArea: {left: 60, top: 10, bottom: 60, height: "40%", width: "100%"}

                };

                chart = new google.visualization.LineChart($elm[0]);
            }

            chart.draw(data, options);
        });
    }

    function downloadCSV (csv_out, reportType) {
        var blob = new Blob([csv_out], {type: 'text/csv;charset=utf-8'});
        var fileName = reportType + ".csv";
        var link = document.createElement('a');

        if (link.download !== undefined) {
            link.setAttribute("href", window.URL.createObjectURL(blob));
            link.setAttribute("download", fileName);
            var event = document.createEvent("MouseEvents");
            event.initEvent("click", true, false);
            link.dispatchEvent(event);
            return "success";
        } else if (navigator.msSaveBlob) {
            navigator.msSaveBlob(blob, fileName);
            return "success";
        } else {
            return "failed";
        }

    }

    // Extend DataTable functionality to include toCSV
    google.setOnLoadCallback(function() {
        google.visualization.DataTable.prototype.toCSV = function () {
            var dt_cols = this.getNumberOfColumns();
            var dt_rows = this.getNumberOfRows();

            var csv_cols = [];
            var csv_out;

            // Iterate columns
            for (var i = 0; i < dt_cols; i++) {
                // Replace any commas in column labels
                csv_cols.push(this.getColumnLabel(i).replace(/,/g, ""));
            }

            // Create column row of CSV
            csv_out = csv_cols.join(",") + "\r\n";

            // Iterate rows
            for (i = 0; i < dt_rows; i++) {
                var raw_col = [];
                for (var j = 0; j < dt_cols; j++) {
                    // Replace any commas in row values
                    raw_col.push(this.getFormattedValue(i, j, 'label').replace(/,/g, ""));
                }
                // Add row to CSV text
                csv_out += raw_col.join(",") + "\r\n";
            }

            return csv_out;
        };
    });

    function DateRangeController() {
        var ctrl = this;

        ctrl.formats = ['dd/MM/yyyy', 'yyyy/MM/dd'];
        ctrl.format = ctrl.formats[0];

        ctrl.confirm = function() {
            ctrl.onDatesConfirmed();
        }
    }

    app.component('dateRange', {
        templateUrl: 'dateRange.html',
        controller: DateRangeController,
        bindings: {
            startDate: '=',
            endDate: '=',
            institutionId: '=',
            onDatesConfirmed: '&'
        }
    });

    app.directive('tablechart', ['$timeout', function ($timeout) {
        return {
            restrict: 'AE',
            scope: {
                title: '@title',
                width: '@width',
                height: '@height',
                getChartData: '&data',
                searchdate: '@searchDate'
            },
            link: function ($scope, $elm, $attr, $log) {
                draw($attr);
                function draw($attr){
                    if(!draw.triggered){
                        draw.triggered=true;

                        // Set timeout to prevent the code from being executed and
                        // wait till the current $digest complete
                        $timeout(function() {
                            var p = $scope.getChartData();
                            p.then(function (resp) {
                                draw.triggered = false;
                                drawGoogleChart($scope, resp, $elm, 'table');
                                if ($attr.searchdate != null) {
                                    $scope.$watch(function() {
                                        return $attr.searchdate;
                                    }, function(newVal, oldVal){
                                        if (newVal !== oldVal) {
                                            draw($attr);
                                        }
                                    });
                                }
                            }, function (resp) {
                                log.error("Error while rendering chart", resp);
                                draw.triggered = false;
                            });
                        });
                    }
                }
            }
        }
    }]);

    app.directive('barchart', ['$timeout', function ($timeout) {
        return {
            restrict: 'AE',
            scope: {
                title: '@title',
                width: '@width',
                height: '@height',
                xaxis: '@xaxis',
                yaxis: '@yaxis',
                getChartData: '&data',
                searchdate: '@searchDate'
            },
            link: function ($scope, $elm, $attr) {
                draw($attr);
                function draw($attr){
                    if(!draw.triggered){
                        draw.triggered=true;
                        $timeout(function() {
                            var p = $scope.getChartData();
                            p.then(function (resp) {
                                draw.triggered = false;
                                drawGoogleChart($scope, resp, $elm, 'barchart');
                                if ($attr.searchdate != null) {
                                    $scope.$watch(function() {
                                        return $attr.searchdate;
                                    }, function(newVal, oldVal){
                                        if (newVal !== oldVal) {
                                            draw($attr);
                                        }
                                    });
                                }
                            }, function (resp) {
                                $log.error("Error while rendering chart", resp);
                                draw.triggered = false;
                            });
                        });
                    }
                }
            }
        }
    }]);

    app.directive('linechart', ['$timeout', function($timeout) {
        return {
            restrict: 'AE',
            scope: {
                title: '@title',
                width: '@width',
                height: '@height',
                xaxis: '@xaxis',
                yaxis: '@yaxis',
                getChartData: '&data',
                searchdate: '@searchDate'
            },
            link: function ($scope, $elm, $attr) {
                draw($attr);
                function draw($attr){
                    if(!draw.triggered){
                        draw.triggered=true;
                        $timeout(function() {
                            var p = $scope.getChartData();
                            p.then(function (resp) {
                                draw.triggered = false;
                                drawGoogleChart($scope, resp, $elm, 'linechart');
                                if ($attr.searchdate != null) {
                                    $scope.$watch(function() {
                                        return $attr.searchdate;
                                    }, function(newVal, oldVal){
                                        if (newVal !== oldVal) {
                                            draw($attr);
                                        }
                                    });
                                }
                            }, function (resp) {
                                $log.error("Error while rendering chart", resp);
                                draw.triggered = false;
                            });
                        });
                    }
                }
            }
        }
    }]);

    app.directive('piechart', ['$timeout', function($timeout) {
        return {
            restrict: 'AE',
            scope: {
                title: '@title',
                width: '@width',
                height: '@height',
                pieHole: '@piehole', // value 0 to 1 is a donut pie chart
                getChartData: '&data',
                searchdate: '@searchDate'
            },
            link: function ($scope, $elm, $attr) {
                draw($attr);
                function draw($attr){
                    if(!draw.triggered){
                        draw.triggered=true;
                        $timeout(function() {
                            var p = $scope.getChartData();
                            p.then(function (resp) {
                                draw.triggered = false;
                                drawGoogleChart($scope, resp, $elm, 'piechart');
                                if ($attr.searchdate != null) {
                                    $scope.$watch(function() {
                                        return $attr.searchdate;
                                    }, function(newVal, oldVal){
                                        if (newVal !== oldVal) {
                                            draw($attr);
                                        }
                                    });
                                }
                            }, function (resp) {
                                $log.error("Error while rendering chart", resp);
                            });
                        });
                    }
                }
            }
        }
    }]);

}