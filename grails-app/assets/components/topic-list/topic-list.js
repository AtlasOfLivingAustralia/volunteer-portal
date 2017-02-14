//= require_self (1)
//= require_tree /topic-list/templates

angular.module('topicList',['ngRoute', 'ui.bootstrap.pagination', 'ui.bootstrap.tpls', 'forumDashboard', 'forumService', 'util']).component('topicList', {
    templateUrl: '/topic-list/topic-list.html',
    bindings: {
        'topics': '=',
        'total': '=',
        'onSort': '&',
        'onPageUpdate': '&',
        'hidePagination': '@',
        'loading': '=',
        'showCreateBtn': '=',
        'max': '@',
        'disableSorting': '@'
    },
    controller: ['$scope', 'forumService', '$location', 'util', function ($scope, forumService, $location, util) {
        var self = this;
        self.currentPage = 1;
        self.max = self.max || 10;
        $scope.util = util;

        $scope.updateSort = function(field){
            if(self.disableSorting){
                return
            }

            // when an unsorted column is clicked, make sure it is sorted in ascending order.
            if(self.sort != field){
                self.order = ''
            }

            self.sort = field;
            switch (self.order){
                case 'asc':
                    self.order = 'desc';
                    break;
                case 'desc':
                    self.order = 'asc';
                    break;
                default:
                    self.order = 'asc';
                    break;
            }

            self.onSort && self.onSort({sort: self.sort, order: self.order});
        };

        $scope.isSortedOnField = function (field) {
            return self.sort == field;
        };

        $scope.isAscending = function (field) {
            return ( self.sort == field ) && ( self.order == 'asc');
        };

        $scope.isDescending = function (field) {
            return ( self.sort == field ) && ( self.order == 'desc');
        };

        $scope.isForumEmpty = function () {
            if(self.total == 0) {
                return true;
            } else {
                return false;
            }
        };

        $scope.onPageUpdate = function () {
            var offset = (self.currentPage - 1) * self.max;
            self.onPageUpdate({max: self.max, offset: offset});
        };

        $scope.getLastReplyDate = function () {
            if(this.topic.dateCreated == this.topic.lastReplyDate){
                return ''
            } else {
                return this.topic.lastReplyDate
            }
        };

        $scope.isFeaturedTopic = function () {
            return this.topic.featured;
        };

        $scope.isSticky = function () {
            return this.topic.sticky;
        };

        $scope.isLocked = function () {
            return this.topic.locked;
        };

        $scope.deleteTopic = function () {
            var topic = this.topic;
            var promise = forumService.deleteTopic(this.topic.id);
            self.loading = true;
            promise.then(function () {
                $scope.onPageUpdate();
            }, function () {
                alert('An error occurred when deleting topic - ' + topic.title);
                self.loading = false;
            })
        };

        $scope.createTopic = function () {
            $location.url('/topic/create');
        }
    }]
});