//= encoding UTF-8
//= require digivol-module
//= require markerclusterer.js
//= require angular/angular-ui-bootstrap
//= require angular/angular-marked
//= require angular/angular-sanitize
//= require underscore
//= require_self
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
          animation: google.maps.Animation.DROP,
          icon: BVP_JS_URLS.singleMarkerPath
        });
        markers.push(marker);
        google.maps.event.addListener(marker, 'click', function () {
          notebook.infowindow.setContent("[loading...]");
          // load info via AJAX call
          load_content(marker, task.taskId);
        });
      }); // end each

      new MarkerClusterer(notebook.map, markers, { maxZoom: 18, imagePath: BVP_JS_URLS.markersPath });
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
  }
};

$(function() {
  notebook.initMap();
});


function digivolNotebooksTabs(config) {

  var nb = angular.module('notebook', ['digivol', 'ui.bootstrap', 'ngSanitize', 'hc.marked']);

  nb.value('taskListUrl', config.taskListUrl);
  nb.value('forumPostsUrl', config.forumPostsUrl);
  nb.value('changedFieldsUrl', config.changedFieldsUrl);
  nb.value('auditViewUrl', config.auditViewUrl);

  var notebookTabsController =
    ['$log', '$scope',
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
        $scope.$on('unreadValidationViewed', function (event, taskInstance) {
          // hack to get this out to the non-angular parts of the app
          $(document).triggerHandler('unreadValidationViewed', {taskInstance: taskInstance});
        });
      }];

  var taskListController = [
    '$anchorScroll', '$http', '$log', '$q', '$scope', '$uibModal', '$window', 'taskListUrl',
    function TaskListController($anchorScroll, $http, $log, $q, $scope, $uibModal, $window, taskListUrl) {
      var $ctrl = this;

      $ctrl.data = null;

      $ctrl.page = $ctrl.offset / $ctrl.max;
      $ctrl.cancelPromise = null;
      $ctrl.maxSize = 5;

      $ctrl.sort = $ctrl.sort || 'dateTranscribed';
      $ctrl.order = $ctrl.order || 'desc';

      $ctrl.firstLoad = true;

      $ctrl.load = function (args) {
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
        }).then(function (response) {
          $ctrl.cancelPromise = null;
          //$log.debug(response);
          $ctrl.data = response.data;
          $ctrl.firstLoad = false;
        }, function (error) {
          $log.error("couldn't load data for tab", error);
          $window.alert("An error occured, please refresh the page and try again.");
        });
      };

      $ctrl.viewNotifications = function (taskInstance) {
        var modalInstance = $uibModal.open({
          templateUrl: 'viewNotifications.html',
          controller: 'viewNotificationsModalCtrl',
          controllerAs: '$ctrl',
          bindToController: true,
          resolve: {
            taskInstance: function () {
              return taskInstance;
            }
          }
        });
      };

      if ($ctrl.tabIndex == 0) {
        $scope.$on('unreadValidationViewed', function (event, taskInstance) {
          if ($ctrl.data) {
            _.chain($ctrl.data.viewList).filter(function (t) {
              return t.id == taskInstance.id;
            }).each(function (t) {
              t.unread = false;
            });
          }
        });
      }
      $ctrl.pageChanged = function () {
        $ctrl.offset = ($ctrl.page - 1) * $ctrl.max;
        $anchorScroll('tasklist-top-' + $ctrl.tabIndex);
        $ctrl.load();
      };

      $ctrl.sortedClasses = function (column) {
        return column == $ctrl.sort ? ['sorted', $ctrl.order] : [];
      };

      // watch the selectedTab value to initiate lazy loading of tab contents
      $scope.$watch(
        function (scope) {
          return $ctrl.selectedTab;
        },
        function (newValue, oldValue) {
          if (newValue == $ctrl.tabIndex && $ctrl.data == null) {
            $ctrl.load();
          }
        }
      );
    }];

  var forumPostsController = [
    '$anchorScroll', '$http', '$log', '$q', '$scope', '$window', 'forumPostsUrl',
    function ForumPostsController($anchorScroll, $http, $log, $q, $scope, $window, forumCommentsUrl) {
      var $ctrl = this;

      $ctrl.data = null;

      $ctrl.page = $ctrl.offset / $ctrl.max;
      $ctrl.cancelPromise = null;
      $ctrl.maxSize = 5;

      $ctrl.load = function () {

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
        }).then(function (response) {
          $ctrl.cancelPromise = null;
          $log.debug(response);
          $ctrl.data = response.data;
        }, function (error) {
          $log.error("couldn't load data for forum tab", error);
          $window.alert("An error occured, please refresh the page and try again.");
        });
      };

      $ctrl.pageChanged = function () {
        $ctrl.offset = ($ctrl.page - 1) * $ctrl.max;
        $anchorScroll('forumlist-top');
        $ctrl.load();
      };

      $scope.$watch(
        function (scope) {
          return $ctrl.selectedTab;
        },
        function (newValue, oldValue) {
          if (newValue == $ctrl.tabIndex && $ctrl.data == null) {
            $ctrl.load();
          }
        }
      );
    }];

  var viewNotificationsModalCtrl =
    ['$http', '$log', '$rootScope', '$scope', '$uibModalInstance', 'auditViewUrl', 'changedFieldsUrl', 'taskInstance',
      function ViewNotificationsModalCtrl($http, $log, $rootScope, $scope, $uibModalInstance, auditViewUrl, changedFieldsUrl, taskInstance) {
        var $ctrl = this;
        $ctrl.taskInstance = taskInstance;

        $ctrl.loading = true;
        $ctrl.error = null;

        $http.get(changedFieldsUrl + "/" + taskInstance.id).then(
          function (response) {
            $ctrl.loading = false;
            $ctrl.error = false;
            angular.extend($ctrl, response.data);
          },
          function (error) {
            $ctrl.loading = false;
            $ctrl.error = true;
            $log.error("couldn't get changed fields", error);
          }
        ).then(function () {
          if (taskInstance.unread) {
            $http.post(auditViewUrl + '/' + taskInstance.id).then(function () {
              $rootScope.$broadcast('unreadValidationViewed', taskInstance);
            });
          }
        });

        $ctrl.close = function () {
          $uibModalInstance.close();
        };
      }];

  nb.controller('notebookTabsController', notebookTabsController)
    .controller('viewNotificationsModalCtrl', viewNotificationsModalCtrl)
    .component('taskList', {
      templateUrl: 'taskList.html',
      controller: taskListController,
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
      controller: forumPostsController,
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