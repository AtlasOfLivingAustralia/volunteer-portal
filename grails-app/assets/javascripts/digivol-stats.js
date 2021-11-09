//=encoding UTF-8
//=require digivol-module
//=require livestamp
//=require_self

function digivolStats(config) {
    var stats = angular.module('stats', ['digivol']);

    stats.controller('StatsCtrl', [
        '$scope', '$http', '$log',
        function ($scope, $http, $log) {
            $scope.lbLoading = true;
            $scope.conLoading = true;

            $scope.transcriberCount = null;
            $scope.completedTasks = null;
            $scope.totalTasks = null;

            $scope.daily = {userId: -1, email: '', name: '', score: null};
            $scope.weekly = {userId: -1, email: '', name: '', score: null};
            $scope.monthly = {userId: -1, email: '', name: '', score: null};
            $scope.alltime = {userId: -1, email: '', name: '', score: null};

            $scope.contributors = [];

            $scope.avatarUrl = function (user) {
                var email = user.email || "";
                return "//www.gravatar.com/avatar/" + email + "?s=40&d=mm"
            };

            $scope.userProfileUrl = function (user) {
                var id = user.userId || "";
                return config.userProfileUrl.replace("-1", id);
            };

            $scope.projectUrl = function (project) {
                var id = project.projectId || "";
                return config.projectUrl.replace('-1', id);
            };

            $scope.additionalTranscribedThumbs = function (contrib) {
                return Math.max(contrib.transcribedItems - 5, 0);
            };


            $scope.taskSummaryUrl = function (thumb) {
                var id = thumb.id || "";
                return config.taskSummaryUrl.replace('-1', id);
            };

            var p = $http.get(config.statsUrl, {
                params: {
                    institutionId: config.institutionId,
                    projectId: config.projectId,
                    projectType: config.projectType,
                    tags: config.tags,
                    maxContributors: config.maxContributors,
                    disableStats: config.disableStats,
                    disableHonourBoard: config.disableHonourBoard
                }
            });
            p.then(function (resp) {
                    angular.extend($scope, resp.data);
                    $scope.lbLoading = false;
                },
                function (resp) {
                    $log.error("Got error response for leaderboard", resp);
                });

            var c = $http.get(config.contributorsUrl, {
                params: {
                    institutionId: config.institutionId,
                    projectId: config.projectId,
                    projectType: config.projectType,
                    tags: config.tags,
                    maxContributors: config.maxContributors
                }
            });
            c.then(function (resp) {
                   angular.extend($scope, resp.data);
                   $scope.conLoading = false;
                },
                function (resp) {
                    $log.error("Got error response for contributors", resp);
                });
        }
    ]);
}

