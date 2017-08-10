package au.org.ala.volunteer

import grails.transaction.Transactional
import org.springframework.web.multipart.MultipartFile

class FrontPageController {

    def index() {

        redirect(action: "edit", params: params)
    }

    def edit() {
        ['frontPage':FrontPage.instance()]
    }

    @Transactional
    def save() {
        def frontPage = FrontPage.instance();

        frontPage.projectOfTheDay = Project.get(Long.parseLong(params['projectOfTheDay']))
        frontPage.numberOfContributors = params.int('numberOfContributors') ?: 10
        frontPage.useGlobalNewsItem = params['useGlobalNewsItem'] == "on"

        frontPage.newsTitle = params["newsTitle"]
        frontPage.newsBody = params["newsBody"]
        frontPage.newsCreated = params["newsCreated"]

        final systemMessageUpdated = frontPage.systemMessage != params["systemMessage"]
        frontPage.systemMessage = params["systemMessage"]

        frontPage.showAchievements = params['showAchievements'] == 'on'
        frontPage.enableTaskComments = params['enableTaskComments'] == 'on'
        frontPage.enableForum = params['enableForum'] == 'on'

        frontPage.heroImageAttribution = params['heroImageAttribution']

        frontPage.save()

        log.info("System Message update: $systemMessageUpdated and ${frontPage.systemMessage}")
        if (systemMessageUpdated) {
            log.info("Sending Alert Message event with ${frontPage.systemMessage}")
            notify(FrontPageService.ALERT_MESSAGE, frontPage.systemMessage)
        }

        flash.message = "${message(code: 'default.updated.message', args: [message(code: 'frontPage.label', default: 'Front Page'), ''])}"
        redirect(action: "edit", params: params)
    }

    def fileUploadService
    def settingsService

    @Transactional
    def uploadHeroImage() {
        if (params.containsKey('clear-hero')) {
            def frontPage = FrontPage.instance()
            frontPage.heroImage = null
            frontPage.save()

        } else if (params.containsKey('save-hero')) {
            def heroImage = fileUploadService.uploadImage('hero', request.getFile('heroImage'))

            def frontPage = FrontPage.instance()

            frontPage.heroImage = heroImage.name
            frontPage.save()
        }
        redirect(action: 'edit')
    }

    def getLogos() {
        def logos = settingsService.getSetting(SettingDefinition.FrontPageLogos)
        respond logos
    }

    @Transactional
    def addLogoImage() {
        Map<String, List<MultipartFile>> fileMap = request.multiFileMap
        try {
            def results = fileUploadService.uploadImages('logos', fileMap)
            results.collectMany { it.error ? [ it ] : [] }.each { log.error("Couldn't upload ${it.k}", it.error)}
            def additionalLogos = results.collectMany { it.file ? [ it.file.name ] : [] }
            def logos = settingsService.getSetting(SettingDefinition.FrontPageLogos)
            def newLogos = logos + additionalLogos
            settingsService.setSetting(SettingDefinition.FrontPageLogos.key, newLogos)
            redirect(action: 'edit')
        } catch (e) {
            log.error("Exception uploading logos", e)
            flash.message = message(code: "frontPage.error_uploading_images")
            redirect(action: 'edit')
        }
    }

    @Transactional
    def updateLogoImages() {
        def logos = request.getJSON()
        if (logos instanceof List) {
            settingsService.setSetting(SettingDefinition.FrontPageLogos.key, (List<String>) logos)
            def x = settingsService.getSetting(SettingDefinition.FrontPageLogos)
            respond x
        } else {
            response.sendError(400)
        }
    }

}
