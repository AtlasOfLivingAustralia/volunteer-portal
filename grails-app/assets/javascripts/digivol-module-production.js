angular.module('digivol').config(['$compileProvider', function ($compileProvider) {
  $compileProvider.debugInfoEnabled(false);
}]).config(['$logProvider', function($logProvider) {
  $logProvider.debugEnabled(false);
}]);