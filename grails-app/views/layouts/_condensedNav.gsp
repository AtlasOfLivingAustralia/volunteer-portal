<nav class="navbar navbar-default navbar-fixed-top">
    <div class="expedition-tab">
        <div class="container">
            <div class="row">
                <div class="col-sm-6 hidden-xs">
                    <g:ifPageProperty name="page.includeBack">
                        <a href="javascript:history.back()" class="btn btn-hollow transcription-back grey">Back</a>
                    </g:ifPageProperty>
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