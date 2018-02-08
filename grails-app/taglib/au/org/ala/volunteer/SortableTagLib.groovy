package au.org.ala.volunteer

import org.springframework.web.servlet.support.RequestContextUtils

class SortableTagLib {

    static namespace = 's'

    static defaultEncodeAs = [taglib: 'raw']
    //static encodeAsForTags = [tagName: [taglib:'html'], otherTagName: [taglib:'none']]

    /**
     * Renders a sortable column to support sorting in list views.<br/>
     *
     * Attribute title or titleKey is required. When both attributes are specified then titleKey takes precedence,
     * resulting in the title caption to be resolved against the message source. In case when the message could
     * not be resolved, the title will be used as title caption.<br/>
     *
     * Examples:<br/>
     *
     * &lt;g:sortableColumn property="title" title="Title" /&gt;<br/>
     * &lt;g:sortableColumn property="title" title="Title" style="width: 200px" /&gt;<br/>
     * &lt;g:sortableColumn property="title" titleKey="book.title" /&gt;<br/>
     * &lt;g:sortableColumn property="releaseDate" defaultOrder="desc" title="Release Date" /&gt;<br/>
     * &lt;g:sortableColumn property="releaseDate" defaultOrder="desc" title="Release Date" titleKey="book.releaseDate" /&gt;<br/>
     *
     * @emptyTag
     *
     * @attr tag - the type of tag
     * @attr property - i18nName of the property relating to the field
     * @attr defaultOrder default order for the property; choose between asc (default if not provided) and desc
     * @attr title title caption for the column
     * @attr titleKey title key to use for the column, resolved against the message source
     * @attr params a map containing request parameters
     * @attr action the i18nName of the action to use in the link, if not specified the list action will be linked
     * @attr params A map containing URL query parameters
     * @attr class CSS class i18nName
     */
    Closure sortableColumn = { attrs ->
        def writer = out
        if (!attrs.property) {
            throwTagError(message(code: "sortableTagLib.tag_x_missing_attribute_y", args: ["sortableColumn","property"]))
        }

        if (!attrs.title && !attrs.titleKey) {
            throwTagError(message(code: "sortableTagLib.tag_x_missing_attribute_y_or_z", args: ["sortableColumn","i18nTitle", "titleKey"]))
        }

        def property = attrs.remove("property")
        def action = attrs.action ? attrs.remove("action") : (actionName ?: "list")

        def defaultOrder = attrs.remove("defaultOrder")
        if (defaultOrder != "desc") defaultOrder = "asc"

        def tag = attrs.remove("tag")
        if (!tag) {
            throwTagError(message(code: "sortableTagLib.tag_x_missing_attribute_y", args: ["sortableColumn","tag"]))
        }

        // current sorting property and order
        def sort = params.sort
        def order = params.order

        // add sorting property and params to link params
        def linkParams = [:]
        if (params.id) linkParams.put("id", params.id)
        def paramsAttr = attrs.remove("params")
        if (paramsAttr) linkParams.putAll(paramsAttr)
        linkParams.sort = property

        // propagate "max" and "offset" standard params
        if (params.max) linkParams.max = params.max
        if (params.offset) linkParams.offset = params.offset

        // determine and add sorting order for this column to link params
        attrs.class = (attrs.class ? "${attrs.class} sortable" : "sortable")
        if (property == sort) {
            attrs.class = attrs.class + " sorted " + order
            if (order == "asc") {
                linkParams.order = "desc"
            }
            else {
                linkParams.order = "asc"
            }
        }
        else {
            linkParams.order = defaultOrder
        }

        // determine column title
        def title = attrs.remove("title")
        def titleKey = attrs.remove("titleKey")
        def mapping = attrs.remove('mapping')
        if (titleKey) {
            if (!title) title = titleKey
            def messageSource = grailsAttributes.messageSource
            def locale = RequestContextUtils.getLocale(request)
            title = messageSource.getMessage(titleKey, null, title, locale)
        }

        writer << "<$tag "
        // process remaining attributes
        attrs.each { k, v ->
            writer << "${k}=\"${v?.encodeAsHTML()}\" "
        }
        writer << '>'
        def linkAttrs = [params: linkParams]
        if (mapping) {
            linkAttrs.mapping = mapping
        }

        linkAttrs.action = action

        writer << link(linkAttrs) {
            title
        }
        writer << "</$tag>"
    }
}
