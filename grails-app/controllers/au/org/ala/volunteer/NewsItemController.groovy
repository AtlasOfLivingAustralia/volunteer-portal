package au.org.ala.volunteer

import grails.gorm.transactions.Transactional
import org.springframework.web.multipart.MultipartFile
import org.springframework.web.multipart.MultipartHttpServletRequest

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
        log.debug("Toggling status for news item: ${newsItem?.id}, current status: ${newsItem?.isActive}")
        if (!newsItem) {
            render status: 404
            return
        }
        if (!userService.isSiteAdmin()) {
            log.debug("No permission to toggle news item status, user is not a site admin.")
            response.sendError(SC_FORBIDDEN, "You don't have permission")
            return
        }
        log.debug("verifyId: ${params.verifyId}, newsItem.id: ${newsItem.id}, params.verifyId as long == newsItem.id: ${params.verifyId as long == newsItem.id}")
        log.debug("verify check: ${!params.verifyId} || ${params.verifyId as long != newsItem.id}")
        if (params.verifyId == null || params.verifyId as long != newsItem.id) {
            log.debug("Verification ID does not match news item ID, user does not have permission to toggle status.")
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return
        }

        log.debug("Toggling status for news item: ${newsItem.id}, current status: ${newsItem.isActive}")
        newsItem.isActive = (!newsItem.isActive)
        log.debug("New status for news item: ${newsItem.isActive}")
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
        log.debug("End date: ${datePickerRanges.endDate}")
        log.debug("Start date: ${datePickerRanges.startDate}")
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
        log.debug("Saving news item with params: ${params}")
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
            log.debug("Parsed date: ${newsItem.dateExpires}, ${newsItem.dateExpires.class.name}")
        }

        newsItem.createdBy = userService.getCurrentUser()
        newsItem.dateCreated = new Date()

        if (!newsItem.validate()) {
            log.debug("NewsItem has errors: ${newsItem.errors}")
            render view: 'create', model: [newsItem: newsItem]
            return
        }

        newsItem.save(flush: true, failOnError: true)

        // optional thumbnail upload handling
        if (request instanceof MultipartHttpServletRequest) {
            MultipartFile f = ((MultipartHttpServletRequest) request).getFile('newsItemThumb')
            if (f != null && f.size > 0) {
                def allowedMimeTypes = ['image/jpeg', 'image/png']
                if (!allowedMimeTypes.contains(f.getContentType())) {
                    flash.message = "Image must be one of: ${allowedMimeTypes}"
                } else {
                    // Upload image
                    def result = newsItemService.uploadImage(newsItem.id, f)
                    if (!result) {
                        flash.message = "Error uploading image"
                        redirect(action: 'create', params: params)
                        return
                    } else {
                        log.debug("Image uploaded successfully: ${result}")
                    }
                }
            }
        }

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

    def clearImage(NewsItem newsItem) {
        if (!userService.isSiteAdmin()) {
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return
        }

        if (newsItem) {
            // Clear the image associated with the news item
            def result = newsItemService.deleteImage(newsItem.id)
            if (!result) {
                flash.message = "Error removing image for news item with ID ${newsItem.id}"
            } else {
                log.debug("Image removed successfully for news item with ID ${newsItem.id}")
                flash.message = "Image removed successfully."
            }
        }

        redirect(action: 'edit', id: newsItem.id)
    }

    @Transactional
    def update(NewsItem newsItem) {
        if (!userService.isSiteAdmin()) {
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return
        }
        log.debug("Updating news item with params: ${params}")

        if (params.dateExpiresPicker) {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy")
            LocalDate localDate = LocalDate.parse(params.dateExpiresPicker as String, formatter)
            newsItem.dateExpires = Date.from(localDate.atStartOfDay(ZoneId.systemDefault()).toInstant())
            log.debug("Parsed date: ${newsItem.dateExpires}, ${newsItem.dateExpires.class.name}")
        }

        if (!newsItem.validate()) {
            log.debug("NewsItem has errors: ${newsItem.errors}")
            render view: 'edit', model: [newsItem: newsItem]
            return
        }

        log.debug("Attempting to update news item: ${newsItem.id}, title: ${newsItem.title}")
        newsItem.save(flush: true)

        // optional thumbnail upload handling
        if (request instanceof MultipartHttpServletRequest) {
            MultipartFile f = ((MultipartHttpServletRequest) request).getFile('newsItemThumb')
            if (f != null && f.size > 0) {
                log.debug("Processing uploaded file: ${f.originalFilename}, size: ${f.size}, content type: ${f.contentType}")
                def allowedMimeTypes = ['image/jpeg', 'image/png']
                if (!allowedMimeTypes.contains(f.getContentType())) {
                    flash.message = "Image must be one of: ${allowedMimeTypes}"
                } else if (newsItemService.getImageUrl(newsItem.id) != null) {
                    flash.message = "Image already exists, please clear it before uploading a new one."
                } else {
                    // Upload image
                    def result = newsItemService.uploadImage(newsItem.id, f)
                    if (!result) {
                        flash.message = "Error uploading image"
                        redirect(action: 'create', params: params)
                        return
                    } else {
                        log.debug("Image uploaded successfully: ${result}")
                    }
                }
            } else {
                log.debug("No file uploaded or file is empty.")
            }
        }

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

    def viewNewsItemImageFragment(NewsItem newsItem) {
        [newsItem: newsItem]
    }
}
