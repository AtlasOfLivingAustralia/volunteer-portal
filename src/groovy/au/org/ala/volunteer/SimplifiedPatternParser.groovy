package au.org.ala.volunteer

import java.util.regex.Pattern

class SimplifiedPatternParser {

    static String RESERVED = ".[]\$^\\|?*()+"

    public static Pattern compile(String pattern) {
        def regex =  "^" + pattern.replaceAll("\\(\\*\\)", new String([1] as char[])) + "\$"
        regex = regex.replaceAll("\\*", new String([2] as char[]))
        def sb = new StringBuilder()
        regex.each { ch->
            if (RESERVED.contains(ch)) {
                sb << ch
            } else if (ch == 1) {
                sb << "(.*?)"
            } else if (ch == 2) {
                sb << ".*"
            } else {
                sb << ch
            }
        }

        return Pattern.compile(sb.toString())
    }

}
