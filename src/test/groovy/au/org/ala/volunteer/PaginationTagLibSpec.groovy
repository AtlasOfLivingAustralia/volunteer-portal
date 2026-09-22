package au.org.ala.volunteer

import grails.testing.web.taglib.TagLibUnitTest
import org.grails.taglib.GrailsTagException
import spock.lang.Specification

class PaginationTagLibSpec extends Specification implements TagLibUnitTest<PaginationTagLib> {

    void "paginate requires a total"() {
        when:
        applyTemplate('<cl:paginate />')

        then:
        thrown GrailsTagException
    }

    void "paginate renders steps for the first page"() {
        when:
        def paginate = applyTemplate('<cl:paginate controller="test" action="index" total="20" />')

        then:
        paginate == '<ul class="pagination"><li class="prev disabled"><span>&laquo;</span></li><li class="active"><span>1</span></li><li><a href="/test/index?offset=10&amp;max=10" class="step">2</a></li><li class="next"><a href="/test/index?offset=10&amp;max=10" class="step">&raquo;</a></li></ul>'
    }
}