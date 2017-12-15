angular.module('digivol').config(['$compileProvider', function ($compileProvider) {
  $compileProvider.debugInfoEnabled(true);
}]).config(['$logProvider', function($logProvider) {
  $logProvider.debugEnabled(true);
}]);