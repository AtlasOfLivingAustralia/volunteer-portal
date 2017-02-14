//= require_self
//= require_tree /project-forum/templates/

angular.module('projectForum', ['forumService', 'ngRoute', 'util']).component('projectForum', {
    templateUrl: '/project-forum/project-forum.html',
    controller: ['forumService', '$routeParams', '$scope', 'util', '$sce', function (forumService, $routeParams, $scope, util, $sce) {
        var self = this;
        $scope.projectId = $routeParams.projectId;
        $scope.context = util.getContext();
        $scope.project = null;
        $scope.topics = null;
        $scope.totalCount = null;
        $scope.isWatching = false;
        $scope.watchStatusMessage = '';
        $scope.loading = false;
        $scope.topicSortField = '';
        $scope.topicOrderDirection = 'asc';
        $scope.taskTopics = null;
        $scope.taskTopicTotalCount = null;
        $scope.taskTopicLoading = false;
        $scope.taskTopicSortField = '';
        $scope.taskTopicOrderDirection = 'asc';
        $scope.$sce = $sce;

        self.getProject= function (sort, order, max, offset) {
            $scope.loading = true;
            $scope.topicSortField = sort || $scope.topicSortField;
            $scope.topicOrderDirection = order || $scope.topicOrderDirection;

            var promise = forumService.getProjectForum($scope.projectId, $scope.topicSortField, $scope.topicOrderDirection, max, offset);
            promise.then(function (resp) {
                if(resp.data && resp.data.projectInstance){
                    $scope.project = resp.data.projectInstance;
                    $scope.topics = resp.data.topics.topics;
                    $scope.totalCount = resp.data.topics.totalCount;
                    $scope.isWatching = resp.data.isWatching;
                }

                $scope.$root.title =  'DIGIVOL | ' + $scope.project.name;
                util.updateBreadcrumbs(resp.data.projectInstance, resp.data.taskInstance, resp.data.topic, true);
                $scope.loading = false;
            }, function () {
                $scope.loading = false;
            });
        };

        self.getTaskTopics = function (sort, order, max, offset) {
            $scope.taskTopicLoading = true;
            $scope.taskTopicSortField = sort || $scope.taskTopicSortField;
            $scope.taskTopicOrderDirection = order || $scope.taskTopicOrderDirection;

            var promise = forumService.getProjectTaskTopics($scope.projectId, $scope.taskTopicSortField, $scope.taskTopicOrderDirection, max, offset);
            promise.then(function (resp) {
                if(resp.data && resp.data.projectInstance){
                    $scope.taskTopics = resp.data.topics;
                    $scope.taskTopicTotalCount = resp.data.totalCount;
                }

                $scope.taskTopicLoading = false;
            }, function () {
                $scope.taskTopicLoading = false;
            });
        };

        self.setWatchingStatus = function () {
            $scope.watchStatusMessage = '';
            var promise = forumService.setProjectWatchStatus($scope.projectId, $scope.isWatching);
            promise.then(function (resp) {
                if(resp.data){
                    if(resp.data.success){
                        $scope.watchStatusMessage = resp.data.message;
                    }
                }
            })
        };

        self.getProjectLink = function () {
            return util.getProjectLink($scope.projectId);
        };

        self.getSortedTopics = function (sort, order) {
            self.getProject(sort, order, undefined, undefined);
        };

        self.getPageForExpedition = function (max, offset) {
            self.getProject(undefined, undefined, max, offset);
        };

        self.getSortedTaskTopics = function (sort, order) {
            self.getTaskTopics(sort, order, undefined, undefined);
        };

        self.getPageForTaskTopics = function (max, offset) {
            self.getTaskTopics(undefined, undefined, max, offset);
        };

        self.goToCreateTopic = function () {
            util.goToCreateTopicForProject($scope.projectId);
        };

        self.initForTopics = function (type) {
            switch (type){
                case 'task':
                    if(!$scope.taskTopics){
                        self.getTaskTopics();
                    }
                    break;
                case 'expedition':
                    if(!$scope.topics){
                        self.getTopics();
                    }
                    break;
            }
        };

        self.getProject()
    }]
});