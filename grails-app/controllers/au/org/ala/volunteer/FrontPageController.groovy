package au.org.ala.volunteer

import grails.events.EventPublisher
import grails.gorm.transactions.Transactional
import org.springframework.web.multipart.MultipartFile
import java.util.concurrent.TimeUnit

class FrontPageController implements EventPublisher {

    def userService
    def fileUploadService
    def settingsService
    def projectService

    def index() {
        redirect(action: "edit", params: params)
    }

    def edit() {
        if (userService.isAdmin()) {
            ['frontPage': FrontPage.instance()]
        } else {
            render(view: '/notPermitted')
        }
    }

    @Transactional
    def save() {
        if (userService.isAdmin()) {
            def frontPage = FrontPage.instance();

            frontPage.randomProjectOfTheDay = params['randomProjectOfTheDay'] == 'on'
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

            // If Random Project of the Day is selected, and it hasn't been updated today, then update.
            if (frontPage.randomProjectOfTheDay &&
                    projectService.isTimeToUpdateRandomProject(frontPage.randomProjectDateUpdated)) {
                def potdId = projectService.selectRandomProject()
                Project potd = Project.get(potdId)
                if (potd) {
                    frontPage.projectOfTheDay = potd
                    frontPage.randomProjectDateUpdated = new Date()
                } else {
                    flash.message = message(code: 'frontPage.randomProject.fail', default: 'Unable to select random project.') as String
                    redirect(action: "edit", params: params)
                    return
                }
            } else {
                frontPage.projectOfTheDay = (params['projectOfTheDay'] ? Project.get(Long.parseLong(params['projectOfTheDay'])) : frontPage.projectOfTheDay)
            }

            frontPage.save(failOnError: true, flush: true)

            log.info("System Message update: $systemMessageUpdated and ${frontPage.systemMessage}")
            if (systemMessageUpdated) {
                log.info("Sending Alert Message event with ${frontPage.systemMessage}")
                notify(FrontPageService.ALERT_MESSAGE, frontPage.systemMessage)
            }

            flash.message = message(code: 'default.updated.message',
                        args: [message(code: 'frontPage.label', default: 'Front Page'), '']) as String
            redirect(action: "edit")
        } else {
            render(view: '/notPermitted')
        }
    }

    @Transactional
    def uploadHeroImage() {
        if (userService.isAdmin()) {
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
        } else {
            render(view: '/notPermitted')
        }
    }

    def getLogos() {
        if (userService.isAdmin()) {
            def logos = settingsService.getSetting(SettingDefinition.FrontPageLogos)
            respond logos
        } else {
            render(view: '/notPermitted')
        }
    }

    @Transactional
    def addLogoImage() {
        if (userService.isAdmin()) {
            Map<String, List<MultipartFile>> fileMap = request.multiFileMap
            try {
                def results = fileUploadService.uploadImages('logos', fileMap)
                results.collectMany { it.error ? [it] : [] }.each { log.error("Couldn't upload ${it.k}", it.error) }
                def additionalLogos = results.collectMany { it.file ? [it.file.name] : [] }
                def logos = settingsService.getSetting(SettingDefinition.FrontPageLogos)
                def newLogos = logos + additionalLogos
                settingsService.setSetting(SettingDefinition.FrontPageLogos.key, newLogos)
                redirect(action: 'edit')
            } catch (e) {
                log.error("Exception uploading logos", e)
                flash.message = 'Error uploading images'
                redirect(action: 'edit')
            }
        } else {
            render(view: '/notPermitted')
        }
    }

    @Transactional
    def updateLogoImages() {
        if (userService.isAdmin()) {
            def logos = request.getJSON()
            if (logos instanceof List) {
                settingsService.setSetting(SettingDefinition.FrontPageLogos.key, (List<String>) logos)
                def x = settingsService.getSetting(SettingDefinition.FrontPageLogos)
                respond x
            } else {
                response.sendError(400)
            }
        } else {
            render(view: '/notPermitted')
        }
    }

}
