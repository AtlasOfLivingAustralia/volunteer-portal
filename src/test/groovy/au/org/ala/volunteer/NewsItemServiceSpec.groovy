package au.org.ala.volunteer

import au.org.ala.volunteer.helper.FlybernateSpec
import grails.testing.services.ServiceUnitTest
import groovy.util.logging.Slf4j
import static au.org.ala.volunteer.helper.TaskDataHelper.*

@Slf4j
class NewsItemServiceSpec extends FlybernateSpec implements ServiceUnitTest<NewsItemService> {

    NewsItem newsItem1
    def setup() {
        // Setup any necessary data or mocks here
        newsItem1 = setupNewsItem("Test news item 1", "This is content.")
        log.info("Created news item: ${newsItem1.title}")
        log.info("News Items: ${NewsItem.list()}")
    }

    def "test list method with default sorting"() {
        when: "list is called without sort parameters"
        def result = service.list([statusFilter: 'active'])

        then: "the result should be sorted by dateCreated in descending order"
        result.sort { it.dateCreated }.reverse() == result
    }

    def "test getCurrentNewsItem returns the latest active news item"() {
        when: "getCurrentNewsItem is called"
        def currentNewsItem = service.getCurrentNewsItem()

        then: "it should return the latest active news item that has not expired"
        currentNewsItem != null
        currentNewsItem.isActive == true
        currentNewsItem.dateExpires > new Date()
    }

    def "test getFeaturedNewsItems returns the correct number of featured items"() {
        when: "getFeaturedNewsItems is called with a specific maxResults"
        def featuredItems = service.getFeaturedNewsItems(5)

        then: "it should return the specified number of featured news items"
        featuredItems.size() <= 5
    }

    void "linkForumTopicToNewsItem should link topic to news item when no topic exists"() {
        given:
        def newsItem = setupNewsItem("News Item with no topic", "Content for news item without topic.")
        def topic = setupForumTopic("Topic title")
        newsItem.save(flush: true, failOnError: true)

        when:
        service.linkForumTopicToNewsItem(topic, newsItem.id)

        then:
        newsItem.topic == topic
    }

    void "linkForumTopicToNewsItem should not overwrite existing topic"() {
        given:
        def existingTopic = setupForumTopic("Topic title")
        def newsItem = setupNewsItem("News Item with no topic", "Content for news item without topic.")
        newsItem.topic = existingTopic
        newsItem.save(flush: true, failOnError: true)
        def newTopic = setupForumTopic("Topic title")

        when:
        service.linkForumTopicToNewsItem(newTopic, newsItem.id)

        then:
        newsItem.topic == existingTopic
    }

    void "linkForumTopicToNewsItem should do nothing when topic is null"() {
        given:
        def newsItem = setupNewsItem("News Item with no topic", "Content for news item without topic.")

        when:
        service.linkForumTopicToNewsItem(null, newsItem.id)

        then:
        newsItem.topic == null
    }

    void "linkForumTopicToNewsItem should do nothing when newsItemId is invalid"() {
        given:
        NewsItem.get(999) >> null
        def topic = setupForumTopic("Topic title")

        when:
        service.linkForumTopicToNewsItem(topic, 999)

        then:
        noExceptionThrown()
    }

    void "hasNewsItemHaveTopic should return true when news item exists and has a topic"() {
        given:
        def newsItem = setupNewsItem("News Item with no topic", "Content for news item without topic.")
        def topic = setupForumTopic("Topic title")
        newsItem.topic = topic
        newsItem.save(flush: true, failOnError: true)

        when:
        def result = service.hasNewsItemHaveTopic(newsItem.id)

        then:
        result == true
    }

    void "hasNewsItemHaveTopic should return false when news item exists but has no topic"() {
        given:
        def newsItem = setupNewsItem("News Item with no topic", "Content for news item without topic.")

        when:
        def result = service.hasNewsItemHaveTopic(newsItem.id)

        then:
        result == false
    }

    void "hasNewsItemHaveTopic should return false when news item does not exist"() {
        given:
        NewsItem.get(999) >> null

        when:
        def result = service.hasNewsItemHaveTopic(999)

        then:
        result == false
    }
}
