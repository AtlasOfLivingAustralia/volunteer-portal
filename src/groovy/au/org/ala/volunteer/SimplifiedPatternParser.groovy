package au.org.ala.volunteer

import java.util.regex.Pattern

/**
 * Created with IntelliJ IDEA.
 * User: baird
 * Date: 30/11/12
 * Time: 4:56 PM
 * To change this template use File | Settings | File Templates.
 */
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
