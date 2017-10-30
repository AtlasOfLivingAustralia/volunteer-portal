<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="org.springframework.context.i18n.LocaleContextHolder" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags --%>
    <cl:addApplicationMetaTags/>
    <asset:link rel="shortcut icon" href="favicon.ico" type="image/x-icon"/>

    <title><g:message code="main.title" /></title>

    <asset:stylesheet href="digivol.css"/>
    <g:render template="/layouts/jsUrls" />
    <g:layoutHead />

    <g:render template="/layouts/commonCss" />

    <asset:stylesheet href="doedat-custom.css"/>

    %{--<!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->--}%
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
</head>
<body class="${pageProperty(name: 'body.class')}" data-ng-app="${pageProperty(name: 'body.data-ng-app')}">
<nav class="navbar navbar-default navbar-fixed-top">

    <div class="container">
        <div class="navbar-header">
            <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar"
                    aria-expanded="false" aria-controls="navbar">
                <span class="sr-only"><g:message code="main.navigation.toggle" /></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>
            <g:link uri="/" class="navbar-brand"><asset:image src="doedat/logoDoeDat.png"/></g:link>
        </div>

        <div id="navbar" class="navbar-collapse collapse">

            <div style="" class="navbar-wrapper">
                <div class="custom-search-input" style="">
                    <g:form controller="project" action="list" method="GET" >
                        <div class="input-group">
                            <g:textField name="q" class="form-control input-lg" placeholder="${message(code: "main.navigation.search.placeholder")}" />
                            <span class="input-group-btn">
                                <button class="btn btn-info btn-lg" type="button">
                                    <i class="glyphicon glyphicon-search"></i>
                                </button>
                            </span>
                        </div>
                    </g:form>
                </div>

                <ul class="nav navbar-nav ">
                    <li class="${pageProperty(name: 'page.selectedNavItem') == 'bvp' ? 'active' : ''}"><g:link
                            uri="/"><g:message code="main.navigation.home" /></g:link>
                    </li>
                    <li class="${pageProperty(name: 'page.selectedNavItem') == 'institutions' ? 'active' : ''}"><g:link
                            controller="institution" action="list"><g:message code="main.navigation.institutions" /></g:link></li>
                    <li class="${pageProperty(name: 'page.selectedNavItem') == 'expeditions' ? 'active' : ''}"><g:link
                            controller="project" action="list"><g:message code="main.navigation.expeditions" /></g:link></li>
                    <li class="${pageProperty(name: 'page.selectedNavItem') == 'tutorials' ? 'active' : ''}"><g:link
                            controller="tutorials" action="index"><g:message code="main.navigation.tutorials" /></g:link></li>
                    <li class="${pageProperty(name: 'page.selectedNavItem') == 'forum' ? 'active' : ''}"><g:link
                            controller="forum" action="index"><g:message code="main.navigation.forum" /></g:link></li>
                    <li class="${pageProperty(name: 'page.selectedNavItem') == 'contact' ? 'active' : ''}"><g:link
                            controller="contact" action="index"><g:message code="main.navigation.contact_us" /></g:link></li>


                <!-- Logged In Starts -->
                    <cl:isNotLoggedIn>
                        <li>
                            <a href="${grailsApplication.config.security.cas.loginUrl}?service=${grailsApplication.config.serverURL}&language=${ LocaleContextHolder.getLocale().getLanguage()}"><i class="glyphicon glyphicon-user"></i> <g:message code="main.navigation.log_in" /></a>
                        </li>
                    </cl:isNotLoggedIn>
                    <cl:isLoggedIn>
                        <li class="dropdown ${pageProperty(name: 'page.selectedNavItem') == 'userDashboard' ? 'active' : ''}">
                            <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                                <span class="glyphicon glyphicon-user"></span>
                                <!-- My Profile -->
                                <g:message code="action.myProfile" /> <span class="hidden unread-count label label-danger label-as-badge"></span>
                                <span class="glyphicon glyphicon-chevron-down"></span>
                            </a>

                            <g:render template="/layouts/profileDropDown"/>
                        </li>
                        <cl:ifAdmin>
                            <li class="${pageProperty(name: 'page.selectedNavItem') == 'bvpadmin' ? 'active' : ''}">
                                <a href="${g.createLink(controller: 'admin')}"><i class="fa fa-cog fa-lg"></i> <g:message code="main.navigation.admin" /></a>
                            </li>
                        </cl:ifAdmin>
                    </cl:isLoggedIn>

                <!-- Logged In Ends -->

                <!-- Language selection starts -->
                <!--<ul class="nav navbar-nav navbar-right" style="">-->
                    <li class="dropdown language-selection ">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                            <span class="locale">${ LocaleContextHolder.getLocale().getLanguage()}</span>
                            <span class="glyphicon glyphicon-chevron-down"></span>
                        </a>
                        <g:render template="/layouts/languageDropdown"/>
                    </li>
                    <!--</ul>-->


                </ul>
            </div>
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
    <div class="a-feature ${g.pageProperty(name: "page.pageType", default: "simple-header")}">
        <div class="container">
            %{--<div class="row">--}%
            %{--<div class="col-sm-10">--}%
            <g:pageProperty name="page.page-title"/>
            %{--</div>--}%
            %{--</div>--}%
        </div>
    </div>
</g:if>

<g:layoutBody/>

<section id="why" class="white">
    <div class="container">
        <h2 class="heading"><g:message code="layout.whyinvolved.heading" /></h2>

        <div class="row">
            <div class="col-sm-4">
                <h3><g:message code="layout.whyinvolved.contribute.heading" /></h3>
                <p><g:message code="layout.whyinvolved.contribute.body" /></p>
            </div>

            <div class="col-sm-4">
                <h3><g:message code="layout.whyinvolved.volunteer.heading" /></h3>
                <p><g:message code="layout.whyinvolved.volunteer.body" /></p>
            </div>

            <div class="col-sm-4">
                <h3><g:message code="layout.whyinvolved.accessible.heading" /></h3>
                <p><g:message code="layout.whyinvolved.accessible.body" /></p>
            </div>
        </div>
    </div>
</section>

<section id="logos-institutions">
    <div class="container">
        <h2 class="heading"><g:message code="main.institutions_using_digivol" /></h2>

        <div class="row">

            <div class="col-sm-12">
                <asset:image src="institutions/logoAustMus@2x.png"/>
                <asset:image src="institutions/logoCSIRO.svg"/>
                <cl:insitutionLogos />
                %{--<asset:image src="institutions/logoMelbourneVictoria@2x.png"/>--}%
                %{--<asset:image src="institutions/logoVermont@2x.png"/>--}%
                %{--<asset:image src="institutions/logoSmithsonian@2x.png"/>--}%
            </div>

        </div>
    </div>

</section>


<section id="footer" class="dark">
    <footer>
        <div class="container">

            <div class="row footer-header social-media-sharing">
                <div class="col-sm-12">
                    <a class="footer-brand " href="https://www.facebook.com/groups/181836918595085/"><asset:image
                            src="doedat/logoDoeDatInverted.png"/></a>

                    <div class="social-icons pull-right">
                        <a href="https://www.facebook.com/DigiVolOnline/?ref=hl" class="btn-lg"><i class="fa fa-facebook fa-lg"></i></a>
                        <a href="https://twitter.com/AMDigiVol" class="btn-lg"><i class="fa fa-twitter fa-lg"></i></a>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-sm-3">
                    <h3><g:message code="main.navigation.expeditions" /></h3>
                    <ul>
                        <li><g:link controller="project" action="list"><g:message code="main.view_expeditions" /></g:link></li>
                    </ul>
                </div>

                <div class="col-sm-3">
                    <h3><g:message code="main.about_digivol" /></h3>
                    <ul>
                        <li><g:link controller="about" fragment="what-is-digivol"><g:message code="main.about_digivol.what" /></g:link></li>
                        <li><g:link controller="about" fragment="what-does-digivol-mean"><g:message code="main.about_digivol.why" /></g:link></li>
                        <li><g:link controller="about" fragment="about-digivol"><g:message code="main.about_digivol.submit" /></g:link></li>
                        <li><g:link controller="about" fragment="why"><g:message code="main.about_digivol.references" /></g:link></li>
                    </ul>
                </div>

                <div class="col-sm-3">
                    <h3><g:message code="main.about_digivol.how_can_i_volunteer" /></h3>
                    <ul>
                        <li><g:link controller="about" fragment="new-project"><g:message code="main.about_digivol.how_can_i_volunteer.become" /></g:link></li>
                        <li><g:link controller="about" fragment="references"><g:message code="main.about_digivol.how_can_i_volunteer.how" /></g:link></li>
                        <li><g:link controller="about" fragment="how-can-i-help"><g:message code="main.about_digivol.how_can_i_volunteer.what" /></g:link></li>
                        <li><g:link controller="about" fragment="how-to-start"><g:message code="main.about_digivol.how_can_i_volunteer.examples" /></g:link></li>
                    </ul>
                </div>

                <div class="col-sm-3">
                    <h3><g:message code="main.about_digivol.contact_us" /></h3>

                    <p><g:message code="main.about_digivol.contact_us.description" /></p>

                    <p class="address">
                        <a href="mailto:${message(code: "main.about_digivol.contact_us.email")}"><g:message code="main.about_digivol.contact_us.email" /></a>
                        <br/>
                        <g:message code="main.about_digivol.contact_us.address1" />
                        <br/>
                        <g:message code="main.about_digivol.contact_us.address2" />
                        <br/>
                        <g:message code="main.about_digivol.contact_us.address3" />
                    </p>
                </div>
            </div>

        </div>
    </footer>
</section>

<g:render template="/layouts/associatedBrands" />

<g:render template="/layouts/notifications" />

<g:render template="/layouts/ga" />

<asset:javascript src="digivol.js" />
<!-- JS resources-->
<asset:deferredScripts/>
</body>
</html>