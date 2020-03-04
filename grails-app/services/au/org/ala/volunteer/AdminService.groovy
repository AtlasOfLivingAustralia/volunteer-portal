package au.org.ala.volunteer

import grails.transaction.Transactional

@Transactional
class AdminService {

    @Transactional(readOnly = true)
    def getCustomLandingPageSettings () {
       List<Label> landingPages = LandingPage.findAllByEnabled(true)
       landingPages
    }
}