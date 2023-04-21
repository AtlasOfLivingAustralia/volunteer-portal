<%@ page import="au.org.ala.volunteer.Template" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
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
<asset:script type="text/javascript">
    var T_CONF = {
        templateId:${templateInstance.id},
        viewParams:<cl:json value="${viewParams2}"/>,
        submitUrl: "<g:createLink controller="template" action="uploadSpotterFile"/>",
        audioSubmitUrl: "<g:createLink controller="template" action="uploadSpotterFile" params="[fileType: 'audio']"/>",
        imageUrlTemplate: "<cl:sizedImageUrl prefix="wildlifespotter" name="{{name}}" width="{{width}}" height="{{height}}" format="{{format}}" template="true"/>",
        audioUrlTemplate: "<cl:audioUrl prefix="audiotranscribe" name="{{name}}" format="{{format}}" template="true"/>",
        saveTemplateUrl: "<g:createLink controller="template" action="saveWildlifeTemplateConfig" id="${id}"/>"
    };
</asset:script>

<asset:javascript src="audio-template-config.js" asset-defer=""/>
<asset:javascript src="template-config.js" asset-defer=""/>

</body>
</html>
