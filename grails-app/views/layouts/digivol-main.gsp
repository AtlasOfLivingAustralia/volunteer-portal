<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags --%>
    <cl:addApplicationMetaTags/>
    <asset:link rel="shortcut icon" href="favicon.ico" type="image/x-icon"/>

    <title><g:layoutTitle default="DIGIVOL | Home"/></title>

    <asset:stylesheet href="digivol.css"/>
    <g:render template="/layouts/jsUrls" />
    <g:layoutHead />

    <g:render template="/layouts/commonCss" />

    %{--<!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->--}%
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
</head>
<body class="${pageProperty(name: 'body.class')}" data-ng-app="${pageProperty(name: 'body.data-ng-app')}">
<nav class="navbar navbar-expand-lg navbar-light bg-light fixed-top">
    <div class="container">
        <button type="button" class="navbar-toggler" data-bs-toggle="collapse" data-bs-target="#navbar"
                aria-expanded="false" aria-controls="navbar" aria-label="Toggle navigation" role="button">
            <span class="visually-hidden">Toggle navigation</span>
            <span class="navbar-toggler-icon"></span>
        </button>

        <g:link uri="${grailsApplication.config.getProperty("grails.serverURL", String) ?: '/'}" class="navbar-brand digivol-logo">
            <asset:image src="logoDigivol.png"/>
        </g:link>

        <div id="navbar" class="collapse navbar-collapse">
            <div class="custom-search-input">
                <g:form controller="project" action="list" method="GET" >
                    <div class="input-group">
                        <g:textField name="q" class="form-control input-lg header-search-input" placeholder="Search e.g. Bivalve" />
                        <button class="btn btn-info btn-lg" id="header-search" type="submit">
                            <i class="fa fa-search"></i>
                        </button>
                    </div>
                </g:form>
            </div>

            <ul class="navbar-nav ms-auto main-menu">
                <li class="nav-item ${pageProperty(name: 'page.selectedNavItem') == 'bvp' ? 'active' : ''}">
                    <g:link uri="${grailsApplication.config.getProperty("grails.serverURL", String) ?: '/'}" class="nav-link">Home</g:link>
                </li>
                <li class="nav-item ${pageProperty(name: 'page.selectedNavItem') == 'institutions' ? 'active' : ''}">
                    <g:link controller="institution" action="list" class="nav-link">Institutions</g:link>
                </li>
                <li class="nav-item ${pageProperty(name: 'page.selectedNavItem') == 'expeditions' ? 'active' : ''}">
                    <g:link controller="project" action="list" class="nav-link">Expeditions</g:link>
                </li>
                <cl:showLandingPage />
                <li class="nav-item ${pageProperty(name: 'page.selectedNavItem') == 'tutorials' ? 'active' : ''}">
                    <g:link controller="tutorials" action="index" class="nav-link">Tutorials</g:link>
                </li>
                <li class="nav-item ${pageProperty(name: 'page.selectedNavItem') == 'forum' ? 'active' : ''}">
                    <g:link controller="forum" action="index" class="nav-link">Forum</g:link>
                </li>
                <!-- Logged In Starts -->
                <cl:isNotLoggedIn>
                    <li class="nav-item">
                        <cl:loginLink class="nav-link"><i class="fa fa-user"></i> Log in</cl:loginLink>
                    </li>
                </cl:isNotLoggedIn>
                <cl:isLoggedIn>
                    <li class="nav-item dropdown ${pageProperty(name: 'page.selectedNavItem') == 'userDashboard' ? 'active' : ''}">
                        <a href="#" class="nav-link dropdown-toggle" data-bs-toggle="dropdown">
                            <span class="fa fa-user"></span>
                           <!-- My Profile -->
                            <g:message code="action.myProfile" />
                            <span class="fa fa-chevron-down"></span>
                        </a>

                        <g:render template="/layouts/profileDropDown"/>
                    </li>
                    <cl:ifAdmin>
                        <li class="nav-item ${pageProperty(name: 'page.selectedNavItem') == 'bvpadmin' ? 'active' : ''}">
                            <a class="nav-link" href="${g.createLink(controller: 'admin')}"><i class="fa fa-cog fa-lg"></i> Admin</a>
                        </li>
                    </cl:ifAdmin>
                </cl:isLoggedIn>
                <!-- Logged In Ends -->
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
        <h2 class="heading">Institutions using DigiVol</h2>

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

            <div class="row footer-header">
                <div class="col-sm-12">
                    <span class="footer-brand"><asset:image src="logoDigivolInverted.png"/></span>

                    <div class="social-icons float-end">
                        <g:link controller="newsItem" action="index" class="btn-lg" target="_blank" title="DigiVol News"><i class="fa fa-newspaper-o fa-lg"></i></g:link>
                        <a href="https://www.facebook.com/AMDigiVol/" class="btn-lg" target="_blank" title="DigiVol on Facebook"><i class="fa fa-facebook fa-lg"></i></a>
                        <a href="https://twitter.com/AMDigiVol" class="btn-lg" target="_blank" title="DigiVol on Twitter/X"><i class="fa fa-twitter fa-lg"></i></a>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-sm-3">
                    <h3>Expeditions</h3>
                    <ul>
                        <li><g:link controller="project" action="list">View all expeditions</g:link></li>
                    </ul>
                </div>

                <div class="col-sm-3">
                    <h3>About DigiVol</h3>
                    <ul>
                        <li><g:link controller="about" fragment="what-is-digivol">What is DigiVol</g:link></li>
                        <li><g:link controller="about" fragment="why-capture-this-data">Why capture this data</g:link></li>
                        <li><g:link controller="about" fragment="submit-an-expedition">Submit an expedition</g:link></li>
                        <li><g:link controller="newsItem" action="index">DigiVol News</g:link></li>
                        <li><g:link controller="about" fragment="useful-references">Useful references</g:link></li>
                    </ul>
                </div>

                <div class="col-sm-3">
                    <h3>How can I volunteer</h3>
                    <ul>
                        <li><g:link controller="about" fragment="registering">Become an Online Volunteer</g:link></li>
                        <li><g:link controller="about" fragment="transcribing">How to get started</g:link></li>
                        <li><g:link controller="about" fragment="what-happens-next">What happens next</g:link></li>
                        <li><g:link controller="about" fragment="examples">Examples</g:link></li>
                    </ul>
                </div>

                <div class="col-sm-3">
                    <h3>Contact us</h3>

                    <p>Get help in using DIGIVOL and reporting issues</p>

                    <p class="address">
                        <a href="mailto:${grailsApplication.config.getProperty('grails.contact.emailAddress', String)}">
                            ${grailsApplication.config.getProperty('grails.contact.emailAddress', String)}</a><br/>
                        Australian Museum<br/>
                        Sydney NSW 2010
                    </p>
                </div>
            </div>

        </div>
    </footer>
</section>

<g:render template="/layouts/associatedBrands" />

<g:render template="/layouts/notifications" />

<g:render template="/layouts/ga" />
<g:render template="/layouts/fathom" />

<asset:javascript src="digivol.js" />
<!-- JS resources-->
<asset:deferredScripts/>
</body>
</html>