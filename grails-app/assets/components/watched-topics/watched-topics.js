//= require_self (1)
//= require_tree /watched-topics/templates

angular.module('watchedTopics',['forumDashboard', 'forumService', 'util']).component('watchedTopics', {
    templateUrl: '/watched-topics/watched-topics.html',
    bindings: {
        'topics': '=',
        'onSort': '&',
        'loading': '='
    },
    controller: ['$scope', 'forumService', 'util', function ($scope, forumService, util) {
        var self = this;
        self.max = 10;
        self.currentPage = 1;
        $scope.util = util;

        $scope.updateSort = function(field){
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

            self.onSort({sort: self.sort, order: self.order});
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

        $scope.removeTopic = function (topic) {
            var index = self.topics.indexOf(topic);
            if(index >= 0){
                self.topics.splice(index, 1);
            }
        };

        $scope.stopTopicWatch = function () {
            var topic = this.topic;
            self.loading = true;
            var promise = forumService.setTopicWatchStatus(this.topic.id, false);
            promise.then(function () {
                $scope.removeTopic(topic);
                self.loading = false;
            }, function () {
                self.loading = false;
            });
        };

        $scope.goToTopic = function () {
            util.goToTopic(this.topic.id);
        }
    }]
});