<%@ page import="au.org.ala.volunteer.Template" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="templateEntityName" value="${message(code: 'template.label', default: 'Template')}"/>
    <title><g:message code="wildlifeSpotter.template.label" default="Wildlife Spotter Template Configuration"/></title>
    <style>
         .minimizable.ng-hide-add,
         .minimizable.ng-hide-remove {
            transition: all ease-out 0.25s;
             max-height: 600px;
             overflow-y: hidden;
        }
        .minimizable.ng-hide {
            max-height: 0;
            overflow-y: hidden;
        }
        .form-control {
            height: 32px;
        }
    </style>
</head>
<body>
<cl:headerContent title="${message(code: 'default.wildlifeSpotterOptions.label', default: 'Wildlife Spotter Options')}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
                [link: createLink(controller: 'template', action: 'list'), label: message(code: 'default.list.label', args: [templateEntityName])],
                [link: createLink(controller: 'template', action: 'edit', id: templateInstance.id), label: "${message(code: 'default.edit.label', args: [templateEntityName])} - ${templateInstance.name}"]
        ]
    %>

    <h2>Template: ${templateInstance.name}</h2>
</cl:headerContent>

<div class="container" ng-app="wildlifespottertemplateconfig" ng-controller="TemplateConfigController as tcc">'
    <div class="row">
        <div class="col-sm-12">
            <button class="btn btn-primary" ng-click="tcc.save()"><i class="fa fa-save"></i> Save</button>
        </div>
    </div>
    <div class="row" >
        <div class="col-sm-12">
            <h1>
                Categories
                <button class="btn btn-mini btn-primary" ng-click="tcc.addCategory()"><i class="fa fa-plus"></i></button>
                <button class="btn btn-mini btn-primary" ng-click="tcc.minimizeAll(tcc.categoryUiStatus)" title="Minimize all"><i class="fa fa-window-minimize"></i></button>
            </h1>
            <div class="panel panel-default" ng-repeat="c in tcc.model.categories">
                <div class="panel-heading">
                    <div class="pull-right">
                        <div class="btn-group btn-group-xs" role="group" aria-label="Category options">
                            <button class="btn btn-default" ng-click="tcc.moveCategoryUp($index)"><i class="fa fa-arrow-up"></i></button>
                            <button class="btn btn-default" ng-click="tcc.moveCategoryDown($index)"><i class="fa fa-arrow-down"></i></button>
                            <button ng-if="!tcc.categoryUiStatus[$index].minimized" class="btn btn-default" ng-click="tcc.categoryUiStatus[$index].minimized = true" ><i class="fa fa-window-minimize"></i></button>
                            <button ng-if="tcc.categoryUiStatus[$index].minimized" class="btn btn-default" ng-click="tcc.categoryUiStatus[$index].minimized = false" ><i class="fa fa-window-maximize"></i></button>
                        </div>
                        <button class="btn btn-danger btn-xs" ng-click="tcc.removeCategory($index)" ><i class="fa fa-close"></i></button>
                    </div>
                    <h2 class="panel-title" ng-bind="c.name || 'New category'"></h2>
                </div>
                <div class="minimizable" ng-show="!tcc.categoryUiStatus[$index].minimized">
                    <div class="panel-body">
                        <form>
                            <div class="form-group">
                                <label>Name</label>
                                <input type="text" class="form-control" placeholder="Category name" ng-model="c.name" ng-change="tcc.categoryChange(c)">
                            </div>
                        </form>
                    </div>
                    <table class="table">
                        <thead>
                        <tr>
                            <th>Entry Name</th>
                            <th>Icon</th>
                            <th><button class="btn btn-mini btn-primary" ng-click="tcc.addEntry(c)"><i class="fa fa-plus"></i></button></th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr ng-repeat="e in c.entries">
                            <td><input type="text" class="form-control" placeholder="Entry name" ng-model="e.name" ng-change="tcc.entryChange(c, e)"></td>
                            <td ngf-drop="tcc.addImage(e,$index,$files)" ngf-accept="'image/*'"><img ng-src="{{tcc.entryUrl(e)}}"></td>
                            <td>
                                <button class="btn btn-mini btn-primary" type="file" ngf-select="tcc.addImage(c.entries,$index,$files)" ngf-accept="'image/*'"><i class="fa fa-upload"></i></button>
                                <button class="btn btn-mini btn-default" ng-click="tcc.moveUp(c.entries,$index)"><i class="fa fa-arrow-up"></i></button>
                                <button class="btn btn-mini btn-default" ng-click="tcc.moveDown(c.entries,$index)"><i class="fa fa-arrow-down"></i></button>
                                <button class="btn btn-mini btn-danger" ng-click="tcc.removeEntry(c,$index)"><i class="fa fa-trash"></i></button>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            <button class="btn btn-primary" ng-click="tcc.addCategory()"><i class="fa fa-plus"></i> Add category</button>
        </div>
    </div>
    <div class="row">
        <div class="col-sm-12">
            <h1>Animals
                <button class="btn btn-mini btn-primary" ng-click="tcc.addAnimal()"><i class="fa fa-plus"></i></button>
                <button class="btn btn-mini btn-primary" ng-click="tcc.sortAnimals()" title="Sort alphabetically"><i class="fa fa-sort-alpha-asc"></i></button>
                <button class="btn btn-mini btn-primary" ng-click="tcc.minimizeAll(tcc.animalUiStatus)" title="Minimize all"><i class="fa fa-window-minimize"></i></button>
            </h1>
            <div class="panel panel-default" ng-repeat="a in tcc.model.animals">
                <div class="panel-heading">
                    <div class="pull-right">
                        <div class="btn-group btn-group-xs" role="group" aria-label="Animal options">
                            <button class="btn btn-default" ng-click="tcc.moveAnimalUp($index)"><i class="fa fa-arrow-up"></i></button>
                            <button class="btn btn-default" ng-click="tcc.moveAnimalDown($index)"><i class="fa fa-arrow-down"></i></button>
                            <button ng-if="!tcc.animalUiStatus[$index].minimized" class="btn btn-default" ng-click="tcc.animalUiStatus[$index].minimized = true" ><i class="fa fa-window-minimize"></i></button>
                            <button ng-if="tcc.animalUiStatus[$index].minimized" class="btn btn-default" ng-click="tcc.animalUiStatus[$index].minimized = false" ><i class="fa fa-window-maximize"></i></button>
                        </div>
                        <button class="btn btn-danger btn-xs" ng-click="tcc.removeAnimal(a)"><i class="fa fa-close"></i></button>
                    </div>
                    <h2 class="panel-title" ng-bind="tcc.fullName(a) || 'New animal'"></h2>
                </div>
                <div class="minimizable" ng-show="!tcc.animalUiStatus[$index].minimized">
                    <div class="panel-body">
                        <form>
                            <div class="form-group">
                                <label>Common Name</label>
                                <input type="text" class="form-control" placeholder="Animal name" ng-model="a.vernacularName">
                            </div>
                            <div class="form-group">
                                <label>Scientific Name</label>
                                <input type="text" class="form-control" placeholder="Animal name" ng-model="a.scientificName">
                            </div>
                            <div class="form-group">
                                <label>Description</label>
                                <textarea class="form-control" placeholder="Description (markdown?)" ng-model="a.description"></textarea>
                            </div>
                            <div class="form-group" ng-repeat="c in tcc.model.categories">
                                <label>{{c.name}}</label>
                                <select class="form-control" ng-options="e.name as e.name for e in c.entries" ng-model="a.categories[c.name]">
                                    <option value="">Other</option>
                                </select>
                            </div>
                        </form>
                    </div>
                    <table class="table">
                        <thead>
                        <tr>
                            <th>Image</th>
                            <th><button class="btn btn-mini btn-primary" ng-click="tcc.addBlankImage(a)"><i class="fa fa-plus"></i></button></th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr ng-repeat="i in a.images">
                            <td ngf-drop="tcc.addImage(a,$index,$files)"><img ng-src="{{tcc.imageUrl(i)}}"></td>
                            <td>
                                <button class="btn btn-mini btn-primary" type="file" ngf-select="tcc.addImage(a.images,$index,$files)"><i class="fa fa-upload"></i></button>
                                <button class="btn btn-mini btn-default" ng-click="tcc.moveUp(a.images,$index)"><i class="fa fa-arrow-up"></i></button>
                                <button class="btn btn-mini btn-default" ng-click="tcc.moveDown(a.images,$index)"><i class="fa fa-arrow-down"></i></button>
                                <button class="btn btn-mini btn-danger" ng-click="tcc.removeImage(a,$index)"><i class="fa fa-trash"></i></button>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            <button class="btn btn-primary" ng-click="tcc.addAnimal()"><i class="fa fa-plus"></i> Add animal</button>
        </div>
    </div>
    <div class="row">
        <div class="col-sm-12">
            <button class="btn btn-primary" ng-click="tcc.save()"><i class="fa fa-save"></i> Save</button>
        </div>
    </div>
</div>
<asset:javascript src="wildlifespotter-template-config.js" asset-defer=""/>

<asset:script type="text/javascript">
    var viewParams = <cl:json value="${viewParams2}"/>;
    var wstc = angular.module('wildlifespottertemplateconfig', ['ngAnimate', 'ngFileUpload']);
    function TemplateConfigController($http, Upload) {
      var self = this;
      self.model = viewParams;
      self.categoryUiStatus = [];
      self.animalUiStatus = [];

      for (var i = 0; i < self.model.categories.length; ++i) {
        self.categoryUiStatus.push({minimized: true});
      }

      for (i = 0; i < self.model.animals.length; ++i) {
        self.animalUiStatus.push({minimized: true});
      }

      self.addCategory = function() {
        self.model.categories.push({name: '', entries: []});
        self.categoryUiStatus.push({minimized: false});
      };

      self.removeCategory = function(index) {
        self.model.categories.splice(index, 1);
        self.categoryUiStatus.splice(index, 1);
      };

      self.addEntry = function(c) {
        c.entries.push({name: '', hash: ''});
      };

      self.removeEntry = function(c, $index) {
        c.entries.splice($index, 1);
      };

      self.addAnimal = function() {
        self.model.animals.push({vernacularName: '', scientificName: '', description: '', categories: {}, images: []});
        self.animalUiStatus.push({minimized: false});
      };

      self.removeAnimal = function($index) {
        self.model.animals.splice($index, 1);
        self.animalUiStatus.splice(index, 1);
      };

      self.addBlankImage = function(a) {
        a.images.push({hash: ''});
      };

      self.removeImage = function(a, $index) {
        a.images.splice($index, 1);
      };

      self.addImage = function(entryOrAnimalArray, $index, $file) {

        var entryOrAnimal = entryOrAnimalArray[$index];
        if (!$file) {
          entryOrAnimal.hash = '';
          return;
        }

        var data;
        if ("name" in entryOrAnimal) {
          data = {entry: $file[0]};
        } else {
          data = {animal: $file[0]};
        }
        var name = $file[0].name;

        Upload.upload({
          url: "<g:createLink controller="wildlifeSpotterAdmin" action="uploadImage" />",
          data: data
        }).then(function (resp) {
          console.log('Success ' + name + ' uploaded. Response: ' + JSON.stringify(resp.data));
          entryOrAnimal.hash = resp.data.hash;
        }, function (resp) {
          bootbox.alert("Image upload failed");
          console.log('Error status: ' + resp.status);
        }, function (evt) {
          var progressPercentage = parseInt(100.0 * evt.loaded / evt.total);
          console.log('progress: ' + progressPercentage + '% ' + name);
        });
      };

      self.moveCategoryUp = function(index) {
        self.moveUp(self.model.categories, index);
        self.moveUp(self.categoryUiStatus, index);
      };
      self.moveCategoryDown = function(index) {
        self.moveDown(self.model.categories, index);
        self.moveDown(self.categoryUiStatus, index);
      };
      self.moveAnimalUp = function(index) {
        self.moveUp(self.model.animals, index);
        self.moveUp(self.animalUiStatus, index);
      };
      self.moveAnimalDown = function(index) {
        self.moveDown(self.model.animals, index);
        self.moveDown(self.animalUiStatus, index);
      };

      self.moveUp = function(a, $index) {
        if ($index <= 0) {
          return;
        }
        var a1 = a[$index];
        a[$index] = a[$index - 1];
        a[$index - 1] = a1;
      };

      self.moveDown = function(a, $index) {
        if ($index >= (a.length - 1)) {
          return;
        }
        var a1 = a[$index];
        a[$index] = a[$index + 1];
        a[$index + 1] = a1;
      };

      self.sortAnimals = function() {
        self.minimizeAll(self.animalUiStatus);
        self.model.animals.sort(function(a,b) {
          var nameA = self.fullName(a).toUpperCase();
          var nameB = self.fullName(b).toUpperCase();
          if (nameA < nameB) {
            return -1;
          }
          if (nameA > nameB) {
            return 1;
          }

          // names must be equal
          return 0;
        });
      };

      self.minimizeAll = function(array) {
        for (var i = 0; i < array.length; ++i) {
          array[i].minimized = true;
        }
      };

      var imageUrlTemplate = "<cl:sizedImageUrl prefix="wildlifespotter" name="{{name}}" width="{{width}}" height="{{height}}" format="{{format}}" template="true"/>";

      self.entryUrl = function(e) {
        var url = imageUrlTemplate.replace("{{name}}", e.hash).replace("{{width}}", "156").replace("{{height}}", "52").replace("{{format}}", "png");
        return url;
      };

      self.imageUrl = function(i) {
        var url = imageUrlTemplate.replace("{{name}}", i.hash).replace("{{width}}", "150").replace("{{height}}", "150").replace("{{format}}", "jpg");
        return url;
      };

      self.fullName = function(a) {
        if (a.vernacularName && a.scientificName) {
          return a.vernacularName + " (" + a.scientificName+")";
        } else if (a.vernacularName) {
          return a.vernacularName;
        } else if (a.scientificName) {
          return a.scientificName;
        } else {
          return '';
        }
      };

      self.categoryChange = function(cat) {
        var oldValue = cat.prevName;
        var newValue= cat.name;
        var model = self.model;
        if (!(typeof oldValue === 'undefined')) {
          for (var i = 0; i < model.animals.length; ++i) {
            var animal = model.animals[i];
            if (oldValue in animal.categories) {
              animal.categories[newValue] = animal.categories[oldValue];
              delete animal.categories[oldValue];
            }
          }
        }
        cat.prevName = cat.name;
      };

      self.entryChange = function(cat, entry) {
        var oldValue = entry.prevName;
        var newValue= entry.name;
        var model = self.model;
        if (!(typeof oldValue === 'undefined')) {
          for (var i = 0; i < model.animals.length; ++i) {
            var animal = model.animals[i];
            if (animal.categories[cat.name] === oldValue) {
              animal.categories[cat.name] = newValue;
            }
          }
        }
        entry.prevName = entry.name;
      };

      self.save = function() {
        var p = $http.post("<g:createLink controller="wildlifeSpotterAdmin" action="saveTemplateConfig" id="${id}"/>", self.model);
        p.then(function(response) {
          bootbox.alert("Saved!");
        }, function(response) {
          bootbox.alert("Couldn't save WildlifeSpotter config");
        });
      };

    }

    wstc.controller('TemplateConfigController', TemplateConfigController);
</asset:script>
</body>
</html>