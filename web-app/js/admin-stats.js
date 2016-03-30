function adminStats(config) {

    var app = angular.module('statApp', []);

    app.config(['$httpProvider', function ($httpProvider) {
        // enable http caching
        $httpProvider.defaults.cache = true;
    }]);

    app.service('statService', ['$http', '$q', function($http, $q) {
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

    app.controller('statsCtrl', ['$scope', 'statService', '$log', function ($scope, statService, $log) {

        $scope.searchDate = [$scope.startDate, $scope.endDate];

        var getNewVolunteerData = function () {
            var stats = statService.getVolunteer($scope.startDate, $scope.endDate);
            stats.then(function(data){
                angular.extend($scope, data);
            }, function (resp) {
                $log.error("Got error response for leaderboard", resp);
            });
        };

        getNewVolunteerData();

        $scope.getActiveTranscribers = function () {
            return statService.getActiveTranscribers($scope.startDate, $scope.endDate);
        };

        $scope.getTranscriptionsByVolunteerAndProject = function () {
            return statService.getTranscriptionsByVolunteerAndProject($scope.startDate, $scope.endDate);
        };

        $scope.getTranscriptionsByDay = function () {
            return statService.getTranscriptionsByDay($scope.startDate, $scope.endDate);
        };

        $scope.getValidationsByDay = function () {
            return statService.getValidationsByDay($scope.startDate, $scope.endDate);
        };

        $scope.getTranscriptionsByInstitution = function () {
            return statService.getTranscriptionsByInstitution();
        };

        $scope.getValidationsByInstitution = function () {
            return statService.getValidationsByInstitution();
        };

        $scope.getHourlyContributions = function () {
            return statService.getHourlyContributions($scope.startDate, $scope.endDate);
        };

        $scope.getHistoricalHonourBoard = function () {
            return statService.getHistoricalHonourBoard($scope.startDate, $scope.endDate);
        };

        $scope.setDateRange = function () {
            //$scope.searchDate = $scope.startDate;
            $scope.searchDate = [$scope.startDate, $scope.endDate];
            getNewVolunteerData();
        };
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

            //Instantiateanddrawourchart,passinginsomeoptions.
            var chart = new google.visualization.Table($elm[0]);
        } else if (type == "barchart") {

            var options = {
                title: $scope.title,
                vAxis: {
                    title: $scope.yaxis
                },
                hAxis: {title: $scope.xaxis},
                width: $scope.width,
                height: $scope.height,
                lineWidth: 1,
                chartArea:{left:70,top:20,bottom:0, height: "70%", width: "100%"}
            };
            // Instantiate and draw our chart, passing in some options.
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
            // Instantiate and draw our chart, passing in some options.
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
                chartArea:{left:70,top:20,bottom:0, height: "70%", width: "100%"}

            };

            var chart = new google.visualization.LineChart($elm[0]);
        }
        chart.draw(data,options);
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