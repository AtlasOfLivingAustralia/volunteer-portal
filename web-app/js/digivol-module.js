var digivolModule = angular.module('digivol', []);

digivolModule.run(['$http', '$log', '$rootScope', function($http, $log, $rootScope) {
  $rootScope.unreadCount = 0;
  $http.get(BVP_JS_URLS.unreadValidatedCount).then(function(response) {
    $rootScope.unreadCount = response.data.count;
  }, function(error) {
    console.log("couldn't retrieve unread validated count", error);
  });
  $rootScope.$on('unreadValidationViewed', function(task) {
    $log.debug("Got unreadValidationViewed for task:", task);
    $rootScope.unreadCount -= 1;
  });
}]);