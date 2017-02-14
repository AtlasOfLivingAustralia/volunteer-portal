<!--
/*
 * Copyright (C) 2017 Atlas of Living Australia
 * All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 * 
 * Created by Temi on 19/1/17.
 */
-->
<%@ page import="grails.util.Environment" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>{{title}}</title>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <content tag="disableBreadcrumbs">true</content>
    <content tag="angularApp">forumApp</content>
    <asset:stylesheet src="forum-assets.css"></asset:stylesheet>
    <asset:javascript src="angular-assets.js"></asset:javascript>
    <asset:javascript src="forum-assets.js"></asset:javascript>
    <asset:javascript src="image-viewer.js" asset-defer="" />
    <asset:script type="text/javascript">
        angular.module('forumConfig', []).constant('config', {
            contextPath: '${request.contextPath}',
            development: ${Environment.current == Environment.DEVELOPMENT},
            breadcrumbs: [],
            title: 'DigiVol | Forum',
            urlPrefix: '#!'
        });
    </asset:script>
    %{-- ensures forum nav is selected when app is running --}%
    ${sitemesh.parameter(name: 'selectedNavItem', value: 'forum')}
</head>
<body>
<breadcrumbs></breadcrumbs>
<div ng-view>

</div>
</body>
</html>
