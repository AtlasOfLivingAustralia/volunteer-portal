(function() {
  var transcribe = angular.module('transcribe', ['ui.router']);

  transcribe.controller('ImageCtrl', [
            "$scope", "$log", "leafletData", "leafletBoundsHelpers", "taskConfig",
    function($scope,   $log,   leafletData,   leafletBoundsHelpers,   taskConfig) {
      var maxBounds = leafletBoundsHelpers.createBoundsFromArray([[-540, -960], [540, 960]]);
      angular.extend($scope, {
        defaults: {
          scrollWheelZoom: true,
          crs: 'Simple',
          maxZoom: 4
        },
        center: {
          lat: 0,
          lng: 0,
          zoom: 0
        },
        maxBounds: maxBounds,
        layers: {
          baselayers: {
            andes: {
              name: 'Andes',
              type: 'imageOverlay',
              url: 'examples/img/andes.jpg',
              bounds: [[-540, -960], [540, 960]],
              layerParams: {
                noWrap: true,
                attribution: 'Creative Commons image found <a href="http://www.flickr.com/photos/c32/8025422440/">here</a>'
              }
            }
          }
        }
      });
    }
  ]);

  transcribe.controller('TranscribeCtrl', ["$scope", function($scope) {

  }]);

  transcribe.directive("dvReplace", function() {
      return {
        replace: true,
        restrict: 'A',
        templateUrl: function (iElement, iAttrs) {
          if (!iAttrs.dvReplace) throw new Error("dv-replace: template url must be provided");
          return iAttrs.dvReplace;
        }
      };
  });

  transcribe.directive('dvDynamicField', function() {
    return {
      restrict: 'E',
      //transclude: true,
      scope: {
        field: '='
      },
      link: function(scope) {
        var dt;
        switch (scope.field.type) {
          case 'hidden':
          case 'textarea':
          case 'select':
          case 'sheetNumber':
          case 'latLong':
          case 'imageMultiSelect':
          case 'text':
          case 'checkbox':
          case 'readonly':
          case 'unitRange':
          case 'autocomplete':
          case 'date':
          case 'mappingTool':
            dt = 'dv-field-' + scope.field.type;
            break;
          case 'collectorColumns':
          case 'autocompleteTextarea':
          default:
            dt = 'dv-field-unknown';
            break;
        }
        scope.dynamicTemplate = dt;
      },
      template: '<div ng-include="dynamicTemplate"></div>'
    }
  });

  transcribe.directive('dvBootstrapField', function() {
    return {
      restrict: 'E',
      transclude: true,
      scope: {
        field: '='
      },
      templateUrl: 'dv-bs-field-template'
    }
  });

  //transcribe.directive('dvTranscribePage', function() {
  //  return {
  //    restrict: 'E',
  //    //transclude: false,
  //    scope: {
  //      legend: '=',
  //      fields: '='
  //    },
  //    //controller: ['$scope', function($scope) {
  //    //
  //    //}]
  //  }
  //});

  transcribe.config(["$provide", function ($provide) {
    $provide.decorator('tabsetDirective', function($delegate) {
      var directive = $delegate[0];
      directive.templateUrl = "dv/template/tabs/tabset.override.html";
      return $delegate;
    });
    $provide.decorator('tabDirective', function($delegate) {
      var directive = $delegate[0];
      directive.templateUrl = "dv/template/tabs/tab.override.html";
      return $delegate;
    });
  }]);


  angular.module("dv/template/tabs/tab.override.html", []).run(["$templateCache", function($templateCache) {
    $templateCache.put("dv/template/tabs/tab.override.html",
      "<button type='button' data-ng-class='{btn-primary: active, btn-default: !active}' class='btn btn-circle uib-tab' data-ng-click='select()' data-ng-disabled='disabled' uib-tab-heading-transclude>{{heading}}</button>\n" +
      //"<li ng-class=\"{active: active, disabled: disabled}\" class=\"uib-tab\">\n" +
      //"  <a href ng-click=\"select()\" uib-tab-heading-transclude>{{heading}}</a>\n" +
      //"</li>\n" +
      "");
  }]);

  angular.module("dv/template/tabs/tabset.override.html", []).run(["$templateCache", function($templateCache) {
    $templateCache.put("dv/template/tabs/tab.override.html",
      "<div class=\"stepwizard\">\n    <div class=\"stepwizard-row\">\n      <div class=\"stepwizard-step\">\n        <span>Steps</span>\n        <div ng-transclude></div>\n      </div>\n    </div>\n  </div>\n\n  <!-- Form -->\n  <div class=\"row\" \n       ng-repeat=\"tab in tabs\"\n       ng-class=\"{active: tab.active}\"\n       uib-tab-content-transclude=\"tab\">\n  </div>" +
      //"<div>\n" +
      //"  <ul class=\"nav nav-{{type || 'tabs'}}\" ng-class=\"{'nav-stacked': vertical, 'nav-justified': justified}\" ng-transclude></ul>\n" +
      //"  <div class=\"tab-content\">\n" +
      //"    <div class=\"tab-pane\" \n" +
      //"         ng-repeat=\"tab in tabs\" \n" +
      //"         ng-class=\"{active: tab.active}\"\n" +
      //"         uib-tab-content-transclude=\"tab\">\n" +
      //"    </div>\n" +
      //"  </div>\n" +
      //"</div>\n" +
      "");
  }]);

})();