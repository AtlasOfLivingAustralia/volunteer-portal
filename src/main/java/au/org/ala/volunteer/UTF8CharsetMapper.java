package au.org.ala.volunteer;

import org.apache.catalina.util.CharsetMapper;

import java.util.Locale;

public class UTF8CharsetMapper extends CharsetMapper {
    public UTF8CharsetMapper() {
        super();
    }

    public UTF8CharsetMapper(String name) {
        super(name);
    }

    public String getCharset(Locale locale) {
        return "UTF-8";
    }
}
