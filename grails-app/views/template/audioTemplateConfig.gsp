<%@ page import="au.org.ala.volunteer.Template" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="templateEntityName" value="${message(code: 'template.label', default: 'Template')}"/>
    <title><g:message code="wildlifeSpotter.template.label" default="Audio Template Configuration"/></title>
    <asset:stylesheet href="inline-player.css" />
    <style>
    .form-control {
        height: 32px;
    }

    .pointer {
        cursor: pointer;
    }

    .save-options {
        margin-top: 5px;
    }
    </style>
</head>

<body>
<cl:headerContent title="${message(code: 'default.wildlifeSpotterOptions.label', default: 'Audio Transcribe Options')}"
                  selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
                [link: createLink(controller: 'template', action: 'list'), label: message(code: 'template.manage.label', default: "Manage Templates")],
                [link: createLink(controller: 'template', action: 'edit', id: templateInstance.id), label: "${message(code: 'default.edit.label', args: [templateEntityName])} - ${templateInstance.name}"]
        ]
    %>

    <h2>Template: ${templateInstance.name}</h2>
</cl:headerContent>

<div class="container" ng-app="wildlifespottertemplateconfig" ng-controller="TemplateConfigController as tcc">
    <div class="row">
        <div class="col-sm-12">
            <button class="btn btn-primary save-options" ng-click="tcc.save()"><i class="fa fa-save"></i> Save</button>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <h1>
                Categories
                <button class="btn btn-mini btn-primary" ng-click="tcc.addCategory()"><i class="fa fa-plus"></i>
                </button>
                <button class="btn btn-mini btn-primary" ng-click="tcc.minimizeAll(tcc.categoryUiStatus)"
                        title="Minimize all"><i class="fa fa-window-minimize"></i></button>
                <button class="btn btn-mini btn-primary" ngf-select="tcc.uploadCategoryJSON($file)"
                        title="Upload Categories as JSON"><i class="fa fa-upload"></i></button>
                <button class="btn btn-mini btn-primary" ng-click="tcc.downloadCategoryJSON()"
                        title="Download Categories as JSON"><i class="fa fa-download"></i></button>
            </h1>

            <div class="panel panel-default" ng-repeat="c in tcc.model.categories">
                <div class="panel-heading pointer"
                     ng-click="tcc.categoryUiStatus[$index].minimized = !tcc.categoryUiStatus[$index].minimized">
                    <div class="pull-right">
                        <div class="btn-group btn-group-xs" role="group" aria-label="Category options">
                            <button class="btn btn-default"
                                    ng-click="tcc.moveCategoryUp($index); $event.stopPropagation();"><i
                                    class="fa fa-arrow-up"></i></button>
                            <button class="btn btn-default"
                                    ng-click="tcc.moveCategoryDown($index); $event.stopPropagation();"><i
                                    class="fa fa-arrow-down"></i></button>
                            <button ng-if="!tcc.categoryUiStatus[$index].minimized" class="btn btn-default"
                                    ng-click="tcc.categoryUiStatus[$index].minimized = true; $event.stopPropagation();"><i
                                    class="fa fa-window-minimize"></i></button>
                            <button ng-if="tcc.categoryUiStatus[$index].minimized" class="btn btn-default"
                                    ng-click="tcc.categoryUiStatus[$index].minimized = false; $event.stopPropagation();"><i
                                    class="fa fa-window-maximize"></i></button>
                        </div>
                        <button class="btn btn-danger btn-xs"
                                ng-click="tcc.removeCategory($index); $event.stopPropagation();"><i
                                class="fa fa-trash"></i></button>
                    </div>

                    <h2 class="panel-title" ng-bind="c.name || 'New category'"></h2>
                </div>

                <div class="minimizable" ng-show="!tcc.categoryUiStatus[$index].minimized">
                    <div class="panel-body">
                        <form>
                            <div class="form-group">
                                <label>Name</label>
                                <input type="text" class="form-control" placeholder="Category name" ng-model="c.name"
                                       ng-change="tcc.categoryChange(c)">
                            </div>
                        </form>
                    </div>
                    <table class="table">
                        <thead>
                        <tr>
                            <th>Entry Name</th>
                            <th>Icon</th>
                            <th>
                                <button class="btn btn-mini btn-primary"
                                        ng-click="tcc.addEntry(c)">
                                    <i class="fa fa-plus"></i>
                                </button>
                                <button class="btn btn-mini btn-primary"
                                        type="file"
                                        ngf-drop="tcc.addManyImages(null,c,$files)"
                                        ngf-select="tcc.addManyImages(null,c,$files)"
                                        ngf-accept="'image/*'"
                                        title="upload multiple category images"><i
                                        class="fa fa-upload"></i></button>
                            </th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr ng-repeat="e in c.entries">
                            <td><input type="text" class="form-control" placeholder="Entry name" ng-model="e.name"
                                       ng-change="tcc.entryChange(c, e)"></td>
                            <td ngf-drop="tcc.addImage(c.entries,$index,$files)" ngf-accept="'image/*'">
                                <img ng-if="tcc.entryUrl(e) !== ''" ng-src="{{tcc.entryUrl(e)}}">
                                <img ng-if="tcc.entryUrl(e) === ''" src="https://via.placeholder.com/80?text=No+image">
                            </td>
                            <td>
                                <button class="btn btn-mini btn-primary" type="file"
                                        ngf-select="tcc.addImage(c.entries,$index,$files)" ngf-accept="'image/*'"><i
                                        class="fa fa-upload"></i></button>
                                <button class="btn btn-mini btn-default" ng-click="tcc.moveUp(c.entries,$index)"><i
                                        class="fa fa-arrow-up"></i></button>
                                <button class="btn btn-mini btn-default" ng-click="tcc.moveDown(c.entries,$index)"><i
                                        class="fa fa-arrow-down"></i></button>
                                <button class="btn btn-mini btn-danger" ng-click="tcc.removeEntry(c,$index)"><i
                                        class="fa fa-trash"></i></button>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            <button class="btn btn-primary" ng-click="tcc.addCategory()"><i class="fa fa-plus"></i> Add category
            </button>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <h1>Animals
                <button class="btn btn-mini btn-primary" ng-click="tcc.addAnimal()"><i class="fa fa-plus"></i></button>
                <button class="btn btn-mini btn-primary" ng-click="tcc.sortAnimals()" title="Sort alphabetically"><i
                        class="fa fa-sort-alpha-asc"></i></button>
                <button class="btn btn-mini btn-primary" ng-click="tcc.minimizeAll(tcc.animalUiStatus)"
                        title="Minimize all"><i class="fa fa-window-minimize"></i></button>
                <button class="btn btn-mini btn-primary" ngf-select="tcc.uploadAnimalCSV($file)"
                        title="Upload CSV of animals"><i class="fa fa-upload"></i></button>
                <button class="btn btn-mini btn-primary" ng-click="tcc.downloadAnimalCSV()"
                        title="Download CSV of animals"><i class="fa fa-download"></i></button>
            </h1>

            <div class="panel panel-default" ng-repeat="a in tcc.model.animals">
                <div class="panel-heading pointer"
                     ng-click="tcc.animalUiStatus[$index].minimized = !tcc.animalUiStatus[$index].minimized">
                    <div class="pull-right">
                        <div class="btn-group btn-group-xs" role="group" aria-label="Animal options">
                            <button class="btn btn-default"
                                    ng-click="tcc.moveAnimalUp($index); $event.stopPropagation();"><i
                                    class="fa fa-arrow-up"></i></button>
                            <button class="btn btn-default"
                                    ng-click="tcc.moveAnimalDown($index); $event.stopPropagation();"><i
                                    class="fa fa-arrow-down"></i></button>
                            <button ng-if="!tcc.animalUiStatus[$index].minimized" class="btn btn-default"
                                    ng-click="tcc.animalUiStatus[$index].minimized = true; $event.stopPropagation();"><i
                                    class="fa fa-window-minimize"></i></button>
                            <button ng-if="tcc.animalUiStatus[$index].minimized" class="btn btn-default"
                                    ng-click="tcc.animalUiStatus[$index].minimized = false; $event.stopPropagation();"><i
                                    class="fa fa-window-maximize"></i></button>
                        </div>
                        <button class="btn btn-danger btn-xs"
                                ng-click="tcc.removeAnimal($index); $event.stopPropagation()"><i
                                class="fa fa-trash"></i></button>
                    </div>

                    <h2 class="panel-title" ng-bind="tcc.fullName(a) || 'New animal'"></h2>
                </div>

                <div class="minimizable" ng-show="!tcc.animalUiStatus[$index].minimized">
                    <div class="panel-body">
                        <form>
                            <div class="form-group">
                                <label>Common Name</label>
                                <input type="text" class="form-control" placeholder="Animal name"
                                       ng-model="a.vernacularName">
                            </div>

                            <div class="form-group">
                                <label>Scientific Name</label>
                                <input type="text" class="form-control" placeholder="Animal name"
                                       ng-model="a.scientificName">
                            </div>

                            <div class="form-group">
                                <label>Description</label>
                                <textarea class="form-control" placeholder="Description (markdown?)"
                                          ng-model="a.description"></textarea>
                            </div>

                            <div class="form-group" ng-repeat="c in tcc.model.categories">
                                <label>{{c.name}}</label>
                                <select class="form-control" ng-options="e.name as e.name for e in c.entries"
                                        ng-model="a.categories[c.name]">
                                    <option value="">Other</option>
                                </select>
                            </div>
                        </form>
                    </div>
                    <table class="table">
                        <thead>
                        <tr>
                            <th style="padding-left: 15px;">Image</th>
                            <th>
                                <button class="btn btn-mini btn-primary" ng-click="tcc.addBlankImage(a)"
                                        ng-disabled="a.images.length > 0">
                                    <i class="fa fa-plus"></i>
                                </button>
                                <button class="btn btn-mini btn-primary"
                                        type="file"
                                        ngf-select="tcc.addManyImages(a,null,$files)"
                                        ngf-multiple="false"
                                        ngf-accept="'image/*'"
                                        ng-disabled="a.images.length > 0"
                                        title="Upload multiple images for this animal">
                                    <i class="fa fa-upload"></i>
                                </button>
                            </th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr ng-repeat="i in a.images">
                            <td style="padding-left: 15px;" ngf-drop="tcc.addImage(a.images,$index,$files)">
%{--                                <img ng-src="{{tcc.imageUrl(i)}}"></td>--}%
                                <img ng-if="tcc.imageUrl(i) !== ''" ng-src="{{tcc.imageUrl(i)}}">
                                <img ng-if="tcc.imageUrl(i) === ''" src="https://via.placeholder.com/150?text=No+image">
                            <td>
                                <button class="btn btn-mini btn-primary" type="file"
                                        ngf-select="tcc.addImage(a.images,$index,$files)" ngf-accept="'image/*'"><i
                                        class="fa fa-upload"></i></button>
                                <button class="btn btn-mini btn-danger" ng-click="tcc.removeImage(a,$index)"><i
                                        class="fa fa-trash"></i></button>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                    <table class="table">
                        <thead>
                        <tr>
                            <th style="padding-left: 15px;">Audio Samples</th>
                            <th>
                                <button class="btn btn-mini btn-primary"
                                        type="file"
                                        ngf-select="tcc.addManyAudio(a,null,$files)"
                                        ngf-multiple="true"
                                        ngf-accept="'audio/*'"
                                        title="Upload multiple audio samples for this animal">
                                    <i class="fa fa-upload"></i>
                                </button>
                            </th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr ng-repeat="i in a.audio">
                            <td class="audio-flat"  style="padding-left: 15px;" ngf-drop="tcc.addAudio(a.audio,$index,$files)">
                                <span class="sm2_link"><a href="{{tcc.audioUrl(i)}}">Audio Sample {{$index + 1}}</a></span> <span ng-if="$index == 0">(This sample will be displayed on the animal selection view)</span>
                            </td>
                            <td>
                                <button class="btn btn-mini btn-primary" type="file"
                                        ngf-select="tcc.addAudio(a.audio,$index,$files)" ngf-accept="'audio/*'"><i
                                        class="fa fa-upload"></i></button>
                                <button class="btn btn-mini btn-danger" ng-click="tcc.removeAudio(a,$index)"><i
                                        class="fa fa-trash"></i></button>
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
            <button class="btn btn-primary save-options" ng-click="tcc.save()"><i class="fa fa-save"></i> Save</button>
        </div>
    </div>
</div>
<asset:javascript src="audio-template-config.js" asset-defer=""/>


<asset:script type="text/javascript">
    var templateId = ${templateInstance.id};
    var viewParams = <cl:json value="${viewParams2}"/>;
    var wstc = angular.module('wildlifespottertemplateconfig', ['ngAnimate', 'ngFileUpload']);

    function TemplateConfigController($http, $log, $timeout, $window, Upload) {
        var self = this;
        self.model = _.defaults(viewParams, { animals: [], categories:[]});

        function initCategoryUiStatus() {
            self.categoryUiStatus = [];
            for (var i = 0; i < self.model.categories.length; ++i) {
                self.categoryUiStatus.push({minimized: true});
            }
        }

        function initAnimalUiStatus() {
            self.animalUiStatus = [];
            for (var i = 0; i < self.model.animals.length; ++i) {
                self.animalUiStatus.push({minimized: true});
            }
        }

        function ensureAnimalArray() {
            if (angular.isUndefined(self.model.animals) || self.model.animals === null) {
                self.model.animals = [];
            }
        };

        initCategoryUiStatus();
        initAnimalUiStatus();

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
            ensureAnimalArray();
            self.model.animals.push({vernacularName: '', scientificName: '', description: '', categories: {}, images: [], audio: []});
            self.animalUiStatus.push({minimized: false});
        };

        self.removeAnimal = function($index) {
            self.model.animals.splice($index, 1);
            self.animalUiStatus.splice($index, 1);
        };

        self.addBlankImage = function(a) {
            ensureImagesArray(a);
            a.images.push({hash: ''});
        };

        function ensureImagesArray(a) {
            if (angular.isUndefined(a.images) || a.images === null) {
                a.images = [];
            }
        };

        function ensureAudioArray(a) {
            if (angular.isUndefined(a.audio) || a.audio === null) {
                a.audio = [];
            }
        };

        self.removeImage = function(a, $index) {
            a.images.splice($index, 1);
        };

        self.removeAudio = function(a, $index) {
            a.audio.splice($index, 1);
        };

        self.addManyFiles = function(animal, category, $files, fileType) {
            for (var i = 0; i < $files.length; i++) {
                var file = $files[i];
                var hashable;
                if (category) {
                    hashable = {name: $files[i].name, hash: ''};
                    category.entries.push(hashable);
                } else {
                    hashable = {hash: ''};
                    if (fileType === 'image') {
                        ensureImagesArray(animal);
                        animal.images.push(hashable);
                    } else if (fileType === 'audio') {
                        ensureAudioArray(animal);
                        animal.audio.push(hashable);
                    }
                }

                uploadFile(hashable, file, fileType);
            }
        };

        self.addManyImages = function(animal, category, $files) {
            self.addManyFiles(animal, category, $files, 'image');
        };

        self.addManyAudio = function(animal, category, $files) {
            self.addManyFiles(animal, category, $files, 'audio');
        };

        self.addFile = function(entryOrAnimalArray, $index, $file, fileType) {
            var entryOrAnimal = entryOrAnimalArray[$index];
            if (!$file) {
                entryOrAnimal.hash = '';
                return;
            }

            uploadFile(entryOrAnimal, $file[0], fileType);
        };

        self.addImage = function(entryOrAnimalArray, $index, $file) {
            self.addFile(entryOrAnimalArray, $index, $file, 'image');
        };

        self.addAudio = function(entryOrAnimalArray, $index, $file) {
            self.addFile(entryOrAnimalArray, $index, $file, 'audio');
        };

        function uploadFile(hashable, file, type) {
            var data;
            if ("name" in hashable) {
                data = {entry: file};
            } else {
                data = {animal: file};
            }
            var name = file.name;
            var submitUrl = "<g:createLink controller="template" action="uploadSpotterFile"/>";
            if (type !== undefined && type === 'audio') {
                submitUrl = "<g:createLink controller="template" action="uploadSpotterFile" params="[fileType: 'audio']"/>";
            }

            Upload.upload({
                url: submitUrl,
                data: data
            }).then(function (resp) {
                $log.debug('Success ' + name + ' uploaded. Response: ' + JSON.stringify(resp.data));
                hashable.hash = resp.data.hash;
                hashable.ext = resp.data.format;
            }, function (resp) {
                bootbox.alert("Image upload failed");
                $log.error('Error status: ' + resp.status);
            }, function (evt) {
                var progressPercentage = parseInt(100.0 * evt.loaded / evt.total);
                $log.info('progress: ' + progressPercentage + '% ' + name);
            });
        };

        function uploadImage(hashable, file) {
            uploadFile(hashable, file, 'image');
        };

        function uploadAudio(hashable, file) {
            uploadFile(hashable, file, 'audio');
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

        var imageUrlTemplate = "<cl:sizedImageUrl prefix="wildlifespotter" name="{{name}}" width="{{width}}"
                                                  height="{{height}}" format="{{format}}" template="true"/>";

        var audioUrlTemplate = "<cl:audioUrl prefix="audiotranscribe" name="{{name}}" format="{{format}}" template="true"/>";

        self.entryUrl = function(e) {
            var url = "";
            if (!angular.isUndefined(e.hash) && e.hash !== "") {
                url = imageUrlTemplate.replace("{{name}}", e.hash).replace("{{width}}", "100").replace("{{height}}", "100").replace("{{format}}", "png");
            }
            return url;
        };

        self.imageUrl = function(i) {
            var url = "";
            if (!angular.isUndefined(i.hash) && i.hash !== "") {
                url = imageUrlTemplate.replace("{{name}}", i.hash).replace("{{width}}", "150").replace("{{height}}", "150").replace("{{format}}", i.ext);
            }
            return url;
        };

        self.audioUrl = function(i) {
            var url = audioUrlTemplate.replace("{{name}}", i.hash).replace("{{format}}", i.ext);
            return url;
        }

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

        self.uploadCategoryJSON = function($file) {
            var reader = new FileReader();

            reader.onload = function(e) {
                // Render thumbnail.
                var categories = JSON.parse(e.target.result);
                console.log(categories);

                // TODO sanity check
                if (!Array.isArray(categories)) {
                    bootbox.alert("Uploaded file is not an array");
                    return;
                }

                var catDefaults = { name: '', entries: [] };
                var entryDefaults = { hash: '', name: '' };

                categories = categories.map(function(v,i,l) {
                    var cat = _.defaults(v, catDefaults);
                    cat.entries = cat.entries.map(function(v2,i2,l2) {
                        return _.defaults(v2, entryDefaults);
                    });
                    return cat;
                });

                self.model.categories = categories;
            };

            // Read in the image file as a data URL.
            reader.readAsText($file);
        };

        self.downloadCategoryJSON = function($file) {
            var data = JSON.stringify(angular.copy(self.model.categories).map(function(v,i,l) {
                var cat = _.omit(v, 'prevName');
                cat.entries = v.entries.map(function(v2,i2,l2) {
                    return _.omit(v2, 'prevName');
                });
                return cat;
            }), null, 2);
            var fileName = "" + templateId + "-categories.json";
            downloadFile(data, 'application/json', fileName);
        };

        self.uploadAnimalCSV = function($file) {
            CSV.fetch({
                file: $file
            }).done(function(dataset) {
                $log.info(dataset);

                var normalisedFields = _.map(dataset.fields, function(v,i) {
                    var key = findCategory(v);
                    if (!key) bootbox.alert("Unknown category/column: " + v);
                        return key || v;
                });

                var defaultCats = _.chain(self.model.categories).pluck('name').map(function(v) { return [v, null] }).object().value();
                var catNames = _.chain(self.model.categories).pluck('name').value();
                var animalDefaults = {
                    vernacularName: '',
                    scientificName: '',
                    description: '',
                    images: [],
                    audio: [],
                    categories: defaultCats
                };

                var animals = _.map(dataset.records, function(v,i,l) {
                    var row = _.chain(v).map(function(v2,i2) {
                        var field = normalisedFields[i2];
                        return [field, v2];
                    }).value();

                    var animal = _.chain(row).filter(function(v2,i2) {
                        return _.contains(['vernacularName','scientificName','description','images'], v2[0]);
                    }).object().value();

                    if (animal.images) animal.images = animal.images.split(',').map(function (s,i,l) { return {hash: s.trim()}; });
                    else animal.images = [];

                    var categories = _.chain(row).filter(function(v2,i2) {
                        var field = v2[0];
                        return !_.contains(['vernacularName','scientificName','description','images'], field) && _.contains(catNames, field);
                    }).map(function(v2,i2) {
                        var field = v2[0];
                        var origValue = v2[1];
                        var value = findCatEntry(field, origValue);
                        if (origValue && !value) {
                            bootbox.alert("Can't find a matching value for row " + (i+2) + ", vernacular name " +
                                animal.vernacularName + ", category " + field + ", value of " + origValue );
                        }
                        return [ field, value ];
                    }).object().value();

                    animal.categories = _.defaults(categories, defaultCats);

                    animal = _.defaults(animal, animalDefaults);
                    if (animal.vernacularName == null) animal.vernacularName = '';
                    if (animal.scientificName == null) animal.scientificName = '';
                    if (animal.description == null) animal.description = '';

                    return animal;
                });

                $log.info(animals);

                self.model.animals = animals;
                initAnimalUiStatus();

            }).fail(function(e) {
                bootbox.alert("Couldn't read CSV:" + e);
            });
        };

        function findCategory(s) {
            var S = s.toUpperCase();
            var vn = 'vernacularName', sn = 'scientificName', desc = 'description', images = 'images';
            if (S === vn.toUpperCase()) return vn;
            if (S === sn.toUpperCase()) return sn;
            if (S === desc.toUpperCase()) return desc;
            if (S === images.toUpperCase()) return images;
            for (var i = 0; i < self.model.categories.length; ++i) {
                var c = self.model.categories[i];
                var name = (c.name || '').toUpperCase();
                if (name === S) {
                    return c.name;
                }
            }
            return null;
        }

        function findCatEntry(cat, value) {
            var V = (value || '').toUpperCase();
            var c = _.findWhere(self.model.categories, { name: cat });

            if (!c) return null;

            for (var i = 0; i < c.entries.length; ++i) {
                var e = c.entries[i];
                var name = (e.name || '').toUpperCase();
                if (name === V) {
                    return e.name;
                }
            }

            return null;
        }

        self.downloadAnimalCSV = function() {
            var fields = ["vernacularName","scientificName","description"].concat(_.pluck(self.model.categories, "name"),["images"]);
            var records = self.model.animals.map(function(v,i,l) {
                var start = [v.vernacularName, v.scientificName, v.description];
                var cats = self.model.categories.map(function(v2,i2,l2) {
                    return v.categories[v2.name];
                });
                var images = (v.images || []).map(function(v2,i2,l2) { return v2.hash}).join(',');
                return start.concat(cats,[images]);
            });
            var data = CSV.serialize([fields].concat(records));
            var fileName = "" + templateId + "-animals.csv";
            downloadFile(data, 'text/csv', fileName);
        };

        function downloadFile(data, contentType, fileName) {
            var file = new Blob([data], {type: contentType});
            var a = document.createElement("a");
            document.body.appendChild(a);
            var fileURL = $window.URL.createObjectURL(file);
            a.href = fileURL;
            a.download = fileName;
            a.click();
            document.body.removeChild(a);
            $timeout(function() {
                $log.info("Revoking " + fileName);
                $window.URL.revokeObjectURL(fileURL);
            }, 60 * 1000, false);
        }

        function filterModel() {
            var results = _.chain(self.model.animals).zip(self.animalUiStatus).filter(function(e,i,l) {
                var animal = e[0];
                var result = animal.scientificName || animal.vernacularName || animal.description || (animal.images && animal.images.length && animal.images.some(function(v) { return !!v.hash}));
            return result;
        }).unzip().value();
        self.model.animals = results[0];
        self.animalUiStatus = results[1];

        results = _.chain(self.model.categories).zip(self.categoryUiStatus).filter(function(e,i,l) {
            var cat = e[0];
            var result = cat.name || (cat.entries && cat.entries.length && cat.entries.every(function(entry) {
                return !!entry.name || !!entry.hash;
            }));
                return result;
            }).unzip().value();
            self.model.categories = results[0];
            self.categoryUiStatus = results[1];
        }

        self.save = function() {
            filterModel();
            var p = $http.post("<g:createLink controller="template" action="saveWildlifeTemplateConfig" id="${id}"/>", self.model);
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
