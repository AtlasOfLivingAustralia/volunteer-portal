var digivolModule = angular.module('digivol', []);

digivolModule.run(['$anchorScroll', function($anchorScroll) {
  $anchorScroll.yOffset = function() {
    return angular.element('.navbar.navbar-fixed-top') || 0;
  }
}]);
