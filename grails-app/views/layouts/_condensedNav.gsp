<%@ page contentType="text/html; charset=UTF-8" %>
<nav class="navbar navbar-default navbar-fixed-top">
    <div class="expedition-tab">
        <div class="container">
            <div class="row">
                <div class="col-sm-6 hidden-xs">
                    <g:ifPageProperty name="page.includeBack">
                        <g:set var="includeBackGrey" value="${false}"/>
                        <g:ifPageProperty name="page.includeBackGrey" equals="true"><g:set var="includeBackGrey" value="${true}"/></g:ifPageProperty>
                        <a href="${g.pageProperty(name:'page.backHref')}" class="btn btn-hollow transcription-back ${includeBackGrey ? 'grey' :''}"><g:message code="action.back" /></a>
                    </g:ifPageProperty>
                </div>
                <div class="col-sm-6">
                    <div class="digivol-tab">
                            <g:link uri="/" class="tab-brand"><g:message code="condensedNav.a_digivol_expedition.a" /> <asset:image src="doedat/logoDoeDatInverted.png" /> <g:message code="condensedNav.a_digivol_expedition.expedition" /></g:link>
                        <ul class="navbar-short navbar-right">
                        <!-- Logged In Starts -->
                            <cl:isNotLoggedIn>
                                <li>
                                    <a href="${grailsApplication.config.security.cas.loginUrl}?service=${grailsApplication.config.serverURL}/&language=${ org.springframework.context.i18n.LocaleContextHolder.getLocale().getLanguage()}"><i class="glyphicon glyphicon-user"></i> <g:message code="action.login" /></a>
                                </li>

                                <li><a href="#"><g:message code="action.register" /></a></li>
                            </cl:isNotLoggedIn>
                            <cl:isLoggedIn>
                                <li class="dropdown ${pageProperty(name: 'page.selectedNavItem') == 'userDashboard' ? 'active' : ''}">
                                    <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                                        <span class="glyphicon glyphicon-user"></span>
                                        <g:message code="action.myProfile" />
                                        <span class="glyphicon glyphicon-chevron-down"></span>
                                    </a>

                                    <g:render template="/layouts/profileDropDown"/>
                                </li>
                            </cl:isLoggedIn>
                            <li class="dropdown">
                                <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                                    <span class="locale">${ org.springframework.context.i18n.LocaleContextHolder.getLocale().getLanguage()}</span>
                                    <span class="glyphicon glyphicon-chevron-down"></span>
                                </a>
                                <g:render template="/layouts/languageDropdown"/>
                            </li>

                    </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>
</nav>