package au.org.ala.volunteer

import groovy.time.TimeCategory
import java.text.NumberFormat
import java.text.DecimalFormat
import au.org.ala.cas.util.AuthenticationCookieUtils
import groovy.xml.MarkupBuilder

class VolunteerTagLib {
    //def authenticateService

    static namespace = 'cl'

    def authService
    def userService
    def grailsApplication
    def settingsService
    def multimediaService
    def markdownService

    def isLoggedIn = { attrs, body ->
        if (AuthenticationCookieUtils.cookieExists(request, AuthenticationCookieUtils.ALA_AUTH_COOKIE)) {
            out << body()
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

    def ifAdmin = {attrs, body ->
        if (isAdmin()) {
            out << body()
        }
    }

    private boolean isAdmin() {
        return grailsApplication.config.security.cas.bypass || request?.isUserInRole(CASRoles.ROLE_ADMIN)
    }

    /**
     * @attr markdown defaults to true, will invoke the markdown service
     * @attr tooltipPosition (one of 'topLeft, 'topMiddle', 'topRight', 'bottomLeft', 'bottomMiddle', 'bottomRight')
     * @atrr tipPosition (one of 'topLeft, 'topMiddle', 'topRight', 'bottomLeft', 'bottomMiddle', 'bottomRight')
     * @attr targetPosition (one of 'topLeft, 'topMiddle', 'topRight', 'bottomLeft', 'bottomMiddle', 'bottomRight')
     */
    def helpText = { attrs, body ->
        def mb = new MarkupBuilder(out)
        def helpText = (body() as String)?.trim()?.replaceAll("[\r\n]", "");
        if (helpText) {
            helpText = markdownService.markdown(helpText)
            def attributes = [href:'#', class:'fieldHelp', title:helpText, tabindex: "-1"]
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

            mb.a(attributes) {
                span(class:'help-container') {
                    mkp.yieldUnescaped('&nbsp;')
                }
            }
        } else {
            mb.mkp.yieldUnescaped("&nbsp;")
        }
    }

    /**
     * Show map of records based on UID
     *
     * - content is loaded by ajax calls
     */
    def recordsMap = {
        out <<
            "<div class='recordsMap'>" +
            " <img id='recordsMap' class='no-radius' src='${resource(dir:'images/map',file:'map-loader.gif')}' width='340' />" +
            " <img id='mapLegend' src='${resource(dir:'images/ala', file:'legend-not-available.png')}' width='128' />" +
            "</div>" +
            "<div class='learnMaps'><span class='asterisk-container'><a href='${grailsApplication.config.ala.baseURL}/about/progress/map-ranges/'>Learn more about Atlas maps</a>&nbsp;</span></div>"

        /*out << "<div class='distributionImage'>${body()}<img id='recordsMap' class='no-radius' src='${resource(dir:'images/map',file:'map-loader.gif')}' width='340' />" +
                "<img id='mapLegend' src='${resource(dir:'images/ala', file:'legend-not-available.png')}' width='128' />" +
                "</div>"*/
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
    def navbar = { attrs, body ->

        def selected = null;

        if (attrs.containsKey('selected')) {
            selected = attrs.selected as String;
        }

        def items = [:]

        items << [bvp:[link: createLink(uri: '/'), title: 'Biodiversity Volunteer Portal']]
        items << [expeditions: [link: createLink(controller: 'project', action: 'list'), title: 'Expeditions']]
        items << [tutorials: [link: createLink(controller: 'tutorials'), title: 'Tutorials']]
        if (FrontPage.instance().enableForum) {
            items << [forum:[link: createLink(controller: 'forum'), title: 'Forum']]
        }

        def dashboardEnabled = settingsService.getSetting(SettingDefinition.EnableMyDashboard)
        if (dashboardEnabled) {
            def isLoggedIn = AuthenticationCookieUtils.cookieExists(request, AuthenticationCookieUtils.ALA_AUTH_COOKIE)
            if (isLoggedIn || userService.currentUser) {
                items << [userDashboard: [link: createLink(controller:'user', action:'dashboard'), title:"My Dashboard"]]
            }
        }

        items << [contact: [link: createLink(controller: 'contact'), title: 'Contact Us']]
        items << [getinvolved:[link: createLink(controller: 'getInvolved'), title:"How can I volunteer?"]]
        items << [aboutbvp: [link: createLink(controller: 'about'), title: 'About the Portal']]

        def mb = new MarkupBuilder(out)
        mb.div(class:'navbar navbar-static-top', id:"nav-site") {
            div(class:'navbar-inner') {
                div(class:'container') {
                    div(class:'nav-collapse collapse') {
                        ul(class:'nav') {
                            for (def key : items.keySet()) {
                                def item = items[key]
                                mb.li(class:'nav-' + key + (selected == key ? ' active' : '')) {
                                    a(href:item.link) {
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
            out << '<div class="alert alert-error" style="margin-top:10px">' + flash.systemMessage + '</div>'
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
                        h3('Comments', style: "padding-bottom: 0px;min-height: 0px")
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
                if (authService.username()) {
                    tr(class: 'prop', style: 'width: 100%; min-height: 0px') {
                        td(style: 'padding-bottom: 0px; padding-top: 0px;') {
                            span('Add a new comment by typing in the box below, and clicking "Save comment"') {}
                        }
                    }
                    tr(class:'prop',style: 'width: 100%') {
                        td(style: 'padding-top: 0px; padding-bottom: 0px;') {
                            textarea("", name:'comment_textarea', id:'comment_textarea', cols: '80', rows: '3', style:'width: 600px')
                        }
                    }
                    tr(class:'prop', style: 'width: 100%') {
                        td(class: 'name',style: "text-align: left; vertical-align: bottom; padding-top: 0px") {
                            button(id: 'addCommentButton', 'Save comment')
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
            User validator = null;
            User transcriber = null;
            if (taskInstance.fullyValidatedBy) {
                validator = User.findByUserId(taskInstance?.fullyValidatedBy)
            }

            if (taskInstance.fullyTranscribedBy) {
                transcriber = User.findByUserId(taskInstance?.fullyTranscribedBy)
            }
            def mb = new MarkupBuilder(out)

            if (transcriber) {
                mb.span(class:"label label-info") {
                    mkp.yield("Transcribed by ${transcriber.displayName} on ${taskInstance.dateFullyTranscribed?.format("yyyy-MM-dd HH:mm:ss")}")
                }
            }

            if (validator) {
                def status = "Not yet validated"
                def badgeClass = "label"
                if (taskInstance.isValid == false) {
                    status = "Marked as invalid by ${validator.displayName} on ${taskInstance?.dateFullyValidated?.format("yyyy-MM-dd HH:mm:ss")}"
                    badgeClass = "label label-important"
                } else if (taskInstance.isValid) {
                    status = "Marked as Valid by ${validator.displayName} on ${taskInstance?.dateFullyValidated?.format("yyyy-MM-dd HH:mm:ss")}"
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
            def user = User.findByUserId(attrs.userId)
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
     * @attr title
     * @attr selectedNavItem
     * @attr crumbLabel
     * @attr hideTitle
     * @attr hideCrumbs
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
                mb.nav(id:'breadcrumb') {
                    ol {
                        li {
                            a(href:createLink(uri:'/')) {
                                mkp.yield(message(code:'default.home.label'))
                            }
                        }
                        if (crumbList) {
                            for (int i = 0; i < crumbList?.size(); i++) {
                                def item = crumbList[i]
                                li {
                                    a(href: item.link) {
                                        mkp.yield(item.label)
                                    }
                                }
                            }
                        }
                        li(class:'last') {
                            span {
                                mkp.yield(crumbLabel)
                            }
                        }
                    }
                }
            }

            if (!attrs.hideTitle) {
                mb.h1 {
                    mkp.yield(attrs.title)
                }
            }

            if (bodyContent) {
                mb.div {
                    mb.mkp.yieldUnescaped(bodyContent)
                }
            }

        }

    }

    def spinner = { attrs, body ->
        out << "<image src=\"${resource(dir:'images', file:'spinner.gif')}\" />"
    }

    def taskThumbnail = { attrs, body ->
        def task = attrs.task as Task
        if (task) {
            def url = ""
            def mm = task.multimedia?.first()
            if (mm) {
                url = multimediaService.getImageThumbnailUrl(mm)
            }

            if (url) {
                out << "<img src=\"${url}\" style=\"height:100px\"/>"
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
        mb.li(class: active == current ? 'active' : '') {
            a(href:attrs.href) {
                i(class:'icon-chevron-right') { mkp.yieldUnescaped('&nbsp;')}
                mkp.yield(attrs.title)
            }
        }
    }



}