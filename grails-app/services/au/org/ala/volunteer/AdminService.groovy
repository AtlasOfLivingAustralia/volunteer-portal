package au.org.ala.volunteer

import grails.gorm.transactions.Transactional

@Transactional
class AdminService {

    @Transactional(readOnly = true)
    def getCustomLandingPageSettings () {
       List<Label> landingPages = LandingPage.findAllByEnabled(true)
       landingPages
    }
}