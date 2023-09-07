package au.org.ala.volunteer

import au.org.ala.userdetails.UserDetailsFromIdListResponse
import au.org.ala.web.AuthService
import au.org.ala.web.UserDetails
import grails.testing.gorm.DataTest
import grails.testing.services.ServiceUnitTest

//import grails.test.mixin.Mock
//import grails.test.mixin.TestFor
import spock.lang.Specification

//@TestFor(UserService)
//@Mock(User)
class UserServiceSpec extends Specification implements ServiceUnitTest<UserService>, DataTest {

    //def mockAuthService

    def setup() {
        mockDomain(User)
        User potato = new User(userId: '1234', email: 'email@example.com', firstName: 'Mr Potato', lastName: 'Head', displayName: 'Mr Potato Head', created: new Date())
        User smitty = new User(userId: '1235', email: 'smitty@smitty.com', firstName: 'Smitty', lastName: 'Smitty', displayName: 'Smitty Smitty', created: new Date())

        def zjxs = new User(userId: '545', email: 'zjxs@zjxs.org', firstName: 'ZJXS', displayName: 'ZJXS ', created: new Date())
        def clvf = new User(userId: '546', email: 'clvf@clvf.net', firstName: 'CLVF', displayName: 'CLVF ', created: new Date())

        potato.save()
        smitty.save()

        zjxs.save()
        clvf.save()
    }

    def cleanup() {
    }

    def "test propsForUserId with authService success"() {
        setup:
        def mockAuthService = Stub(AuthService)
        mockAuthService.getUserForUserId(_) >> { String id -> new UserDetails(userId: id, userName: 'potato@potato.com', firstName: 'Potato', lastName: 'Head, Esq.')}
        service.authService = mockAuthService

        when:
        def x = service.detailsForUserId('1234')

        then:
        x.email == 'potato@potato.com'
        x.displayName == 'Potato Head, Esq.'
        //mockAuthService.verify()
    }

    def "test propsForUserId with authService null"() {
        setup:
        def mockAuthService = Stub(AuthService)
        mockAuthService.getUserForUserId(_) >> { String id -> null}
        service.authService = mockAuthService

        when:
        def x = service.detailsForUserId('4321')

        then:
        x.email == ''
        x.displayName == ''
        //mockAuthService.verify()
    }

    def "test propsForUserId with authService exception"() {
        setup:
        def mockAuthService = Stub(AuthService)
        mockAuthService.getUserForUserId(_) >> { String id -> throw new IOException("Network failure")}
        service.authService = mockAuthService

        when:
        def x = service.detailsForUserId('1234')

        then:
        x.email == 'email@example.com'
        x.displayName == 'Mr Potato Head' // display name is computed in database
        //mockAuthService.verify()
    }

    def "test updateAllUsers"() {
        setup:
        def mockAuthService = Stub(AuthService)
        mockAuthService.getUserDetailsById(_, _) >> { List<String> ids, boolean includeProps -> usersForUserIds(ids) }
        service.authService = mockAuthService

        when:
        service.updateAllUsers()
        def p = User.findByUserId('1234')
        def s = User.findByUserId('1235')

        then:
        p.email == 'potato@potato.org'
//        p.displayName == 'Señor Potato' // displayName is computed in database.
        s.email == 'smitty@smitty.com'
//        s.displayName == 'Smitty Smitty' // displayName is computed in database.
    }

    def "test propsForUserIds"() {
        setup:
        def mockAuthService = Stub(AuthService)
        mockAuthService.getUserDetailsById(_) >> { List<String> ids -> new UserDetailsFromIdListResponse(users: ['545': new UserDetails(userId: '545', userName: 'test.email@potato.org', firstName: 'Display', lastName: 'Name') ], success: true, invalidIds: [] ) }
        service.authService = mockAuthService

        when:

        def results = service.detailsForUserIds( [ '545' ] )

        then:
        results*.userName == ['test.email@potato.org' ]
    }

    def "test propsForUserIds with missing ids"() {
        setup:
        def mockAuthService = Stub(AuthService)
        mockAuthService.getUserDetailsById(_) >> { List<String> ids -> new UserDetailsFromIdListResponse( users: [ '545': new UserDetails(userId: '545', userName: 'test.email@potato.org', firstName: 'Display', lastName: 'Name') ], success: true, invalidIds: [546] ) }
        service.authService = mockAuthService

        when:

        def results = service.detailsForUserIds( [ '545', '546' ] )

        then:
        results*.userName == ['test.email@potato.org', 'clvf@clvf.net' ]
    }

    def "test propsForUserIds with failed service call"() {
        setup:
        def mockAuthService = Stub(AuthService)
        mockAuthService.getUserDetailsById(_) >> { List<String> ids -> throw new IOException() }
        service.authService = mockAuthService

        when:

        def results = service.detailsForUserIds( [ '545', '546' ] )

        then:
        results*.userName == ['zjxs@zjxs.org', 'clvf@clvf.net' ]
    }

    private static usersForUserIds(List<String> ids) {
        new UserDetailsFromIdListResponse(
                users: ['1234': new UserDetails(userId: '1234', userName: 'potato@potato.org', firstName: 'Señor', lastName: 'Potato'),
                 '1235': new UserDetails(userId: '1235', userName: 'smitty@smitty.com', firstName: 'Smitty', lastName: 'Smitty')],
            success: true,
            invalidIds: [545, 546]
        )
    }
}
