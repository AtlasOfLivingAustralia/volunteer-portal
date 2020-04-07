package au.org.ala.volunteer

import spock.lang.Specification

class WebUtilsSpec extends Specification {

    def 'test stripNonPrintableCharacters'(String input, String result) {
        expect:
        result == WebUtils.stripNonPrintableCharacters(input)

        where:
        input || result
        'Aasdf' | 'Aasdf'
        '\0\1\2\3\4\5\6\7' | ''
        '🌟ひかり, ヒカリ, 光🏳\0️‍⚧️' | '🌟ひかり, ヒカリ, 光🏳️‍⚧️'
        '\0'   | ''
        '\0\n\r\0\n\r\0' | '\n\r\n\r'
        '\uD800\uDC00\0' | '\uD800\uDC00'
    }
}
