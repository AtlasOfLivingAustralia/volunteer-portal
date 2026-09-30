<nav class="navbar navbar-light fixed-top condensed-navbar">
    <div class="expedition-tab mx-auto">
        <div class="container">
            <div class="row condensed-nav-row">
                <div class="col-sm-6 d-none d-sm-block condensed-nav-back">
                    <g:ifPageProperty name="page.includeBack">
                        <g:set var="includeBackGrey" value="${false}"/>
                        <g:ifPageProperty name="page.includeBackGrey" equals="true"><g:set var="includeBackGrey" value="${true}"/></g:ifPageProperty>
                        <a href="${g.pageProperty(name:'page.backHref')}" class="btn btn-outline-${includeBackGrey ? 'secondary' :'light'} transcription-back">
                            <i class="fa fa-long-arrow-left"></i>&nbsp;${g.pageProperty(name:'page.backText')}
                        </a>
                    </g:ifPageProperty>
                </div>
                <div class="col-sm-6 condensed-nav-meta">
                    <div class="digivol-tab">
                        <g:link uri="/" class="tab-brand">A <asset:image src="logoDigivolInverted.png" /> <g:message code="suffix.expedition" /></g:link>
                        <ul class="navbar-short">
                        <!-- Logged In Starts -->
                            <cl:isNotLoggedIn>
                                <li>
                                    <cl:loginLink><i class="fa fa-user"></i> <g:message code="action.login" /></cl:loginLink>
                                </li>

                                <li><a href="#"><g:message code="action.register" /></a></li>
                            </cl:isNotLoggedIn>
                            <cl:isLoggedIn>
                                <li class="dropdown ${pageProperty(name: 'page.selectedNavItem') == 'userDashboard' ? 'active' : ''}">
                                    <a href="#" class="dropdown-toggle" data-bs-toggle="dropdown">
                                        <span class="fa fa-user"></span>
                                        <g:message code="action.myProfile" />
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