package au.org.ala.volunteer

class MarkdownTagLib {

    static namespace = "markdown"

    def markdownService

    def renderHtml = { attrs, body ->
        String text
        if(attrs.template) {
            text = g.render(template: attrs.template)
        } else {
            text = attrs.text ?: body()
        }
        out << markdownService.renderMarkdown(text)
    }
}
