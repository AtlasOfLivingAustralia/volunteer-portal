//= require_self (1)
//= require_tree /forum-dashboard/templates

angular.module('forumDashboard',['topicList', 'watchedTopics', 'expeditionForums', 'ngRoute', 'forumConfig', 'forumService', 'util']).component('forumDashboard',{
    templateUrl: '/forum-dashboard/forum-dashboard.html',
    controller: ['forumService', '$log', '$scope', '$routeParams', 'util', function (f, $log, $scope, $routeParams, util) {
        var self = this;
        $scope.$root.title =  'DIGIVOL | Forum';
        var activeView = $routeParams.tab ||'featured';
        $scope.util = util;
        $scope.searchText = '';

        $scope.activeTab = 'tabRecentTopics';
        $scope.generalTopics = [];
        $scope.generalTopicsCount = 0;
        $scope.generalTopicsCurrentPage = 0;
        $scope.generalTopicsSortField = 'lastReplyDate';
        $scope.generalTopicsOrderDirection = 'asc';
        $scope.generalTopicsInit = false;
        $scope.generalForumsRequestSent = false;

        $scope.featuredTopics = [];
        $scope.featuredTopicsCount = 0;
        $scope.featuredTopicsInit = false;
        $scope.featuredTopicsSortField = 'lastReplyDate';
        $scope.featuredTopicsOrderDirection = 'asc';
        $scope.featuredTopicsCurrentPage = 0;
        $scope.featuredForumsRequestSent = false;

        $scope.watchedTopics = [];
        $scope.watchedTopicsSortField = 'title';
        $scope.watchedTopicsOrderDirection = 'asc';
        $scope.watchedTopicsInit = false;
        $scope.watchedTopicsRequestSent = false;

        $scope.expeditionForums = [];
        $scope.expeditionForumsCount = 0;
        $scope.expeditionForumsQueryString = '';
        $scope.expeditionForumsSortField = 'completed';
        $scope.expeditionForumsOrderDirection = 'asc';
        $scope.expeditionForumsStats = {};
        $scope.expeditionForumsRequestSent = false;
        $scope.expeditionForumsInit = false;

        $scope.getGeneralTopics  = function (sort, order, max, offset) {
            $scope.generalTopicsSortField = sort || $scope.generalTopicsSortField;
            $scope.generalTopicsOrderDirection = order || $scope.generalTopicsOrderDirection;

            $scope.generalForumsRequestSent = true;
            var promise = f.getGeneralTopics(sort, order, max, offset);

            promise.then(function (response) {
                $log.debug(response.data);
                if(response.data && response.data.topics) {
                    $scope.generalTopics.splice(0,$scope.generalTopics.length);
                    $scope.generalTopics.push.apply($scope.generalTopics, response.data.topics);
                    $scope.generalTopicsCount = response.data.totalCount;
                }

                util.setBreadcrumbForDashboard('general');

                $scope.generalForumsRequestSent = false;
            }, function () {
                $scope.generalForumsRequestSent = false;
            });
        };

        $scope.updateGeneralTopics = function (sort, order) {
            $scope.generalTopicsSortField = sort;
            $scope.generalTopicsOrderDirection = order;
            $scope.getGeneralTopics(sort, order, undefined, undefined)
        };

        $scope.generalTopicsPageChange = function (max, offset) {
            $scope.getGeneralTopics(undefined, undefined, max, offset);
        };

        $scope.getFeaturedTopics = function (sort, order, max, offset) {
            $scope.featuredTopicsSortField = sort || $scope.featuredTopicsSortField;
            $scope.featuredTopicsOrderDirection = order || $scope.featuredTopicsOrderDirection;
            $scope.featuredForumsRequestSent = true;

            var promise = f.getFeaturedTopics($scope.featuredTopicsSortField, $scope.featuredTopicsOrderDirection, max, offset);
            promise.then(function (response) {
                $log.debug(response.data);
                if(response.data && response.data.featuredTopics) {
                    $scope.featuredTopics.splice(0,$scope.featuredTopics.length);
                    $scope.featuredTopics.push.apply($scope.featuredTopics, response.data.featuredTopics);
                    $scope.featuredTopicsCount = response.data.totalCount;
                }

                util.setBreadcrumbForDashboard('featured');
                $scope.featuredForumsRequestSent = false;
            },function () {
                $scope.featuredForumsRequestSent = false;
            });
        };

        $scope.updateFeaturedTopics = function (sort, order) {
            $scope.getFeaturedTopics(sort, order, undefined, undefined);
        };

        $scope.featuredTopicsPageChange = function (max, offset) {
            $scope.getFeaturedTopics(undefined, undefined, max, offset);
        };


        $scope.getWatchedTopics = function (sort, order) {
            $scope.watchedTopicsSortField = sort;
            $scope.watchedTopicsOrderDirection = order;
            var promise = f.getWatchedTopics(sort,order);
            $scope.watchedTopics.splice(0,$scope.watchedTopics.length);
            $scope.watchedTopicsRequestSent = true;

            promise.then(function (response) {
                $log.debug(response.data);
                if(response.data && response.data.topics) {
                    $scope.watchedTopics.push.apply($scope.watchedTopics, response.data.topics);
                }

                util.setBreadcrumbForDashboard('watched');
                $scope.watchedTopicsRequestSent = false;
            }, function () {
                $scope.watchedTopicsRequestSent = false;
            });
        };

        $scope.getExpeditionForums = function (sort, order, query, max, offset) {
            $scope.expeditionForumsSortField = sort || $scope.expeditionForumsSortField;
            $scope.expeditionForumsOrderDirection = order || $scope.expeditionForumsOrderDirection;
            $scope.expeditionForumsQueryString = query || $scope.expeditionForumsQueryString;

            var promise = f.getExpeditionForums($scope.expeditionForumsSortField,$scope.expeditionForumsOrderDirection, $scope.expeditionForumsQueryString, max, offset);
            $scope.expeditionForumsRequestSent = true;
            promise.then(function (response) {
                $log.debug(response.data);
                if(response.data && response.data.projectSummaryList) {
                    $scope.expeditionForumsCount = response.data.projectSummaryList.matchingProjectCount;
                    $scope.expeditionForums.splice(0,$scope.expeditionForums.length);
                    $scope.expeditionForums.push.apply($scope.expeditionForums, response.data.projectSummaryList.projectRenderList);
                    $scope.expeditionForumsStats = response.data.forumStats;
                   }

                util.setBreadcrumbForDashboard('expedition');
                $scope.expeditionForumsRequestSent = false;
            },function () {
                $scope.expeditionForumsRequestSent = false;
            });
        };

        $scope.expeditionForumsOrderBy = function (sort, order) {
            $scope.getExpeditionForums(sort, order);
        };

        $scope.expeditionForumsSearch = function (query) {
            $scope.expeditionForumsQueryString = query;
            $scope.getExpeditionForums('completed', 'asc', query);
          };

        $scope.expeditionForumsPageChange = function (max, offset) {
            $scope.getExpeditionForums(undefined, undefined, undefined, max, offset);
        };

        $scope.initTabContent= function(tab){
            switch (tab){
                case 'expedition':
                    if(!$scope.expeditionForumsInit){
                        $scope.getExpeditionForums();
                        // $state.go('/forum-dashboard/tabGeneralTopics', {}, {notify: false});
                    }

                    $scope.expeditionForumsInit = true;
                    $scope.activeTab = 'tabProjectForums';
                    break;
                case 'watched':
                    if(!$scope.watchedTopicsInit){
                        $scope.getWatchedTopics();
                    }

                    $scope.watchedTopicsInit = true;
                    $scope.activeTab = 'tabWatchedTopics';
                    break;
                case 'general':
                    if(!$scope.generalTopicsInit){
                        $scope.updateGeneralTopics();
                    }

                    $scope.generalTopicsInit = true;
                    $scope.activeTab = 'tabGeneralTopics';
                    break;
                case 'featured':
                    if(!$scope.featuredTopicsInit){
                        $scope.updateFeaturedTopics();
                    }

                    $scope.featuredTopicsInit = true;
                    $scope.activeTab = 'tabRecentTopics';
                    break;
            }
        };

        $scope.initTabContent(activeView);
    }]
});