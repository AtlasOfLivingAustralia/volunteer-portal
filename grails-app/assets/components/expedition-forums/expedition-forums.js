//= require_self (1)
//= require_tree /expedition-forums/templates

angular.module('expeditionForums',['util']).component('expeditionForums', {
    templateUrl: '/expedition-forums/expedition-forums.html',
    bindings: {
        forums: '=',
        stats: '=',
        onSearch: '&',
        onSort: '&',
        onPageUpdate: '&',
        total: '=',
        loading: '='
    },
    controller:['$scope', 'util', function ($scope, util) {
        var self = this;
        self.queryString = '';
        self.sort = '';
        self.order = '';
        self.max = 10;
        self.currentPage = 1;
        $scope.util = util;

        $scope.getPercentageTranscribed = function () {
            if(this.forum.percentageTranscribed == undefined){
                console.log('Computing getPercentageTranscribed - ' + this.forum.project.name);
                if( this.forum.taskCount){
                    this.forum.percentageTranscribed = Math.floor(this.forum.transcribedCount * 100 / this.forum.taskCount);
                } else {
                    this.forum.percentageTranscribed = 0;
                }
            }

            return this.forum.percentageTranscribed;
        };

        $scope.getPercentageValidated = function () {
            if(!this.forum.percentageValidated == undefined){
                if( this.forum.taskCount){
                    this.forum.percentageValidated = Math.floor(this.forum.validatedCount * 100 / this.forum.taskCount);
                } else {
                    this.forum.percentageValidated = 0;
                }
            }

            return this.forum.percentageValidated;
        };

        $scope.getNumberOfExpeditionTopics = function () {
            return self.stats[this.forum.project.name].projectTopicCount;
        };

        $scope.getNumberOfTaskTopics = function () {
            return self.stats[this.forum.project.name].taskTopicCount;
        };

        $scope.searchQuery = function () {
            self.onSearch({query: self.queryString});
        };

        $scope.updateSort = function (field) {
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

        $scope.onPageUpdate = function () {
            var offset = (self.currentPage - 1) * self.max;
            self.onPageUpdate({max: self.max, offset: offset});
        }
    }]
});