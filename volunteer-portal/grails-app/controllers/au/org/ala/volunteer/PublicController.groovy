package au.org.ala.volunteer

class PublicController {

    def index = { }

    /**
     * Do logouts through this app so we can invalidate the session.
     *
     * @param casUrl the url for logging out of cas
     * @param appUrl the url to redirect back to after the logout
     */
    def logout = {
        session.invalidate()
        redirect(url: "${params.casUrl}?url=${params.appUrl}")
    }
}
