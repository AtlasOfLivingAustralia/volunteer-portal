function digivolStats(config) {
  var stats = angular.module('stats',[]);

  stats.controller('StatsCtrl', [
    '$scope', '$http', '$log',
    function ($scope, $http, $log) {
      $scope.loading = true;

      $scope.transcriberCount = null;
      $scope.completedTasks = null;
      $scope.totalTasks = null;

      $scope.daily = { userId: -1, email: '', name: '', score: null };
      $scope.weekly = { userId: -1, email: '', name: '', score: null };
      $scope.monthly = { userId: -1, email: '', name: '', score: null };
      $scope.alltime = { userId: -1, email: '', name: '', score: null };

      $scope.contributors = [];

      $scope.avatarUrl = function (user) {
        var email = user.email || "";
        return "//www.gravatar.com/avatar/" + email + "?s=40&d=mm"
      };

      $scope.userProfileUrl = function(user) {
        var id = user.userId || "";
        return config.userProfileUrl.replace("-1", id);
      };

      $scope.projectUrl = function(project) {
        var id = project.projectId || "";
        return config.projectUrl.replace('-1', id);
      };

      $scope.additionalTranscribedThumbs = function(contrib) {
        return Math.max(contrib.transcribedItems - 5, 0);
      };

      var p = $http.get(config.statsUrl, {
        params: {
          institutionId: config.institutionId,
          projectId: config.projectId,
          maxContributors: config.maxContributors,
          disableStats: config.disableStats,
          disableHonourBoard: config.disableHonourBoard
        }
      });
      p.then(function (resp) {
          angular.extend($scope, resp.data);
          $scope.loading = false;
        },
        function (resp) {
          $log.error("Got error response for leaderboard", resp);
        });
    }
  ]);
}
