//= require_self
//= require_tree /topic-view/templates/

angular.module('topicView', ['forumDashboard', 'ngRoute', 'forumService', 'util']).component('topicView',{
    templateUrl: '/topic-view/topic-view.html',
    controller: ['$routeParams', '$scope', 'forumService', '$sce', 'util', function ($routeParams, $scope, forumService, $sce, util) {
        var self = this;
        $scope.topic = {};
        $scope.topicId = $routeParams.topicId;
        $scope.watch = false;
        $scope.messages = [];
        $scope.$sce = $sce;
        $scope.context = util.getContext();
        $scope.title = '';
        $scope.taskInstance = null;
        $scope.projectInstance = null;
        $scope.fields = null;
        $scope.templateFields = null;
        $scope.imageMetaData = null;
        $scope.sampleImage = false;
        $scope.util = util;
        $scope.error = '';

        self.util = util;
        self.getForumTopic = function () {
            var promise = forumService.getForumTopic($scope.topicId);
            promise.then(function (resp) {
                $scope.topic = resp.data.topic;
                $scope.watch = resp.data.isWatched;
                $scope.messages = resp.data.messages;
                $scope.title = resp.data.title;
                $scope.taskInstance = resp.data.taskInstance;
                $scope.projectInstance = resp.data.projectInstance;
                $scope.fields = resp.data.fields;
                $scope.templateFields = resp.data.templateFields;
                $scope.imageMetaData = resp.data.imageMetaData;
                $scope.sampleImage = resp.data.sampleImage;

                $scope.$root.title =  'DIGIVOL | Forum Topic: ' + $scope.title;
                util.updateBreadcrumbs(resp.data.projectInstance, resp.data.taskInstance, resp.data.topic, true);

                setTimeout(function () {
                    if (setImageViewerHeight) {
                        setupPanZoom();
                    }
                })
            });
        };

        self.deleteMessage = function (messageId) {
            $scope.error = '';
            var promise = forumService.deleteMessage(messageId);

            promise.then(function (resp) {
                self.getForumTopic();
            }, function () {
                $scope.error = 'You do not have sufficient privileges to edit/delete this message!'
            });
        };

        self.updateWatch = function () {
            forumService.setTopicWatchStatus($scope.topicId, $scope.watch);
        };

        self.goBack = function () {
            if($scope.projectInstance && $scope.projectInstance.id){
                util.goToProjectForum($scope.projectInstance.id);
            } else {
                util.goToForum('general');
            }
        };

        self.goToTask = function () {
            util.goToTask($scope.taskInstance.id);
        };

        self.getForumTopic();
    }]
});