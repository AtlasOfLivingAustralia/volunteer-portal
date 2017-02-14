//= require_self
//= require_tree /message-edit/templates/

angular.module('messageEdit',['util', 'ngRoute', 'forumService']).component('messageEdit',{
    templateUrl: '/message-edit/message-edit.html',
    controller: ['util', '$routeParams', '$scope', '$sce', 'forumService', function (util, $routeParams, $scope, $sce, forumService) {
        var self = this;
        $scope.topicId = $routeParams.topicId;
        $scope.messageId = $routeParams.messageId;
        $scope.message = '';
        $scope.$sce = $sce;
        $scope.util = util;
        $scope.preview = '';
        $scope.watch = false;
        $scope.context = util.getContext();

        $scope.getMessageData = function () {
            var data = {
                messageText: $scope.message,
                watchTopic: $scope.watch?'on':''
            };
            return data;
        };

        $scope.getMessage = function () {
            var promise = forumService.getMessageForId($scope.messageId);
            promise.then(function (resp) {
                var data = resp.data;
                if(data){
                    $scope.watch = data.isWatched;
                    $scope.message = data.messageText;
                    $scope.preview = data.forumMessage.text;

                    $scope.setTitleAndBreadcrumbs();
                }
            });
        };

        $scope.getMessagePreview = function () {
            var promise = forumService.getEditMessagePreview($scope.messageId, $scope.message);
            promise.then(function (resp) {
                if(resp.data && resp.data.markDownText){
                    $scope.preview = resp.data.markDownText;
                }
            });
        };

        $scope.updateMessage = function () {
            $scope.error = '';
            var data = $scope.getMessageData();
            var promise = forumService.updateMessage($scope.messageId, data);
            promise.then(function (resp) {
                util.goToTopic($scope.topicId);
            }, function (resp) {
                $scope.error = 'Could not save message. An error at the server.';
            });
        };

        $scope.setTitleAndBreadcrumbs = function () {
            $scope.$root.title =  'DIGIVOL | Edit Message';
            util.updateBreadcrumbs($scope.project, $scope.task, $scope.topic, true, [{title: "Edit Message"}]);
        };

        $scope.getMessage();
    }]
});