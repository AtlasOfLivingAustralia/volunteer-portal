package au.org.ala.volunteer

import au.org.ala.cas.util.AuthenticationCookieUtils
import com.google.gson.GsonBuilder
import grails.converters.JSON
import grails.util.Environment
import grails.util.Metadata
import groovy.time.TimeCategory
import groovy.xml.MarkupBuilder
import org.apache.commons.io.FileUtils
import org.grails.web.mapping.CachingLinkGenerator
import org.springframework.beans.factory.annotation.Value
import org.springframework.web.servlet.support.RequestDataValueProcessor

import java.text.SimpleDateFormat

class VolunteerTagLib {

    static namespace = 'cl'

    def userService
    def settingsService
    def multimediaService
    def markdownService
    def institutionService
    def authService
    def achievementService
    def taskService

    static returnObjectForTags = ['emailForUserId', 'displayNameForUserId', 'achievementBadgeBase', 'newAchievements', 'achievementsEnabled', 'buildDate', 'myProfileAlert', 'readStatusIcon', 'newAlert', 'formatFileSize']

    /**
     * @attr title The page title
     */
    def pageTitle = { attrs, body ->
        def appName = g.message(code: 'default.application.name').toString().toUpperCase()
        def pageName = attrs.title ?: 'Home'
        out << "$appName | $pageName"
    }

    def showCurrentUserName = {attrs, body ->
        out << userService.authService.displayName
    }

    def showCurrentUserEmail = {attrs, body ->
        out << userService.authService.email
    }

    def isLoggedIn = { attrs, body ->

        if (AuthenticationCookieUtils.cookieExists(request, AuthenticationCookieUtils.ALA_AUTH_COOKIE)) {
            out << body()
        }
    }

    def isNotLoggedIn = { attrs, body ->
        if (!AuthenticationCookieUtils.cookieExists(request, AuthenticationCookieUtils.ALA_AUTH_COOKIE)) {
            out << body()
        }
    }

    /**
     * @param project
     *
     */
    def ifValidator = {attrs, body ->
        Project p = attrs.project as Project
        if(p == null) {
            Task t = attrs.task as Task
            if(t!=null) {
                p = t.project
            }
        }
        if (userService.isValidator(p)) {
            out << body()
        }
    }

    def ifNotValidator = {attrs, body ->
        Project p = attrs.project as Project
        if (!userService.isValidator(p)) {
            out << body()
        }
    }

    def ifAdmin = {attrs, body ->
        if (isAdmin()) {
            out << body()
        }
    }

    /**
     * @attr institution The institution to test against
     */
    def ifInstitutionAdmin = { attrs, body ->
        if (isInstitutionAdmin(attrs.institution)) {
            out << body()
        }
    }

    private boolean isInstitutionAdmin(Institution institution) {
        return isAdmin() || userService.isInstitutionAdmin(institution)
    }

    private boolean isAdmin() {
        return grailsApplication.config.security.cas.bypass || userService.isSiteAdmin()
    }

    /**
     * @attr markdown defaults to true, will invoke the markdown service
     * @attr tooltipPosition (one of 'topLeft, 'topMiddle', 'topRight', 'bottomLeft', 'bottomMiddle', 'bottomRight')
     * @atrr tipPosition (one of 'topLeft, 'topMiddle', 'topRight', 'bottomLeft', 'bottomMiddle', 'bottomRight')
     * @attr targetPosition (one of 'topLeft, 'topMiddle', 'topRight', 'bottomLeft', 'bottomMiddle', 'bottomRight')
     * @attr width
     */
    def helpText = { attrs, body ->
        def mb = new MarkupBuilder(out)
        def helpText = (body() as String)?.trim()?.replaceAll("[\r\n]", "");
        if (helpText) {
            helpText = markdownService.markdown(helpText)
            def attributes = [href:'#', class:"btn btn-default btn-xs fieldHelp", title:helpText, tabindex: "-1"]
            if (attrs.tooltipPosition) {
                attributes.tooltipPosition = attrs.tooltipPosition
            }
            if (attrs.tipPosition) {
                attributes.tipPosition = attrs.tipPosition
            }
            if (attrs.targetPosition) {
                attributes.targetPosition = attrs.targetPosition
            }

            if (attrs.width) {
                attributes.width = attrs.width
            }

            if (attrs.customClass) {
                attributes.customClass = attrs.customClass;
            }

            mb.a(attributes) {
                span(class:'fa fa-question help-container') {
                    mkp.yieldUnescaped('')
                }
            }
        } else {
            mb.mkp.yieldUnescaped("&nbsp;")
        }
    }

    /**
     * @attr markdown defaults to true, will invoke the markdown service
     * @attr tooltipPosition (one of 'topLeft, 'topMiddle', 'topRight', 'bottomLeft', 'bottomMiddle', 'bottomRight')
     * @atrr tipPosition (one of 'topLeft, 'topMiddle', 'topRight', 'bottomLeft', 'bottomMiddle', 'bottomRight')
     * @attr targetPosition (one of 'topLeft, 'topMiddle', 'topRight', 'bottomLeft', 'bottomMiddle', 'bottomRight')
     */
    def ngHelpText = { attrs, body ->
        def mb = new MarkupBuilder(out)
        def helpText = (body() as String)?.trim()?.replaceAll("[\r\n]", "");
        if (helpText) {
            helpText = markdownService.markdown(helpText)
            def attributes = [href:'javascript:void(0)', class:'btn btn-default btn-xs fieldHelp', qtip:helpText, tabindex: "-1"]
            if (attrs.tooltipPosition) {
                attributes.qtipMy = attrs.tooltipPosition
            }
            if (attrs.tipPosition) {
                attributes.qtipAt = attrs.tipPosition
            }
            if (attrs.targetPosition) {
                attributes.targetPosition = attrs.targetPosition
            }

            if (attrs.classes) {
                attributes.'qtip-class' = attrs.classes;
            } else {
                attributes.'qtip-class' = 'qtip-bootstrap';
            }

            if (attrs.width) {
                attributes.width = attrs.width
            }

            mb.a(attributes) {
                i(class:'fa fa-question help-container') {
                    mkp.yieldUnescaped('')
                }
            }
        } else {
            mb.mkp.yieldUnescaped("&nbsp;")
        }
    }

    /**
     * Writes a para with date last updated.
     *
     * @param date
     */
    def lastUpdated = {attrs ->
        if (attrs.date) {
            out << "<p class='lastUpdated'>${message(code: 'volunteerTagLib.last_updated')} ${attrs.date}</p>"
        }
    }

    // Renders a nav bar as an unordered list
    /**
     *
     */
    //TODO This is hideous and it should disappear after applying the new skin
    def navbar = { attrs, body ->

        def selected = null;

        if (attrs.containsKey('selected')) {
            selected = attrs.selected as String;
        }

        def items = [:]

        items << [bvp:[link: createLink(uri: '/'), title: message(code:'default.application.name', default:'DigiVol')]]
        items << [expeditions: [link: createLink(controller: 'project', action: 'list'), title: message(code: 'volunteerTagLib.expeditions')]]
        def institutionsEnabled = settingsService.getSetting(SettingDefinition.InstitutionsEnabled)

        if (institutionsEnabled) {
            items << [institutions:[link: createLink(controller: 'institution', action:'list'), title: message(code: 'volunteerTagLib.institutions')]]
        }

        items << [tutorials: [link: createLink(controller: 'tutorials'), title: message(code: 'volunteerTagLib.tutorials')]]
        if (FrontPage.instance().enableForum) {
            items << [forum:[link: createLink(controller: 'forum'), title: message(code: 'volunteerTagLib.forum')]]
        }

        def dashboardEnabled = settingsService.getSetting(SettingDefinition.EnableMyNotebook)
        if (dashboardEnabled) {
            def isLoggedIn = AuthenticationCookieUtils.cookieExists(request, AuthenticationCookieUtils.ALA_AUTH_COOKIE)
            if (isLoggedIn || userService.currentUser) {
                items << [userDashboard: [link: createLink(controller:'user', action:'notebook'), title:message(code: 'volunteerTagLib.my_notebook')]]
            }
        }

        items << [contact: [link: createLink(controller: 'contact'), title: message(code: 'volunteerTagLib.contact_us')]]
        items << [getinvolved:[link: createLink(controller: 'getInvolved'), title:message(code: 'volunteerTagLib.how_can_i_volunteer')]]
        items << [aboutbvp: [link: createLink(controller: 'about'), title: "About ${message(code:'default.application.name')}"]]
        if (isAdmin()) {
            items << [bvpadmin: [link: createLink(controller: 'admin'), title: message(code: 'volunteerTagLib.admin'), icon:'icon-cog icon-white']]
        }

        def mb = new MarkupBuilder(out)
        mb.div(class:'navbar navbar-static-top', id:"nav-site") {
            div(class:'navbar-inner') {
                div(class:'container') {
                    div(class:'nav-collapse collapse') {
                        ul(class:'nav') {
                            for (def key : items.keySet()) {
                                def item = items[key]
                                mb.li(class:'nav-' + key + (selected == key ? ' active' : '')) {
                                    a(href:item.link, id: 'bvpmenuitem-' + key) {
                                        if (item.icon) {
                                            i(class: item.icon) {
                                                mkp.yieldUnescaped("&nbsp;")
                                            }
                                            mkp.yieldUnescaped("&nbsp;")
                                        }
                                        mkp.yield(item.title)
                                    }
                                }
                            }
                        }

                    }
                }
            }
        }

    }

    def messages = { attrs, body ->

        if (flash.message) {
            out << '<div class="alert alert-info" style="margin-top:10px">' + flash.message + '</div>'
        }

        if (flash.systemMessage) {
            out << '<div class="alert alert-error bvp-system-message" style="margin-top:10px">' + flash.systemMessage + '</div>'
        }
    }

    /**
     * @param task The task instance
     */
    def taskComments = { attrs, body ->

        if (!FrontPage.instance().enableTaskComments) {
            return ;
        }

        Task task = attrs.task;

        def mb = new MarkupBuilder(out)

        mb.table(style: 'width: 100%', class: "comment-control") {
            thead {
                tr {
                    th {
                        h3(message(code: 'volunteerTagLib.comments'), style: "padding-bottom: 0px;min-height: 0px")
                    }
                }
            }
            tbody {
                tr {
                    td {
                        div(class:"comments-content", id:"comments-content") {

                        }
                    }
                }
                if (userService.currentUserId) {
                    tr(class: 'prop', style: 'width: 100%; min-height: 0px') {
                        td(style: 'padding-bottom: 0px; padding-top: 0px;') {
                            span(message(code: 'volunteerTagLib.add_a_new_comment.description')) {}
                        }
                    }
                    tr(class:'prop',style: 'width: 100%') {
                        td(style: 'padding-top: 0px; padding-bottom: 0px;') {
                            textarea("", name:'comment_textarea', id:'comment_textarea', cols: '80', rows: '3', style:'width: 600px')
                        }
                    }
                    tr(class:'prop', style: 'width: 100%') {
                        td(class: 'name',style: "text-align: left; vertical-align: bottom; padding-top: 0px") {
                            button(id: 'addCommentButton', message(code: 'volunteerTagLib.save_comment'))
                        }
                    }
                }
            }
        }

        def script = """

            loadComments();

            \$('#addCommentButton').click(function(e) {
                e.preventDefault();
                saveComment();
            });

            function saveComment() {
                var comment  = \$('#comment_textarea').val();
                \$.ajax({url:"${createLink(action: 'saveComment', controller: 'taskComment', params: [taskId: task.id])}&comment=" + encodeURIComponent(comment), success: function(data) {
                    loadComments();
                    \$('#comment_textarea').val("");
                }});
            }

            function loadComments() {
                var urlbase = "${createLink(action: 'getCommentsAjax', controller: 'taskComment', params: [taskId: task.id])}"
                \$.ajax({url:urlbase, success: function(data) {
                    \$("#comments-content").html(data);
                }});
            }

            function deleteTaskComment(e, taskCommentId) {
                e.preventDefault();

                \$.ajax({url:"${createLink(action: 'deleteComment', controller: 'taskComment')}?commentId=" + taskCommentId, success: function(data) {
                    loadComments();
                }});
            }
        """
        mb.script() {
            mkp.yieldUnescaped(script)
        }

    }

    /**
     * @param task The task instance
     */
    def validationStatus = { attrs, body ->

        def taskInstance = attrs.task as Task

        if (taskInstance) {
            def validator = null;
            def transcriber = null;
            if (taskInstance.fullyValidatedBy) {
                validator = userService.detailsForUserId(taskInstance?.fullyValidatedBy)
            }

            if (taskInstance.fullyTranscribedBy) {
                transcriber = userService.detailsForUserId(taskInstance?.fullyTranscribedBy)
            }
            def mb = new MarkupBuilder(out)

            if (transcriber) {
                mb.span(class:"label label-info") {
                    mkp.yield(message(code: 'volunteerTagLib.transcribed_by_x_on_y', args: [transcriber.displayName, taskInstance.dateFullyTranscribed?.format("yyyy-MM-dd HH:mm:ss")]))
                }
            }

            if (validator) {
                def status = "Not yet validated"
                def badgeClass = "label"
                if (taskInstance.isValid == false) {
                    status = message(code: 'volunteerTagLib.marked_as_invalid_by_x_on_y', args: [validator.displayName, taskInstance?.dateFullyValidated?.format("yyyy-MM-dd HH:mm:ss")])
                    badgeClass = "label label-danger"
                } else if (taskInstance.isValid) {
                    status = message(code: 'volunteerTagLib.marked_as_valid_by_x_on_y', args: [validator.displayName, taskInstance?.dateFullyValidated?.format("yyyy-MM-dd HH:mm:ss")])
                    badgeClass = "label label-success"
                }
                mb.span(class:badgeClass) {
                    mkp.yield(status)
                }
            }

        }
    }

    /**
     * @attr userId User id
     */
    def userDisplayName = { attrs, body ->
        if (attrs.userId) {
            def user = userService.detailsForUserId(attrs.userId)
            def mb = new MarkupBuilder(out)
            mb.span(class:'userDisplayName') {
                if (user) {
                    mkp.yield(user.displayName)
                } else {
                    mkp.yield(attrs.userId)
                }
            }
        }
    }

    /**
     * @attr title //REQUIRED
     * @attr selectedNavItem
     * @attr crumbLabel
     * @attr hideTitle
     * @attr hideCrumbs
     * @attr complexBodyMarkup
     */
    def headerContent = { attrs, body ->

        def mb = new MarkupBuilder(out)
        def bodyContent = body.call()
        def crumbLabel = attrs.crumbLabel ?: attrs.title ?: ""

        if (attrs.selectedNavItem) {
            sitemesh.parameter(name: 'selectedNavItem', value: attrs.selectedNavItem)
        }

        sitemesh.captureContent(tag:'page-header') {

            def crumbList = []
            def keyIndex = 1

            if (pageScope.crumbs) {
                crumbList = pageScope.crumbs
            } else {
                Map crumb
                while (crumb = attrs.getAt("breadcrumb${keyIndex++}")) {
                    crumbList << crumb
                }
            }

            if (!attrs.hideCrumbs) {
                mb.ul(class: 'breadcrumb-list') {
                    li {
                        a(href:createLink(uri:'/')) {
                            mkp.yield(message(code:'default.home.label'))
                        }
                    }
                    if (crumbList) {
                        for (int i = 0; i < crumbList?.size(); i++) {
                            def item = crumbList[i]
                            li {
                                span(class:'glyphicon glyphicon-menu-right') {
                                    mkp.yield(' ')
                                }
                                if(item && item.link != null && item.label != null && item.label?.toString() != null) {
                                    a(href: item.link) {
                                        mkp.yield(item.label)
                                    }
                                }
                            }
                        }
                    }
                    li(class:'active') {
                        span(class:'glyphicon glyphicon-menu-right') {
                            mkp.yield(' ')
                        }
                        mkp.yield(crumbLabel)
                    }
                }

            }


        }

        sitemesh.captureContent(tag:'page-title') {
            def heading = ""
            if (!attrs.hideTitle) {
                heading = attrs.title
            }

            if (attrs.complexBodyMarkup) {
                mb.mkp.yieldUnescaped(bodyContent)
            } else {
                mb.div(class:"row") {
                    div(class:"col-sm-10") {
                        if (heading) {
                            mb.h1(class:'bvp-heading') {
                                mkp.yield(attrs.title)
                            }
                        }
                        mb.mkp.yieldUnescaped(bodyContent)
                    }
                }
            }
        }
    }

    def readStatusIcon = { attrs, body ->
        def unReadList = taskService.getUnreadValidatedTasks(attrs.project, userService.currentUser?.userId)
        if (attrs.taskId in (unReadList)) {
            out << '<span class="glyphicon glyphicon-envelope"  style="color:#000192"></span>'
        } else {
            out << '<span class="glyphicon glyphicon-ok"></span>'
        }
    }

    def spinner = { attrs, body ->
        out << '<i class="fa fa-cog fa-spin fa-2x"></i>'
    }

    def sequenceThumbnail = { attrs, body ->
        def project = attrs.project
        def seq = attrs.seqNo as String
        def task = taskService.findByProjectAndFieldValue(project, "sequenceNumber", seq)
        if (task) {
            def url, fullUrl = ''
            def mm = task.multimedia?.first()
            if (mm) {
                url = multimediaService.getImageThumbnailUrl(mm)
                fullUrl = multimediaService.getImageUrl(mm)
            }

            if (!url) {
                // sample
                url = resource(file:'/sample-task-thumbnail.jpg')
            }
            if (!fullUrl) {
                fullUrl = resource(file: '/sample-task.jpg')
            }

            if (url) {
                out << "<img src=\"${url}\" data-full-src=\"$fullUrl\"/>"
                out << "<img class=\"hidden\" src=\"$fullUrl\"/>"
            }
        }
    }

    def taskThumbnail = { attrs, body ->
        def task = attrs.task as Task
        def fixedHeight = attrs.fixedHeight
        def withHidden = attrs.withHidden

        if (fixedHeight == null) fixedHeight = true
        if (withHidden == null) withHidden = false

        if (task) {
            def url = "", fullUrl = ''
            final Multimedia mm = task.multimedia?.first()
            if (mm != null) {
                url = multimediaService.getImageThumbnailUrl(mm)
                fullUrl = multimediaService.getImageUrl(mm)
            }

            if (!url) {
                // sample
                url = resource(file:'/sample-task-thumbnail.jpg')
            }
            if (!fullUrl) {
                fullUrl = resource(file: '/sample-task.jpg')
            }

            if (url) {
                out << "<img src=\"${url}\" data-full-src=\"$fullUrl\"${fixedHeight ? ' style="height:100px"' : ''} />"
                if (withHidden) out << "<img class=\"hidden\" src=\"$fullUrl\"/>"
            }

        }
    }

    /**
     * @attr startTime
     * @attr endTime
     */
    def timeAgo = { attrs, body ->
        def s = attrs.startTime as Date
        def e = attrs.endTime as Date
        use(TimeCategory) {
            out << "${(e - s)} ago"
        }
    }

    def navSeperator = { attrs, body ->
        out << "&nbsp;&#187;&nbsp;"
    }

    /**
     * @attr active
     * @attr title
     * @attr href
     */
    def settingsMenuItem = { attrs, body ->
        def active = attrs.active
        if (!active) {
            active = attrs.title
        }
        def current = pageProperty(name:'page.pageTitle')?.toString()

        def mb = new MarkupBuilder(out)
        mb.li(class: "list-group-item ${active == current ? 'active' : ''}") {
            a(href:attrs.href) {
                i(class:'fa fa-chevron-right') { mkp.yieldUnescaped('&nbsp;')}
                mkp.yield(attrs.title)
            }
        }
    }

    /**
     * @attr value the object to convert to JSON
     */
    def json = { attrs, body ->
        final val = (attrs.value as JSON) ?: "null"
        out << val
    }

    /**
     * @id The id of the institution
     */
    def institutionImageUrl = { attrs, body ->
        out << institutionService.getImageUrl(Institution.get(attrs.id as Long))
    }


    /**
     * @id The id of the institution
     */
    def institutionBannerUrl = { attrs, body ->
        out << institutionService.getBannerImageUrl(Institution.get(attrs.id as Long))
    }

    /**
     * @id The id of the institution
     */
    def institutionLogoUrl = { attrs, body ->
        out << institutionService.getLogoImageUrl(Institution.get(attrs.id as Long))
    }

    /**
     * @attr institution
     */
    def ifInstitutionHasLogo = { attrs, body ->
        def institutionInstance = attrs.institution as Institution
        if (institutionService.hasLogoImage(institutionInstance)) {
            out << body()
        }
    }

    /**
     *
     */
    def achievementBadgeBase = { attrs, body ->
        achievementService.badgeImageUrlPrefix
    }

    /**
     * @achievement The AchievementDescription
     * @id The id of the institution
     */
    def achievementBadgeUrl = { attrs, body ->
        def achievementDesc = attrs.achievement ?: AchievementDescription.get(attrs.id as Long)
        out << achievementService.getBadgeImageUrl(achievementDesc)
    }

    /**
     * @attr achievementDescription
     */
    def ifAchievementHasBadge = { attrs, body ->
        def achievementDescription = attrs.achievementDescription as AchievementDescription
        if (!achievementDescription) {
            def id = (attrs.achievementDescription ?: attrs.id) as Long
            achievementDescription = AchievementDescription.get(id)
        }
        if (achievementService.hasBadgeImage(achievementDescription)) {
            out << body()
        }
    }

    /**
     * @attr email
     * @atte i18nName
     */
    def contactLink = { attrs, body ->
        def name = attrs.name ?: attrs.email
        def email = attrs.email
        def mb = new MarkupBuilder(out)
        if (name && email) {
            mb.a(href: "mailto:${email}") {
                mkp.yield(name)
            }
        } else if (name) {
            out << name
        }
    }

    /**
     * Gets the email address for a user as an object instead of writing it directly to the outputstream
     *
     * @attr id REQUIRED The userId to get the email address for
     */
    def emailForUserId = { attrs, body ->
        propForUserId(attrs, 'email')
    }

    /**
     * Gets the display i18nName for a user as an object instead of writing it directly to the outputstream
     *
     * @attr id REQUIRED The userId to get the display i18nName address for
     */
    def displayNameForUserId = { attrs, body ->
        propForUserId(attrs, 'displayName')
    }

    private def propForUserId(def attrs, String prop) {
        def id = attrs.remove('id')

        userService.propertyForUserId(id, prop)
    }

    /**
     * Output a users email or display i18nName, fetched from userdetails.
     *
     * @attr id REQUIRED The user id to get the user details for
     * @attr displayName true to output the display i18nName, defaults to false
     * @attr email true to output the email address, defaults to false
     */
    def userDetails = { attrs, body ->
        def id = attrs.remove('id')
        def displayName = attrs.remove('displayName')?.asBoolean() ?: false
        def email = attrs.remove('email')?.asBoolean() ?: false


        if (displayName && email) {
            log.error("Both display name and email specified, select only one!")
            throw new RuntimeException(message(code: 'volunteerTagLib.both_display_name_and_email_specified'))
        }

        def user = userService.detailsForUserId(id)
        if (user) {
            out << (email ? user.email : displayName ? user.displayName : 'NEITHER_EMAIL_OR_DISPLAY_NAME_SPECIFIED').encodeAsHTML()
        } else {
            out << 'FAILED_TO_FIND_USER' // TODO Change this before commit
        }
    }

    /**
     * Output a users display i18nName and email, fetched from userdetails unless it's unavailable.  If the user can't
     * be found a not found string is used instead.  The not found string can optionally be wrapped in a
     * &lt;span class="muted" /> if the muted attribute is set to true
     *
     * @attr id REQUIRED The user id to get the user details for
     * @attr notFound value to use if the user is not found
     * @attr muted set to true to wrap not found value in <span class='muted'>
     */
    def userDisplayString = { attrs, body ->
        def id = attrs.remove('id')
        def notFound = attrs.remove('notFound')
        def muted = attrs.remove('muted')?.asBoolean()

        def user
        if (id) user = userService.detailsForUserId(id)
        else user = null

        if (user) {
            out << "${user.displayName.encodeAsHTML()} (${user.email.encodeAsHTML()})"
        } else if (muted) {
            out << "<span class='muted'>${notFound ?: id}</span>"
        } else {
            out << notFound ?: id
        }
    }


    /**
     * Output the meta tags (HTML head section) for the build meta data in application.properties
     * E.g.
     * <meta i18nName="svn.revision" content="${g.meta(i18nName:'svn.revision')}"/>
     * etc.
     *
     * Updated to use properties provided by build-info plugin
     */
    def addApplicationMetaTags = { attrs ->
        def metaList = [
                'app.version', 
                'app.grailsVersion',
                'build.ci',
                'build.date', 
                'build.jdk', 
                'build.number', 
                'git.branch', 
                'git.commit',
                'git.slug', 
                'git.tag', 
                'git.timestamp'
        ]
        def mb = new MarkupBuilder(out)

        mb.meta(name:'grails.env', content: "${Environment.current}")
        metaList.each {
            def content = g.meta(name: 'info.' + it)
            if (content) {
                mb.meta(name:it, content: content)
            } else {
                log.debug("info.$it not found in meta info")
            }
        }
        mb.meta(name:'java.version', content: "${System.getProperty('java.version')}")
    }

    /**
     * Gets the list of new achievements for the current user
     */
    def newAchievements = { attrs ->
        if (settingsService.getSetting(SettingDefinition.EnableMyNotebook) && settingsService.getSetting(SettingDefinition.EnableAchievementCalculations)) {
            achievementService.newAchievementsForUser(userService.currentUser)
        } else {
            []
        }
    }

    /**
     * Returns true if achievements are enabled, false otherwise
     */
    def achievementsEnabled = { attrs ->
        settingsService.getSetting(SettingDefinition.EnableMyNotebook) && settingsService.getSetting(SettingDefinition.EnableAchievementCalculations)
    }

    def buildDate = { attrs ->
        def bd = Metadata.current['info.build.date']
        log.debug("Build Date type is ${bd?.class?.name}")
        def df = new SimpleDateFormat('MMM d, yyyy')
        if (bd) {
            try {
                df.format(new SimpleDateFormat('EEE MMM dd HH:mm:ss zzz yyyy').parse(bd))
            } catch (e) {
                df.format(new Date())
            }
        } else {
            df.format(new Date())
        }
    }

    /**
     * Truncate text at maxlength with ellipse symbol
     *
     * @attr maxlength REQUIRED
     * @attr ellipse
     */
    def truncate = { attrs, body ->
        final ELLIPSIS = attrs.ellipse ?: '…'
        def maxLength = attrs.maxlength
        final bodyText = body().replaceAll("<[^>]*>", '') // strip out html tags

        if (maxLength == null || !maxLength.isInteger() || maxLength.toInteger() <= 0) {
            throw new Exception("The attribute 'maxlength' must an integer greater than 3. Provided value: $maxLength")
        } else {
            maxLength = maxLength.toInteger()
        }
        if (maxLength <= ELLIPSIS.size()) {
            throw new Exception("The attribute 'maxlength' must be greater than 3. Provided value: $maxLength")
        }
        if (bodyText.length() > maxLength) {
            out << bodyText[0..maxLength - (ELLIPSIS.size() + 1)] + ELLIPSIS
        } else {
            out << bodyText
        }
    }

    /**
     * Taken from http://stackoverflow.com/a/7427266/249327
     *
     * Attr hex REQUIRED
     */
    def hexToRbg = { attrs, body ->
        String hex = attrs.hex
        String color = Integer.valueOf( hex.substring( 1, 3 ), 16 ) + "," +
                Integer.valueOf( hex.substring( 3, 5 ), 16 ) + "," +
                Integer.valueOf( hex.substring( 5, 7 ), 16 )
        out << color
    }

    def gson = new GsonBuilder().create()

    def analyticsTrackers = { attrs, body ->
        def trackers = grailsApplication.config.digivol.trackers ?: []
        switch (trackers) {
            case String:
                trackers = ((String)trackers).split(',')*.trim()
        }
        out << gson.toJson(trackers)
    }

    Closure formatFileSize = { attrs, body ->
        def size = attrs.remove('size')
        return FileUtils.byteCountToDisplaySize(size)
    }

    /**
     * Display text describing who created the project and the date it was created on.
     * parameters
     * project - required - project instance
     */
    def projectCreatedBy = { attrs, body ->
        Project project = attrs.project
        User user = project.createdBy

        if(user){
            String date = g.formatDate(date:project.dateCreated, format: "dd MMMM, yyyy")
            out << ("<small>" + message(code:'project.project_settings.created_by', args: [(createLink(controller: 'user', action: 'show')+"/"+user?.id),user?.displayName])+" "+message(code:'project.project_settings.on')+" ${date}.</small>")
        }
    }

    def insitutionLogos = { attrs, body ->
        def logos = settingsService.getSetting(SettingDefinition.FrontPageLogos)
        logos.each {
            out << "<img src=\"${grailsApplication.config.server.url}/${grailsApplication.config.images.urlPrefix}/logos/$it\">"
        }
    }

    @Value('${google.maps.key}')
    String mapsApiKey

    /**
     * Insert a script tag for the google maps api using the google.maps.key property if one
     * is set.
     * @attr callback The callback function to use
     */
    def googleMapsScript = { attrs, body ->
        if ( attrs.containsKey('if') && !attrs.remove('if') ) return
        def url = "https://maps.googleapis.com/maps/api/js"
        def opts = [:]
        def callback = attrs.remove('callback')
        if (callback) {
            opts['callback'] = callback
        }
        if (mapsApiKey) {
            opts['key'] = mapsApiKey
        } else {
            log.warn("No google.maps.key config settings was found.")
        }
        if(org.springframework.context.i18n.LocaleContextHolder.getLocale()) {
            opts['language'] = org.springframework.context.i18n.LocaleContextHolder.getLocale().getLanguage();
        }

        if (opts) {
            url += "?" + opts.collect { "$it.key=${URLEncoder.encode(it.value, 'UTF-8')}" }.join("&")
        }
        asset.script(type: 'text/javascript', src: url, async: true, defer: true)
        asset.script(type: 'text/javascript') {'''
var gmapsReady = false;
function onGmapsReady() {
    gmapsReady = true;
    notify();
}
function notify() {
    if (typeof $ != 'undefined') {
        $(window).trigger('digivol.gmapsReady');
    } else {
        window.setTimeout(notify);
    }
}
'''
        }
    }

    def googleChartsScript = { attrs, body ->
        out << '<script type="text/javascript" src="https://www.google.com/jsapi"></script>'
    }

}