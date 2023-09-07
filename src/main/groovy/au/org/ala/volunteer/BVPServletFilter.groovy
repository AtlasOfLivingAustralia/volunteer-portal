package au.org.ala.volunteer

//import org.apache.log4j.Logger
import groovy.util.logging.Slf4j

import javax.servlet.Filter
import javax.servlet.FilterConfig
import javax.servlet.ServletRequest
import javax.servlet.ServletResponse
import javax.servlet.FilterChain
import javax.servlet.http.HttpServletRequest
import au.org.ala.cas.util.AuthenticationCookieUtils
import java.util.regex.Pattern
import java.util.regex.Matcher

@Slf4j
class BVPServletFilter implements Filter  {

    //private static final Logger logger = Logger.getLogger(BVPServletFilter.class)
    
    private List<Pattern> _filterPatterns;

    void init(FilterConfig filterConfig) {
        _filterPatterns = new ArrayList<Pattern>();
        addPattern("/plugins/.*")
        addPattern("/monitoring")
        addPattern("/assets/.*")
        addPattern("/static/.*")
        //addPattern("/image/.*")
        addPattern("/es")
        addPattern("/admin/userActivityInfo")
    }

    private void addPattern(String pattern) {
        _filterPatterns.add(Pattern.compile(pattern))
    }

    void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) {
        try {
            def request = servletRequest as HttpServletRequest
            if (request) {
                def contextPath = request.servletContext.contextPath
                boolean doLog = true;
                String requestUri = request.requestURI - contextPath
                for (Pattern p : _filterPatterns) {
                    Matcher m = p.matcher(requestUri)
                    if (m.find()) {
                        doLog = false;
                        break;
                    }
                }

                def session = request.getSession(false)

                if (doLog) {
                    def username = AuthenticationCookieUtils.getUserName(request) ?: "unknown"
                    def userAgent = request.getHeader("user-agent")
                    log.info "Session: ${session?.id} User: ${username} IP: ${request.remoteAddr} UA: ${userAgent} URI: ${request.requestURI}"
                }
//                request.getHeaderNames().each {
//                    println it + " = " + request.getHeader(it)
//                }
            }
        } finally {
            filterChain.doFilter(servletRequest, servletResponse)
        }
    }

    void destroy() {
    }
}
