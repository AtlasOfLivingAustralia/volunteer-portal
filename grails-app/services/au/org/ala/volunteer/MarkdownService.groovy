package au.org.ala.volunteer

import com.vladsch.flexmark.html2md.converter.FlexmarkHtmlConverter
import com.vladsch.flexmark.util.ast.Node
import com.vladsch.flexmark.html.HtmlRenderer
import com.vladsch.flexmark.parser.Parser
import groovy.util.logging.Slf4j

@Slf4j
class MarkdownService {

    def sanitizerService

    /**
     * Parses markdown into HTML, sanitizes and then returns to markdown.
     * @param markdown the markdown to process
     * @return the sanitized markdown
     */
    def sanitizeMarkdown(String markdown) {
        Parser parser = Parser.builder().build();
        Node document = parser.parse(markdown ?: "")
        HtmlRenderer renderer = HtmlRenderer.builder().build()
        def html = sanitizerService.sanitize(renderer.render(document))
        def md = FlexmarkHtmlConverter.builder().build().convert(html)
        md
    }

    /**
     * Renders markdown to HTML and sanitizes the generated HTML before returning.
     * @param markdown The markdown to process.
     * @return the sanitized HTML generated from the supplied markdown.
     */
    def renderMarkdown(String markdown) {
        Parser parser = Parser.builder().build();
        Node document = parser.parse(markdown ?: "")
        HtmlRenderer renderer = HtmlRenderer.builder().build()
        def md = sanitizerService.sanitize(renderer.render(document))
        log.info("Returning markdown: ${md}")
        md
    }
}
