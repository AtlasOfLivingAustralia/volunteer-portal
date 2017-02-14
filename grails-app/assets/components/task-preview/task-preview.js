//= require_self
//= require_tree /task-preview/templates/
angular.module('taskPreview',['util']).component('taskPreview', {
    templateUrl: '/task-preview/task-preview.html',
    bindings: {
        taskInstance: '=',
        imageMetaData: '=',
        fields: '=',
        sampleImage: '=',
        templateFields: '='
    },
    controller: ['util', function (util) {
        var self = this;
        self.util = util;
    }]
});