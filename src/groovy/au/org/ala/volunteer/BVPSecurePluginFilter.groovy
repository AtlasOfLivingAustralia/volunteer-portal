package au.org.ala.volunteer

import au.org.ala.web.SecurityPrimitives
import org.apache.log4j.Logger
import org.springframework.web.context.request.RequestContextHolder

import javax.servlet.Filter
import javax.servlet.FilterChain
import javax.servlet.FilterConfig
import javax.servlet.ServletException
import javax.servlet.ServletRequest
import javax.servlet.ServletResponse
import javax.servlet.http.HttpServletRequest
import java.util.regex.Pattern

class BVPSecurePluginFilter implements Filter {

    /*
    <filter>
        <filter-name>BVPSecurePluginFilter</filter-name>
        <filter-class>au.org.ala.volunteer.BVPSecurePluginFilter</filter-class>
    </filter>

    <filter-mapping>
        <filter-name>BVPSecurePluginFilter</filter-name>
        <url-pattern>/monitoring</url-pattern>
        <url-pattern>/metrics</url-pattern>
        <url-pattern>/metrics/*</url-pattern>
    </filter-mapping>
    */
    
    private static final Logger logger = Logger.getLogger(BVPSecurePluginFilter)

    SecurityPrimitives securityPrimitives

    def urls = [ Pattern.compile('.*/monitoring')
                ,Pattern.compile('.*/metrics(/.*)?')
                ]

    @Override
    void init(FilterConfig filterConfig) throws ServletException {
        //securityPrimitives = ApplicationContextHolder.applicationContext.getBean(SecurityPrimitives)
    }

    @Override
    void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain chain) throws IOException, ServletException {
        def request = servletRequest as HttpServletRequest
        //logger.error(RequestContextHolder.currentRequestAttributes().getRequest().getUserPrincipal())
        if (request) {
            request.getSession().getServletContext()

            String requestUri = request.getRequestURI()
            if (urls.any { p -> p.matcher(requestUri).find() }) {
                if (securityPrimitives.isAnyGranted([CASRoles.ROLE_ADMIN])) {
                    logger.debug("Allowing access to $requestUri because admin role is granted")
                    chain.doFilter(servletRequest, servletResponse)
                } else {
                    logger.warn("Access denied to $requestUri because admin role is not granted")
                }
            } else {
                logger.debug("Allowing access to $requestUri because it's not in the filter list")
                chain.doFilter(servletRequest, servletResponse)
            }

        } else {
            logger.debug("Allowing access because there is no request")
            chain.doFilter(servletRequest, servletResponse)
        }
    }

    @Override
    void destroy() {
        securityPrimitives = null
    }
}
