function adminStats(config) {

    var app = angular.module('statApp', ['digivol']);

    app.config(['$httpProvider', function ($httpProvider) {
        // enable http caching
        $httpProvider.defaults.cache = true;
    }]);

    app.service('StatsService', ['$http', '$q', function($http, $q) {
        return {
            getVolunteer: function (startDate, endDate) {
                return $http.get(config.volunteerStatsURL, {params:{"startDate": startDate, "endDate": endDate}}).then(function (response) {
                    return response.data;
                }, function (response) {
                    $q.reject(response);
                });
            },

            getActiveTranscribers: function (startDate, endDate) {
                return $http.get(config.activeTranscribersURL, {params:{"startDate": startDate, "endDate": endDate}}).then(function (response) {
                    return response.data;
                }, function (response) {
                    $q.reject(response);
                });
            },

            getTranscriptionsByVolunteerAndProject: function (startDate, endDate) {
                return $http.get(config.transcriptionsByVolunteerProject, {params:{"startDate": startDate, "endDate": endDate}}).then(function (response) {
                    return response.data;
                }, function (response) {
                    $q.reject(response);
                });
            },

            getTranscriptionsByDay: function (startDate, endDate) {
                return $http.get(config.transcriptionsByDay, {params:{"startDate": startDate, "endDate": endDate}}).then(function (response) {
                    return response.data;
                }, function (response) {
                    $q.reject(response);
                });
            },

            getValidationsByDay: function (startDate, endDate) {
                return $http.get(config.validationsByDay, {params:{"startDate": startDate, "endDate": endDate}}).then(function (response) {
                    return response.data;
                }, function (response) {
                    $q.reject(response);
                });
            },

            getTranscriptionsByInstitution: function () {
                return $http.get(config.transcriptionsByInstitution).then(function (response) {
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

            getHourlyContributions: function (startDate, endDate) {
                return $http.get(config.hourlyContributions, {params:{"startDate": startDate, "endDate": endDate}}).then(function (response) {
                    return response.data;
                }, function (response) {
                    $q.reject(response);
                });
            },

            getHistoricalHonourBoard: function (startDate, endDate) {
                return $http.get(config.historicalHonourBoard, {params:{"startDate": startDate, "endDate": endDate}}).then(function (response) {
                    return response.data;
                }, function (response) {
                    $q.reject(response);
                });
            },

        };
    }]);

    app.controller('statsCtrl', ['$scope', 'StatsService', '$log', function ($scope, StatsService, $log) {

        $scope.searchDate = [$scope.startDate, $scope.endDate];

        // Used to hold csv data
        $scope.activeTranscribers = "";
        $scope.transcriptionsByVolunteerAndProject = "";
        $scope.transcriptionsByDay ="";
        $scope.validationsByDay = "";
        $scope.transcriptionsByInstitution = "";
        $scope.validationsByInstitution = "";
        $scope.hourlyContributions = "";
        $scope.historicalHonourBoard = "";

        var getNewVolunteerData = function () {
            var stats = statService.getVolunteer($scope.startDate, $scope.endDate);
            stats.then(function(data){
                angular.extend($scope, data);
            }, function (resp) {
                $log.error("Error from getting data in getVolunteer", resp);
            });
        };

        getNewVolunteerData();

        $scope.getActiveTranscribers = function () {
            var stats = statService.getActiveTranscribers($scope.startDate, $scope.endDate);
            return stats.then(function(data) {
                $scope.activeTranscribers = data;
                return data;
            }, function (resp) {
                $log.error("Error from getting data in getActiveTranscriber", resp);
                return "";
            });
        };

        $scope.getTranscriptionsByVolunteerAndProject = function () {
            var stat = statService.getTranscriptionsByVolunteerAndProject($scope.startDate, $scope.endDate);
            return stat.then(function(data) {
                $scope.transcriptionsByVolunteerAndProject = data;
                return data;
            }, function (resp) {
                $log.error("Error from getting data in getTranscriptionsByVolunteerAndProject", resp);
                return resp;
            });
        };

        $scope.getTranscriptionsByDay = function () {
            var stat = statService.getTranscriptionsByDay($scope.startDate, $scope.endDate);
            return stat.then(function(data) {
                $scope.transcriptionsByDay = data;
                return data;
            }, function (resp) {
                $log.error("Error from getting data in getTranscriptionsByDay", resp);
                return resp;
            });
        };

        $scope.getValidationsByDay = function () {
            var stat = statService.getValidationsByDay($scope.startDate, $scope.endDate);
            return stat.then(function(data) {
                $scope.validationsByDay = data;
                return data;
            }, function (resp) {
                $log.error("Error from getting data in getValidationsByDay", resp);
                return resp;
            });
        };

        $scope.getTranscriptionsByInstitution = function () {
            var stat = statService.getTranscriptionsByInstitution();
            return stat.then(function(data) {
                $scope.transcriptionsByInstitution = data;
                return data;
            }, function (resp) {
                $log.error("Error from getting data in getTranscriptionsByInstitution", resp);
                return resp;
            });
        };

        $scope.getValidationsByInstitution = function () {
            var stat = statService.getValidationsByInstitution();
            return stat.then(function(data) {
                $scope.validationsByInstitution = data;
                return data;
            }, function (resp) {
                $log.error("Error from getting data in getValidationsByInstitution", resp);
                return resp;
            });
        };

        $scope.getHourlyContributions = function () {
            var stat = statService.getHourlyContributions($scope.startDate, $scope.endDate);
            return stat.then(function(data) {
                $scope.hourlyContributions = data;
                return data;
            }, function (resp) {
                $log.error("Error from getting data in getHourlyContributions", resp);
                return resp;
            });
        };

        $scope.getHistoricalHonourBoard = function () {
            $scope.loading = true;
            var stat = statService.getHistoricalHonourBoard($scope.startDate, $scope.endDate);
            return stat.then(function(data) {
                $scope.historicalHonourBoard = data;
                $scope.loading = false;
                return data;
            }, function (resp) {
                $log.error("Error from getting data in getHistoricalHonourBoard", resp);
                return resp;
            });
        };

        $scope.setDateRange = function () {
            $scope.searchDate = [$scope.startDate, $scope.endDate];
            getNewVolunteerData();
        };

        $scope.exportToCSV = function (data, reportType) {
        //    var dt = new google.visualization.DataTable(data);
        //    var csv =  dt.toCSV();
        //    if (downloadCSV(csv, reportType) == "failed") {
                //request browser to trigger server api to download
                var url = config.exportCSVReport + "?reportType=" + reportType + "&&startDate=" + $scope.startDate + "&&endDate=" + $scope.endDate
                window.open(url, '_blank', '');
        //    };
        }

    }]);

    function drawGoogleChart($scope, jsonString, $elm, type) {
        var data = new google.visualization.DataTable(jsonString);

        if (type == 'table') {
            //Setchartoptions
            var options = {
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

            var chart = new google.visualization.Table($elm[0]);

        } else if (type == "barchart") {

            var options = {
                title: $scope.title,
                vAxis: {
                    title: $scope.yaxis
                },
                hAxis: {title: $scope.xaxis, slantedText:true},
                width: $scope.width,
                height: $scope.height,
                lineWidth: 1,
                legend: {position: 'none'},
                colors: ['#76A7FA'],
                chartArea:{left:60,top:10,bottom:60, height: "40%", width: "100%"}
            };

            var chart = new google.visualization.ColumnChart($elm[0]);

        } else  if (type == "piechart") {

            var options = {
                title: $scope.title,
                width: $scope.width,
                height: $scope.height,
                pieHole: $scope.pieHole,
                pieSliceText: 'value',
                pieSliceTextStyle: {
                    color: 'black',
                }

            };

            var chart = new google.visualization.PieChart($elm[0]);

        } else if (type == 'linechart') {
            var options = {
                hAxis: {title: $scope.xaxis},
                vAxis: {
                    title: $scope.yaxis
                },
                width: $scope.width,
                height: $scope.height,
                colors: ['#a52714'],
                legend: {position: 'none'},
                lineWidth: 1,
                chartArea:{left:60,top:10,bottom:60, height: "40%", width: "100%"}

            };

            var chart = new google.visualization.LineChart($elm[0]);
        }

        chart.draw(data,options);
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
    google.visualization.DataTable.prototype.toCSV = function () {
        var dt_cols = this.getNumberOfColumns();
        var dt_rows = this.getNumberOfRows();

        var csv_cols = [];
        var csv_out;

        // Iterate columns
        for (var i=0; i<dt_cols; i++) {
            // Replace any commas in column labels
            csv_cols.push(this.getColumnLabel(i).replace(/,/g,""));
        }

        // Create column row of CSV
        csv_out = csv_cols.join(",")+"\r\n";

        // Iterate rows
        for (i=0; i<dt_rows; i++) {
            var raw_col = [];
            for (var j=0; j<dt_cols; j++) {
                // Replace any commas in row values
                raw_col.push(this.getFormattedValue(i, j, 'label').replace(/,/g,""));
            }
            // Add row to CSV text
            csv_out += raw_col.join(",")+"\r\n";
        }

        return csv_out;
    }

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
                                        if (newVal != oldVal) {
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
                                        if (newVal != oldVal) {
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
                                        if (newVal != oldVal) {
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
                                        if (newVal != oldVal) {
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