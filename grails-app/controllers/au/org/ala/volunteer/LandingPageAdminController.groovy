package au.org.ala.volunteer

import au.org.ala.web.AlaSecured
import grails.gorm.transactions.Transactional
import grails.converters.JSON
import static org.springframework.http.HttpStatus.CREATED
import static org.springframework.http.HttpStatus.NO_CONTENT

@AlaSecured(value="ROLE_VP_ADMIN", redirectController = "index", redirectAction="notPermitted")
class LandingPageAdminController {

    def fileUploadService
    def settingsService

    def index(Integer max) {
        params.max = Math.min(max ?: 10, 100)
        respond LandingPage.list(params), model: [landingPageCount: LandingPage.count()]
    }

    def create() {
        def landingPageInstance = chainModel?.landingPage ?: new LandingPage()
        landingPageInstance.label = new HashSet<Label>()
        landingPageInstance.numberOfContributors = 10
        ['landingPageInstance': landingPageInstance, projectTypes: ProjectType.listOrderByName()]
    }

    def edit (LandingPage landingPageInstance) {
        if (!landingPageInstance) {
            if (chainModel?.landingPage) {
                landingPageInstance = chainModel.landingPage
            } else {
                def landingPageId = params['id']
                landingPageInstance = LandingPage.findById(landingPageId)
            }
        }
        ['landingPageInstance': landingPageInstance, projectTypes: ProjectType.listOrderByName()]
    }

    def editImage(LandingPage landingPageInstance) {
        respond landingPageInstance
    }

    def editSelections(LandingPage landingPageInstance) {
        final labelCats = Label.withCriteria { projections { distinct 'category' } }
        ['landingPageInstance': landingPageInstance, 'labels': Label.listOrderByCategory(), 'labelCats': labelCats]
    }

    def filterLabelCategory () {
        def list
        def category = params['category'] ?: null
        if (category != 'all') {
            list = Label.findAllByCategory(category)
        } else {
            list = Label.listOrderByValue()
        }
        render list*.toMap() as JSON
    }

    @Transactional
    def saveProjectLabels(LandingPage landingPageInstance) {

        if (landingPageInstance.hasErrors()) {
            chain action: "edit", model: ['landingPage': landingPageInstance]
        } else {

            def newLabel = Label.findById(params['tag'])
            if (!landingPageInstance.label) {
                landingPageInstance.label = new ArrayList<Label>()
            }

            landingPageInstance.label.add(newLabel)
            landingPageInstance.save flush: true
        }
        redirect(action: "editSelections", params: ['id': landingPageInstance.id])
    }

    @Transactional
    def delete(LandingPage landingPage) {

        if (landingPage == null) {
            notFound()
            return
        }

        landingPage.delete flush: true

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.deleted.message', args: [message(code: 'LandingPageAdmin.label', default: 'Landing Page'), landingPage.id])
                redirect action: "index", method: "GET"
            }
            '*' { render status: NO_CONTENT }
        }
    }

    @Transactional
    def save(LandingPage landingPageInstance) {
        if (landingPageInstance.hasErrors()) {
            if (!landingPageInstance.id) {
                chain action: "create", model: ['landingPage': landingPageInstance]
            } else {
                chain action: "edit", model: ['landingPage': landingPageInstance]
            }
            return
        } else {
            landingPageInstance.save flush: true
        }
        redirect(action: "edit", params: ['id': landingPageInstance.id])
    }

    @Transactional
    def deleteLabel () {
        def landingPageId = params['landingPageId']
        if (landingPageId.isLong()) {
            def landingPage = LandingPage.findById (landingPageId.toLong())
            def labels = landingPage.label
            def labelIdToRemove = params['selectedLabelId']
            if (labelIdToRemove && labelIdToRemove.isLong()) {
                landingPage.label = labels.grep {label ->
                    label.id != labelIdToRemove.toLong()
                }
                landingPage.save(flush: true)
                render status: NO_CONTENT
            }
        }
    }

    @Transactional
    def uploadImage() {
        Long landingPageId = params['id'].toLong()
        def landingPage = LandingPage.findById (landingPageId)
        if (params.containsKey('clear-hero')) {
            landingPage.landingPageImage = null
            landingPage.save(flush: true)

        } else {
            def imageFile = request.getFile('heroImage')
            if (imageFile) {
                def heroImage = fileUploadService.uploadImage('landingPage', imageFile)

                landingPage.landingPageImage = heroImage.name
                landingPage.save(flush: true)
            }
        }
        redirect(action: "editImage", params: ['id': landingPage.id])
    }
}
