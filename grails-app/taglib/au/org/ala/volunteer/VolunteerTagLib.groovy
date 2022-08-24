package au.org.ala.volunteer

import au.org.ala.cas.util.AuthenticationCookieUtils
import com.google.common.base.Stopwatch
import com.google.gson.GsonBuilder
import grails.converters.JSON
import grails.util.Environment
import grails.util.Metadata
import groovy.time.TimeCategory
import groovy.xml.MarkupBuilder
import org.apache.commons.io.FileUtils
import org.apache.http.client.utils.URIBuilder
import org.grails.web.util.GrailsApplicationAttributes
import org.springframework.beans.factory.annotation.Value
import org.springframework.web.context.request.RequestAttributes
import org.springframework.web.context.request.RequestContextHolder

import java.text.SimpleDateFormat

class VolunteerTagLib {

    static namespace = 'cl'

    def userService
    def settingsService
    def multimediaService
    def markdownService
    def institutionService
    def achievementService
    def taskService
    def adminService
    def templateService
    def projectService

    static returnObjectForTags = ['emailForUserId', 'displayNameForUserId', 'achievementBadgeBase', 'newAchievements', 'achievementsEnabled', 'buildDate', 'myProfileAlert', 'readStatusIcon', 'newAlert', 'formatFileSize', 'createLoginLink']

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

    def urlAppend = {attrs, body ->
        def base = attrs.remove('base')?.toString() ?: ''
        def path = attrs.remove('path')?.toString() ?: ''
        out << (base?.endsWith('/') ? base + path : base + '/' + path)
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
    * Build navigation links to the custom landing page
    */
    def showLandingPage = {attrs, body ->
        def numberOfCustomLinksAtTopPage = grailsApplication.config.numberOfCustomLinksAtTopPage ?: 1

        List<LandingPage> landingPages = adminService.getCustomLandingPageSettings ()
        def mb = new MarkupBuilder(out)
        def buildLandingPage = {
            landingPages.each {
                if (it) {
                    def shortUrl = it.shortUrl //it.id
                    def title = it.title

                    mb.li(class: '') {
                        a(href: createLink(mapping: 'landingPage', params: [shortUrl: shortUrl])) {
                            mkp.yield(title)
                        }
                    }

                }
            }
        }
        if (landingPages.size() > numberOfCustomLinksAtTopPage) {
            mb.li(class: "dropdown") {
                a([href: "#", class:"dropdown-toggle", 'data-toggle': "dropdown"]) {
                    span(class: 'glyphicon glyphicon-camera') {
                        mkp.yield("")
                    }
                    mkp.yield(' Camera Traps')
                    span(class: "glyphicon glyphicon-chevron-down")
                }
                mb.ul(class: 'dropdown-menu profile-links') {
                    buildLandingPage()
                }
            }
        } else {
            buildLandingPage()
        }

    }

    /**
     * @param project
     *
     */
    def ifValidator = {attrs, body ->
        Project p = attrs.project as Project
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

    /**
     * Prints the contents if the user is a Site Admin OR an Institution Admin
     */
    def ifAdmin = {attrs, body ->
        if (isAdmin()) {
            out << body()
        }
    }

    /**
     * Prints the contents if the user is a Site Admin
     */
    def ifSiteAdmin = {attrs, body ->
        if (isSiteAdmin()) {
            out << body()
        }
    }

    def ifNotSiteAdmin = {attrs, body ->
        if (!isSiteAdmin()) {
            out << body()
        }
    }

    /**
     * @attr institution The institution to test against
     */
    def ifInstitutionAdmin = { attrs, body ->
        if (isSiteAdmin()) {
            out << body()
        } else if (attrs.institution && isInstitutionAdmin(attrs.institution as Institution)) {
            out << body()
        } else if (attrs.project) {
            Project p = attrs.project as Project
            if (isInstitutionAdmin(p.institution)) {
                out << body()
            }
        }
    }

    /**
     * Displays a button for use with templates. It checks if the user has access to edit the template passed in
     * the parameters and displays an active or disabled button depending on the permission returned.
     * Required attributes:
     * @attr template the template instance
     * @attr styleClass the CSS class to add to the button
     * @attr id the HTML ID of the element
     * @attr label the button label
     */
    def templateEditableButton = {attrs, body ->
        def editAllowed = false
        if (isSiteAdmin()) {
            editAllowed = true
        } else if (attrs.template) {
            def templatePermissions = templateService.getTemplatePermissions(attrs.template)
            if (templatePermissions.canEdit) {
                editAllowed = true
            }
        }

        if (editAllowed) {
            out << "<button class=\"${attrs.styleClass}\" id=\"${attrs.id}\">${attrs.label}</button>"
        } else {
            out << "<button class=\"${attrs.styleClass}\" style=\\\"pointer-events: auto;\\\" id=\"${attrs.id}\" " +
                    "title=\"${message(code:'template.edit.button.nopermission', default:'Not allowed')}\" disabled>${attrs.label}</button>"
        }
    }

    /**
     * @attr project The Project.
     */
    def hasProjectBackgroundImage = {attrs, body ->
        String bgImagePath = projectService.getBackgroundImage(attrs.project as Project)
        if (bgImagePath) {
            out << body()
        }
    }

    def hasNoProjectBackgroundImage = { attrs, body ->
        String bgImagePath = projectService.getBackgroundImage(attrs.project as Project)
        if (!bgImagePath) {
            out << body()
        }
    }

    def backgroundImageUrl = { attrs, body ->
        out << projectService.getBackgroundImage(attrs.project as Project)
    }

    /**
     * Creates an image element from the background image of a project
     * @attr project The project
     * @attr class Any CSS class to add to the element
     * @attr style Any custom CSS style to add to the element
     */
    def backgroundImage = { attrs, body ->
        def backgroundImageUrl = projectService.getBackgroundImage(attrs.project as Project)
        def cssClass = attrs.remove("class")
        def style = attrs.remove("style")

        out << "<img src="
        out << backgroundImageUrl
        if (cssClass) out << " class=\"${cssClass.encodeAsHTML()}\""
        if (style) out << " style=\"${style.encodeAsHTML()}\""
        out << " />"
    }

    /**
     * Creates an image element from the featured image of a project.
     * @attr project The Project
     * @attr class Any CSS class to add to the element
     * @attr style Any custom style added to the element
     * @attr dataErrorUrl A URL to an image if no featured image can be found.
     * @attr width The image width
     * @attr height The image height
     * @attr alt The alt text for the image
     * @attr title The title for the image
     * @attr preLoad if true, allows for pre-load and resizing (jquery plugin)
     */
    def featuredImage = { attrs, body ->
        def featuredImageUrl = projectService.getFeaturedImage(attrs.project as Project)
        def cssClass = attrs.remove("class")
        def style = attrs.remove("style")
        def dataErrorUrl = attrs.remove("data-error-url")
        def width = attrs.remove("width")
        def height = attrs.remove("height")
        def alt = attrs.remove("alt")
        def title = attrs.remove("title")
        def preLoad = "true".equalsIgnoreCase(attrs.remove("preLoad") as String)

        out << "<img "
        if (preLoad) out << "src=\"\" realsrc="
        else out << "src="
        out << featuredImageUrl
        if (cssClass) out << " class=\"${cssClass.encodeAsHTML()}\""
        if (style) out << " style=\"${style.encodeAsHTML()}\""
        if (dataErrorUrl) out << " data-error-url=\"${dataErrorUrl.encodeAsHTML()}\""
        if (width) out << " width=\"${width.encodeAsHTML()}\""
        if (height) out << " height=\"${height.encodeAsHTML()}\""
        if (alt) out << " alt=\"${alt.encodeAsHTML()}\""
        if (title) out << " title=\"${title.encodeAsHTML()}\""
        out << " />"
    }

    private boolean isInstitutionAdmin(Institution institution) {
        //return isAdmin() || userService.isInstitutionAdmin(institution)
        return userService.isInstitutionAdmin(institution)
    }

    private boolean isSiteAdmin() {
        return grailsApplication.config.security.cas.bypass || userService.isSiteAdmin()
    }

    private boolean isAdmin() {
        return grailsApplication.config.security.cas.bypass || userService.isSiteAdmin() || userService.isInstitutionAdmin()
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
        def helpText = (body() as String)?.trim()?.replaceAll("[\r\n]", "")
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
                attributes.customClass = attrs.customClass
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
        def helpText = (body() as String)?.trim()?.replaceAll("[\r\n]", "")
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
                attributes.'qtip-class' = attrs.classes
            } else {
                attributes.'qtip-class' = 'qtip-bootstrap'
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
            out << "<p class='lastUpdated'>last updated: ${attrs.date}</p>"
        }
    }

    // Renders a nav bar as an unordered list
    /**
     *
     */
    //TODO This is hideous and it should disappear after applying the new skin
    def navbar = { attrs, body ->

        def selected = null

        if (attrs.containsKey('selected')) {
            selected = attrs.selected as String
        }

        def items = [:]

        items << [bvp:[link: createLink(uri: '/'), title: message(code:'default.application.name', default:'DigiVol')]]
        items << [expeditions: [link: createLink(controller: 'project', action: 'list'), title: 'Expeditions']]
        def institutionsEnabled = settingsService.getSetting(SettingDefinition.InstitutionsEnabled)

        if (institutionsEnabled) {
            items << [institutions:[link: createLink(controller: 'institution', action:'list'), title: 'Institutions']]
        }

        items << [tutorials: [link: createLink(controller: 'tutorials'), title: 'Tutorials']]
        if (FrontPage.instance().enableForum) {
            items << [forum:[link: createLink(controller: 'forum'), title: 'Forum']]
        }

        def dashboardEnabled = settingsService.getSetting(SettingDefinition.EnableMyNotebook)
        if (dashboardEnabled) {
            def isLoggedIn = AuthenticationCookieUtils.cookieExists(request, AuthenticationCookieUtils.ALA_AUTH_COOKIE)
            if (isLoggedIn || userService.currentUser) {
                items << [userDashboard: [link: createLink(controller:'user', action:'notebook'), title:"My Notebook"]]
            }
        }

        items << [contact: [link: createLink(controller: 'contact'), title: 'Contact Us']]
        items << [getinvolved:[link: createLink(controller: 'getInvolved'), title:"How can I volunteer?"]]
        items << [aboutbvp: [link: createLink(controller: 'about'), title: "About ${message(code:'default.application.name')}"]]
        if (isAdmin()) {
            items << [bvpadmin: [link: createLink(controller: 'admin'), title: "Admin", icon:'icon-cog icon-white']]
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
    def validationStatus = { attrs, body ->

        def taskInstance = attrs.task as Task

        if (taskInstance) {
            def validator = null
            List transcribers = []
            if (taskInstance.fullyValidatedBy) {
                validator = userService.detailsForUserId(taskInstance?.fullyValidatedBy)
            }

            if (taskInstance.isFullyTranscribed) {
                taskInstance.transcriptions.each {
                    if (it.dateFullyTranscribed) {
                        transcribers << [user:userService.detailsForUserId(it.fullyTranscribedBy), dateFullyTranscribed: it.dateFullyTranscribed]
                    }
                }
            }
            def mb = new MarkupBuilder(out)

            transcribers.each { transcriber ->
                mb.span(class:"label label-info") {
                    mkp.yield("Transcribed by ${transcriber.user?.displayName} on ${transcriber.dateFullyTranscribed?.format("yyyy-MM-dd HH:mm:ss")}")
                }
            }

            if (validator) {
                def status = "Not yet validated"
                def badgeClass = "label"
                if (!taskInstance.isValid) {
                    status = "Partially validated by ${validator.displayName} on ${taskInstance?.dateFullyValidated?.format("yyyy-MM-dd HH:mm:ss")}"
                    badgeClass = "label label-warning"
                } else if (taskInstance.isValid) {
                    status = "Validated by ${validator.displayName} on ${taskInstance?.dateFullyValidated?.format("yyyy-MM-dd HH:mm:ss")}"
                    badgeClass = "label label-success"
                }
                mb.span(class:badgeClass) {
                    mkp.yield(status)
                }
            }

        }
    }

    def transcribers = { attrs ->
        def taskInstance = attrs.task as Task
        taskInstance.attach()

        int transcribedCount = 0
        taskInstance?.transcriptions?.each { transcription ->
            if (transcription.dateFullyTranscribed) {
                out << "<p>"
                out << "${transcription.dateFullyTranscribed?.format("yyyy-MM-dd HH:mm:ss")} by "
                out << "${cl.displayNameForUserId(id: transcription.fullyTranscribedBy) ?: '<span class=\"muted\">unknown</span>'}"
                out << "</p>"
                transcribedCount++
            }
        }
        if (transcribedCount == 0) {
            out << "<span class=\"muted\">Not transcribed</span>"
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
                                a(href: item.link) {
                                    mkp.yield(item.label)
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
            attrs.task = task
            out << multimediaThumbnail(attrs, body)
        }
    }

    def multimediaThumbnail = { attrs, body ->
        Stopwatch sw = Stopwatch.createStarted()
        def url, fullUrl = ''
//        def mm = attrs.task.multimedia?.first()
        def mm = attrs.multimedia
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
        log.debug('multimediaThumbnail {}', sw)
    }

    def taskThumbnail = { attrs, body ->
        Stopwatch sw = Stopwatch.createStarted()
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

            if (task.project.projectType.name == ProjectType.PROJECT_TYPE_AUDIO) {
                url = resource(file:'/icons-audio-52.png')
            }

            if (!url) {
                // sample
                url = resource(file:'/sample-task-thumbnail.jpg')
            }
            if (!fullUrl) {
                fullUrl = resource(file: '/sample-task.jpg')
            }

            if (url && task.project.projectType.name != ProjectType.PROJECT_TYPE_AUDIO) {
                out << "<img src=\"${url}\" data-full-src=\"$fullUrl\"${fixedHeight ? ' style="height:100px"' : ''} />"
                if (withHidden) out << "<img class=\"hidden\" src=\"$fullUrl\"/>"
            } else {
                out << "<img src=\"${url}\" data-full-src=\"$fullUrl\" />"
                if (withHidden) out << "<img class=\"hidden\" src=\"$fullUrl\"/>"
            }

        }
        log.debug('taskThumbnail {}', sw)
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

    def imageUrlPrefix = { attrs, body ->
        def name = attrs.remove('name')
        def type = attrs.remove('type')
        if (name) {
            out << "${grailsApplication.config.server.url}/${grailsApplication.config.images.urlPrefix}/${type}/$name"
        } else {
            out << "${grailsApplication.config.server.url}/${grailsApplication.config.images.urlPrefix}/${type}"
        }
    }

    def sizedImage = { attrs, body ->
        def title = attrs.remove('title')
        def alt = attrs.remove('alt')
        def cssClass = attrs.remove('class')
        out << "<img src="
        out << sizedImageUrl(attrs, body)
        if (cssClass) {
            out << " class=\"${cssClass.encodeAsHTML()}\""
        }
        if (title) {
            out << " title=\"${title.encodeAsHTML()}\""
        }
        if (alt) {
            out << " alt=\"${alt.encodeAsHTML()}\""
        }
        out << "/>"
    }

    def audioSample = { attrs, body ->
        def linkText = attrs.remove('linkText')
        out << "<a href="
        out << audioUrl(attrs, body)
        out << " aria-label=\"Audio sample\" class=\"sm2_link\">"
        if (linkText) {
            out << linkText
        }
        out << "</a>"
    }

    def sizedImageUrl = { attrs, body ->
        def prefix = attrs.remove('prefix')
        def name = attrs.remove('name')
        def width = attrs.remove('width')
        def height = attrs.remove('height')
        def format = attrs.remove('format') ?: 'jpg'
        def template = attrs.remove('template')?.toBoolean()
        String url = g.createLink(controller: 'image', action: 'size', params: [prefix: prefix, width: width, height: height, name: name, format: format])
        out << (template ? url.replace('%7B', '{').replace('%7D','}') : url)
    }

    def audioUrl = { attrs, body ->
        def prefix = attrs.remove('prefix')
        def name = attrs.remove('name')
        def format = attrs.remove('format') ?: 'wav'
        def template = attrs.remove('template')?.toBoolean()
        String url = g.createLink(controller: 'image', action: 'audioFile', params: [prefix: prefix, name: name, format: format])
        out << (template ? url.replace('%7B', '{').replace('%7D','}') : url)
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
     * @atte name
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
     * Gets the display name for a user as an object instead of writing it directly to the outputstream
     *
     * @attr id REQUIRED The userId to get the display name address for
     */
    def displayNameForUserId = { attrs, body ->
        propForUserId(attrs, 'displayName')
    }

    private def propForUserId(def attrs, String prop) {
        def id = attrs.remove('id')

        userService.propertyForUserId(id, prop)
    }

    /**
     * Output a users email or display name, fetched from userdetails.
     *
     * @attr id REQUIRED The user id to get the user details for
     * @attr displayName true to output the display name, defaults to false
     * @attr email true to output the email address, defaults to false
     */
    def userDetails = { attrs, body ->
        def id = attrs.remove('id')
        def displayName = attrs.remove('displayName')?.asBoolean() ?: false
        def email = attrs.remove('email')?.asBoolean() ?: false


        if (displayName && email) {
            log.error("Both display name and email specified, select only one!")
            throw new RuntimeException("Both display name and email specified, select only one!")
        }

        def user = userService.detailsForUserId(id)
        if (user) {
            out << (email ? user.email : displayName ? user.displayName : 'NEITHER_EMAIL_OR_DISPLAY_NAME_SPECIFIED').encodeAsHTML()
        } else {
            out << 'FAILED_TO_FIND_USER' // TODO Change this before commit
        }
    }

    /**
     * Output a users display name and email, fetched from userdetails unless it's unavailable.  If the user can't
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
            out << "${user.displayName.encodeAsHTML()}"
        } else if (muted) {
            out << "<span class='muted'>${notFound ?: id}</span>"
        } else {
            out << notFound ?: id
        }
    }


    /**
     * Output the meta tags (HTML head section) for the build meta data in application.properties
     * E.g.
     * <meta name="svn.revision" content="${g.meta(name:'svn.revision')}"/>
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
            } catch (Exception ignored) {
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
        def size = attrs.remove('size') as long
        return PrettySize.toPrettySize(size)
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
            out << "<small>Created by <a href=\"${createLink(controller: 'user', action: 'show',)}/${user?.id}\">${user?.displayName}</a> on ${date}.</small>"
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

        if (opts) {
            url += "?" + opts.collect { "${URLEncoder.encode(it.key, 'UTF-8')}=${URLEncoder.encode(it.value, 'UTF-8')}" }.join("&")
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


    def loginLink = { attrs, body ->
        def mb = new MarkupBuilder(out)
        mb.a([href: createLoginLink(attrs,body)] + attrs) {
            mkp.yieldUnescaped(body())
        }
    }

    /**
     * @emptyTag
     */
    def createLoginLink = { attrs ->
        def link = new URIBuilder(grailsApplication.config.security.cas.loginUrl).addParameter("service", g.createLink(uri: '/', absolute: true)).build().toString()
        return link
    }

    /**
     * Renders a list of the users who have transcribed a Task.  Each user is rendered as a link that goes to
     * the user page.
     *
     * Used in the _taskListTable gsp.
     */
    def transcriberNames = { attrs ->

        def taskInstance = attrs.task as Task
        Set transcribers = new HashSet()
        if (taskInstance) {
            taskInstance.transcriptions.each {
                if (it.dateFullyTranscribed) {
                    transcribers << it.fullyTranscribedBy
                }
            }

            def mb = new MarkupBuilder(out)
            def transcribeUsers = transcribers ? User.findAllByUserIdInList(transcribers.toList()) : []
            if (transcribeUsers.size() > 1) {
                mb.p {
                    transcribeUsers.eachWithIndex { user, idx ->
                        mkp.yieldUnescaped(g.link(controller: 'user', action: 'show', id: user.id) {
                            cl.userDetails(id: user.userId, displayName: true)
                        })
                        if (idx + 1 < transcribeUsers.size()) mkp.yieldUnescaped('<br />')
                    }
                }
            } else if (transcribeUsers.size() > 0) {
                def user = transcribeUsers.first()
                out << "<a href=\"${createLink(controller: 'user', action: 'show',)}/${user?.id}\">${user?.displayName}</a>"
            }
        }
    }

    /**
     * Renders the options for a select list of templates, organised into categories.
     * @attr templateList REQUIRED the list of maps - [template, category]
     * @attr currentTemplateId REQUIRED the current selected template
     */
    def templateSelectOptions = { attrs ->
        log.debug("Current template ID: ${attrs.currentTemplateId}")
        def category = ""
        def output = ""
        log.debug("Template count: ${attrs.templateList?.size()}")
        attrs.templateList.each { Map row ->
            Template template = row.template as Template
            if (category != row.category) {
                category = row.category
                if (output.length() > 0) output += "</optgroup>"
                output += "<optgroup label='${getTemplateCategory(category)}'>"
            }

            if (!template.isHidden || userService.isSiteAdmin()) {
                output += "<option value='${template.id}' ${(attrs.currentTemplateId == template.id ? 'selected' : '')}>${template}${(attrs.currentTemplateId == template.id ? ' (Current)' : '')}</option>"
            } else if (template.isHidden && attrs.currentTemplateId == template.id) {
                output += "<option value='${template.id}' selected>${template} (Current)</option>"
            }
        }

        out << output
    }

    /**
     * Returns a Category name for the category code provided.
     *
     * @param categoryCode the code, either c1, c2, c3 or c4.
     * @return the name of the category.
     */
    private def getTemplateCategory(def categoryCode) {
        def category
        switch (categoryCode) {
            case 'c1': category = "Global Templates"
                break
            case 'c2': category = "Hidden Templates"
                break
            case 'c4': category = "Unassigned Templates (templates not assigned to an expedition)"
                break
            default: category = "Available Templates"

        }
        return category
    }

    /**
     * Builds a Project select list with projects grouped into Insitutions.
     * @attr inactiveFlag The inactive flag to use (include active or inactive projects)
     * @attr archiveFlag The archive flag to use
     * @attr selectedProject the current project to display as selected
     */
    def projectSelectGrouped = { attrs ->
        boolean inactive = false
        boolean archived = false
        def output = ""
        def currInstitution = 0
        if (attrs.inactiveFlag) inactive = attrs.inactiveFlag
        if (attrs.archiveFlag) archived = attrs.archiveFlag
        def projectList = Project.createCriteria().list {
            and {
                eq('inactive', inactive)
                eq('archived', archived)
            }
            'institution' {
                order('name', 'asc')
            }
            order('name', 'asc')
        }
        projectList.each { Project project ->
            if (currInstitution != project.institution.id) {
                currInstitution = project.institution.id
                if (output.length() > 0) output += "</optgroup>"
                output += "<optgroup label='${project.institution.name}'>"
            }
            if (project.id == attrs.selectedProject) {
                output += "<option value='${project.id}' selected>${project.name}</option>"
            } else {
                output += "<option value='${project.id}'>${project.name}</option>"
            }
        }

        out << output
    }

}