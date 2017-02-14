//= require_self
//= require_tree /message/templates/
angular.module('message', ['util']).component('message',{
    templateUrl: '/message/message.html',
    bindings:{
        topicId: '=',
        msg: '=',
        preview: '=',
        watch: '=',
        getMessagePreview: '&',
        saveNewMessage: '&',
    },
    controller: ['util', '$scope', '$sce', function (util, $scope, $sce) {
        var self = this;
        $scope.context = util.getContext();
        $scope.util = util;
        $scope.$sce = $sce;
    }]
});