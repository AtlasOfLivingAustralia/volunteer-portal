package au.org.ala.volunteer

import grails.testing.gorm.DomainUnitTest
import grails.testing.web.controllers.ControllerUnitTest
import spock.lang.*

import javax.servlet.http.HttpServletResponse
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.time.format.DateTimeParseException

class NewsItemControllerSpec extends Specification implements ControllerUnitTest<NewsItemController>, DomainUnitTest<NewsItem> {

    User user123 = new User(id: 123L, displayName: "Test User", email: "me@you.com", firstName: "Test", lastName: "User")

    def setup() {
        def userServiceStub = Stub(UserService) {
            isSiteAdmin() >> false
        }
        controller.userService = userServiceStub
    }

    void "Test the index action returns the correct model"() {
        given:
        controller.newsItemService = Mock(NewsItemService) {
            1 * list(_) >> []
        }

        when:"The index action is executed"
        controller.index()

        then:"The model is correct"
        !model.newsItemList
        model.newsItemCount == 0
    }

    void "Test the create action returns the correct model"() {
        given:
        controller.userService = Mock(UserService) {
            1 * isSiteAdmin() >> true
        }
        when:"The create action is executed"
        controller.create()

        then:"The model is correctly created"
        model.defaultStartDate!= null
        model.defaultEndDate != null
    }

    void "save should not persist when user is not site admin"() {
        when:
        controller.save()

        then:
        response.redirectedUrl == null
        view == '/notPermitted'
        flash.message != null
    }

    void "save should persist valid news item with expiration date"() {
        given:
        def userServiceStub = Stub(UserService) {
            isSiteAdmin() >> true
        }
        controller.userService = userServiceStub
        params.title = "Valid News Item"
        params.dateExpiresPicker = "15/10/2023"
        params.isActive = true
        params.content = "This is a valid news item content."

        when:
        controller.save()

        then:
        response.redirectedUrl == '/newsItem/manage'
        flash.message.contains("created")
    }

    void "save should not persist invalid news item"() {
        given:
        def userServiceStub = Stub(UserService) {
            isSiteAdmin() >> true
        }
        controller.userService = userServiceStub
        params.title = ""

        when:
        controller.save()

        then:
        view == '/newsItem/create'
        model.newsItem.errors.hasErrors()
    }

    void "update should not persist when user is not site admin"() {
        when:
        controller.update(new NewsItem())

        then:
        response.redirectedUrl == null
        view == '/notPermitted'
        flash.message == "You do not have permission to view this page"
    }

    void "update should persist valid news item with expiration date"() {
        given:
        def userServiceStub = Stub(UserService) {
            isSiteAdmin() >> true
        }
        controller.userService = userServiceStub
        def newsItem = new NewsItem(title: "Existing News Item", content: "This is existing content.", isActive: true)
        newsItem.dateCreated = new Date()
        newsItem.createdBy = new User([id: 123L])
        params.dateExpiresPicker = "15/10/2023"

        when:
        controller.update(newsItem)

        then:
        response.redirectedUrl == '/newsItem/manage'
        flash.message.contains("updated")
    }

    void "update should not persist invalid news item"() {
        given:
        def userServiceStub = Stub(UserService) {
            isSiteAdmin() >> true
        }
        controller.userService = userServiceStub
        def newsItem = new NewsItem(title: "")

        when:
        controller.update(newsItem)

        then:
        view == '/newsItem/edit'
        model.newsItem.errors.hasErrors()
    }

    void "delete should not remove news item when user is not site admin"() {
        when:
        controller.delete(new NewsItem())

        then:
        response.redirectedUrl == null
        view == '/notPermitted'
        flash.message == "You do not have permission to view this page"
    }

    void "delete should remove news item and linked topic"() {
        given:
        def userServiceStub = Stub(UserService) {
            isSiteAdmin() >> true
        }
        controller.userService = userServiceStub
        def forumServiceStub = Stub(ForumService) {
            deleteTopic(_) >> true
        }
        controller.forumService = forumServiceStub
        def newsItem = new NewsItem(topic: new ForumTopic())

        when:
        controller.delete(newsItem)

        then:
        response.redirectedUrl == '/newsItem/manage'
        flash.message.contains("deleted")
    }

    void "toggleNewsItemStatus should return 404 when news item is null"() {
        when:
        controller.toggleNewsItemStatus(null)

        then:
        response.status == 404
    }

    void "toggleNewsItemStatus should return forbidden when user is not site admin"() {
        given:
        def newsItem = new NewsItem(id: 1)

        when:
        controller.toggleNewsItemStatus(newsItem)

        then:
        response.status == HttpServletResponse.SC_FORBIDDEN
        response.errorMessage == "You don't have permission"
    }

    void "toggleNewsItemStatus should render not permitted when verifyId does not match news item id"() {
        given:
        def userServiceStub = Stub(UserService) {
            isSiteAdmin() >> true
        }
        controller.userService = userServiceStub
        params.verifyId = 2
        def newsItem = new NewsItem(id: 1)

        when:
        controller.toggleNewsItemStatus(newsItem)

        then:
        view == '/notPermitted'
        flash.message == "You do not have permission to view this page"
    }

    void "toggleNewsItemStatus should toggle isActive and redirect to referer"() {
        given:
        def userServiceStub = Stub(UserService) {
            isSiteAdmin() >> true
        }
        controller.userService = userServiceStub
        params.verifyId = 123
        request.addHeader("referer", "/previousPage")
        def newsItem = new NewsItem(title: 'This is a title', content: 'Content', createdBy: user123, isActive: true)
        newsItem.id = 123L
        newsItem.dateCreated = new Date()
        newsItem.dateExpires = new Date() + 30 // Set a future expiration date

        when:
        controller.toggleNewsItemStatus(newsItem)

        then:
        newsItem.isActive == false
        response.redirectedUrl == "/previousPage"
        flash.message == "The news item's status has been set to inactive."
    }

    void "toggleNewsItemStatus should toggle isActive and redirect to manage when referer is not set"() {
        given:
        def userServiceStub = Stub(UserService) {
            isSiteAdmin() >> true
        }
        controller.userService = userServiceStub
        params.verifyId = 123
        def newsItem = new NewsItem(title: 'This is a title', content: 'Content', createdBy: user123, isActive: true)
        newsItem.id = 123L
        newsItem.dateCreated = new Date()
        newsItem.dateExpires = new Date() + 30 // Set a future expiration date

        when:
        controller.toggleNewsItemStatus(newsItem)

        then:
        newsItem.isActive == false
        response.redirectedUrl == "/newsItem/manage"
        flash.message == "The news item's status has been set to inactive."
    }

    void "getDatePickerRanges should return correct start and end dates"() {
        when:
        def result = controller.getDatePickerRanges()

        then:
        result.startDate == LocalDate.now().format(DateTimeFormatter.ofPattern(DateConstants.DATE_FORMAT_SHORT, Locale.ENGLISH))
        result.endDate == LocalDate.now().plusDays(30).format(DateTimeFormatter.ofPattern(DateConstants.DATE_FORMAT_SHORT, Locale.ENGLISH))
    }

    void "getDatePickerRanges should handle invalid date format constant gracefully"() {
        given:
        DateConstants.DATE_FORMAT_SHORT = "invalid_format"

        when:
        def result = controller.getDatePickerRanges()

        then:
        thrown(IllegalArgumentException)
    }
}






