angular.module('forumApp', ['forumDashboard', 'topicCreateEdit', 'topicView', 'projectForum', 'breadcrumbs',
    'messageReply', 'messageEdit', 'searchResults', 'ngRoute']).config([
    '$routeProvider', '$locationProvider', function ($routeProvider, $locationProvider) {
        $locationProvider.hashPrefix('!');

        $routeProvider
            .when('/forum-dashboard/:tab', {
                template: '<forum-dashboard></forum-dashboard>'
            })
            .when('/topic/settings/:topicId', {
                template: '<topic-create-edit></topic-create-edit>'
            })
            .when('/topic/create', {
                template: '<topic-create-edit create="true"></topic-create-edit>'
            })
            .when('/topic/create/project/:projectId', {
                template: '<topic-create-edit create="true"></topic-create-edit>'
            })
            .when('/topic/:topicId', {
                template: '<topic-view></topic-view>'
            })
            .when('/topic/reply/:topicId', {
                template: '<message-reply></message-reply>'
            })
            .when('/topic/:topicId/message/:messageId', {
                template: '<message-edit></message-edit>'
            })
            .when('/expedition-forum/:projectId', {
                template: '<project-forum></project-forum>'
            })
            .when('/search/:searchText', {
                template: '<search-results></search-results>'
            })
            .otherwise('/forum-dashboard/featured');
    }
]);