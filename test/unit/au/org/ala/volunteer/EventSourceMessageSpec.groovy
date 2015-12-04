package au.org.ala.volunteer

import grails.test.mixin.TestMixin
import grails.test.mixin.web.ControllerUnitTestMixin
import spock.lang.Specification

@TestMixin(ControllerUnitTestMixin)
class EventSourceMessageSpec extends Specification {

    // fields

    // fixture methods

    def setup() {}          // run before every feature method
    def cleanup() {}        // run after every feature method
    def setupSpec() {}     // run before the first feature method
    def cleanupSpec() {}   // run after the last feature method

    // feature methods
    void "test write string data"() {
        setup:
        def msg = new EventSourceMessage(data:'potato')
        def sw = new StringWriter()
        when:
        msg.writeTo(sw)

        then:
        sw.toString() == """data: potato

"""
    }

    void "test write map data"() {
        setup:
        def d = [hello: "world\npotato", count: 2]
        def msg = new EventSourceMessage(data:d)
        def sw = new StringWriter()
        when:
        msg.writeTo(sw)

        then:
        sw.toString() == """data: {"hello":"world\\npotato","count":2}

"""
    }

    void "test empty alert"() {
        setup:
        def d = ''
        def msg = new EventSourceMessage(event: 'alertMessage', data:d)
        def sw = new StringWriter()
        when:
        msg.writeTo(sw)

        then:
        sw.toString() == "event: alertMessage\ndata: \n\n"
    }

    void "test event and data"() {
        //[class:achievement.award, badgeUrl:http://devt.ala.org.au//data/volunteer-portal/achievements/c9d40d75-6cd9-4d83-ae96-110e6efe07bb.png, title:Congratulations!, id:8702543, message:You were just awarded the Completed 30 Tasks achievement!, profileUrl:/volunteer-portal/user/notebook]
        setup:
        def msg = new EventSourceMessage(event: 'achievementAwarded', data: [class:'achievement.award', badgeUrl:'http://devt.ala.org.au//data/volunteer-portal/achievements/c9d40d75-6cd9-4d83-ae96-110e6efe07bb.png', title:'Congratulations!', id:8702543, message:'You were just awarded the Completed 30 Tasks achievement!', profileUrl:'/volunteer-portal/user/notebook'])
        def sw = new StringWriter()

        when:
        msg.writeTo(sw)

        then:
        sw.toString() == """event: achievementAwarded
data: {"class":"achievement.award","badgeUrl":"http://devt.ala.org.au//data/volunteer-portal/achievements/c9d40d75-6cd9-4d83-ae96-110e6efe07bb.png","title":"Congratulations!","id":8702543,"message":"You were just awarded the Completed 30 Tasks achievement!","profileUrl":"/volunteer-portal/user/notebook"}

"""
    }

    void "test id and event"() {
        setup:
        def msg = new EventSourceMessage(id: '1', event: 'event')
        def sw = new StringWriter()

        when:
        msg.writeTo(sw)

        then:
        sw.toString() == """id: 1
event: event

"""
    }

    void "test comment"() {
        setup:
        def msg = new EventSourceMessage(comment: 'ka')
        def sw = new StringWriter()

        when:
        msg.writeTo(sw)

        then:
        sw.toString() == """: ka

"""
    }

    void "test write multiple data"() {
        setup:
        def msg = new EventSourceMessage(event: 'e', data: [msg: 'msg'])
        def msg2 = new EventSourceMessage(event: 'e', data: [msg: 'msg2'])
        def sw = new StringWriter()

        when:
        msg.writeTo(sw)
        msg.writeTo(sw)
        msg2.writeTo(sw)

        then:
        sw.toString() == """event: e
data: {"msg":"msg"}

event: e
data: {"msg":"msg"}

event: e
data: {"msg":"msg2"}

"""
    }

    void "test gstring"() {
        setup:
        final val = 37
        def msg = new EventSourceMessage(event: 'e', data: [msg: "$val times".toString()])
        def sw = new StringWriter()

        when:
        msg.writeTo(sw)

        then:
        sw.toString() == """event: e
data: {"msg":"37 times"}

"""
    }

    // helper methods

}