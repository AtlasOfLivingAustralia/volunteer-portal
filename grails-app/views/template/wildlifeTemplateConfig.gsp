<%@ page import="au.org.ala.volunteer.Template" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <g:set var="templateEntityName" value="${message(code: 'template.label', default: 'Template')}"/>
    <title><g:message code="wildlifeSpotter.template.label" default="Wildlife Spotter Template Configuration"/></title>
    <style>
    .form-control {
        height: 32px;
    }

    .pointer {
        cursor: pointer;
    }
    </style>
</head>

<body>
<cl:headerContent title="${message(code: 'default.wildlifeSpotterOptions.label', default: 'Wildlife Spotter Options')}"
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
            <button class="btn btn-primary" ng-click="tcc.save()"><i class="fa fa-save"></i> Save</button>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <h1>
                Categories
                <button class="btn btn-sm btn-outline-secondary" ng-click="tcc.addCategory()" data-bs-toggle="tooltip" data-bs-placement="top" title="Add Category">
                    <i class="fa fa-plus"></i>
                </button>
                <button class="btn btn-sm btn-outline-secondary" ng-click="tcc.minimizeAll(tcc.categoryUiStatus)" data-bs-toggle="tooltip" data-bs-placement="top"
                        title="Minimize all">
                    <i class="fa fa-window-minimize"></i>
                </button>
                <button class="btn btn-sm btn-outline-secondary" ngf-select="tcc.uploadCategoryJSON($file)" data-bs-toggle="tooltip" data-bs-placement="top"
                        title="Upload Categories as JSON">
                    <i class="fa fa-upload"></i>
                </button>
                <button class="btn btn-sm btn-outline-secondary" ng-click="tcc.downloadCategoryJSON()" data-bs-toggle="tooltip" data-bs-placement="top"
                        title="Download Categories as JSON">
                    <i class="fa fa-download"></i>
                </button>
            </h1>

            <div class="card" ng-repeat="c in tcc.model.categories">
                <div class="card-header pointer"
                     ng-click="tcc.categoryUiStatus[$index].minimized = !tcc.categoryUiStatus[$index].minimized">
                    <div class="float-end">
                        <div class="btn-group btn-group-sm" role="group" aria-label="Category options">
                            <button class="btn btn-sm btn-outline-secondary"
                                    ng-click="tcc.moveCategoryUp($index); $event.stopPropagation();" data-bs-toggle="tooltip" data-bs-placement="top"
                                    title="Move category up">
                                <i class="fa fa-arrow-up"></i>
                            </button>
                            <button class="btn btn-sm btn-outline-secondary"
                                    ng-click="tcc.moveCategoryDown($index); $event.stopPropagation();" data-bs-toggle="tooltip" data-bs-placement="top"
                                    title="Move category down">
                                <i class="fa fa-arrow-down"></i>
                            </button>
                            <button ng-if="!tcc.categoryUiStatus[$index].minimized" class="btn btn-sm btn-outline-secondary" data-bs-toggle="tooltip" data-bs-placement="top"
                                    title="Minimize category"
                                    ng-click="tcc.categoryUiStatus[$index].minimized = true; $event.stopPropagation();">
                                <i class="fa fa-window-minimize"></i>
                            </button>
                            <button ng-if="tcc.categoryUiStatus[$index].minimized" class="btn btn-sm btn-outline-secondary" data-bs-toggle="tooltip" data-bs-placement="top"
                                    title="Maximize category"
                                    ng-click="tcc.categoryUiStatus[$index].minimized = false; $event.stopPropagation();">
                                <i class="fa fa-window-maximize"></i>
                            </button>
                        </div>
                        <button class="btn btn-sm btn-outline-danger" data-bs-toggle="tooltip" data-bs-placement="top" title="Remove category"
                                ng-click="tcc.removeCategory($index); $event.stopPropagation();">
                            <i class="fa fa-times"></i>
                        </button>
                    </div>

                    <h2 class="card-title" ng-bind="c.name || 'New category'"></h2>
                </div>

                <div class="minimizable" ng-show="!tcc.categoryUiStatus[$index].minimized">
                    <div class="card-body">
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
                                <button class="btn btn-sm btn-secondary" ng-click="tcc.addEntry(c)" data-bs-toggle="tooltip" data-bs-placement="top" title="Add entry">
                                    <i class="fa fa-plus"></i>
                                </button>
                                <button class="btn btn-sm btn-secondary" type="file"
                                        ngf-drop="tcc.addManyImages(null,c,$files)"
                                        ngf-select="tcc.addManyImages(null,c,$files)" ngf-multiple="true" data-bs-toggle="tooltip" data-bs-placement="top"
                                        ngf-accept="'image/*'" title="upload multiple category images">
                                    <i class="fa fa-upload"></i>
                                </button>
                            </th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr ng-repeat="e in c.entries">
                            <td><input type="text" class="form-control" placeholder="Entry name" ng-model="e.name"
                                       ng-change="tcc.entryChange(c, e)"></td>
                            <td ngf-drop="tcc.addImage(c.entries,$index,$files)" ngf-accept="'image/*'"><img
                                    ng-src="{{tcc.entryUrl(e)}}"></td>
                            <td>
                                <button class="btn btn-sm btn-outline-secondary" type="file" data-bs-toggle="tooltip" data-bs-placement="top" title="Upload entry image"
                                        ngf-select="tcc.addImage(c.entries,$index,$files)" ngf-accept="'image/*'">
                                    <i class="fa fa-upload"></i>
                                </button>
                                <button class="btn btn-sm btn-outline-secondary" ng-click="tcc.moveUp(c.entries,$index)" data-bs-toggle="tooltip" data-bs-placement="top"
                                        title="Move entry up">
                                    <i class="fa fa-arrow-up"></i>
                                </button>
                                <button class="btn btn-sm btn-outline-secondary" ng-click="tcc.moveDown(c.entries,$index)" data-bs-toggle="tooltip" data-bs-placement="top"
                                        title="Move entry down">
                                    <i class="fa fa-arrow-down"></i>
                                </button>
                                <button class="btn btn-sm btn-outline-danger" ng-click="tcc.removeEntry(c,$index)" data-bs-toggle="tooltip" data-bs-placement="top"
                                        title="Remove entry">
                                    <i class="fa fa-times"></i>
                                </button>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            <button class="btn btn-sm btn-secondary" ng-click="tcc.addCategory()"><i class="fa fa-plus"></i> Add category
            </button>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <h1>Animals
                <button class="btn btn-sm btn-outline-secondary" ng-click="tcc.addAnimal()" data-bs-toggle="tooltip" data-bs-placement="top" title="Add animal">
                    <i class="fa fa-plus"></i>
                </button>
                <button class="btn btn-sm btn-outline-secondary" ng-click="tcc.sortAnimals()" data-bs-toggle="tooltip" data-bs-placement="top" title="Sort alphabetically">
                    <i class="fa fa-sort-alpha-asc"></i>
                </button>
                <button class="btn btn-sm btn-outline-secondary" ng-click="tcc.minimizeAll(tcc.animalUiStatus)" data-bs-toggle="tooltip" data-bs-placement="top"
                        title="Minimize all">
                    <i class="fa fa-window-minimize"></i>
                </button>
                <button class="btn btn-sm btn-outline-secondary" ngf-select="tcc.uploadAnimalCSV($file)" data-bs-toggle="tooltip" data-bs-placement="top"
                        title="Upload CSV of animals">
                    <i class="fa fa-upload"></i>
                </button>
                <button class="btn btn-sm btn-outline-secondary" ng-click="tcc.downloadAnimalCSV()" data-bs-toggle="tooltip" data-bs-placement="top"
                        title="Download CSV of animals">
                    <i class="fa fa-download"></i>
                </button>
            </h1>

            <div class="card" ng-repeat="a in tcc.model.animals">
                <div class="card-header pointer"
                     ng-click="tcc.animalUiStatus[$index].minimized = !tcc.animalUiStatus[$index].minimized">
                    <div class="float-end">
                        <div class="btn-group btn-group-sm" role="group" aria-label="Animal options">
                            <button class="btn btn-sm btn-outline-secondary" data-bs-toggle="tooltip" data-bs-placement="top" title="Move animal up"
                                    ng-click="tcc.moveAnimalUp($index); $event.stopPropagation();">
                                <i class="fa fa-arrow-up"></i></button>
                            <button class="btn btn-sm btn-outline-secondary" data-bs-toggle="tooltip" data-bs-placement="top" title="Move animal down"
                                    ng-click="tcc.moveAnimalDown($index); $event.stopPropagation();">
                                <i class="fa fa-arrow-down"></i></button>
                            <button ng-if="!tcc.animalUiStatus[$index].minimized" class="btn btn-sm btn-outline-secondary"
                                    data-bs-toggle="tooltip" data-bs-placement="top" title="Minimise details"
                                    ng-click="tcc.animalUiStatus[$index].minimized = true; $event.stopPropagation();">
                                <i class="fa fa-window-minimize"></i></button>
                            <button ng-if="tcc.animalUiStatus[$index].minimized" class="btn btn-sm btn-outline-secondary"
                                    data-bs-toggle="tooltip" data-bs-placement="top" title="Maximise details"
                                    ng-click="tcc.animalUiStatus[$index].minimized = false; $event.stopPropagation();">
                                <i class="fa fa-window-maximize"></i></button>
                        </div>
                        <button class="btn btn-sm btn-outline-danger btn-sm" data-bs-toggle="tooltip" data-bs-placement="top" title="Remove animal"
                                ng-click="tcc.removeAnimal($index); $event.stopPropagation()">
                            <i class="fa fa-times"></i></button>
                    </div>

                    <h2 class="card-title" ng-bind="tcc.fullName(a) || 'New animal'"></h2>
                </div>

                <div class="minimizable" ng-show="!tcc.animalUiStatus[$index].minimized">
                    <div class="card-body">
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
                            <th>Image</th>
                            <th>
                                <button class="btn btn-sm btn-secondary" ng-click="tcc.addBlankImage(a)"
                                        data-bs-toggle="tooltip" data-bs-placement="top" title="Add new image">
                                    <i class="fa fa-plus"></i>
                                </button>
                                <button class="btn btn-sm btn-secondary" type="file"  data-bs-toggle="tooltip" data-bs-placement="top"
                                        ngf-select="tcc.addManyImages(a,null,$files)" ngf-multiple="true"
                                        ngf-accept="'image/*'" title="Upload multiple images for this animal">
                                    <i class="fa fa-upload"></i>
                                </button>
                            </th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr ng-repeat="i in a.images">
                            <td ngf-drop="tcc.addImage(a.images,$index,$files)"><img ng-src="{{tcc.imageUrl(i)}}"></td>
                            <td>
                                <button class="btn btn-sm btn-outline-secondary" type="file" data-bs-toggle="tooltip" data-bs-placement="top"
                                        title="Upload image for this animal"
                                        ngf-select="tcc.addImage(a.images,$index,$files)" ngf-accept="'image/*'">
                                    <i class="fa fa-upload"></i></button>
                                <button class="btn btn-sm btn-outline-secondary" ng-click="tcc.moveUp(a.images,$index)"
                                        data-bs-toggle="tooltip" data-bs-placement="top" title="Move up">
                                    <i class="fa fa-arrow-up"></i></button>
                                <button class="btn btn-sm btn-outline-secondary" ng-click="tcc.moveDown(a.images,$index)"
                                        data-bs-toggle="tooltip" data-bs-placement="top" title="Move down">
                                    <i class="fa fa-arrow-down"></i></button>
                                <button class="btn btn-sm btn-outline-danger" ng-click="tcc.removeImage(a,$index)"
                                        data-bs-toggle="tooltip" data-bs-placement="top" title="Remove image">
                                    <i class="fa fa-times"></i></button>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            <button class="btn btn-secondary" ng-click="tcc.addAnimal()"><i class="fa fa-plus"></i> Add animal</button>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <button class="btn btn-primary" ng-click="tcc.save()" style="margin-top: 1rem;"><i class="fa fa-save"></i> Save</button>
        </div>
    </div>
</div>

<asset:script type="text/javascript">
    var T_CONF = {
        templateId:${templateInstance.id},
        viewParams:<cl:json value="${viewParams2}"/>,
        submitUrl: "<g:createLink controller="template" action="uploadSpotterFile"/>",
        audioSubmitUrl: "<g:createLink controller="template" action="uploadSpotterFile" params="[fileType: 'audio']"/>",
        imageUrlTemplate: "<cl:sizedImageUrl prefix="wildlifespotter" name="{{name}}" width="{{width}}" height="{{height}}" format="{{format}}" template="true" allowBroken="true"/>",
        audioUrlTemplate: "<cl:audioUrl prefix="audiotranscribe" name="{{name}}" format="{{format}}" template="true"/>",
        saveTemplateUrl: "<g:createLink controller="template" action="saveWildlifeTemplateConfig" id="${id}"/>",
        placeholderImageUrl: "${resource(dir: 'images', file: 'ws-placeholder-150.png')}"
    };
</asset:script>

<asset:javascript src="wildlifespotter-template-config.js" asset-defer=""/>
<asset:javascript src="template-config.js" asset-defer=""/>

<asset:script type="text/javascript">
    $(document).ready(function () {
        const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
        const tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
            if (bootstrap.Tooltip.getInstance(tooltipTriggerEl)) {
                return;
            }
            return new bootstrap.Tooltip(tooltipTriggerEl)
        })
    });
</asset:script>
</body>
</html>
