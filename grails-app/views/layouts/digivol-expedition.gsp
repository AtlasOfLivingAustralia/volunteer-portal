<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags --%>
    <cl:addApplicationMetaTags/>
    <meta name="description" content="Atlas of Living Australia"/>
    <meta name="author" content="Atlas of Living Australia"/>
    <r:external dir="images/" file="favicon.ico"/>

    <title><g:layoutTitle default="DIGIVOL | Home"/></title>

    <r:require module="digivol"/>
    <g:layoutHead/>
    <r:layoutResources/>

    <%-- Allow overriding of primary branding colour --%>
    <meta name="theme-color" content="${g.pageProperty(name: "page.primaryColour", default: "#d5502a")}"/>
    <g:render template="/layouts/commonCss" />

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
</head>

<body class="${pageProperty(name: 'body.class')?:'digivol'}">

<nav class="navbar navbar-default navbar-fixed-top">

    <div class="expedition-tab">
        <div class="container">
            <div class="row">
                <div class="col-sm-6 hidden-xs">
                    <a href="javascript:history.back()" class="btn btn-hollow transcription-back grey">Back</a>
                </div>
                <div class="col-sm-6">
                    <div class="digivol-tab">
                        <a href="${g.createLink(uri:"/")}" class="tab-brand">A <r:img dir="images/2.0/" file="logoDigivolInverted.png" /> Expedition</a>
                        <ul class="navbar-short">
                        <!-- Logged In Starts -->
                            <cl:isNotLoggedIn>
                                <li>
                                    <a href="${grailsApplication.config.casServerName}/cas/login?service=${grailsApplication.config.grails.serverURL}/"><i class="glyphicon glyphicon-user"></i> Log in</a>
                                </li>

                                <li><a href="#">Register</a></li>
                            </cl:isNotLoggedIn>
                            <cl:isLoggedIn>
                                <li class="dropdown ${pageProperty(name: 'page.selectedNavItem') == 'userDashboard' ? 'active' : ''}">
                                    <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                                        <span class="glyphicon glyphicon-user"></span>
                                        My Profile
                                        <span class="glyphicon glyphicon-chevron-down"></span>
                                    </a>

                                    <g:render template="/layouts/profileDropDown"/>
                                </li>
                            </cl:isLoggedIn>
                        </ul>

                    </div>
                </div>
            </div>
        </div>
    </div>
</nav>

<g:layoutBody/>

<section id="associated-brands" class="dark darker">
    <div class="container">
        <div class="row">
            <div class="col-sm-7">
                <r:img dir="images/2.0/" file="logoAustMus.png"/> <r:img dir="images/2.0/" file="logoALA.png"/>
            </div>

            <div class="col-sm-5">
                <r:img dir="images/2.0/" file="logoAGI.png" class="logo-agi"/>
            </div>
        </div>
    </div>
</section>

<r:script>
    var BVP_JS_URLS = {
                selectProjectFragment: "${createLink(controller: 'project', action: 'findProjectFragment')}",
                webappRoot: "${resource(dir: '/')}",
                picklistAutocompleteUrl: "${createLink(action: 'autocomplete', controller: 'picklistItem')}"
            };
</r:script>
<!-- JS resources-->
<r:layoutResources/>

</body>
</html>