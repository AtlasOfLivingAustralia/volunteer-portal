<ul class="dropdown-menu">
    <li class="hidden-xs">
        <div class="navbar-login logged-in">
            <div class="row">
                <div class="col-2 col-lg-3">
                    <p class="text-center">
                        <a href="//en.gravatar.com/" class="external" target="_blank" id="gravatarLink" title="${message(code:"avatar.customise.label")}">
                            <img src="//www.gravatar.com/avatar/${cl.showCurrentUserEmail().toLowerCase().encodeAsMD5()}?s=80"
                                 class="img-circle img-fluid avatar"/>
                        </a>
                    </p>
                </div>

                <div class="col-10 col-lg-9">
                    <p class="text-start word-wrap-break-word"><strong>${cl.showCurrentUserName()}</strong><br/>
                        <a href="#" class="profile-email">${cl.showCurrentUserEmail()}</a>
                    </p>
                </div>
            </div>
        </div>
    </li>
    <li class="divider hidden-xs"></li>
    <li>
        <div class="navbar-login navbar-login-session">
            <div class="row">
                <div class="col-lg-12">
                    <ul class="profile-links">
                        <li><a href="${cl.urlAppend(base: grailsApplication.config.getProperty('userDetails.url', String), path: 'my-profile')}" class="" target="_blank"><g:message code="action.viewProfile" /></a></li>
                        <li><a href="${g.createLink(controller: 'user', action: 'notebook')}" class=""><g:message code="action.notebook" /> <span class="hidden unread-count label label-danger label-as-badge"></span></a></li>
                        <li><a href="${g.createLink(uri: '/logout')}" class="">Logout</a></li>
                    </ul>
                </div>
            </div>
        </div>
    </li>
</ul>

