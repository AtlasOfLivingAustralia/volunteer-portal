"use strict";

var notebook = {
    map: null,

    infowindow: null,

    initMap: function (){
        notebook.map = new google.maps.Map(document.getElementById('map'), {
            scaleControl: true,
            center: new google.maps.LatLng(-24.766785, 134.824219), // centre of Australia
            zoom: 3,
            minZoom: 1,
            streetViewControl: false,
            scrollwheel: false,
            mapTypeControl: true,
            mapTypeControlOptions: {
                style: google.maps.MapTypeControlStyle.DROPDOWN_MENU
            },
            navigationControl: true,
            navigationControlOptions: {
                style: google.maps.NavigationControlStyle.SMALL // DEFAULT
            },
            mapTypeId: google.maps.MapTypeId.ROADMAP
        });

        notebook.infowindow = new google.maps.InfoWindow();

        // load markers via JSON web service
        var tasksJsonUrl = $('#map').attr('markers-url');
        $.get(tasksJsonUrl, {}, notebook.drawMarkers);
    },

    drawMarkers: function (data) {

        if (data) {
            var markers = [];
            $.each(data, function (i, task) {
                var latlng = new google.maps.LatLng(task.lat, task.lng);
                var marker = new google.maps.Marker({
                    position: latlng,
                    map: notebook.map,
                    title: "record: " + task.taskId,
                    animation: google.maps.Animation.DROP
                });
                markers.push(marker);
                google.maps.event.addListener(marker, 'click', function () {
                    notebook.infowindow.setContent("[loading...]");
                    // load info via AJAX call
                    load_content(marker, task.taskId);
                });
            }); // end each

            new MarkerClusterer(notebook.map, markers, { maxZoom: 18 });
        }

        /**
         * Function to load info windows content via Ajax
         * @param marker
         * @param id
         */
        function load_content(marker, id) {
            $.ajax($('#map').attr('infowindow-url') + "/" + id).done(function(data) {
                var content =
                    "<div style='font-size:12px;line-height:1.3em;'>Catalogue No.: " + data.cat + "<br/>Taxon: " + data.name + "<br/>Transcribed by: " + data.transcriber +
                    "</div>";
                notebook.infowindow.close();
                notebook.infowindow.setContent(content);
                notebook.infowindow.open(notebook.map, marker);
            });

        }
    },

    /**
     * Function to load tabs content via Ajax if required
     */
    loadContent: function () {
        var currentSelectedTab = $('#profileTabsList li.active a');
        // This is a workaround to show the static content of the tab that was selected when no Ajax is involved
        $('#profileTabsList li:eq(0) a').tab('show');
        currentSelectedTab.tab('show');
        if ($.inArray(currentSelectedTab.attr('tab-index'), notebook.nonAjaxTabs) == -1) {
            var url = $('#profileTabsList li.active a').attr('content-url');
            $.ajax(url).done(function (content) {
                $("#profileTabsContent .tab-pane.active").html(content);
            });
        }
    }
};

$(function() {
    // notebook.loadContent();
    notebook.initMap();
});


function digivolNotebooksTabs(config) {

    var nb = angular.module('notebook', ['ui.bootstrap', 'ngSanitize', 'hc.marked', 'digivol']);

    nb.value('taskListUrl', config.taskListUrl);
    nb.value('forumPostsUrl', config.forumPostsUrl);

    function NotebookTabsController($log, $scope) {
        var $ctrl = this;
        angular.extend($ctrl, config);
        $ctrl.tabs = [];
        for (var i = 0; i < 5; ++i) {
            if (i == config.selectedTab) {
                $ctrl.tabs.push({
                    max: config.max || 10,
                    sort: config.sort,
                    offset: config.offset || 0,
                    order: config.order,
                    query: config.query
                });
            } else {
                $ctrl.tabs.push({
                    max: 10,
                    offset: 0
                })
            }
        }
        if ($ctrl.userInstance) {
            $ctrl.userInstance['isValidator'] = config.isValiator;
            $ctrl.userInstance['isAdmin'] = config.isAdmin;
        }
    }

    function TaskListController($http, $log, $q, $scope, $uibModal, taskListUrl) {
        var $ctrl = this;

        $ctrl.data = null;

        $ctrl.page = $ctrl.offset / $ctrl.max;
        $ctrl.cancelPromise = null;
        $ctrl.maxSize = 5;
        
        $ctrl.load = function(args) {
            if (args) {
                if (args.sorting) {
                    args.sorting = undefined;
                    if (args.sort == $ctrl.sort) {
                        $ctrl.order = $ctrl.order == 'asc' ? 'desc' : 'asc';
                    }
                }
                angular.extend($ctrl, args);
            }
            var params = {
                selectedTab: $ctrl.tabIndex,
                max: $ctrl.max,
                sort: $ctrl.sort,
                offset: $ctrl.offset,
                order: $ctrl.order,
                q: $ctrl.query
            };
            if ($ctrl.project) {
                params['projId'] = $ctrl.project.id;
            }
            if ($ctrl.cancelPromise != null) {
                $ctrl.cancelPromise.resolve();
            }
            $ctrl.cancelPromise = $q.defer();
            return $http.get(taskListUrl, {
                params: params,
                timeout: $ctrl.cancelPromise.promise
            }).then(function(response) {
                $ctrl.cancelPromise = null;
                console.debug(response);
                $ctrl.data = response.data;
            });
        };

        $ctrl.viewNotifications = function(taskInstance) {
            var modalInstance = $uibModal.open({
                // animation: $scope.animationsEnabled,
                templateUrl: 'viewNotifications.html',
                controller: 'ViewNotificationsModalCtrl',
                controllerAs: '$ctrl',
                bindToController: true,
                //size: size,
                resolve: {
                    taskInstance: function () {
                        return taskInstance;
                    }
                }
            });

            modalInstance.closed.then(function () {
                $http.post(auditViewUrl, { taskId: taskInstance.id }).then(function() {
                    taskInstance.unread = false;
                    $scope.$emit('unreadValidationViewed', { task: taskInstance });
                });
            });
        };
        
        $ctrl.pageChanged = function() {
            $ctrl.offset = ($ctrl.page - 1) * $ctrl.max;
            $ctrl.load();
        };

        $ctrl.sortedClasses = function(column) {
            return column == $ctrl.sort ? ['sorted', $ctrl.order] : [];
        };
        
        // watch the selectedTab value to initiate lazy loading of tab contents
        $scope.$watch(
          function ( scope ) { return $ctrl.selectedTab ; },
          function (newValue, oldValue) {
              if (newValue == $ctrl.tabIndex && $ctrl.data == null) {
                  $ctrl.load();
              }
          }
        );
    }

    function ForumPostsController($http, $q, $scope, forumCommentsUrl) {
        var $ctrl = this;

        $ctrl.data = null;

        $ctrl.page = $ctrl.offset / $ctrl.max;
        $ctrl.cancelPromise = null;
        $ctrl.maxSize = 5;

        $ctrl.load = function() {

            var params = {
                max: $ctrl.max,
                sort: $ctrl.sort,
                offset: $ctrl.offset,
                order: $ctrl.order
            };
            if ($ctrl.project) {
                params['projId'] = $ctrl.project.id;
            }
            if ($ctrl.cancelPromise != null) {
                $ctrl.cancelPromise.resolve();
            }
            $ctrl.cancelPromise = $q.defer();
            return $http.get(forumCommentsUrl, {
                params: params,
                timeout: $ctrl.cancelPromise.promise
            }).then(function(response) {
                $ctrl.cancelPromise = null;
                console.debug(response);
                $ctrl.data = response.data;
            });
        };

        $ctrl.pageChanged = function() {
            $ctrl.offset = ($ctrl.page - 1) * $ctrl.max;
            $ctrl.load();
        };

        $scope.$watch(
          function ( scope ) { return $ctrl.selectedTab ; },
          function (newValue, oldValue) {
              if (newValue == $ctrl.tabIndex && $ctrl.data == null) {
                  $ctrl.load();
              }
          }
        );
    }

    function ViewNotificationsModalCtrl($uibModalInstance, taskInstance) {
        var $ctrl = this;
        $ctrl.taskInstance = taskInstance;

        $ctrl.ok = function () {
            $uibModalInstance.close($scope.selected.item);
        };

        $ctrl.cancel = function () {
            $uibModalInstance.dismiss('cancel');
        };
    }

    nb.controller('notebookTabsController', ['$log', '$scope', NotebookTabsController])
      .controller('viewNotificationsModalCtrl', ['$uibModalInstance', 'taskInstance', ViewNotificationsModalCtrl])
      .component('taskList', {
        templateUrl: 'taskList.html',
        controller: ['$http', '$log', '$q', '$scope', '$uibModal', 'taskListUrl', TaskListController],
        bindings: {
            //'viewList': '<',
            //'recentValidatedTaskCount': '<',
            //'totalMatchingTasks': '<',
            'tabIndex': '<',
            'selectedTab': '<',
            'project': '<',
            'user': '<',
            'query': '<',
            'max': '<',
            'sort': '<',
            'offset': '<',
            'order': '<'
        }
      })
      .component('forumPosts', {
        templateUrl: 'forumPosts.html',
        controller: ['$http', '$q', '$scope', 'forumPostsUrl', ForumPostsController],
        bindings: {
            'tabIndex': '<',
            'selectedTab': '<',
            'max': '<',
            'sort': '<',
            'offset': '<',
            'order': '<'
        }
      });
}

