//= require_self
//= require_tree /search-results/templates/
angular.module('searchResults', ['util', 'ngRoute', 'heading', 'forumService']).component('searchResults', {
    templateUrl: '/search-results/search-results.html',
    controller: ['util', '$routeParams', '$scope', '$sce', 'forumService', function (util, $routeParams, $scope, $sce, forumService) {
        var self = this;
        $scope.context = util.getContext();
        $scope.searchText = $routeParams.searchText;
        $scope.heading = "Search results: '" + $scope.searchText + "'";
        $scope.total = 0;
        $scope.currentPage = 1;
        $scope.max = 10;
        $scope.results = [];
        $scope.$sce = $sce;
        $scope.util = util;


        var breadcrumbs = [{title: 'Forum', href: util.getForumLink('featured')}, {title: $scope.heading}];
        util.setBreadcrumbs(breadcrumbs);

        self.searchForText = function (max, offset) {
            max = max || $scope.max;
            offset = offset || 0;
            var promise = forumService.searchTextInForums($scope.searchText, max, offset);
            promise.then(function (resp) {
                if(resp.data){
                    $scope.total = resp.data.totalCount;
                    $scope.results = resp.data.results;
                }
            })
        };

        self.onPageUpdate = function () {
            var offset = ($scope.currentPage - 1) * $scope.max;
            self.searchForText($scope.max, offset);
        };

        self.searchForText();
    }]
});