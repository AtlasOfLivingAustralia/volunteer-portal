//= encoding UTF-8
//= require angular-assets
//= require_self
//= require ${grails.util.Environment.currentEnvironment == grails.util.Environment.PRODUCTION ? 'digivol-module-production' : 'digivol-module-dev'}

var digivolModule = angular.module('digivol', []);

digivolModule.run(['$anchorScroll', function($anchorScroll) {
  $anchorScroll.yOffset = function() {
    return angular.element('.navbar.navbar-fixed-top') || 0;
  }
}]);
