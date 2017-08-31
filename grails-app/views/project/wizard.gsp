<%@ page import="org.springframework.context.i18n.LocaleContextHolder" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><cl:pageTitle title="${message(code: 'project.wizard.title')}"/></title>

    <asset:stylesheet src="digivol-new-project-wizard" />
</head>

<body class="admin" data-ng-app="projectWizard">
<div class="container" >
    <cl:headerContent title="${message(code: 'project.wizard.title')}" selectedNavItem="bvpadmin">
        <h2 class="ng-cloak">{{$state.current.data.title}}</h2>
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin', action: 'index'), label: message(code: 'project.wizard.administration')]
            ]
        %>
    </cl:headerContent>
    <div class="panel panel-default">
        <div class="panel-body ng-cloak">
            <ui-view autoscroll="false"></ui-view>
        </div>
    </div>
    <script type="text/ng-template" id="start.html">
        <h3><g:message code="project.wizard.welcome" /></h3>
        <div>
            <g:message code="project.wizard.welcome.before_you_start" />
            <ul>
                <li><g:message code="project.wizard.welcome.requirement1" /></li>
                <li><g:message code="project.wizard.welcome.requirement2" /></li>
                <li><g:message code="project.wizard.welcome.requirement3" /></li>
                <li><g:message code="project.wizard.welcome.requirement4" /></li>
                <li><g:message code="project.wizard.welcome.requirement5" /></li>
                <li><g:message code="project.wizard.welcome.requirement6" /></li>
                <li><g:message code="project.wizard.welcome.requirement7" /></li>
            </ul>
        </div>

        <button role="button" type="button" class="btn btn-default" data-ng-click="cancel()"><g:message code="default.cancel"/></button>
        <button role="button" type="button" class="btn btn-primary" data-ng-click="continue()"><g:message code="project.wizard.start" />&nbsp;<i class="glyphicon glyphicon-chevron-right glyphicon-white"></i></button>
    </script>

    <script type="text/ng-template" id="institution-details.html">
        <form class="form-horizontal" name="form">
            <div class="form-group">
                <label class="col-sm-3 control-label" for="featuredOwner"><g:message code="project.expedition_institution" /></label>

                <div class="col-sm-6">
                    <input type="text" class="form-control" id="featuredOwner" name="featuredOwner" ng-model="project.featuredOwner.name" dv-typeahead ta-options="options" ta-datasets="data" ta-change="institutionSelect(type, suggestion)" ta-select="institutionSelect(type, suggestion)" ta-autocomplete="institutionSelect(type, suggestion)" />
                </div>

                <div class="col-sm-3">
                    <cl:ngHelpText><g:message code="project.wizard.expedition_institution.help" /></cl:ngHelpText>
                    <input type="hidden" name="featuredOwnerId" data-ng-model="project.featuredOwner.id"/>
                    <span id="institution-link-icon" class="ng-cloak muted" data-ng-show="project.featuredOwner.id"><small><i class="icon-ok"></i> <g:message code="project.wizard.expedition_institution.linked_to" /> <a
                            id="institution-link" ng-href="${createLink(controller: 'institution', action: 'index')}/{{project.featuredOwner.id}}" target="_blank"><g:message code="project.wizard.expedition_institution.institution" />!</a></small></span>
                </div>
            </div>

            <div class="form-group">
                <div class="col-sm-offset-3 col-sm-9">
                    <button role="button" type="button" class="btn btn-default" data-ng-click="cancel()"><g:message code="default.cancel" /></button>
                    <button role="button" type="button" class="btn btn-default" data-ng-click="back()"><i class="glyphicon glyphicon-chevron-left"></i>&nbsp;<g:message code="default.back" /></button>
                    <button role="button" type="button" class="btn btn-primary" data-ng-click="continue()" ><g:message code="default.next" />&nbsp;<i
                            class="glyphicon glyphicon-chevron-right glyphicon-white"></i></button>
                </div>
            </div>

        </form>
    </script>
    
    <script type="text/ng-template" id="project-details.html">
        <form class="form-horizontal" name="form">
        
            <div class="form-group required" show-errors>
                <label class="col-sm-3 control-label" for="projectName"><g:message code="project.wizard.expedition_name" /></label>
        
                <div class="col-sm-6">
                    <input type="text" class="form-control" name="projectName" id="projectName" data-ng-model="project.name" data-ng-model-options="{ debounce: 500 }" data-ng-required="true" dv-projectname />
                </div>

                <div class="col-sm-3">
                    <cl:ngHelpText><g:message code="project.wizard.expedition_name.help" /></cl:ngHelpText>
                    <span ng-show="form.projectName.$pending.projectname"><g:message code="project.wizard.expedition_name.checking" /></span>
                    <span style="color: red; font-weight: bold" ng-show="form.projectName.$error.projectname"><g:message code="project.wizard.expedition_name.taken" /></span>
                </div>
            </div>
        
            <div class="form-group required" show-errors>
                <label class="col-sm-3 control-label" for="shortDescription"><g:message code="project.shortDescription.label" /></label>
        
                <div class="col-sm-6">
                    <input type="text" class="form-control" name="shortDescription" id="shortDescription" data-ng-model="project.shortDescription" data-ng-required="true"  />
                </div>

                <div class="col-sm-3">
                    <cl:ngHelpText><g:message code="project.wizard.shortDescription.help" /></cl:ngHelpText>
                </div>
            </div>
        
            <div class="form-group required" show-errors>
                <label class="col-sm-3 control-label" id="long-description-label"><g:message code="project.general_settings.long_description" /></label>
        
                <div class="col-sm-6">
                    <textarea ui-tinymce="wizardTinyMceOptions" aria-labelledby="long-description-label" aria-label="Long description" rows="8" class="form-control" name="longDescription"
                                data-ng-model="project.longDescription" required="required" data-ng-required="true"></textarea>
                </div>

                <div class="col-sm-3">
                    <cl:ngHelpText><g:message code="project.wizard.longDescription.help" /></cl:ngHelpText>
                </div>
            </div>
        
            <div class="form-group required" show-errors>
                <label class="col-sm-3 control-label" for="templateId"><g:message code="project.template.label" /></label>
        
                <div class="col-sm-6">
                    <g:select class="form-control" name="templateId" from="${templates}" optionKey="id" data-ng-model="project.templateId" data-dv-convert-to-number="" data-ng-required="true" />
                </div>

                <div class="col-sm-3">
                    <cl:ngHelpText><g:message code="project.wizard.template.help" /></cl:ngHelpText>
                </div>
            </div>
        
            <div class="form-group required" show-errors>
                <label class="col-sm-3 control-label" for="projectTypeId"><g:message code="project.projectType.label" /></label>
        
                <div class="col-sm-6">
                    <g:select class="form-control" name="projectTypeId" from="${projectTypes}" optionKey="id" optionValue="name"
                              data-ng-model="project.projectTypeId" data-dv-convert-to-number="" data-ng-required="true"  />
                </div>

                <div class="col-sm-3">

                </div>
            </div>
        
            <div class="form-group">
                <div class="col-sm-offset-3 col-sm-6">
                    <button role="button" type="button" class="btn btn-default" data-ng-click="cancel()"><g:message code="default.cancel" /></button>
                    <button role="button" type="button" class="btn btn-default" data-ng-click="back()"><i class="glyphicon glyphicon-chevron-left"></i>&nbsp;<g:message code="default.back" /></button>
                    <button role="button" type="button"  class="btn btn-primary" data-ng-disabled="form.$invalid" data-ng-click="continue()"><g:message code="default.next" />&nbsp;<i
                            class="glyphicon glyphicon-chevron-right glyphicon-white"></i></button>
                </div>
            </div>
        
        </form>
    </script>
    
    <script type="text/ng-template" id="image.html">
    <form class="form-horizontal" name="form">

        <div class="form-group">
            <div class="col-sm-offset-3 col-sm-6">
                <g:message code="project.wizard.the_expedition_image_appears_on_the_front_page"/>
            </div>
        </div>

        <div class="form-group">
            <label class="col-sm-3 control-label" for="featuredImage"><g:message code="project.wizard.expedition_image"/></label>

            <div class="col-sm-6">
                <input type="file" name="featuredImage" id="featuredImage" ngf-select="upload($file, 'imageUrl')"/>
            </div>

            <div class="col-sm-3">
                <cl:ngHelpText><g:message code="project.wizard.expedition_image.help"/></cl:ngHelpText>
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
                        class="icon-trash icon-white"></i>&nbsp;<g:message code="project.wizard.expedition_image.remove_image"/></button>
            </div>
        </div>

        <div class="form-group">
            <label class="col-sm-3 control-label" for="imageCopyright"><g:message code="project.wizard.expedition_image.copyright"/></label>

            <div class="col-sm-6">
                <input type="text" id="imageCopyright" name="imageCopyright" class="form-control" data-ng-model="project.imageCopyright"/>
            </div>
        </div>

        <div class="form-group">
            <label class="col-sm-3 control-label" for="backgroundImage"><g:message code="project.wizard.background_image.title"/></label>

            <div class="col-sm-6">
                <input type="file" name="backgroundImage" id="backgroundImage" ngf-select="upload($file, 'backgroundImageUrl')"/>
            </div>

            <div class="col-sm-3">
                <cl:ngHelpText><g:message code="project.wizard.background_image.help"/></cl:ngHelpText>
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
                        class="icon-trash icon-white"></i>&nbsp;<g:message code="project.wizard.background_image.remove_image"/></button>
            </div>
        </div>

        <div class="form-group">
            <label class="col-sm-3 control-label" for="backgroundImageCopyright"><g:message code="project.wizard.background_image.copyright"/></label>

            <div class="col-sm-6">
                <input type="text" id="backgroundImageCopyright" name="backgroundImageCopyright" class="form-control" data-ng-model="project.backgroundImageCopyright"/>
            </div>
        </div>

        <div class="form-group">
            <div class="col-sm-offset-3 col-sm-6">
                <button role="button" type="button" class="btn btn-default" data-ng-click="cancel()" data-ng-disabled="progress > 0"><g:message code="default.cancel"/></button>
                <button role="button" type="button" class="btn btn-default" data-ng-click="back()" data-ng-disabled="progress > 0"><i class="glyphicon glyphicon-chevron-left"></i>&nbsp;<g:message code="default.back"/></button>
                <button role="button" type="button"  class="btn btn-primary" data-ng-click="continue()" data-ng-disabled="progress > 0"><g:message code="default.next"/>&nbsp;<i
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
                        <input type="checkbox" name="showMap" data-ng-model="project.showMap"/>&nbsp;<g:message code="project.wizard.map.show_the_map"/>
                    </label>
                </div>
            </div>
        </div>

        <div class="col-sm-offset-3 col-sm-9">
            <div class="alert alert-warning">
                <g:message code="project.wizard.map.position_the_map_how_you_would_like_it"/>
            </div>
        </div>


        <div id="mapPositionControls" class="form-group col-sm-12" data-ng-style="mapStyle()">

            <div class="row">
                <div class="col-sm-9 map-container">
                    <ui-gmap-google-map center='project.map.centre' zoom='project.map.zoom'></ui-gmap-google-map>
                </div>
                <div class="col-sm-3">
                    <div class="form-group">
                        <label for="mapZoomLevel"><g:message code="project.wizard.zoom"/></label>

                        <input type="number" class="form-control" id="mapZoomLevel" name="mapZoomLevel" data-ng-model="project.map.zoom" data-ng-disabled="!project.showMap"/>
                    </div>

                    <div class="form-group">
                        <label for="mapLatitude"><g:message code="project.wizard.map.center_latitude"/>:</label>

                        <input type="number" step="any" min="-90" max="90" class="form-control" id="mapLatitude" name="mapLatitude" data-ng-model="project.map.centre.latitude" data-ng-disabled="!project.showMap"/>
                    </div>

                    <div class="form-group">
                        <label for="mapLongitude"><g:message code="project.wizard.map.center_longitude"/>:</label>

                        <input type="number" step="any" min="-180" max="180" class="form-control" id="mapLongitude" name="mapLongitude" data-ng-model="project.map.centre.longitude" data-ng-disabled="!project.showMap"/>
                    </div>
                </div>
            </div>
        </div>

        <div class="form-group">
            <div class="col-sm-offset-3 col-sm-9">
                <button role="button" type="button" class="btn btn-default" data-ng-click="cancel()"><g:message code="default.cancel"/></button>
                <button role="button" type="button" class="btn btn-default" data-ng-click="back()"><i class="glyphicon glyphicon-chevron-left"></i>&nbsp;<g:message code="default.back"/></button>
                <button role="button" type="button"  class="btn btn-primary" data-ng-click="continue()"><g:message code="default.next"/>&nbsp;<i
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
                <cl:ngHelpText><g:message code="project.wizard.picklist.help"/></cl:ngHelpText>
            </div>
        </div>

        <div class="form-group">
            <div class="col-sm-12">
                <div class="row">
                    <label class="col-sm-3 control-label" for="label"><g:message code="project.wizard.tags"/></label>
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
                <cl:ngHelpText><g:message code="project.wizard.tags.help"/></cl:ngHelpText>
            </div>
        </div>

        <div class="form-group">
        <label class="col-sm-3 control-label" id="tutorial-links-label"><g:message code="project.wizard.tutorial_links"/></label>
        <div class="col-sm-9">
            <textarea ui-tinymce="wizardTinyMceOptions" aria-labelledby="tutorial-links-label" aria-label="Tutorial Links" ng-model="project.tutorialLinks"></textarea>
        </div>
    </div>

        <div class="form-group">
            <div class="col-sm-offset-3 col-sm-6">
                <button role="button" type="button" class="btn btn-default" data-ng-click="cancel()"><g:message code="default.cancel"/></button>
                <button role="button" type="button" class="btn btn-default" data-ng-click="back()"><i class="glyphicon glyphicon-chevron-left"></i>&nbsp;<g:message code="default.back"/></button>
                <button role="button" type="button"  class="btn btn-primary" data-ng-click="continue()"><g:message code="default.next"/>&nbsp;<i
                        class="glyphicon glyphicon-chevron-right glyphicon-white"></i></button>
            </div>
        </div>

    </form>
        
    </script>
    
    <script type="text/ng-template" id="summary.html">
    <div class="">

        <p>
            <g:message code="project.wizard.final.your_expedition_is_almost_ready.1"/>
        </p>

        <p>
            <g:message code="project.wizard.final.your_expedition_is_almost_ready.2"/>
        </p>

        <table class="table table-bordered table-striped">
            <tr>
                <td class="prop-name"><g:message code="project.expedition_institution"/></td>
                <td class="prop-value">{{::project.featuredOwner.name}}<a ng-if="project.featuredOwner.id" ng-href="${createLink(controller: 'institution', action: 'index')}/{{::project.featuredOwner.id}}" target="_blank"><i class="fa fa-checkmark"></i></a></td>
            </tr>
            <tr>
                <td class="prop-name"><g:message code="project.general_settings.expedition_name"/></td>
                <td class="prop-value">{{::project.name}}</td>
            </tr>
            <tr>
                <td class="prop-name"><g:message code="project.general_settings.short_description"/></td>
                <td class="prop-value">{{::project.shortDescription}}</td>
            </tr>
            <tr>
                <td class="prop-name"><g:message code="project.general_settings.long_description"/></td>
                <td class="prop-value" ng-bind-html="project.longDescription"></td>
            </tr>
            <tr>
                <td class="prop-name"><g:message code="project.template.label"/></td>
                <td class="prop-value">{{::projectTemplate.name}}</td>
            </tr>
            <tr>
                <td class="prop-name"><g:message code="project.projectType.label"/></td>
                <td class="prop-value">

                    <span style="vertical-align: middle">
                        {{::projectType.label}}
                    </span>
                    <img data-ng-if="::projectTypeImageUrl()" style="margin-left: 10px; vertical-align: middle" data-ng-src="::projectTypeImageUrl()"/>
                </td>
            </tr>

            <tr>
                <td class="prop-name"><g:message code="project.expedition_image"/></td>
                <td class="prop-value">

                    <img class="img-thumbnail img-responsive" data-ng-if="::project.imageUrl" data-ng-src="{{::project.imageUrl}}"/>

                    <em data-ng-hide="project.imageUrl"><g:message code="project.wizard.no_image_uploaded"/></em>

                </td>
            </tr>
            <tr>
                <td class="prop-name"><g:message code="project.expedition_image.copyright.label"/></td>
                <td class="prop-value">{{::project.imageCopyright}}</td>
            </tr>

            <tr>
                <td class="prop-name"><g:message code="project.background_image"/></td>
                <td class="prop-value">

                    <img class="img-thumbnail img-responsive" data-ng-if="::project.backgroundImageUrl" data-ng-src="{{::project.backgroundImageUrl}}"/>

                    <em data-ng-hide="project.backgroundImageUrl"><g:message code="project.wizard.no_image_uploaded"/></em>

                </td>
            </tr>
            <tr>
                <td class="prop-name"><g:message code="project.wizard.backgound_image_copyright"/></td>
                <td class="prop-value">{{::project.backgroundImageCopyright}}</td>
            </tr>

            <tr>
                <td class="prop-name"><g:message code="project.wizard.show_map_on_expedition_page"/></td>
                <td class="prop-value">{{::project.showMap ? "${message(code: "default.yes")}" : "${message(code: "default.no")}"}}</td>
            </tr>

            <tr data-ng-if="project.showMap">
                <td class="prop-name">
                    <g:message code="project.wizard.map_position"/>
                </td>
                <td class="prop-value">
                    <ui-gmap-google-map center='project.map.centre' zoom='project.map.zoom' options="mapOptions"></ui-gmap-google-map>

                    <div>
                        <g:message code="default.zoom.label"/>Zoom: {{::project.map.zoom}} <g:message code="admin.mapping_tool.longitude"/>Longitude: {{::project.map.centre.longitude}} <g:message code="admin.mapping_tool.latitude"/>Latitude: {{::project.map.centre.latitude}}
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
                <td class="prop-name"><g:message code="project.general_settings.tags"/></td>
                <td class="prop-value">
                    <div id="labels">
                        <dv-label data-ng-repeat="label in labels" label="label"></dv-label>
                    </div>
                </td>
            </tr>
            <tr>
                <td class="prop-name"><g:message code="default.tutorials.label"/></td>
                <td class="prop-value" ng-bind-html="project.tutorialLinks"></td>
            </tr>

        </table>

        <div class="form-horizontal">
            <div class="form-group" style="margin-top: 10px">
                <div class="col-sm-offset-3 col-sm-9">
                    <button role="button" type="button" class="btn btn-default" data-ng-click="cancel()" data-ng-disabled="loading"><g:message code="default.cancel"/></button>
                    <button role="button" type="button" class="btn btn-default" data-ng-click="back()" data-ng-disabled="loading"><i class="glyphicon glyphicon-chevron-left"></i>&nbsp;<g:message code="default.back"/></button>
                    <button role="button" type="button" class="btn btn-primary" data-ng-click="create()" data-ng-disabled="loading"><span ng-hide="loading"><g:message code="project.wizard.create_expedition"/></span><span ng-show="loading"><i class="fa fa-2x fa-spin fa-cog"></i></span></button>
                </div>
            </div>
        </div>

    </div>
    </script>
    <script type="text/ng-template" id="failed.html">
    <div class="form-horizontal">
        <h3><g:message code="project.wizard.something_went_wrong"/></h3>

        <div class="form-group" style="margin-top: 10px">
            <div class="col-sm-offset-3 col-sm-9">
                <a class="btn btn-default" href="${createLink(controller: 'admin', action:"index")}"><g:message code="project.wizard.done"/></a>
                <a class="btn btn-default" href="${createLink(controller: 'project', action:'wizard')}"><g:message code="project.wizard.create_another_project"/></a>
            </div>
        </div>
    </div>
    </script>
    <script type="text/ng-template" id="success.html">
        <h3><g:message code="project.wizard.success.title"/></h3>

        <p><g:message code="project.wizard.success.2"/></p>

        <p><g:message code="project.wizard.success.3"/> <a ng-href="${createLink(controller: 'task', action: 'staging')}?projectId={{::projectId}}"><g:message code="project.wizard.success.here"/></a></p>

        <p><g:message code="project.wizard.success.or"/></p>

        <p><g:message code="project.wizard.success.4"/> <a ng-href="${createLink(controller: 'project', action: 'edit')}/{{::projectId}}"><g:message code="project.wizard.success.here"/></a>.</p>

        <a class="btn btn-default" href="${createLink(controller: 'admin', action:"index")}"><g:message code="project.wizard.done"/></a>
        <a class="btn btn-default" href="${createLink(controller: 'project', action:'wizard')}"><g:message code="project.wizard.create_another_project"/></a>
    </script>
    <script type="text/ng-template" id="label.html">
    <span class="label" data-ng-class="colour()" title="{{label.category}}">{{label.value}} <i
            data-ng-if="hasRemove" class="glyphicon glyphicon-remove glyphicon-white remove" data-ng-click="remove({label: label})" data-label-id="{{label.id}}"></i></span>
    </script>
<asset:javascript src="digivol-new-project-wizard" asset-defer="" />
<asset:script>
  createProjectModule({
     googleMapsApiKey: '${grailsApplication.config.google.maps.key}',
     defaultLatitude: ${grailsApplication.config.location.default.latitude},
     defaultLongitude: ${grailsApplication.config.location.default.longitude},
     language: '${LocaleContextHolder.getLocale().getLanguage()}',
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
</asset:script>
</div>
</body>
</html>
