//= encoding UTF-8
//= require digivol-module
//= require compile/markerclusterer/1.0/markerclusterer.js
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
      const taskViewUrl = $('#map').attr('taskview-url');
      $.ajax($('#map').attr('infowindow-url') + "/" + id).done(function(data) {
        var content =
            "<div style='font-size:12px;line-height:1.3em;'>" +
            "Task: " + id +
            "<br />File: ";
        if (taskViewUrl !== "") content += "<a href=\"" + taskViewUrl + "/" + id + "\" target=\"_blank\">" + data.filename + "</a>";
        else content += data.filename;
        if (data.name !== "" && data.name !== undefined && data.name !== null) content += "<br />Taxon: " + data.name
        content += "</div>";
        notebook.infowindow.close();
        notebook.infowindow.setContent(content);
        notebook.infowindow.open(notebook.map, marker);
      });

    }
  }
};

$(function() {
  if (gmapsReady) {
    notebook.initMap();
  } else {
    $(window).on('digivol.gmapsReady', function() {
      notebook.initMap();
    });
  }
});


function digivolNotebooksTabs(config) {

  var projectId = config.project ? config.project.id : null;

  var nb = angular.module('notebook', ['digivol', 'ui.bootstrap', 'ngSanitize', 'hc.marked']);

  nb.value('taskListUrl', config.taskListUrl);
  nb.value('forumPostsUrl', config.forumPostsUrl);
  nb.value('projectId', projectId);

  var notebookTabsController =
    ['$log', '$scope',
      function NotebookTabsController($log, $scope) {
        var $ctrl = this;
        angular.extend($ctrl, config);
        $ctrl.tabs = [];
        for (var i = 0; i < 5; ++i) {
          if (i === config.selectedTab) {
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
    '$anchorScroll', '$http', '$log', '$q', '$scope', '$uibModal', '$window', 'projectId', 'taskListUrl',
    function TaskListController($anchorScroll, $http, $log, $q, $scope, $uibModal, $window, projectId, taskListUrl) {
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
            if (args.sort === $ctrl.sort) {
              $ctrl.order = $ctrl.order === 'asc' ? 'desc' : 'asc';
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
        if (projectId) {
          params['projectId'] = projectId;
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

      $ctrl.pageChanged = function () {
        $ctrl.offset = ($ctrl.page - 1) * $ctrl.max;
        $anchorScroll('tasklist-top-' + $ctrl.tabIndex);
        $ctrl.load();
      };

      $ctrl.sortedClasses = function (column) {
        return column === $ctrl.sort ? ['sorted', $ctrl.order] : [];
      };

      // watch the selectedTab value to initiate lazy loading of tab contents
      $scope.$watch(
        function (scope) {
          return $ctrl.selectedTab;
        },
        function (newValue, oldValue) {
          if (newValue === $ctrl.tabIndex && $ctrl.data == null) {
            $ctrl.load();
          }
        }
      );
    }];

  var forumPostsController = [
    '$anchorScroll', '$http', '$log', '$q', '$scope', '$window', 'projectId', 'forumPostsUrl',
    function ForumPostsController($anchorScroll, $http, $log, $q, $scope, $window, projectId, forumPostsUrl) {
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
        if (projectId) {
          params['projectId'] = projectId;
        }
        if ($ctrl.cancelPromise != null) {
          $ctrl.cancelPromise.resolve();
        }
        $ctrl.cancelPromise = $q.defer();
        return $http.get(forumPostsUrl, {
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
          if (newValue === $ctrl.tabIndex && $ctrl.data == null) {
            $ctrl.load();
          }
        }
      );
    }];



  nb.controller('notebookTabsController', notebookTabsController)
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