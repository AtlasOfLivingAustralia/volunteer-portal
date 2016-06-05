var digivolModule = angular.module('digivol', []);

digivolModule.run(['$http', '$log', '$rootScope', function($http, $log, $rootScope) {
  $rootScope.unreadCount = 0;
  if (angular.isDefined(BVP_JS_URLS) && angular.isDefined(BVP_JS_URLS.unreadValidatedCount)) {
    $http.get(BVP_JS_URLS.unreadValidatedCount).then(function(response) {
      $rootScope.unreadCount = response.data.count;
    }, function(error) {
      $log.warn("couldn't retrieve unread validated count", error);
    });
    $rootScope.$on('unreadValidationViewed', function(task) {
      $log.debug("Got unreadValidationViewed for task:", task);
      if ($rootScope.unreadCount > 0) {
        $rootScope.unreadCount -= 1;
      } else {
        $log.warn("Got unreadValidationViewed when unreadCount is 0!")
      }
    });
  } else {
    $log.warn("Unread validated count URL is not defined!")
  }
}]);
