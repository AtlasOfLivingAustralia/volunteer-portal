//= require_self
//= require_tree /breadcrumbs/templates/

angular.module('breadcrumbs', ['forumConfig']).component('breadcrumbs', {
    templateUrl: '/breadcrumbs/breadcrumbs.html',
    controller: ['config', 'util', '$scope', function (config, util, $scope) {
        var self = this;
        $scope.breadcrumbs = config.breadcrumbs;
        self.isLastItem = function (index) {
            return $scope.breadcrumbs.length == (index + 1);
        }
    }]
});
