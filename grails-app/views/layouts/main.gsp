<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<%@ page import="org.springframework.web.context.request.RequestContextHolder" %>
<g:set var="userId" value="${RequestContextHolder.currentRequestAttributes()?.getUserPrincipal()?.attributes?.email}"/>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr" lang="en-US">

<head profile="http://gmpg.org/xfn/11">
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE8; IE=EmulateIE9">
  <meta name="robots" content="index,follow"/>
  <meta name="app.version" content="${g.meta(name: 'app.version')}"/>
  <meta name="app.build" content="${g.meta(name: 'app.build')}"/>

  <title><g:layoutTitle/></title>
  %{--<link rel="stylesheet" href="${resource(dir: 'css', file: 'temp-style.css')}"/>--}%
  <link rel="stylesheet" href="${resource(dir: 'css', file: 'public.css')}"/>

  <link rel="stylesheet" href="${ConfigurationHolder.config.ala.baseURL}/wp-content/themes/ala/style.css" type="text/css" media="screen"/>
  <!--link rel="shortcut icon" href="${resource(dir: 'images', file: 'favicon.ico')}" type="image/x-icon"-->
  <link rel="icon" type="image/x-icon" href="${ConfigurationHolder.config.ala.baseURL}/wp-content/themes/ala/images/favicon.ico"/>
  <link rel="shortcut icon" type="image/x-icon" href="${ConfigurationHolder.config.ala.baseURL}/wp-content/themes/ala/images/favicon.ico"/>
  <link rel="stylesheet" type="text/css" media="screen" href="${ConfigurationHolder.config.ala.baseURL}/wp-content/themes/ala/css/sf.css"/>
  <link rel="stylesheet" type="text/css" media="screen" href="${ConfigurationHolder.config.ala.baseURL}/wp-content/themes/ala/css/highlights.css"/>
  <link rel="stylesheet" type="text/css" media="screen" href="${ConfigurationHolder.config.ala.baseURL}/wp-content/themes/ala/css/jquery.autocomplete.css"/>

  <script language="JavaScript" type="text/javascript" src="${ConfigurationHolder.config.ala.baseURL}/wp-content/themes/ala/scripts/iframe.js"></script>
  <script language="JavaScript" type="text/javascript" src="${ConfigurationHolder.config.ala.baseURL}/wp-content/themes/ala/scripts/form.js"></script>
<!--  <script language="JavaScript" type="text/javascript" src="${ConfigurationHolder.config.ala.baseURL}/wp-content/themes/ala/scripts/jquery-1.5.2.min.js"></script>-->
  <g:javascript library="jquery" plugin="jquery"/>
  <tinyMce:importJs />
  %{--<script language="JavaScript" type="text/javascript" src="${ConfigurationHolder.config.ala.baseURL}/wp-content/themes/ala/scripts/ui.core.js"></script>--}%
  %{--<script language="JavaScript" type="text/javascript" src="${ConfigurationHolder.config.ala.baseURL}/wp-content/themes/ala/scripts/ui.tabs.js"></script>--}%
  <script language="JavaScript" type="text/javascript" src="${ConfigurationHolder.config.ala.baseURL}/wp-content/themes/ala/scripts/hoverintent-min.js"></script>
  <script language="JavaScript" type="text/javascript" src="${ConfigurationHolder.config.ala.baseURL}/wp-content/themes/ala/scripts/superfish/superfish.js"></script>
  <script language="JavaScript" type="text/javascript" src="${ConfigurationHolder.config.ala.baseURL}/wp-content/themes/ala/scripts/jquery.autocomplete.js"></script>
  <script type="text/javascript">
    tinyMCE.init({
        convert_urls : false
    });
    // initialise plugins
    jQuery(function() {
      jQuery('ul.sf').superfish({
        delay:500,
        autoArrows:false,
        dropShadows:false
      });
    });

  </script>
  <link rel="EditURI" type="application/rsd+xml" title="RSD" href="${ConfigurationHolder.config.ala.baseURL}/xmlrpc.php?rsd"/>
  <link rel="wlwmanifest" type="application/wlwmanifest+xml" href="${ConfigurationHolder.config.ala.baseURL}/wp-includes/wlwmanifest.xml"/>
  <link rel='index' title='Atlas Living Australia NG' href='${ConfigurationHolder.config.ala.baseURL}/'/>
  <link rel='prev' title='My Profile' href='${ConfigurationHolder.config.ala.baseURL}/my-profile/'/>
  <link rel='next' title='Search' href='${ConfigurationHolder.config.ala.baseURL}/tools-services/search-tools/'/>

  <g:javascript library="application"/>
  <g:layoutHead/>
</head>

<body class="${pageProperty(name: 'body.class')}" id="${pageProperty(name: 'body.id')}" onload="${pageProperty(name: 'body.onload')}">
<div id="wrapper">
  <div id="banner">
    <div id="logo">
      <a href="${ConfigurationHolder.config.ala.baseURL}" title="Atlas of Living Australia home"><img src="${resource(dir:'images', file: 'ala-logo-36high.png')}" width="215" height="36" alt="Atlas of Living Ausralia logo"/></a>
    </div><!--close logo-->
    <div id="nav">
      <!-- WP Menubar 4.8: start menu nav-site-loggedout, template Superfish, CSS  -->
      <ul class="sf"><li class="nav-home"><a href="http://www.ala.org.au/"><span>Home</span></a></li><li class="nav-explore"><a href="http://www.ala.org.au/explore/"><span>Explore</span></a><ul><li><a href="http://biocache.ala.org.au/explore/your-area"><span>Your Area</span></a></li><li><a href="http://bie.ala.org.au/regions/ "><span>Regions</span></a></li><li><a href="http://www.ala.org.au/explore/species-maps/"><span>Species Maps</span></a></li><li><a href="http://collections.ala.org.au/public/map "><span>National History Collections</span></a></li><li><a href="http://www.ala.org.au/explore/themes/"><span>Themes & Case Studies</span></a></li></ul></li><li class="nav-tools"><a href="http://www.ala.org.au/tools-services/"><span>Tools</span></a><ul><li><a href="http://www.ala.org.au/tools-services/citizen-science/"><span>Citizen Science</span></a></li><li><a href="http://www.ala.org.au/tools-services/images/"><span>Images</span></a></li><li><a href="http://www.ala.org.au/tools-services/identification-tools/"><span>Identification Tools</span></a></li><li><a href="http://www.ala.org.au/tools-services/sds/"><span>Sensitive Data Service</span></a></li><li><a href="http://www.ala.org.au/tools-services/spatial-analysis/"><span>Spatial Analysis</span></a></li><li><a href="http://www.ala.org.au/tools-services/species-name-services/"><span>Taxon Web Services</span></a></li><li><a href="http://www.ala.org.au/tools-services/onlinedesktop-tools-review/"><span>Online & Desktop Tools Review</span></a></li></ul></li><li class="nav-share"><a href="http://www.ala.org.au/share/" title="Share - links, images, images, literature, your time"><span>Share</span></a><ul><li><a href="http://www.ala.org.au/share/share-links/"><span>Share links, ideas, information</span></a></li><li><a href="http://www.ala.org.au/share/share-data/"><span>Share Datasets</span></a></li><li><a href="http://www.ala.org.au/share/about-sharing/"><span>About Sharing</span></a></li></ul></li><li class="nav-support"><a href="http://www.ala.org.au/support/"><span>Support</span></a><ul><li><a href="http://www.ala.org.au/support/contact-us/"><span>Contact Us</span></a></li><li><a href="http://www.ala.org.au/support/get-started/"><span>Get Started</span></a></li><li><a href="http://www.ala.org.au/support/user-feedback/"><span>User Feedback</span></a></li><li><a href="http://www.ala.org.au/support/faq/"><span>Frequently Asked Questions</span></a></li></ul></li><li class="nav-contact"><a href="http://www.ala.org.au/support/contact-us/"><span>Contact Us</span></a></li><li class="nav-about"><a href="http://www.ala.org.au/about/"><span>About the Atlas</span></a><ul><li><a href="http://www.ala.org.au/about/progress/"><span>A Work In Progress</span></a></li><li><a href="http://www.ala.org.au/about/atlas-partners/"><span>Atlas Partners</span></a></li><li><a href="http://www.ala.org.au/about/people/"><span>Working Together</span></a></li><li><a href="http://www.ala.org.au/about/contributors/"><span>Atlas Contributors</span></a></li><li><a href="http://www.ala.org.au/about/project-time-line/"><span>Project Time Line</span></a></li><li><a href="http://www.ala.org.au/about/program-of-projects/"><span>Atlas Projects</span></a></li><li><a href="http://www.ala.org.au/about/international-collaborations/"><span>Associated Projects</span></a></li><li><a href="http://www.ala.org.au/about/communications-centre/"><span>Communications Centre</span></a></li><li><a href="http://www.ala.org.au/about/governance/"><span>Atlas Governance</span></a></li><li><a href="http://www.ala.org.au/about/terms-of-use/"><span>Terms of Use</span></a></li></ul></li><li class="nav-myprofile nav-right"><a href="https://auth.ala.org.au/cas/login?service=http://www.ala.org.au/wp-login.php?redirect_to=http://www.ala.org.au/my-profile/"><span>My Profile</span></a></li><li class="nav-${(userId)?'logout':'login'} nav-right"><cl:loginoutLink/></li></ul>
      <!-- WP Menubar 4.8: end menu nav-site-loggedout, template Superfish, CSS  -->
    </div><!--close nav-->
    <div id="wrapper_search">
      <form id="search-form" action="http://bie.ala.org.au/search" method="get" name="search-form">
        <label for="search">Search</label>
        <input type="text" class="filled" id="search" name="q" value="Search the Atlas"/>
        <span class="search-button-wrapper"><input type="submit" class="search-button" id="search-button" alt="Search" value="Search"/></span>
      </form>
    </div><!--close wrapper_search-->
  </div><!--close banner-->
  <div id="content">
    <div class="section">
        <g:layoutBody/>
    </div>
  </div>
  <div id="footer">
    <div id="footer-nav">
      <ul id="menu-footer-site"><li id="menu-item-1046" class="menu-item menu-item-type-post_type menu-item-1046"><a href="http://www.ala.org.au/">Home</a></li>
        <li id="menu-item-8090" class="menu-item menu-item-type-post_type current-menu-item page_item page-item-883 current_page_item menu-item-8090"><a href="http://www.ala.org.au/explore/">Explore</a></li>
        <li id="menu-item-1051" class="menu-item menu-item-type-post_type menu-item-1051"><a href="http://www.ala.org.au/tools-services/">Tools</a></li>
        <li id="menu-item-8091" class="menu-item menu-item-type-post_type menu-item-8091"><a href="http://www.ala.org.au/share/">Share</a></li>
        <li id="menu-item-1050" class="menu-item menu-item-type-post_type menu-item-1050"><a href="http://www.ala.org.au/support/">Support</a></li>
        <li id="menu-item-1048" class="menu-item menu-item-type-post_type menu-item-1048"><a href="http://www.ala.org.au/support/contact-us/">Contact Us</a></li>
        <li id="menu-item-1047" class="menu-item menu-item-type-post_type menu-item-1047"><a href="http://www.ala.org.au/about/">About the Atlas</a></li>
        <li id="menu-item-1052" class="last menu-item menu-item-type-custom menu-item-1052"><cl:loginoutLink /></li>
      </ul>        <ul id="menu-footer-legal"><li id="menu-item-1045" class="menu-item menu-item-type-post_type menu-item-1045"><a href="http://www.ala.org.au/about/terms-of-use/">Terms of Use</a></li>
      <li id="menu-item-1042" class="menu-item menu-item-type-post_type menu-item-1042"><a href="http://www.ala.org.au/about/terms-of-use/citing-the-atlas/">Citing the Atlas</a></li>
      <li id="menu-item-12256" class="menu-item menu-item-type-custom menu-item-12256"><a href="http://www.ala.org.au/about/privacy-policy">Privacy Policy</a></li>
      <li id="menu-item-3090" class="last menu-item menu-item-type-post_type menu-item-3090"><a href="http://www.ala.org.au/site-map/">Site Map</a></li>
    </ul></div>
    <div class="copyright"><p><a href="http://creativecommons.org/licenses/by/3.0/au/" title="External link to Creative Commons" class="left no-pipe"><img src="http://www.ala.org.au/wp-content/themes/ala/images/creativecommons.png" width="88" height="31" alt=""/></a>This site is licensed under a <a href="http://creativecommons.org/licenses/by/3.0/au/" title="External link to Creative Commons">Creative Commons Attribution 3.0 Australia License</a></p><p>Provider content may be covered by other <span class="asterisk-container"><a href="http://www.ala.org.au/about/terms-of-use/" title="Terms of Use">Terms of Use</a>.</span></div>
  </div><!--close footer-->
</div><!--close wrapper-->
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
 var uvOptions = {};
 (function() {
   var uv = document.createElement('script'); uv.type = 'text/javascript'; uv.async = true;
   uv.src = ('https:' == document.location.protocol ? 'https://' : 'http://') + 'widget.uservoice.com/CrRjXClK7ghEdGZYiEaTg.js';
   var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(uv, s);
 })();
</script>

</body>
</html>