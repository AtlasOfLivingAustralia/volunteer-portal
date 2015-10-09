<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags --%>
    <cl:addApplicationMetaTags/>
    <meta name="description" content="Atlas of Living Australia"/>
    <meta name="author" content="Atlas of Living Australia">
    <r:external dir="images/" file="favicon.ico"/>

    <title><g:layoutTitle default="DIGIVOL | Home"/></title>

    <r:require module="digivol"/>
    <g:layoutHead/>
    <r:layoutResources/>

    <%-- Allow overriding of primary branding colour --%>
    <style>
    section#footer .footer-brand,
    section#footer .footer-brand:hover,
    .navbar-brand,
    .navbar-brand:hover,
    .digivol-tab img,
    body .navbar .navbar-brand,
    body .navbar .navbar-brand:hover,
    body .btn-primary,
    body .btn-primary:hover,
    body .btn-primary:focus,
    body .btn-primary:active,
    body .btn-primary.active,
    body .label,
    .progress .progress-bar-transcribed,
    .key.transcribed,
    .transcription-actions .btn.btn-next {
        background-color: <g:pageProperty name="page.primaryColour" default="#d5502a"/>;
    }

    body .navbar {
        border-color: <g:pageProperty name="page.primaryColour" default="#d5502a"/>;
    }

    body .badge,
    body .badge:hover {
        color: <g:pageProperty name="page.primaryColour" default="#d5502a"/>;
    }
    </style>

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
</head>

<body class="${pageProperty(name: 'body.class')}">
<nav class="navbar navbar-default navbar-fixed-top">
    <div class="container">
        <div class="navbar-header">
            <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar"
                    aria-expanded="false" aria-controls="navbar">
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>
            <a class="navbar-brand" href="#"><r:img dir="images/2.0/" file="logoDigivol.png"/></a>
        </div>

        <div id="navbar" class="navbar-collapse collapse">

            <div class="custom-search-input">
                <div class="input-group">
                    <input type="text" class="form-control input-lg" placeholder="Search e.g. Bivalve"/>
                    <span class="input-group-btn">
                        <button class="btn btn-info btn-lg" type="button">
                            <i class="glyphicon glyphicon-search"></i>
                        </button>
                    </span>
                </div>
            </div>

            <ul class="nav navbar-nav navbar-right">
                <li class="${pageProperty(name: 'page.selectedNavItem') == 'bvp' ? 'active' : ''}"><a href="#">Home</a>
                </li>
                <li class="${pageProperty(name: 'page.selectedNavItem') == 'institutions' ? 'active' : ''}"><a
                        href="#about">Institutions</a></li>
                <li class="${pageProperty(name: 'page.selectedNavItem') == 'expeditions' ? 'active' : ''}"><a
                        href="#contact">Expeditions</a></li>
                <li class="${pageProperty(name: 'page.selectedNavItem') == 'tutorials' ? 'active' : ''}"><a
                        href="#contact">Tutorials</a></li>
                <li class="${pageProperty(name: 'page.selectedNavItem') == 'forum' ? 'active' : ''}"><a
                        href="#contact">Forum</a></li>
                <li class="${pageProperty(name: 'page.selectedNavItem') == 'contact' ? 'active' : ''}"><a
                        href="#contact">Contact Us</a></li>
                <!-- Logged In Starts -->
                <cl:isNotLoggedIn>
                    <li>
                        <a href="${grailsApplication.config.casServerName}/cas/login?service=${grailsApplication.config.grails.serverURL}/"><i class="glyphicon glyphicon-user"></i> Log in</a>
                    </li>
                </cl:isNotLoggedIn>
                <cl:isLoggedIn>
                    <li class="dropdown ${pageProperty(name: 'page.selectedNavItem') == 'userDashboard' ? 'active' : ''}">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                            <span class="glyphicon glyphicon-user"></span>
                            My Profile
                            <span class="glyphicon glyphicon-chevron-down"></span>
                        </a>

                        <ul class="dropdown-menu">
                            <li>

                                <div class="navbar-login">
                                    <div class="row">
                                        <div class="col-lg-4">
                                            <p class="text-center">
                                                <img src="http://api.randomuser.me/portraits/men/49.jpg" alt=""
                                                     class="center-block img-circle img-responsive">
                                            </p>
                                        </div>

                                        <div class="col-lg-8">
                                            <p class="text-left"><strong>Peter Smith</strong><br/><a
                                                    href="#">petersmity@email.com</a></p>
                                        </div>
                                    </div>
                                </div>

                            </li>
                            <li class="divider"></li>
                            <li>
                                <div class="navbar-login navbar-login-session">
                                    <div class="row">
                                        <div class="col-lg-12">
                                            <ul class="profile-links">
                                                <li><a href="#" class="">View Profile</a></li>
                                                <li><a href="#" class="">Notebook</a></li>
                                                <li><a href="${g.createLink(controller: 'logout', action: 'logout', params: [casUrl: "${grailsApplication.config.casServerName}/cas/logout", appUrl: "${grailsApplication.config.grails.serverURL}"])}" class="">Logout</a></li>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </li>
                        </ul>
                    </li>
                    <cl:ifAdmin>
                        <li class="${pageProperty(name: 'page.selectedNavItem') == 'bvpadmin' ? 'active' : ''}">
                            <a href="${g.createLink(controller: 'admin')}"><i class="fa fa-cog fa-lg"></i> Admin</a>
                        </li>
                    </cl:ifAdmin>
                </cl:isLoggedIn>

            <!-- Logged In Ends -->


            <!--
                  <li><a href="#contact">Sign In</a></li>
                  <li><a href="#contact">Register</a></li>
                  -->
            </ul>
        </div>
    </div>
</nav>

<g:if test="${!pageProperty(name: 'page.disableBreadcrumbs', default: false)}">
    <section id="breadcrumb">
        <div class="container">
            <div class="row">
                <div class="col-md-12">
                    <cl:messages/>
                    %{--<div>--}%
                    <g:pageProperty name="page.page-header"/>
                    %{--</div>--}%
                </div>
            </div>
        </div>
    </section>
</g:if>

<g:if test="${g.pageProperty(name: "page.page-title")}">
    <div class="a-feature simple-header">
        <div class="container">
            <div class="row">
                <div class="col-sm-10">
                    <g:pageProperty name="page.page-title"/>
                </div>
            </div>
        </div>
    </div>
</g:if>

<g:layoutBody/>

<section id="why" class="white">
    <div class="container">
        <h2 class="heading">Why should you get involved?</h2>

        <div class="row">
            <div class="col-sm-4">
                <h3>Lorem ipsum dolor sit ame</h3>

                <p>
                    Nullam mollis bibendum nisi, eu feugiat leo efficitur in. Curabitur in porttitor libero.
                </p>
            </div>

            <div class="col-sm-4">
                <h3>Lorem ipsum dolor sit ame</h3>

                <p>
                    Nullam mollis bibendum nisi, eu feugiat leo efficitur in. Curabitur in porttitor libero.e
                </p>
            </div>

            <div class="col-sm-4">
                <h3>Lorem ipsum dolor sit ame</h3>

                <p>
                    Nullam mollis bibendum nisi, eu feugiat leo efficitur in. Curabitur in porttitor libero.
                </p>
            </div>
        </div>
    </div>
</section>

<section id="logos-institutions">
    <div class="container">
        <h2 class="heading">Institutions using digivol</h2>

        <div class="row">

            <div class="col-sm-12">
                <r:img dir="images/2.0/institutions/" file="logoAustMus@2x.png"/>
                <r:img dir="images/2.0/institutions/" file="logoCSIRO@2x.png"/>
                <r:img dir="images/2.0/institutions/" file="logoMelbourneVictoria@2x.png"/>
                <r:img dir="images/2.0/institutions/" file="logoVermont@2x.png"/>
                <r:img dir="images/2.0/institutions/" file="logoSmithsonian@2x.png"/>
            </div>

        </div>
    </div>

</section>


<section id="footer" class="dark">
    <footer>
        <div class="container">

            <div class="row footer-header">
                <div class="col-sm-12">
                    <a class="footer-brand " href="https://www.facebook.com/groups/181836918595085/"><r:img
                            dir="images/2.0/" file="logoDigivolInverted.png"/></a>

                    <div class="social-icons pull-right">
                        <a href="#" class="btn-lg"><i class="fa fa-facebook fa-lg"></i></a>
                        <a href="https://twitter.com/amdigivol" class="btn-lg"><i class="fa fa-twitter fa-lg"></i></a>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-sm-3">
                    <h3>Expeditions</h3>
                    <ul>
                        <li><a href="#">View all expeditions</a></li>
                    </ul>
                </div>

                <div class="col-sm-3">
                    <h3>About Digivol</h3>
                    <ul>
                        <li><a href="#">Why capture this data</a></li>
                        <li><a href="#">Become an online volunteer</a></li>
                        <li><a href="#">Submit an expedition</a></li>
                        <li><a href="#">Useful reference</a></li>
                    </ul>
                </div>

                <div class="col-sm-3">
                    <h3>How can I volunteer</h3>
                    <ul>
                        <li><a href="#">Registering</a></li>
                        <li><a href="#">Transcribing</a></li>
                        <li><a href="#">What happens next</a></li>
                        <li><a href="#">Examples</a></li>
                    </ul>
                </div>

                <div class="col-sm-3">
                    <h3>Contact us</h3>

                    <p>Get help in using DIGIVOL and reporting issues</p>

                    <p class="address">
                        <a href="#">paul.flemons@austmus.gov.au</a><br/>
                        (02) 9320 6343<br/>
                        Australian Museum<br/>
                        Sydney NSW 2010
                    </p>
                </div>
            </div>

        </div>
    </footer>
</section>

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

<g:set var="cheevs" value="${cl.newAchievements()}"/>
<g:if test="${cl.achievementsEnabled() && cheevs.size() > 0}">
    <g:if test="${cheevs.size() < 3}">
        <g:set var="itemgridStyle" value="margin-left:auto; margin-right:auto; width: ${cheevs.size() * 160}px"/>
    </g:if>
    <g:else>
        <g:set var="itemgridStyle" value=""/>
    </g:else>
    <div id="achievement-notifier" class="modal hide fade">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" data-target="#achievement-notifier"
                    aria-hidden="true">&times;</button>

            <h3>Congratulations!  You just achieved...</h3>
        </div>

        <div class="modal-body">
            <div class="itemgrid" style="${itemgridStyle}">
                <g:each in="${cheevs}" var="ach">
                    <div class="item bvpBadge">
                        <img src="${cl.achievementBadgeUrl(achievement: ach.achievement)}"
                             title="${ach.achievement.description}" alt="${ach.achievement.name}"/>

                        <div>${ach.achievement.name}</div>

                        <div>Awarded <prettytime:display date="${ach.awarded}"/></div>
                    </div>
                </g:each>
            </div>

            <p>Visit <g:link controller="user"
                             action="notebook">your notebook</g:link> to see all your achievements.</p>
        </div>

        <div class="modal-footer">
            <button data-dismiss="modal" data-target="#achievement-notifier" class="btn">Close</button>
        </div>
    </div>
    <r:script>
        jQuery(function($) {
            var cheevs = <cl:json value="${cheevs*.id}"/>;
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


%{--<asset:javascript src="application.js" />--}%
<r:script>
    var BVP_JS_URLS = {
                selectProjectFragment: "${createLink(controller: 'project', action: 'findProjectFragment')}",
                webappRoot: "${resource(dir: '/')}",
                picklistAutocompleteUrl: "${createLink(action: 'autocomplete', controller: 'picklistItem')}"
            };
</r:script>
%{--<asset:deferredScripts/>--}%
<!-- JS resources-->
<r:layoutResources/>
</body>
</html>