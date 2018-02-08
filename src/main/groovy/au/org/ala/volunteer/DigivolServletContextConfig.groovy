package au.org.ala.volunteer

import org.springframework.boot.web.servlet.ServletContextInitializer

import javax.servlet.ServletContext
import javax.servlet.ServletException

class DigivolServletContextConfig implements ServletContextInitializer {
    @Override
    void onStartup(ServletContext servletContext) throws ServletException {
        servletContext.addListener(BVPSessionListener.class)
    }
}
