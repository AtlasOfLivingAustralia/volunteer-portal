package au.org.ala.volunteer

import grails.testing.web.controllers.ControllerUnitTest
import spock.lang.Specification

class IndexControllerSpec extends Specification implements ControllerUnitTest<IndexController> {

    def "stats ignores lowercase null and empty tag values"() {
        given:
        List<String> receivedTags = null
        controller.volunteerStatsService = Stub(VolunteerStatsService) {
            generateStats(-1L, '', ['fieldnotes'], false, false) >> { long institutionId, String projectType, List<String> tags, boolean disableStats, boolean disableHonourBoard ->
                receivedTags = tags
                [result: true]
            }
        }
        params.tag = 'fieldnotes'
        params.q = 'null'
        params.tags = 'null'

        when:
        controller.stats(-1L, -1L, '')

        then:
        receivedTags == ['fieldnotes']
    }

    def "stats splits comma separated tags and ignores lowercase null values"() {
        given:
        List<String> receivedTags = null
        controller.volunteerStatsService = Stub(VolunteerStatsService) {
            generateStats(-1L, '', ['fieldnotes', 'birds', 'mammals'], false, false) >> { long institutionId, String projectType, List<String> tags, boolean disableStats, boolean disableHonourBoard ->
                receivedTags = tags
                [result: true]
            }
        }
        params.tag = 'fieldnotes'
        params.q = 'null'
        params.tags = 'birds, mammals, null, '

        when:
        controller.stats(-1L, -1L, '')

        then:
        receivedTags == ['fieldnotes', 'birds', 'mammals']
    }
}


