<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="app.version" content="${g.meta(name:'app.version')}"/>
    <meta name="app.build" content="${g.meta(name:'app.build')}"/>
    <g:if test="${instance}">
        <meta name="description" content="The Atlas of Living Australia's description of the ${instance?.name}. ${instance?.makeAbstract(200)}"/>
    </g:if>
    <g:else>
        <meta name="description" content="Explore Australia's Biodiversity by region."/>
    </g:else>
    <title><g:layoutTitle /></title>
    <link rel="stylesheet" href="http://www.ala.org.au/wp-content/themes/ala2011/style.css" type="text/css" media="screen" />
    <link rel="stylesheet" href="http://www.ala.org.au/wp-content/themes/ala2011/css/bvp.css" type="text/css" media="screen" />
    %{--<link rel="stylesheet" href="http://www.ala.org.au/wp-content/themes/ala2011/style2010.css" type="text/css" media="screen" />--}%
    %{--<link rel="stylesheet" href="http://www.ala.org.au/wp-content/themes/ala2011/style2011.css" type="text/css" media="screen" />--}%
    <link rel="stylesheet" href="http://www.ala.org.au/wp-content/themes/ala2011/css/wp-styles.css" type="text/css" media="screen" />
    <link rel="stylesheet" href="http://www.ala.org.au/wp-content/themes/ala2011/css/buttons.css" type="text/css" media="screen" />
    <link rel="icon" type="image/x-icon" href="http://www.ala.org.au/wp-content/themes/ala2011/images/favicon.ico" />
    <link rel="shortcut icon" type="image/x-icon" href="http://www.ala.org.au/wp-content/themes/ala2011/images/favicon.ico" />
    <link rel="stylesheet" type="text/css" media="screen" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css" />
    <link rel="stylesheet" type="text/css" media="screen" href="http://www.ala.org.au/wp-content/themes/ala2011/css/jquery.autocomplete.css" />
    <link rel="stylesheet" type="text/css" media="screen" href="http://www.ala.org.au/wp-content/themes/ala2011/css/search.css" />
    <link rel="stylesheet" type="text/css" media="screen" href="http://www.ala.org.au/wp-content/themes/ala2011/css/skin.css" />
    <link rel="stylesheet" type="text/css" media="screen" href="http://www.ala.org.au/wp-content/themes/ala2011/css/sf-blue.css" />


    <link rel="stylesheet" href="${resource(dir:'css',file:'public.css')}"/>
    %{--<link rel="stylesheet" href="${resource(dir:'css/smoothness',file:'jquery-ui-1.8.14.custom.css')}" type="text/css" media="screen"/>--}%

    %{--<script language="JavaScript" type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>--}%
    <g:javascript library="application" />
    %{--<g:javascript library="jquery-1.7.min"/>--}%
    <g:javascript library="jquery" plugin="jquery"/>
    %{--<g:javascript library="jquery-ui-1.8.14.custom-notabs.min"/>--}%
    <tinyMce:resources />
    <script type="text/javascript">
        tinyMCE.init({
            mode: "textareas",
            theme: "advanced",
            editor_selector: "mceadvanced",
            theme_advanced_toolbar_location : "top",
            convert_urls : false
        });
    </script>

    <style type="text/css">
        /**************************
        to highlight the correct menu item - should be in style.css
        ***************************/
        .species .nav-species a,
        .regions .nav-locations a,
        .collections .nav-collections a,
        .getinvolved .nav-getinvolved a,
        .datasets .nav-datasets a {
            text-decoration: none;
            background: #3d464c; /* color 3 */
            outline: 0;
            z-index: 100;
        }

        #content img {
            -moz-border-radius: 0;
            -webkit-border-radius: 0;
            -o-border-radius: 0;
            -icab-border-radius: 0;
            -khtml-border-radius: 0;
            border-radius: 0;
        }

        .systemMessage {
            background: #fffacd url(${resource(dir:'images/skin', file: 'exclamation.png')}) 8px 50% no-repeat;
            border: 2px solid red;
            color: #000000;
            font-weight: bold;
            margin: 10px 0 5px 0;
            padding: 5px 5px 5px 30px
        }


    </style>

    <g:layoutHead />

    <script type="text/javascript" src="http://www.ala.org.au/wp-content/themes/ala2011/scripts/html5.js"></script>
    <script language="JavaScript" type="text/javascript" src="http://www.ala.org.au/wp-content/themes/ala2011/scripts/superfish/superfish.js"></script>
    <script language="JavaScript" type="text/javascript" src="http://www.ala.org.au/wp-content/themes/ala2011/scripts/jquery.autocomplete.js"></script>
    <script language="JavaScript" type="text/javascript" src="http://www.ala.org.au/wp-content/themes/ala2011/scripts/uservoice.js"></script>
    <script type="text/javascript">

        // initialise plugins

        jQuery(function(){
            jQuery('ul.sf').superfish( {
                delay:500,
                autoArrows:false,
                dropShadows:false
            });

            jQuery("form#search-form-2011 input#search-2011").autocomplete('http://bie.ala.org.au/search/auto.jsonp', {
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
<body class="${pageProperty(name:'body.class')} getinvolved">
  <hf:banner logoutUrl="${ConfigurationHolder.config.grails.serverURL}/public/logout" logoutReturnToUrl="${ConfigurationHolder.config.grails.serverURL}"/>

  %{--<hf:menu/>--}%

  <g:layoutBody/>

  %{--<div id="content" style="">--}%
      %{--<div class="section">--}%
          %{----}%
      %{--</div>--}%
  %{--</div>--}%
  <hf:footer/>

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