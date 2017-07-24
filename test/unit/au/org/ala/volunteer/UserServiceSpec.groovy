package au.org.ala.volunteer

import au.org.ala.web.AuthService
import au.org.ala.web.UserDetails
import grails.test.mixin.Mock
import grails.test.mixin.TestFor
import spock.lang.Specification

@TestFor(UserService)
@Mock([User])
class UserServiceSpec extends Specification {

    //def mockAuthService

    def setup() {
        User potato = new User(userId: '1234', email: 'email@example.com', displayName: 'Mr Potato Head', created: new Date())
        User smitty = new User(userId: '1235', email: 'smitty@smitty.com', displayName: 'Smitty', created: new Date())

        new User(userId: '545', email: 'zjxs@zjxs.org', displayName: 'ZJXS', created: new Date()).save()
        new User(userId: '546', email: 'clvf@clvf.net', displayName: 'CLVF', created: new Date()).save()

        potato.save()
        smitty.save()
    }

    def cleanup() {
    }

    def "test propsForUserId with authService success"() {
        setup:
        def mockAuthService = mockFor(AuthService)
        mockAuthService.demand.getUserForUserId(1) { String id -> new UserDetails(userId: id, userName: 'potato@potato.com', firstName: 'Potato', lastName: 'Head, Esq.')}
        service.authService = mockAuthService.createMock()

        when:
        def x = service.detailsForUserId('1234')

        then:
        x.email == 'potato@potato.com'
        x.displayName == 'Potato Head, Esq.'
        //mockAuthService.verify()
    }

    def "test propsForUserId with authService null"() {
        setup:
        def mockAuthService = mockFor(AuthService)
        mockAuthService.demand.getUserForUserId(1) { String id -> null }
        service.authService = mockAuthService.createMock()

        when:
        def x = service.detailsForUserId('4321')

        then:
        x.email == ''
        x.displayName == ''
        //mockAuthService.verify()
    }

    def "test propsForUserId with authService exception"() {
        setup:
        def mockAuthService = mockFor(AuthService)
        mockAuthService.demand.getUserForUserId(1) { String id -> throw new IOException("Network failure")}
        service.authService = mockAuthService.createMock()

        when:
        def x = service.detailsForUserId('1234')

        then:
        x.email == 'email@example.com'
        x.displayName == 'Mr Potato Head'
        //mockAuthService.verify()
    }

    def "test updateAllUsers"() {
        setup:
        def mockAuthService = mockFor(AuthService)
        mockAuthService.demand.getUserDetailsById(1) { List<String> ids -> usersForUserIds(ids) }
        service.authService = mockAuthService.createMock()

        when:
        service.updateAllUsers()
        def p = User.findByUserId('1234')
        def s = User.findByUserId('1235')

        then:
        p.email == 'potato@potato.org'
        p.displayName == 'Señor Potato'
        s.email == 'smitty@smitty.com'
        s.displayName == 'Smitty'
    }

    def "test propsForUserIds"() {
        setup:
        def mockAuthService = mockFor(AuthService)
        mockAuthService.demand.getUserDetailsById(1) { List<String> ids -> [ users: [ '545': new UserDetails(userId: '545', userName: 'test.email@potato.org', firstName: 'Display', lastName: 'Name') ], success: true, missingIds: [] ] }
        service.authService = mockAuthService.createMock()

        when:

        def results = service.detailsForUserIds( [ '545' ] )

        then:
        results*.userName == ['test.email@potato.org' ]
    }

    def "test propsForUserIds with missing ids"() {
        setup:
        def mockAuthService = mockFor(AuthService)
        mockAuthService.demand.getUserDetailsById(1) { List<String> ids -> [ users: [ '545': new UserDetails(userId: '545', userName: 'test.email@potato.org', displayName: 'Display Name') ], success: true, invalidIds: [546] ] }
        service.authService = mockAuthService.createMock()

        when:

        def results = service.detailsForUserIds( [ '545', '546' ] )

        then:
        results*.userName == ['test.email@potato.org', 'clvf@clvf.net' ]
    }

    def "test propsForUserIds with failed service call"() {
        setup:
        def mockAuthService = mockFor(AuthService)
        mockAuthService.demand.getUserDetailsById(1) { List<String> ids -> null }
        service.authService = mockAuthService.createMock()

        when:

        def results = service.detailsForUserIds( [ '545', '546' ] )

        then:
        results*.userName == ['zjxs@zjxs.org', 'clvf@clvf.net' ]
    }

    private static usersForUserIds(List<String> ids) {
        sleep(100) // simulate some network latency

        [
                users: ['1234': new UserDetails(userId: '1234', userName: 'potato@potato.org', displayName: 'Señor Potato'),
                 '1235': new UserDetails(userId: '1235', userName: 'smitty@smitty.com', displayName: 'Smitty')],
            success: true,
            invalidIds: [545, 546]
        ]
    }
}
