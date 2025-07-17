package au.org.ala.volunteer

import grails.gorm.transactions.Transactional
import org.springframework.web.multipart.MultipartFile

import java.nio.file.DirectoryStream
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths

@Transactional
class NewsItemService {

    def grailsApplication

    static final String NEWS_ITEM_IMAGE_PREFIX = "news-image-"

    /**
     * Returns a list of NewsItem objects based on the provided parameters.
     * @param params Grails parameters for pagination and sorting.
     * @param listAll If true, returns all news items regardless of their active status; if false, only returns active news items.
     * @return List of NewsItem objects.
     */
    def list(Map params, Boolean listAll = false) {
        if (!params.sort) {
            params.sort = 'dateCreated'
            params.order = 'desc'
        }

        def newsItemList = NewsItem.createCriteria().list(params) {
            if (params.statusFilter == 'active') {
                eq('isActive', true)
            } else if (params.statusFilter == 'inactive') {
                eq('isActive', false)
            }
            if (params.q) {
                or {
                    ilike('title', "%${params.q}%")
                    ilike('content', "%${params.q}%")
                }
            }
            if (!listAll) eq('isActive', true) // Ensure only active news items are returned
            order(params.sort, params.order)
        }

        newsItemList
    }

    /**
     * Returns the latest current news item. A news item is considered current if it is active and has not expired.
     * @return the latest current NewsItem object or null if none exists.
     */
    def getCurrentNewsItem() {
        def currentNewsItem = NewsItem.createCriteria().get {
            eq('isActive', true)
            gt('dateExpires', new Date())
            order('dateCreated', 'desc')
            maxResults(1)
        }
        log.debug("Current news item: ${currentNewsItem?.title ?: 'None'}")

        currentNewsItem
    }

    /**
     * Returns a list of featured news items.
     * @param maxResults the maximum number of featured news items to return. Default is 3.
     * @return List of featured NewsItem objects.
     */
    def getFeaturedNewsItems(int maxResults = 3) {
        def featuredNewsItems = NewsItem.createCriteria().list(max: maxResults) {
            eq('isActive', true)
            order('dateCreated', 'desc')
        }

        featuredNewsItems
    }

    /**
     * Links a ForumTopic to a NewsItem.
     * @param topic The ForumTopic to link.
     * @param newsItemId The ID of the NewsItem to link to.
     */
    def linkForumTopicToNewsItem(ForumTopic topic, long newsItemId) {
        if (!topic || !newsItemId) {
            return
        }

        def newsItem = NewsItem.get(newsItemId)
        if (newsItem) {
            if (!newsItem.topic) {
                newsItem.topic = topic
                newsItem.save(flush: true, failOnError: true)
            } else {
                // If the news item already has a topic, you might want to handle this case differently
                // For example, you could throw an exception or log a warning
                log.warn("NewsItem with ID ${newsItemId} already has a linked ForumTopic.")
            }
        }
    }

    /**
     * Checks if a NewsItem has a linked ForumTopic.
     * @param newsItemId The ID of the NewsItem to check.
     * @return true if the NewsItem has a linked ForumTopic, false otherwise.
     */
    def hasNewsItemHaveTopic(long newsItemId) {
        def newsItem = NewsItem.get(newsItemId)
        if (newsItem) {
            return newsItem.topic != null
        }
        return false
    }

    /**
     * Returns the file path for storing images related to a NewsItem.
     * @param newsItemId The ID of the NewsItem.
     * @return The file path as a String.
     */
    private String getImagePath(long newsItemId) {
        return "${grailsApplication.config.getProperty('images.home', String)}/newsItem/${newsItemId}/"
    }

    /**
     * Finds the first image file in the specified directory that matches the NEWS_ITEM_IMAGE_PREFIX.
     * @param filePath The path to the directory where images are stored.
     * @return The name of the first image file found, or null if no image is found.
     */
    def findImage(String filePath) {
        Path dir = Paths.get(filePath)
        try(DirectoryStream<Path> stream = Files.newDirectoryStream(dir, "${NEWS_ITEM_IMAGE_PREFIX}*.jpg")) {
            for (Path entry : stream) {
                log.debug("Found image: ${entry.toString()}")
                return entry.fileName.toString() // Return the first image found
            }
        } catch (IOException ignored) {
            // Don't log an error if the directory does not exist, just return null
            return null
        }
    }

    /**
     * Returns the URL for the thumbnail image of a NewsItem.
     * @param newsItemId The ID of the NewsItem.
     * @return The URL of the thumbnail image, or null if no image is found.
     */
    def getImageUrl(long newsItemId) {
        def imagePath = getImagePath(newsItemId)
        def thumbnailPath = findImage(imagePath)
        log.debug("Thumbnail path for NewsItem ID ${newsItemId}: ${thumbnailPath}")
        if (thumbnailPath) {
            return "${grailsApplication.config.getProperty('server.url', String)}/${grailsApplication.config.getProperty('images.urlPrefix', String)}newsItem/${newsItemId}/${thumbnailPath}"
        } else {
            return null
        }
    }

    /**
     * Uploads an image for a NewsItem.
     * @param newsItemId The ID of the NewsItem.
     * @param file The MultipartFile containing the image to upload.
     * @return true if the upload was successful, false otherwise.
     */
    def uploadImage(long newsItemId, MultipartFile file) {
        def filePath = getImagePath(newsItemId)
        filePath = filePath + "${NEWS_ITEM_IMAGE_PREFIX}${new Date().getTime()}.jpg"
        if (file && !file.isEmpty()) {
            def dir = new File(filePath).parentFile
            if (!dir.exists()) {
                dir.mkdirs()
            }
            file.transferTo(new File(filePath))
            log.debug("Image uploaded successfully for NewsItem ID: ${newsItemId}")
            return true
        } else {
            log.warn("No file provided or file is empty for NewsItem ID: ${newsItemId}")
        }
        return false
    }

    /**
     * Deletes the image associated with a NewsItem.
     * @param newsItemId The ID of the NewsItem whose image is to be deleted.
     * @return true if the image was successfully deleted, false otherwise.
     */
    def deleteImage(long newsItemId) {
        def filePath = getImagePath(newsItemId)
        def thumbnailPath = findImage(filePath)
        if (thumbnailPath) {
            def fileFullPath = "${filePath}${thumbnailPath}"
            log.debug("Deleting image for NewsItem ID: ${newsItemId}, Path: ${fileFullPath}")
            def file = new File(fileFullPath)
            if (file.exists()) {
                file.delete()
                return true
            }
            log.warn("Image file does not exist for NewsItem ID: ${newsItemId}, Path: ${fileFullPath}")
        }
        return false
    }
}