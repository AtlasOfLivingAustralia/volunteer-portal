//= require_self
//= require_tree /heading/templates/
angular.module('heading', ['util']).component('heading', {
    templateUrl: '/heading/heading.html',
    bindings: {
      title: '=',
    },
    controller: ['util', function (util) {
        var self = this;
    }]
});