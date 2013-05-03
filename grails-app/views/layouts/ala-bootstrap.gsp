<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="app.version" content="${g.meta(name:'app.version')}"/>
        <meta name="app.build" content="${g.meta(name:'app.build')}"/>
        <meta name="description" content="Atlas of Living Australia"/>
        <meta name="author" content="Atlas of Living Australia">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <title><g:layoutTitle /></title>

        <link rel="icon" type="image/x-icon" href="http://www.ala.org.au/wp-content/themes/ala2011/images/favicon.ico">
        <link rel="shortcut icon" type="image/x-icon" href="http://www.ala.org.au/wp-content/themes/ala2011/images/favicon.ico">

        <link rel="stylesheet" type="text/css" href="${resource(dir: 'css', file: 'bootstrap.css', plugin:'ala-web-theme')}">
        <link rel="stylesheet" type="text/css" media="screen" href="${resource(dir: 'css', file: 'bootstrap-responsive.css', plugin:'ala-web-theme')}">
        <link rel="stylesheet" type="text/css" media="screen" href="${grailsApplication.config.ala.baseURL?:'http://www.ala.org.au'}/wp-content/themes/ala2011/css/jquery.autocomplete.css" />
        <link rel="stylesheet" type="text/css" media="screen" href="${resource(dir: 'css', file: 'bvp-bootstrap.css')}">

        <script type="text/javascript" src="${grailsApplication.config.ala.baseURL?:'http://www.ala.org.au'}/wp-content/themes/ala2011/scripts/html5.js"></script>

        <script type="text/javascript" src="${resource(dir:'js/jquery-ui-1.9.1.custom/js', file:'jquery-1.8.2.js')}"></script>
        <script type="text/javascript" src="${resource(dir:'js/jquery-ui-1.9.1.custom/js', file:'jquery-ui-1.9.1.custom.min.js')}"></script>
        <link rel="stylesheet" type="text/css" media="screen" href="${resource(dir: 'js/jquery-ui-1.9.1.custom/css/smoothness', file: 'jquery-ui-1.9.1.custom.min.css')}"/>

        <script src="${resource(dir: 'js', file: 'bootstrap.js', plugin:'ala-web-theme')}"></script>

        <g:layoutHead />
        <r:layoutResources/>
        <script language="JavaScript" type="text/javascript" src="${grailsApplication.config.ala.baseURL?:'http://www.ala.org.au'}/wp-content/themes/ala2011/scripts/jquery.autocomplete.js"></script>
        <script language="JavaScript" type="text/javascript" src="${grailsApplication.config.ala.baseURL?:'http://www.ala.org.au'}/wp-content/themes/ala2011/scripts/uservoice.js"></script>

        <!-- HTML5 shim, for IE6-8 support of HTML5 elements -->
        <!--[if lt IE 9]>
    <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->

        <script type="text/javascript">
            // initialise plugins
            jQuery(function(){
                // autocomplete on navbar search input
                jQuery("form#search-form-2011 input#search-2011, form#search-inpage input#search").autocomplete('http://bie.ala.org.au/search/auto.jsonp', {
                    extraParams: {limit: 100},
                    dataType: 'jsonp',
                    parse: function(data) {
                        var rows = new Array();
                        data = data.autoCompleteList;
                        for(var i=0; i<data.length; i++){
                            rows[i] = {
                                data:data[i],
                                value: data[i].matchedNames[0],
                                result: data[i].matchedNames[0]
                            };
                        }
                        return rows;
                    },
                    matchSubset: false,
                    formatItem: function(row, i, n) {
                        return row.matchedNames[0];
                    },
                    cacheLength: 10,
                    minChars: 3,
                    scroll: false,
                    max: 10,
                    selectFirst: false
                });
            });
        </script>
    </head>
    <body class="${pageProperty(name:'body.class')}" id="${pageProperty(name:'body.id')}" onload="${pageProperty(name:'body.onload')}">

        <hf:banner logoutUrl="${grailsApplication.config.grails.serverURL}/logout/logout"/>

        <cl:navbar selected="${pageProperty(name:'page.selectedNavItem')}" />

        %{--<hf:menu/>--}%

        <header id="page-header">
            <div class="container">
                <cl:messages />
                <hgroup>
                    <g:pageProperty name="page.page-header" />
                </hgroup>
            </div>
        </header>

        <div class="container" id="main-content">
            <g:layoutBody />
        </div><!--/.container-->

    <hf:footer/>
    <!-- JS resources-->
    <r:layoutResources/>

        <script type="text/javascript">
            var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
            document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
        </script>
        <script type="text/javascript">
            var pageTracker = _gat._getTracker("UA-4355440-1");
            pageTracker._initData();
            pageTracker._trackPageview();
        </script>
        <script type="text/javascript">
            // show warning if using IE6
            if ($.browser.msie && $.browser.version.slice(0,1) == '6') {
                $('#header').prepend($('<div style="text-align:center;color:red;">WARNING: This page is not compatible with IE6.' +
                        ' Many functions will still work but layout and image transparency will be disrupted.</div>'));
            }
        </script>
    </body>
</html>