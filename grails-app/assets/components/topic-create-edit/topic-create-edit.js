//= require_self
//= require_tree /topic-create-edit/templates/

angular.module('topicCreateEdit', ['ngRoute', 'forumDashboard', 'forumService', 'util', 'taskPreview']).component('topicCreateEdit', {
    templateUrl: '/topic-create-edit/topic-create-edit.html',
    bindings: {
        create: '='
    },
    controller: ['$routeParams', '$scope', 'forumService', '$location', '$log', 'util', function ($routeParams, $scope, forumService, $location, $log, util ) {
        var self = this;
        $scope.topicId = $routeParams.topicId;
        $scope.projectId = $routeParams.projectId;
        $scope.taskId = $routeParams.taskId;
        $scope.topic = {};
        $scope.errorMessage = '';

        self.getSettings = function () {
            var promise = forumService.getTopicSettings($scope.topicId);
            promise.then(function (resp) {
                var topic = resp.data.topic;
                if(topic){
                    $scope.topic = topic;
                } else {
                    $scope.errorMessage = 'Topic id missing or topic not found! ' + $scope.topicId;
                }

                $scope.$root.title =  'DIGIVOL | ' + $scope.topic.title;
                util.updateBreadcrumbs(resp.data.projectInstance, resp.data.taskInstance, topic, true, [{title: "Edit Topic"}]);
            }, function () {
                $scope.errorMessage = 'An error occurred retrieving topic with id - '  + $scope.topicId;
            })
        };

        self.updateSettings = function () {
            var promise = forumService.updateTopicSettings($scope.topicId, self.getSavedSettings());
            promise.then(function (resp) {
                util.goToForum('featured');
            });
        };

        self.getSavedSettings = function () {
            var topic = $scope.topic;

            return {
                title: topic.title,
                priority: topic.priority,
                sticky: topic.sticky?'on':'',
                locked: topic.locked?'on':'',
                featured: topic.featured?'on':'',
                text: topic.text,
                watchTopic: topic.watch?'on':''
            };
        };

        self.getTopicCreationInfo = function () {
            var promise = forumService.getForumTopicCreationPrerequisiteInfo($scope.topicId, $scope.projectId, $scope.taskId);
            promise.then(function (resp) {
                if(resp.data){
                    var data = resp.data;
                    $scope.topic = {
                        isModerator: resp.data.isModerator,
                        sticky: false,
                        locked: false,
                        featured: false,
                        priority: 'Normal',
                        text: '',
                        watch: false
                    };

                    $scope.$root.title =  'DIGIVOL | New Topic';
                    util.updateBreadcrumbs(data.projectInstance, data.taskInstance, undefined, true, [{title: "New Topic"}]);
                }
            })
        };

        self.createTopic = function () {
            var promise = forumService.createNewForumTopic($scope.topicId, $scope.projectId, $scope.taskId, self.getSavedSettings());

            promise.then(function (resp) {
                if(resp.data){
                    $log.debug(resp.data);
                    util.goToTopic(resp.data.topicId);
                }
            });
        };

        if(self.create){
            self.getTopicCreationInfo();
        } else {
            self.getSettings();
        }
    }]
});