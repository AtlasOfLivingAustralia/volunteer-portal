package au.org.ala.volunteer

import java.util.regex.Pattern

class TutorialTagLib {

    static namespace = 't'

    def p = { attrs, body ->
        out << '<p class="tutorialText">'
        out << body()
        out << '</p>'
    }

    def ul = { attrs, body ->
        out << '<ul class="tutorialText">'
        out << body()
        out << '</ul>'
    }

    /**
     * @param file The image file in the images/tutorial directory
     */
    def screenshot = { attrs, body ->
        out << '<br/><img class="screenshot" src="' + resource(file:"/images/tutorials/${attrs.file}") + '" />'
    }

    /**
     * @param file The image file in the images/tutorial directory
     */
    def img = { attrs, body ->
        out << '<br /><img class="inlineImage" src="' + resource(file:"images/tutorials/${attrs.file}") + '" />'
    }

    String stripBrackets(String s) {
        return s.replaceAll(Pattern.compile("\\[\\d+\\]"), "")
    }

    def heading(attrs, body, int level) {
        def bodyText = body()
        String tagName = "h${level}"
        out << '<a name="' + bodyText + '" ></a><' + tagName +' >'
        out << stripBrackets(bodyText)
        out << '</' + tagName + '>&nbsp;<a href="#toc">[top]</a>'
    }

    def h2 = { attrs, body ->
        heading(attrs, body, 2)
    }

    def h3 = { attrs, body ->
        heading(attrs, body, 3)
    }

    def h4 = { attrs, body ->
        heading( attrs, body, 4)
    }

    def toc = { attrs, body ->
        out << "<ul>"
        out << body()
        out << "</ul>"
    }

    /**
     * @param anchor
     */
    def tocEntry = { attrs, body ->
        out << '<li><a href="#' + attrs.anchor + '">' + stripBrackets(attrs.anchor) + '</a>'
        out << "<ul>"
        out << body()
        out << "</ul>"
        out << '</li>'
    }


}
