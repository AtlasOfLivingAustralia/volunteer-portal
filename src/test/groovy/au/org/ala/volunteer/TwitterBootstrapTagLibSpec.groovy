package au.org.ala.volunteer

import grails.testing.web.taglib.TagLibUnitTest

//import grails.test.mixin.TestFor
import org.grails.taglib.GrailsTagException
import spock.lang.Specification

/**
 * See the API for {@link grails.test.mixin.web.GroovyPageUnitTestMixin} for usage instructions
 */
//@TestFor(TwitterBootstrapTagLib)
class TwitterBootstrapTagLibSpec extends Specification implements TagLibUnitTest<TwitterBootstrapTagLib> {

    def setup() {
        grailsApplication.config.grails.plugins.twitterbootstrap.fixtaglib = true
    }

    def cleanup() {
    }

    void "test paginate tag"() {
        when:
        applyTemplate('<g:paginate />')

        then:
        thrown GrailsTagException

        when:
        def paginate = applyTemplate('<g:paginate controller="test" action="index" total="20" />')

        then:
        paginate == '<ul class="pagination"><li class="prev disabled"><span>&laquo;</span></li><li class="active"><span>1</span></li><li><a href="/test/index?offset=10&amp;max=10" class="step">2</a></li><li class="next"><a href="/test/index?offset=10&amp;max=10" class="step">&raquo;</a></li></ul>'
    }
}
