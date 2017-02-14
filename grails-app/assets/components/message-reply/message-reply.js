//= require_self
//= require_tree /message-reply/templates/

angular.module('messageReply',['forumService', 'message']).component('messageReply',{
    templateUrl: '/message-reply/message-reply.html',
    controller: ['forumService', '$scope', '$routeParams', '$sce', 'util', function (forumService, $scope, $routeParams, $sce, util) {
        var self = this;
        $scope.context = util.getContext();
        $scope.topicId = $routeParams.topicId;
        $scope.topic = null;
        $scope.messages = [];
        $scope.message = '';
        $scope.replyTo = '';
        $scope.$sce = $sce;
        $scope.util = util;
        $scope.preview = '';
        $scope.watch = false;
        $scope.task = null;
        $scope.project = null;
        $scope.creator = null;
        $scope.error = '';
        $scope.insertTagLine = true;
        $scope.fields = null;
        $scope.templateFields = null;
        $scope.imageMetaData = null;
        $scope.sampleImage = false;
        $scope.title = '';

        $scope.getMessageData = function () {
            var data = {
                messageText: $scope.message,
                watchTopic: $scope.watch?'on':''
            };
            return data;
        };

        $scope.getMessages = function () {
            var promise = forumService.getMessagesForTopic($scope.topicId);
            promise.then(function (resp) {
                var data = resp.data;
                if(data){
                    $scope.messages = data.messages;
                    $scope.replyTo = data.replyTo.id;
                    $scope.creator = data.userInstance;
                    $scope.task = data.taskInstance;
                    $scope.project = data.projectInstance;
                    $scope.watch = data.isWatched;
                    $scope.topic = data.topic;
                    $scope.fields = data.fields;
                    $scope.templateFields = data.templateFields;
                    $scope.imageMetaData = data.imageMetaData;
                    $scope.sampleImage = data.sampleImage;
                    $scope.title = data.title;

                    $scope.setTitleAndBreadcrumbs();
                    setTimeout(function () {
                        if (setImageViewerHeight && $scope.task) {
                            setupPanZoom();
                        }
                    })

                }
            });
        };

        $scope.getMessagePreview = function () {
            var promise = forumService.getMessagePreview($scope.topicId, $scope.replyTo, $scope.message);
            promise.then(function (resp) {
                if(resp.data && resp.data.markDownText){
                    $scope.preview = resp.data.markDownText;
                }
            });
        };

        $scope.saveNewMessage = function () {
            $scope.error = '';
            var data = $scope.getMessageData();
            var promise = forumService.saveNewMessage($scope.topicId, $scope.replyTo, data);
            promise.then(function (resp) {
                if(resp.data && resp.data.topicId){
                    util.goToTopic(resp.data.topicId);
                } else {
                    $scope.error = 'Could not save topic. An error at the server.';
                }
            }, function (resp) {
                if(resp.data && resp.data.message){
                    $scope.error = resp.data.message;
                } else {
                    $scope.error = 'Could not save topic. An error at the server.';
                }
            });
        };

        $scope.insertQuote = function () {
            var data = util.getSelectedText();
            var selection = data.element.toString();
            if (selection && selection.length > 0) {
                var message = "\n";
                if ($scope.insertTagLine) {
                    message += "> *" + data.author + " wrote:*  \n";
                }

                message += "> " + selection + "  ";
                $scope.message += message;
            }
        };

        $scope.setTitleAndBreadcrumbs = function () {
            $scope.$root.title =  'DIGIVOL | New Message';
            util.updateBreadcrumbs($scope.project, $scope.task, $scope.topic, true, [{title: "New Message"}]);
        };

        $scope.getMessages();
    }]
});