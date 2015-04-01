<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <cl:addApplicationMetaTags/>
        <meta name="description" content="Atlas of Living Australia"/>
        <meta name="author" content="Atlas of Living Australia">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <title><g:layoutTitle /></title>

        <link rel="icon" type="image/x-icon" href="http://www.ala.org.au/wp-content/themes/ala2011/images/favicon.ico">
        <link rel="shortcut icon" type="image/x-icon" href="http://www.ala.org.au/wp-content/themes/ala2011/images/favicon.ico">

        <link rel="stylesheet" type="text/css" href="${resource(dir: 'css', file: 'bootstrap.css', plugin:'ala-web-theme')}">
        <link rel="stylesheet" type="text/css" media="screen" href="${resource(dir: 'css', file: 'bootstrap-responsive.css', plugin:'ala-web-theme')}">
        <link rel="stylesheet" type="text/css" media="screen" href="${resource(dir: 'css', file: 'bvp-bootstrap.css')}">

        <script type="text/javascript" src="${grailsApplication.config.ala.baseURL?:'http://www.ala.org.au'}/wp-content/themes/ala2011/scripts/html5.js"></script>

        <g:set var="cheevs" value="${cl.newAchievements()}" />

        <g:javascript library="jquery" />

        <r:require module="jquery-ui" />
        <r:require module="qtip" />
        <r:require module="bvp-js" />

        <link href="http://www.ala.org.au/wp-content/themes/ala2011/css/jquery.autocomplete.css" type="text/css" rel="stylesheet" media="screen, projection" />

        <r:require module="bootstrap-js" />

        <g:layoutHead />
        <r:layoutResources/>

        <!-- HTML5 shim, for IE6-8 support of HTML5 elements -->
        <!--[if lt IE 9]>
        <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
        <![endif]-->

        <r:script>

            var BVP_JS_URLS = {
                selectProjectFragment: "${createLink(controller:'project', action:'findProjectFragment')}",
                webappRoot: "${resource(dir:'/')}",
                picklistAutocompleteUrl: "${createLink(action:'autocomplete', controller:'picklistItem')}"
            };

            // initialise plugins
            $(document).ready(function() {

                // show warning if using IE6
                if ($.browser.msie && $.browser.version.slice(0,1) == '6') {
                    $('#header').prepend($('<div style="text-align:center;color:red;">WARNING: This page is not compatible with IE6.' +
                            ' Many functions will still work but layout and image transparency will be disrupted.</div>'));
                }

                $("form#search-form-2011 input#search-2011, form#search-inpage input#search").autocomplete({
                    disabled: false,
                    minLength: 3,
                    delay: 200,
                    select: function(event, ui) { },
                    source: function(request, response) {
                        $.ajax('http://bie.ala.org.au/search/auto.jsonp?limit=100&q=' + request.term, {dataType:'jsonp'}).done(function(data) {
                            var rows = new Array();
                            if (data.autoCompleteList) {
                                var list = data.autoCompleteList;
                                for (var i = 0; i < list.length; i++) {
                                    rows[i] = {
                                        value: list[i].matchedNames[0],
                                        label: list[i].matchedNames[0],
                                        data: list[i]
                                    };
                                }
                            }

                            if (response) {
                                response(rows);
                            }
                        });
                    }
                });

                $("th.sortable > a").addClass("btn");
                $("th.sorted > a").addClass("active");

            });

        </r:script>
    </head>
    <body class="${pageProperty(name:'body.class')}" id="${pageProperty(name:'body.id')}" onload="${pageProperty(name:'body.onload')}">

        <hf:banner logoutUrl="${grailsApplication.config.grails.serverURL}/logout/logout"/>

        <cl:navbar selected="${pageProperty(name:'page.selectedNavItem')}" />

        %{--<hf:menu/>--}%

        <g:set var="containerClass" value="container"/>
        <g:if test="${pageProperty(name:'page.useFluidLayout')}">
            <g:set var="containerClass" value="container-fluid"/>
        </g:if>

        <header id="page-header">
            <div class="container">
                <cl:messages />
                <hgroup>
                    <g:pageProperty name="page.page-header" />
                </hgroup>
            </div>
        </header>

        <div class="${containerClass}" id="main-content">
            <g:layoutBody />
        </div><!--/.container-->

    <hf:footer/>

    <g:if test="${cl.achievementsEnabled() && cheevs.size() > 0}">
        <g:if test="${cheevs.size() < 3}">
            <g:set var="itemgridStyle" value="margin-left:auto; margin-right:auto; width: ${cheevs.size() * 160}px" />
        </g:if>
        <g:else>
            <g:set var="itemgridStyle" value="" />
        </g:else>
        <div id="achievement-notifier" class="modal hide fade">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" data-target="#achievement-notifier" aria-hidden="true">&times;</button>
                <h3>Congratulations!  You just achieved...</h3>
            </div>
            <div class="modal-body">
                <div class="itemgrid" style="${itemgridStyle}">
                    <g:each in="${cheevs}" var="ach">
                        <div class="item bvpBadge">
                            <img src="${cl.achievementBadgeUrl(achievement: ach.achievement)}" title="${ach.achievement.description}" alt="${ach.achievement.name}"/>
                            <div>${ach.achievement.name}</div>
                            <div>Awarded <prettytime:display date="${ach.awarded}" /></div>
                        </div>
                    </g:each>
                </div>
                <p>Visit <g:link controller="user" action="notebook">your notebook</g:link> to see all your achievements.</p>
            </div>
            <div class="modal-footer">
                <button data-dismiss="modal" data-target="#achievement-notifier" class="btn">Close</button>
            </div>
        </div>
<r:script>
jQuery(function($) {
    var cheevs = <cl:json value="${cheevs*.id}" />;
    var acceptUrl = "${g.createLink(controller: 'ajax', action: 'acceptAchievements')}";
    $('#achievement-notifier').on('show', function () {
        $.ajax(acceptUrl, {
            type: 'post',
            data: { ids : cheevs },
            dataType: 'json'
        });
    }).modal('show');
});
</r:script>
    </g:if>

    <script type="text/javascript">
        var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
        document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
    </script>

    <script type="text/javascript">
        var pageTracker = _gat._getTracker("UA-4355440-1");
        pageTracker._initData();
        pageTracker._trackPageview();
    </script>

    <!-- JS resources-->
    <r:layoutResources/>

    </body>
</html>