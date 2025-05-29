package au.org.ala.volunteer

import grails.gorm.transactions.Transactional
import grails.validation.ValidationException

import java.time.LocalDate
import java.time.ZoneId
import java.time.format.DateTimeFormatter

import static javax.servlet.http.HttpServletResponse.SC_FORBIDDEN

class NewsItemController {

    NewsItemService newsItemService
    UserService userService
    ForumService forumService

    def index() {
        // Cards for latest 3 news items
        def featuredNewsItems
        if (NewsItem.count() > 0) {
            featuredNewsItems = newsItemService.getFeaturedNewsItems(3)
        }

        // list of all news items
        params.max = Math.min(params.max ? params.int('max') : 15, 100)
        def newsItemList = newsItemService.list(params)
        render view: 'index', model:[featuredNewsItems: featuredNewsItems, newsItemList: newsItemList,
                                     newsItemCount: newsItemList.size()]
    }

    def show(NewsItem newsItem) {
        if (!newsItem) {
            render status: 404
            return
        }

        // featured news items displayed in footer
        def featuredNewsItems = newsItemService.getFeaturedNewsItems(6).findAll {
            it.id != newsItem.id
        }

        render view: 'show', model: [newsItem: newsItem, featuredNewsItems: featuredNewsItems]
    }

    def manage() {
        if (!userService.isSiteAdmin()) {
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return
        }
        def statusFilterList = [[key: "active", value: "Active"],
                                [key: "inactive", value: "Inactive"]]
        def newsItemList = newsItemService.list(params)

        render view: 'manage', model:[newsItemList: newsItemList, newsItemCount: newsItemList.size(), statusFilterList: statusFilterList]
    }

    @Transactional
    def toggleNewsItemStatus(NewsItem newsItem) {
        log.info("Toggling status for news item: ${newsItem?.id}, current status: ${newsItem?.isActive}")
        if (!newsItem) {
            render status: 404
            return
        }
        if (!userService.isSiteAdmin()) {
            log.info("No permission to toggle news item status, user is not a site admin.")
            response.sendError(SC_FORBIDDEN, "You don't have permission")
            return
        }
        log.info("verifyId: ${params.verifyId}, newsItem.id: ${newsItem.id}, params.verifyId as long == newsItem.id: ${params.verifyId as long == newsItem.id}")
        log.info("verify check: ${!params.verifyId} || ${params.verifyId as long != newsItem.id}")
        if (params.verifyId == null || params.verifyId as long != newsItem.id) {
            log.info("Verification ID does not match news item ID, user does not have permission to toggle status.")
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return
        }

        log.info("Toggling status for news item: ${newsItem.id}, current status: ${newsItem.isActive}")
        newsItem.isActive = (!newsItem.isActive)
        log.info("New status for news item: ${newsItem.isActive}")
        newsItem.save(flush: true, failOnError: true)
        flash.message = "The news item's status has been set to ${newsItem.isActive ? 'active' : 'inactive'}."
        redirect(uri: request?.getHeader("referer") ?: createLink(controller: 'newsItem', action: 'manage'))
    }

    def create() {
        if (!userService.isSiteAdmin()) {
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return
        }
        def datePickerRanges = getDatePickerRanges()
        log.info("End date: ${datePickerRanges.endDate}")
        log.info("Start date: ${datePickerRanges.startDate}")
        render view: 'create', model: [defaultEndDate: datePickerRanges.endDate, defaultStartDate: datePickerRanges.startDate]
    }

    /**
     * Returns the date picker ranges for the news item creation form.
     * @return a map containing the start and end date strings formatted according to the specified pattern.
     */
    private def getDatePickerRanges() {
        String endDateStr = LocalDate.now().plusDays(30).format(DateTimeFormatter.ofPattern(DateConstants.DATE_FORMAT_SHORT, Locale.ENGLISH))
        String startDateStr = LocalDate.now().format(DateTimeFormatter.ofPattern(DateConstants.DATE_FORMAT_SHORT, Locale.ENGLISH))
        return [startDate: startDateStr, endDate: endDateStr]
    }

    @Transactional
    def save() {
        log.info("Saving news item with params: ${params}")
        if (!userService.isSiteAdmin()) {
            log.warn("User is not a site admin, cannot save news item.")
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return
        }
        def newsItem = new NewsItem(params)

        if (params.dateExpiresPicker) {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy")
            LocalDate localDate = LocalDate.parse(params.dateExpiresPicker as String, formatter)
            newsItem.dateExpires = Date.from(localDate.atStartOfDay(ZoneId.systemDefault()).toInstant())
            log.info("Parsed date: ${newsItem.dateExpires}, ${newsItem.dateExpires.class.name}")
        }

        newsItem.createdBy = userService.getCurrentUser()
        newsItem.dateCreated = new Date()

        if (!newsItem.validate()) {
            log.info("NewsItem has errors: ${newsItem.errors}")
            render view: 'create', model: [newsItem: newsItem]
            return
        }

        newsItem.save(flush: true, failOnError: true)

        flash.message = message(code: 'default.created.message', args: [message(code: 'newsItem.label', default: 'NewsItem'), newsItem.title])
        redirect(action: 'manage')
    }

    def edit(Long id) {
        if (!userService.isSiteAdmin()) {
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return
        }
        def datePickerRanges = getDatePickerRanges()
        render view: 'edit', model: [newsItem: NewsItem.get(id), defaultEndDate: datePickerRanges.endDateStr, defaultStartDate: datePickerRanges.startDateStr]
    }

    @Transactional
    def update(NewsItem newsItem) {
        if (!userService.isSiteAdmin()) {
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return
        }
        log.info("Updating news item with params: ${params}")

        if (params.dateExpiresPicker) {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy")
            LocalDate localDate = LocalDate.parse(params.dateExpiresPicker as String, formatter)
            newsItem.dateExpires = Date.from(localDate.atStartOfDay(ZoneId.systemDefault()).toInstant())
            log.info("Parsed date: ${newsItem.dateExpires}, ${newsItem.dateExpires.class.name}")
        }

        if (!newsItem.validate()) {
            log.info("NewsItem has errors: ${newsItem.errors}")
            render view: 'edit', model: [newsItem: newsItem]
            return
        }

        log.info("Attempting to update news item: ${newsItem.id}, title: ${newsItem.title}")
        newsItem.save(flush: true)

        flash.message = message(code: 'default.updated.message', args: [message(code: 'newsItem.label', default: 'NewsItem'), newsItem.title])
        redirect(action: 'manage')
    }

    @Transactional
    def delete(NewsItem newsItem) {
        if (!userService.isSiteAdmin()) {
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return
        }

        if (!newsItem) {
            render status: 404
            return
        }

        if (newsItem.topic) {
            // If the news item is linked to a topic, delete it first
            forumService.deleteTopic(newsItem.topic)
        }

        newsItem.delete(flush: true, failOnError: true)

        flash.message = message(code: 'newsItem.deleted.message')
        redirect(action: 'manage')
    }

}
