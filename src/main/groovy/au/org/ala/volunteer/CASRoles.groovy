package au.org.ala.volunteer

import grails.core.GrailsApplication;

/**
 * Provides role names that could be overridden in external config
 */
public class CASRoles {

    private static CASRoles _instance = null
    private static String DEFAULT_ROLE_ADMIN = "ROLE_VP_ADMIN";
    private static String DEFAULT_ROLE_VALIDATOR = "ROLE_VP_VALIDATOR";

    private GrailsApplication grailsApplication

    private CASRoles() {
        // grab a reference to the grailsApplication
        this.grailsApplication = ApplicationContextHolder.grailsApplication
    }

    public static synchronized CASRoles getInstance() {
        if (!_instance) {
            _instance = new CASRoles();
        }
        return _instance
    }

    public static String getROLE_ADMIN() {
        return getInstance().getRoleAdmin()
    }

    public static String getROLE_VALIDATOR() {
        return getInstance().getRoleValidator()
    }

    public String getRoleAdmin() {
        return grailsApplication.config.security.cas.adminRole ?: DEFAULT_ROLE_ADMIN
    }

    public String getRoleValidator() {
        return grailsApplication.config.security.cas.validatorRole ?: DEFAULT_ROLE_VALIDATOR
    }

}
