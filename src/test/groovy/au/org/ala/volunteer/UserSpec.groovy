package au.org.ala.volunteer

import grails.testing.gorm.DomainUnitTest

//import grails.test.mixin.TestFor
//import grails.test.mixin.TestMixin
//import grails.test.mixin.domain.DomainClassUnitTestMixin
import spock.lang.Shared
import spock.lang.Specification

//@TestFor(User)
//@TestMixin(DomainClassUnitTestMixin)
class UserSpec extends Specification implements DomainUnitTest<User> {

    @Shared
    def date
    @Shared
    def u1, u2

    def setupSpec() {
        grailsApplication.config.images.home = "/tmp/"
//        mockDomain(User)
        date = new Date()
        u1 = new User(userId: "1234", firstName: "Dude", lastName: "User", email: "dude.user@ala.org.au", created: date)
        u2 = new User(userId: "1235", firstName: "Sweet", lastName: "User", email: "sweet.user@ala.org.au", created: date)
        [u1,u2]*.save(flush: true)
    }

    void "Test that project can be compared to a non-gorm object"() {
        when: 'the equals arg is not a gorm object'
        def e = Integer.valueOf(1)
        def d = u1

        then: 'equals should fail but not throw a method not found exception'
        d != e

        when: 'the equals arg is a gorm object'
        d = u1
        def s = u2

        then: 'equals should fail but not throw an exception'
        d != s

        when: 'the equals arg is an equal object'
        d = u1
        def d2 = new User(userId: "1234", firstName: "User", lastName: "Dude", email: "user.dude@ala.org.au", created: date)

        then: 'equals succeeds but does not throw an exception'
        d == d2

        when: 'the equals arg is null'
        d = u1

        then: 'equals is false'
        !d.equals(null)
    }

    void "Test that user can be welcomed"() {
        when: 'User is initialised'
        def y = u1 as User

        then: 'User can be welcomed'
        !y.hasBeenWelcomed()

        when: 'User welcome date is set'
        y.welcomeEmailSent = new Date()

        then: 'User has been welcomed'
        y.hasBeenWelcomed()
    }

}
