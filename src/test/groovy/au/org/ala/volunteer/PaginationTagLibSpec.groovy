package au.org.ala.volunteer

import grails.testing.web.taglib.TagLibUnitTest
import org.grails.taglib.GrailsTagException
import spock.lang.Specification

class PaginationTagLibSpec extends Specification implements TagLibUnitTest<PaginationTagLib> {

    void "total is required"() {
        when:
        applyTemplate('<cl:paginate />')

        then:
        thrown GrailsTagException
    }

    void "first page disables previous and marks step one current"() {
        when:
        def html = applyTemplate('<cl:paginate controller="test" action="index" total="30" />')

        then:
        html.startsWith('<nav aria-label="Pagination"><ul class="pagination">')
        html.contains('<li class="page-item disabled"><span class="page-link" aria-hidden="true">&laquo;</span></li>')
        html.contains('<li class="page-item active" aria-current="page"><span class="page-link">1</span></li>')
        html.contains('aria-label="Next page"')
        html.endsWith('</ul></nav>')
    }

    void "last page disables next"() {
        given:
        params.offset = '20'

        when:
        def html = applyTemplate('<cl:paginate controller="test" action="index" total="30" />')

        then:
        html.contains('<li class="page-item active" aria-current="page"><span class="page-link">3</span></li>')
        html.contains('<li class="page-item disabled"><span class="page-link" aria-hidden="true">&raquo;</span></li>')
        !html.contains('aria-label="Next page"')
    }

    void "a single page renders no step links"() {
        when:
        def html = applyTemplate('<cl:paginate controller="test" action="index" total="5" />')

        then:
        !html.contains('<a')
    }

    void "zero results renders no step links"() {
        when:
        def html = applyTemplate('<cl:paginate controller="test" action="index" total="0" />')

        then:
        !html.contains('<a')
    }

    void "empty prev and next suppress the arrows"() {
        when:
        def html = applyTemplate('<cl:paginate controller="test" action="index" total="30" prev="" next="" />')

        then:
        !html.contains('&laquo;')
        !html.contains('&raquo;')
        html.contains('aria-current="page"')
    }

    void "beyond the first window the ellipsis and first step link appear"() {
        given:
        params.offset = '200'

        when:
        def html = applyTemplate('<cl:paginate controller="test" action="index" total="500" />')

        then:
        html.contains('<li class="page-item disabled"><span class="page-link" aria-hidden="true">&hellip;</span></li>')
        html.contains('>1</a>')
        html.contains('>50</a>')
    }
}