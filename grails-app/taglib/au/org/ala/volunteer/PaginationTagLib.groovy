package au.org.ala.volunteer

import org.springframework.web.servlet.support.RequestContextUtils as RCU

class PaginationTagLib {
    static defaultEncodeAs = [taglib: 'none']

    static namespace = "cl"

    /**
     * Creates next/previous links to support pagination for the current controller.<br/>
     *
     * &lt;cl:paginate total="${Account.count()}" /&gt;<br/>
     *
     * @emptyTag
     *
     * @attr total REQUIRED The total number of results to paginate
     * @attr action the name of the action to use in the link, if not specified the default action will be linked
     * @attr controller the name of the controller to use in the link, if not specified the current controller will be linked
     * @attr id The id to use in the link
     * @attr params A map containing request parameters
     * @attr max The number of records displayed per page (defaults to 10). Used ONLY if params.max is empty
     * @attr maxsteps The number of steps displayed for pagination (defaults to 10). Used ONLY if params.maxsteps is empty
     * @attr offset Used only if params.offset is empty
     * @attr fragment The link fragment (often called anchor tag) to use
     * @attr namespace The namespace to use in the link
     * @attr mapping The URL mapping to use in the link
     * @attr prev Text for the previous link (default: &laquo;, or default.paginate.prev from messages.properties). Pass "" to suppress.
     * @attr next Text for the next link (default: &raquo;, or default.paginate.next from messages.properties). Pass "" to suppress.
     * @attr ariaLabel Accessible name for the wrapping nav element (default: "Pagination")
     */
    def paginate = { attrs ->

        def writer = out
        if (attrs.total == null) {
            throwTagError("Tag [paginate] is missing required attribute [total]")
        }
        def messageSource = grailsAttributes.messageSource
        def locale = RCU.getLocale(request)

        def total = attrs.int('total') ?: 0
        def action = (attrs.action ? attrs.action : (params.action ? params.action : "index"))
        def offset = params.int('offset') ?: 0
        def max = params.int('max')
        def maxsteps = (attrs.int('maxsteps') ?: 10)

        if (!offset) offset = (attrs.int('offset') ?: 0)
        if (!max) max = (attrs.int('max') ?: 10)

        def linkParams = [:]
        if (attrs.params) linkParams.putAll(attrs.params)
        linkParams.offset = offset - max
        linkParams.max = max
        if (params.sort) linkParams.sort = params.sort
        if (params.order) linkParams.order = params.order

        def linkTagAttrs = [action: action]
        if (attrs.namespace) {
            linkTagAttrs.namespace = attrs.namespace
        }
        if (attrs.controller) {
            linkTagAttrs.controller = attrs.controller
        }
        if (attrs.id != null) {
            linkTagAttrs.id = attrs.id
        }
        if (attrs.fragment != null) {
            linkTagAttrs.fragment = attrs.fragment
        }
        //add the mapping attribute if present
        if (attrs.mapping) {
            linkTagAttrs.mapping = attrs.mapping
        }

        linkTagAttrs.params = linkParams

        def cssClasses = "pagination"
        if (attrs.class) {
            cssClasses = "pagination " + attrs.class
        }

        // "" must suppress the arrow, so test for null rather than truthiness
        def prevText = attrs.prev != null ? attrs.prev
                : messageSource.getMessage('default.paginate.prev', null, '&laquo;', locale)
        def nextText = attrs.next != null ? attrs.next
                : messageSource.getMessage('default.paginate.next', null, '&raquo;', locale)

        // determine paging variables
        def steps = maxsteps > 0
        int currentstep = (offset / max) + 1
        int firststep = 1
        int laststep = Math.ceil(total / max)

        linkTagAttrs.class = 'page-link'

        writer << "<nav aria-label=\"${attrs.ariaLabel ?: 'Pagination'}\">"
        writer << "<ul class=\"${cssClasses}\">"

        if (prevText) {
            if (currentstep > firststep) {
                linkParams.offset = offset - max
                writer << '<li class="page-item">'
                writer << g.link(linkTagAttrs.clone() + ["aria-label": 'Previous page']) { prevText }
                writer << '</li>'
            } else {
                writer << '<li class="page-item disabled">'
                writer << "<span class=\"page-link\" aria-hidden=\"true\">${prevText}</span>"
                writer << '</li>'
            }
        }

        // display steps when steps are enabled and laststep is not firststep
        if (steps && laststep > firststep) {

            // determine begin and endstep paging variables
            int beginstep = currentstep - Math.round(maxsteps / 2) + (maxsteps % 2)
            int endstep = currentstep + Math.round(maxsteps / 2) - 1

            if (beginstep < firststep) {
                beginstep = firststep
                endstep = maxsteps
            }
            if (endstep > laststep) {
                beginstep = laststep - maxsteps + 1
                if (beginstep < firststep) {
                    beginstep = firststep
                }
                endstep = laststep
            }

            // display firststep link when beginstep is not firststep
            if (beginstep > firststep) {
                linkParams.offset = 0
                writer << '<li class="page-item">'
                writer << g.link(linkTagAttrs.clone()) { firststep.toString() }
                writer << '</li>'
                writer << ellipsis()
            }

            // display paginate steps
            (beginstep..endstep).each { i ->
                if (currentstep == i) {
                    writer << '<li class="page-item active" aria-current="page">'
                    writer << "<span class=\"page-link\">${i}</span>"
                    writer << '</li>'
                } else {
                    linkParams.offset = (i - 1) * max
                    writer << '<li class="page-item">'
                    writer << g.link(linkTagAttrs.clone()) { i.toString() }
                    writer << '</li>'
                }
            }

            // display laststep link when endstep is not laststep
            if (endstep < laststep) {
                writer << ellipsis()
                linkParams.offset = (laststep - 1) * max
                writer << '<li class="page-item">'
                writer << g.link(linkTagAttrs.clone()) { laststep.toString() }
                writer << '</li>'
            }
        }

        if (nextText) {
            if (currentstep < laststep) {
                linkParams.offset = offset + max
                writer << '<li class="page-item">'
                writer << g.link(linkTagAttrs.clone() + ["aria-label": 'Next page']) { nextText }
                writer << '</li>'
            } else {
                writer << '<li class="page-item disabled">'
                writer << "<span class=\"page-link\" aria-hidden=\"true\">${nextText}</span>"
                writer << '</li>'
            }
        }

        writer << '</ul>'
        writer << '</nav>'
    }

    private static String ellipsis() {
        '<li class="page-item disabled"><span class="page-link" aria-hidden="true">&hellip;</span></li>'
    }
}
