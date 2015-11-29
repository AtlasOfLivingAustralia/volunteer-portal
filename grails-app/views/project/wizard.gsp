<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><cl:pageTitle title="Create a new Expedition"/></title>

    <r:require module="digivol-new-project-wizard" />

    <r:style>
.angular-google-map-container { height: 400px; }

.angular-google-map-container img {
    max-width: none !important;
    max-height: none !important;
}
span.label i.remove {
    cursor: pointer;
}
    </r:style>
</head>

<body class="admin" data-ng-app="projectWizard">
<div class="container" >
    <cl:headerContent title="Create a new Expedition" selectedNavItem="bvpadmin">
        <h2 class="ng-cloak">{{$state.current.data.title}}</h2>
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin', action: 'index'), label: 'Administration']
            ]
        %>
    </cl:headerContent>
    <div class="panel panel-default">
        <div class="panel-body ng-cloak">
            <ui-view autoscroll="false"></div>
        </div>
    </div>
    <script type="text/ng-template" id="start.html">
        <h3>Welcome to the New Expedition wizard</h3>

        <div>
            Before you start you will need the following:
            <ul>
                <li>A name for your expedition, and a description</li>
                <li>An image that represents your expedition (JPEG sized 600px wide, with aspect ration between 4:3 and 16:9)</li>
                <li>A collection of images, each representing a task to be transcribed</li>
                <li>A template for transcribing each task. These are created from the Admin page</li>
                <li>(Optional) Picklists for fields on your template. These can be uploaded through the Admin page</li>
                <li>(Optional) Tutorials or helpful web links. Tutorial files can be uploaded from the Admin page</li>
                <li>(Optional) A csv data file containing additional data for each task</li>
            </ul>
        </div>

        <button role="button" type="button" class="btn btn-default" data-ng-click="cancel()">Cancel</button>
        <button role="button" type="button" class="btn btn-primary" data-ng-click="continue()">Start&nbsp;<i class="glyphicon glyphicon-chevron-right glyphicon-white"></i></button>
    </script>

    <script type="text/ng-template" id="institution-details.html">
        <form class="form-horizontal" name="form">
            <div class="form-group">
                <label class="col-sm-3 control-label" for="featuredOwner">Expedition institution</label>

                <div class="col-sm-6">
                    <input type="text" class="form-control" id="featuredOwner" name="featuredOwner" ng-model="project.featuredOwner.name" dv-typeahead ta-options="options" ta-datasets="data" ta-change="institutionSelect(type, suggestion)" ta-select="institutionSelect(type, suggestion)" ta-autocomplete="institutionSelect(type, suggestion)" />
                </div>

                <div class="col-sm-3">
                    <cl:ngHelpText>This may be the name of an institution, or a specific department or collection within an institution</cl:ngHelpText>
                    <input type="hidden" name="featuredOwnerId" data-ng-model="project.featuredOwner.id"/>
                    <span id="institution-link-icon" class="ng-cloak muted" data-ng-show="project.featuredOwner.id"><small><i class="icon-ok"></i> Linked to <a
                            id="institution-link" ng-href="${createLink(controller: 'institution', action: 'index')}/{{project.featuredOwner.id}}" target="_blank">institution!</a></small></span>
                </div>
            </div>

            <div class="form-group">
                <div class="col-sm-offset-3 col-sm-9">
                    <button role="button" type="button" class="btn btn-default" data-ng-click="cancel()">Cancel</button>
                    <button role="button" type="button" class="btn btn-default" data-ng-click="back()"><i class="glyphicon glyphicon-chevron-left"></i>&nbsp;Back</button>
                    <button role="button" type="button" class="btn btn-primary" data-ng-click="continue()" >Next&nbsp;<i
                            class="glyphicon glyphicon-chevron-right glyphicon-white"></i></button>
                </div>
            </div>

        </form>
    </script>
    
    <script type="text/ng-template" id="project-details.html">
        <form class="form-horizontal" name="form">
        
            <div class="form-group required" show-errors>
                <label class="col-sm-3 control-label" for="projectName">Expedition name</label>
        
                <div class="col-sm-6">
                    <input type="text" class="form-control" name="projectName" id="projectName" data-ng-model="project.name" data-ng-model-options="{ debounce: 500 }" data-ng-required="true" dv-projectname />
                </div>

                <div class="col-sm-3">
                    <cl:ngHelpText>Will be displayed on the front page and in the expeditions list</cl:ngHelpText>
                    <span ng-show="form.projectName.$pending.projectname">Checking if this name is available...</span>
                    <span style="color: red; font-weight: bold" ng-show="form.projectName.$error.projectname">This project name is already taken!</span>
                </div>
            </div>
        
            <div class="form-group required" show-errors>
                <label class="col-sm-3 control-label" for="shortDescription">Short description</label>
        
                <div class="col-sm-6">
                    <input type="text" class="form-control" name="shortDescription" id="shortDescription" data-ng-model="project.shortDescription" data-ng-required="true"  />
                </div>

                <div class="col-sm-3">
                    <cl:ngHelpText>Used on the front page if your expedition is Expedition Of The Day</cl:ngHelpText>
                </div>
            </div>
        
            <div class="form-group required" show-errors>
                <label class="col-sm-3 control-label" for="longDescription">Long description</label>
        
                <div class="col-sm-6">
                    <textarea rows="8" class="form-control" name="longDescription" id="longDescription"
                                data-ng-model="project.longDescription" required="required" data-ng-required="true"></textarea>
                </div>

                <div class="col-sm-3">
                    <cl:ngHelpText>Displayed on the expedition front page</cl:ngHelpText>
                </div>
            </div>
        
            <div class="form-group required" show-errors>
                <label class="col-sm-3 control-label" for="templateId">Template</label>
        
                <div class="col-sm-6">
                    <g:select class="form-control" name="templateId" from="${templates}" optionKey="id" data-ng-model="project.templateId" data-dv-convert-to-number="" data-ng-required="true" />
                </div>

                <div class="col-sm-3">
                    <cl:ngHelpText>The template determines what fields are transcribed</cl:ngHelpText>
                </div>
            </div>
        
            <div class="form-group required" show-errors>
                <label class="col-sm-3 control-label" for="projectTypeId">Expedition type</label>
        
                <div class="col-sm-6">
                    <g:select class="form-control" name="projectTypeId" from="${projectTypes}" optionKey="id" optionValue="label"
                              data-ng-model="project.projectTypeId" data-dv-convert-to-number="" data-ng-required="true"  />
                </div>

                <div class="col-sm-3">

                </div>
            </div>
        
            <div class="form-group">
                <div class="col-sm-offset-3 col-sm-6">
                    <button role="button" type="button" class="btn btn-default" data-ng-click="cancel()">Cancel</button>
                    <button role="button" type="button" class="btn btn-default" data-ng-click="back()"><i class="glyphicon glyphicon-chevron-left"></i>&nbsp;Back</button>
                    <button role="button" type="button"  class="btn btn-primary" data-ng-disabled="form.$invalid" data-ng-click="continue()">Next&nbsp;<i
                            class="glyphicon glyphicon-chevron-right glyphicon-white"></i></button>
                </div>
            </div>
        
        </form>
    </script>
    
    <script type="text/ng-template" id="image.html">
    <form class="form-horizontal" name="form">

        <div class="form-group">
            <div class="col-sm-offset-3 col-sm-6">
                The Expedition image appears on the expedition front page, and in the expeditions list.
            </div>
        </div>

        <div class="form-group">
            <label class="col-sm-3 control-label" for="featuredImage">Expedition image</label>

            <div class="col-sm-6">
                <input type="file" name="featuredImage" id="featuredImage" ngf-select="upload($file, 'imageUrl')"/>
            </div>

            <div class="col-sm-3">
                <cl:ngHelpText>Expedition image should be at least <strong>600 pixels wide</strong> and have an aspect ratio between 4:3 and 16:9. Images that have different dimensions will be scaled to this size when uploaded. To preserve image quality, crop and scale them to this size before uploading.</cl:ngHelpText>
            </div>
            <div class="col-sm-offset-3 col-sm-9" data-ng-if="progress > 0">
                <div class="progress">
                    <div class="progress-bar" role="progressbar" aria-valuenow="{{progress}}" aria-valuemin="0" aria-valuemax="100" ng-style="{'width': progress+'%'}">
                        {{progress}}%
                    </div>
                </div>
            </div>
        </div>

        <div class="form-group" data-ng-if="project.imageUrl">
            <div class="col-sm-offset-3 col-sm-9">
                <img ng-src="{{project.imageUrl}}" class="img-responsive img-thumbnail"/>
                <button role="button" type="button" class="btn btn-warning" data-ng-click="clearImage()"><i
                        class="icon-trash icon-white"></i>&nbsp;Remove image</button>
            </div>
        </div>

        <div class="form-group">
            <label class="col-sm-3 control-label" for="imageCopyright">Image copyright</label>

            <div class="col-sm-6">
                <input type="text" id="imageCopyright" name="imageCopyright" class="form-control" data-ng-model="project.imageCopyright"/>
            </div>
        </div>

        <div class="form-group">
            <label class="col-sm-3 control-label" for="backgroundImage">Expedition background image</label>

            <div class="col-sm-6">
                <input type="file" name="backgroundImage" id="backgroundImage" ngf-select="upload($file, 'backgroundImageUrl')"/>
            </div>

            <div class="col-sm-3">
                <cl:ngHelpText>For best results and to preserve quality, it is recommend that the background image has a <strong>resolution</strong> of at least <strong>2 megapixels</strong> (eg: 1920 x 1080). The system won't accept images bigger than 512KB.<br><strong>The darker the image the better!</strong></cl:ngHelpText>
            </div>
            <div class="col-sm-offset-3 col-sm-9" data-ng-if="backgroundProgress > 0">
                <div class="progress">
                    <div class="progress-bar" role="progressbar" aria-valuenow="{{backgroundProgress}}" aria-valuemin="0" aria-valuemax="100" ng-style="{'width': backgroundProgress+'%'}">
                        {{backgroundProgress}}%
                    </div>
                </div>
            </div>
        </div>

        <div class="form-group" data-ng-if="project.backgroundImageUrl">
            <div class="col-sm-offset-3 col-sm-9">
                <img ng-src="{{project.backgroundImageUrl}}" class="img-responsive img-thumbnail"/>
                <button role="button" type="button" class="btn btn-warning" data-ng-click="clearBackgroundImage()"><i
                        class="icon-trash icon-white"></i>&nbsp;Remove image</button>
            </div>
        </div>

        <div class="form-group">
            <label class="col-sm-3 control-label" for="backgroundImageCopyright">Background Image copyright</label>

            <div class="col-sm-6">
                <input type="text" id="backgroundImageCopyright" name="backgroundImageCopyright" class="form-control" data-ng-model="project.backgroundImageCopyright"/>
            </div>
        </div>

        <div class="form-group">
            <div class="col-sm-offset-3 col-sm-6">
                <button role="button" type="button" class="btn btn-default" data-ng-click="cancel()" data-ng-disabled="progress > 0">Cancel</button>
                <button role="button" type="button" class="btn btn-default" data-ng-click="back()" data-ng-disabled="progress > 0"><i class="glyphicon glyphicon-chevron-left"></i>&nbsp;Back</button>
                <button role="button" type="button"  class="btn btn-primary" data-ng-click="continue()" data-ng-disabled="progress > 0">Next&nbsp;<i
                        class="glyphicon glyphicon-chevron-right glyphicon-white"></i></button>
            </div>
        </div>

    </form>
    </script>

    <script type="text/ng-template" id="map.html">
    <form class="form-horizontal" name="form">

        <div class="form-group">
            <div class="col-sm-offset-3 col-sm-9">
                <div class="checkbox">
                    <label>
                        <input type="checkbox" name="showMap" data-ng-model="project.showMap"/>&nbsp;Show the map on the expedition front page
                    </label>
                </div>
            </div>
        </div>

        <div class="col-sm-offset-3 col-sm-9">
            <div class="alert alert-warning">
                Position the map to how you would like it to appear on the expedition front page
            </div>
        </div>


        <div id="mapPositionControls" class="form-group col-sm-12" data-ng-style="mapStyle()">

            <div class="row">
                <div class="col-sm-9 map-container">
                    <ui-gmap-google-map center='project.map.centre' zoom='project.map.zoom'></ui-gmap-google-map>
                </div>
                <div class="col-sm-3">
                    <div class="form-group">
                        <label for="mapZoomLevel">Zoom</label>

                        <input type="number" class="form-control" id="mapZoomLevel" name="mapZoomLevel" data-ng-model="project.map.zoom" data-ng-disabled="!project.showMap"/>
                    </div>

                    <div class="form-group">
                        <label for="mapLatitude">Center Latitude:</label>

                        <input type="number" step="any" min="-90" max="90" class="form-control" id="mapLatitude" name="mapLatitude" data-ng-model="project.map.centre.latitude" data-ng-disabled="!project.showMap"/>
                    </div>

                    <div class="form-group">
                        <label for="mapLongitude">Center Longitude:</label>

                        <input type="number" step="any" min="-180" max="180" class="form-control" id="mapLongitude" name="mapLongitude" data-ng-model="project.map.centre.longitude" data-ng-disabled="!project.showMap"/>
                    </div>
                </div>
            </div>
        </div>

        <div class="form-group">
            <div class="col-sm-offset-3 col-sm-9">
                <button role="button" type="button" class="btn btn-default" data-ng-click="cancel()">Cancel</button>
                <button role="button" type="button" class="btn btn-default" data-ng-click="back()"><i class="glyphicon glyphicon-chevron-left"></i>&nbsp;Back</button>
                <button role="button" type="button"  class="btn btn-primary" data-ng-click="continue()">Next&nbsp;<i
                        class="glyphicon glyphicon-chevron-right glyphicon-white"></i></button>
            </div>
        </div>

    </form>
    </script>
    
    <script type="text/ng-template" id="extras.html">
    <form class="form-horizontal" name="form">

        <div class="form-group">
            <label class="col-sm-3 control-label" for="picklistId"><g:message code="project.picklistInstitutionCode.label"
                                                                     default="Picklist Collection Code"/></label>

            <div class="col-sm-6">
                <g:select class="form-control" name="picklistId" from="${picklists}" data-ng-model="project.picklistId"/>
            </div>

            <div class="col-sm-3">
                <cl:ngHelpText>Select the picklist to use for this expedition.  A picklist with a specific 'Collection Code' must be loaded first</cl:ngHelpText>
            </div>
        </div>

        <div class="form-group">
            <div class="col-sm-12">
                <div class="row">
                    <label class="col-sm-3 control-label" for="label">Tags</label>
                    <div class="col-sm-9">
                        <div id="labels">
                            <dv-label data-ng-repeat="label in labels" label="label" on-remove="removeLabel(label)"></dv-label>
                        </div>
                    </div>

                </div>
            </div>

            <div class="col-sm-offset-3 col-sm-6">
                <input type="text" class="form-control" autocomplete="off" id="label" dv-typeahead ta-options="options" ta-datasets="data" ta-select="selectLabel(type, suggestion)" ta-autocomplete="selectLabel(type, suggestion)" data-ng-model="labelAutocomplete" />
            </div>

            <div class="col-sm-3">
                <cl:ngHelpText>Select all appropriate tags for the expedition.</cl:ngHelpText>
            </div>
        </div>

        <div class="form-group">
            <div class="col-sm-offset-3 col-sm-6">
                <button role="button" type="button" class="btn btn-default" data-ng-click="cancel()">Cancel</button>
                <button role="button" type="button" class="btn btn-default" data-ng-click="back()"><i class="glyphicon glyphicon-chevron-left"></i>&nbsp;Back</button>
                <button role="button" type="button"  class="btn btn-primary" data-ng-click="continue()">Next&nbsp;<i
                        class="glyphicon glyphicon-chevron-right glyphicon-white"></i></button>
            </div>
        </div>

    </form>
        
    </script>
    
    <script type="text/ng-template" id="summary.html">
    <div class="">

        <p>
            Your expedition is almost ready! Please review the following, and if everything is correct, click on the 'Create Expedition' button.
        </p>

        <p>
            If you find a mistake, or you wish to change something you can click the 'Back' button until you find the item you wish to change.
        </p>

        <table class="table table-bordered table-striped">
            <tr>
                <td class="prop-name">Expedition institution</td>
                <td class="prop-value">{{::project.featuredOwner.name}}<a ng-if="project.featuredOwner.id" ng-href="${createLink(controller: 'institution', action: 'index')}/{{::project.featuredOwner.id}}" target="_blank"><i class="fa fa-checkmark"></i></a></td>
            </tr>
            <tr>
                <td class="prop-name">Expedition name</td>
                <td class="prop-value">{{::project.name}}</td>
            </tr>
            <tr>
                <td class="prop-name">Short description</td>
                <td class="prop-value">{{::project.shortDescription}}</td>
            </tr>
            <tr>
                <td class="prop-name">Long description</td>
                <td class="prop-value">{{::project.longDescription}}</td>
            </tr>
            <tr>
                <td class="prop-name">Template</td>
                <td class="prop-value">{{::projectTemplate.name}}</td>
            </tr>
            <tr>
                <td class="prop-name">Expedition type</td>
                <td class="prop-value">

                    <span style="vertical-align: middle">
                        {{::projectType.label}}
                    </span>
                    <img data-ng-if="::projectTypeImageUrl()" style="margin-left: 10px; vertical-align: middle" data-ng-src="::projectTypeImageUrl()"/>
                </td>
            </tr>

            <tr>
                <td class="prop-name">Expedition image</td>
                <td class="prop-value">

                    <img class="img-thumbnail img-responsive" data-ng-if="::project.imageUrl" data-ng-src="{{::project.imageUrl}}"/>

                    <em data-ng-hide="project.imageUrl">No image uploaded</em>

                </td>
            </tr>
            <tr>
                <td class="prop-name">Image copyright text</td>
                <td class="prop-value">{{::project.imageCopyright}}</td>
            </tr>

            <tr>
                <td class="prop-name">Background image</td>
                <td class="prop-value">

                    <img class="img-thumbnail img-responsive" data-ng-if="::project.backgroundImageUrl" data-ng-src="{{::project.backgroundImageUrl}}"/>

                    <em data-ng-hide="project.backgroundImageUrl">No image uploaded</em>

                </td>
            </tr>
            <tr>
                <td class="prop-name">Background image copyright text</td>
                <td class="prop-value">{{::project.backgroundImageCopyright}}</td>
            </tr>

            <tr>
                <td class="prop-name">Show map on expedition page</td>
                <td class="prop-value">{{::project.showMap ? "Yes" : "No"}}</td>
            </tr>

            <tr data-ng-if="project.showMap">
                <td class="prop-name">
                    Map position
                </td>
                <td class="prop-value">
                    <ui-gmap-google-map center='project.map.centre' zoom='project.map.zoom' options="mapOptions"></ui-gmap-google-map>

                    <div>
                        Zoom: {{::project.map.zoom}} Longitude: {{::project.map.centre.longitude}} Latitude: {{::project.map.centre.latitude}}
                    </div>
                </td>
            </tr>

            <tr>
                <td class="prop-name">
                    <g:message code="project.picklistInstitutionCode.label" default="Picklist Collection Code"/>
                </td>
                <td class="prop-value">
                    {{::project.picklistId}}
                </td>
            </tr>
            <tr>
                <td class="prop-name">Tags</td>
                <td class="prop-value">
                    <div id="labels">
                        <dv-label data-ng-repeat="label in labels" label="label"></dv-label>
                    </div>
                </td>
            </tr>

        </table>

        <div class="form-horizontal">
            <div class="form-group" style="margin-top: 10px">
                <div class="col-sm-offset-3 col-sm-9">
                    <button role="button" type="button" class="btn btn-default" data-ng-click="cancel()" data-ng-disabled="loading">Cancel</button>
                    <button role="button" type="button" class="btn btn-default" data-ng-click="back()" data-ng-disabled="loading"><i class="glyphicon glyphicon-chevron-left"></i>&nbsp;Back</button>
                    <button role="button" type="button" class="btn btn-primary" data-ng-click="create()" data-ng-disabled="loading"><span ng-hide="loading">Create Expedition</span><span ng-show="loading"><i class="fa fa-2x fa-spin fa-cog"></i></span></button>
                </div>
            </div>
        </div>

    </div>
    </script>
    <script type="text/ng-template" id="failed.html">
    <div class="form-horizontal">
        <h3>Boo! Something went wrong</h3>

        <div class="form-group" style="margin-top: 10px">
            <div class="col-sm-offset-3 col-sm-9">
                <a class="btn btn-default" href="${createLink(controller: 'admin', action:"index")}">Done</a>
                <a class="btn btn-default" href="${createLink(controller: 'project', action:'wizard')}">Create another project</a>
            </div>
        </div>
    </div>
    </script>
    <script type="text/ng-template" id="success.html">
        <h3>Your expedition has been created!</h3>

        <p>
            <strong>Note:</strong> Your expedition is currently inactive, and transcribers will not be able to see it in the expeditions list until you mark it as active,
        which you should only do once your tasks are loaded.
        </p>

        <p>
            You can now go to the task staging area and upload the images for each of your tasks <a ng-href="${createLink(controller: 'task', action: 'staging')}?projectId={{::projectId}}">here</a>
        </p>

        <p>
            OR
        </p>

        <p>
            You can edit it's settings <a ng-href="${createLink(controller: 'project', action: 'edit')}/{{::projectId}}">here</a>.
        </p>

        <a class="btn btn-default" href="${createLink(controller: 'admin', action:"index")}">Done</a>
        <a class="btn btn-default" href="${createLink(controller: 'project', action:'wizard')}">Create another project</a>
    </script>
    <script type="text/ng-template" id="label.html">
    <span class="label" data-ng-class="colour()" title="{{label.category}}">{{label.value}} <i
            data-ng-if="hasRemove" class="glyphicon glyphicon-remove glyphicon-white remove" data-ng-click="remove({label: label})" data-label-id="{{label.id}}"></i></span>
    </script>
<r:script>
  createProjectModule({
     stagingId: '${stagingId.encodeAsJavaScript()}',
     cancelUrl: '${createLink(controller: 'project', action: 'wizardCancel', id: id)}',
     autosaveUrl: '${createLink(controller: 'project', action: 'wizardAutosave', id: stagingId)}',
     imageUploadUrl: '${createLink(controller: 'project', action: 'wizardImageUpload', id: stagingId)}',
     imageClearUrl: '${createLink(controller: 'project', action: 'wizardClearImage', id: stagingId)}',
     projectNameValidatorUrl: '${createLink(controller: 'project', action: 'wizardProjectNameValidator')}',
     createUrl: '${createLink(controller:'project', action: 'wizardCreate', id: stagingId)}',
     autosave: '${autosave.encodeAsJavaScript()}',
     labels: <cl:json value="${labels}" />,
     labelColourMap: <cl:json value="${labelColourMap}" />,
     institutions: <cl:json value="${institutions}" />,
     picklists: <cl:json value="${picklists}" />,
     templates: <cl:json value="${templates}" />,
     projectTypes: <cl:json value="${projectTypes}" />,
     projectImageUrl: '${projectImageUrl.encodeAsJavaScript()}'
  });
</r:script>
</div>
</body>
</html>
