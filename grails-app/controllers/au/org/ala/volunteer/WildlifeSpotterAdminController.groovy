package au.org.ala.volunteer

import com.google.common.hash.HashCode
import grails.converters.JSON
import grails.transaction.Transactional
import org.apache.commons.io.FilenameUtils
import org.springframework.web.multipart.MultipartFile

import javax.imageio.ImageIO
import javax.servlet.http.HttpServletResponse

import static javax.servlet.http.HttpServletResponse.SC_BAD_REQUEST
import static javax.servlet.http.HttpServletResponse.SC_NO_CONTENT

class WildlifeSpotterAdminController {

    def index() {

        redirect(action: "edit", params: params)
    }

    def edit() {
        ['wildlifeSpotter':WildlifeSpotter.instance()]
    }

    @Transactional
    def save() {
        def frontPage = WildlifeSpotter.instance()

        frontPage.bodyCopy = params['bodyCopy']
        frontPage.numberOfContributors = params.int('numberOfContributors') ?: 10
        frontPage.heroImageAttribution = params['heroImageAttribution']

        frontPage.save()

        redirect(action: "edit", params: params)
    }

    def fileUploadService
    def settingsService

    @Transactional
    def uploadHeroImage() {
        if (params.containsKey('clear-hero')) {
            def frontPage = WildlifeSpotter.instance()
            frontPage.heroImage = null
            frontPage.save()

        } else if (params.containsKey('save-hero')) {
            def heroImage = fileUploadService.uploadImage('wildlifespotter', request.getFile('heroImage'))

            def frontPage = WildlifeSpotter.instance()

            frontPage.heroImage = heroImage.name
            frontPage.save()
        }
        redirect(action: 'edit')
    }

    def templateConfig(long id) {
        def template = Template.get(id)
        def viewParams2 = template.viewParams2 ?: [ categories: [], animals: [] ]
        [id: id, templateInstance: template, viewParams2: viewParams2]
    }

    @Transactional
    def saveTemplateConfig(long id) {
        def template = Template.get(id)
        template.viewParams2 = request.getJSON() as Map

        template.save()
        respond status: SC_NO_CONTENT
    }

    def uploadImage() {
        MultipartFile upload = request.getFile('animal') ?: request.getFile('entry')

        if (upload) {
            def file = fileUploadService.uploadImage('wildlifespotter', upload) { MultipartFile f, HashCode h ->
                h.toString() + "." + fileUploadService.extension(f)
            }
            def hash = FilenameUtils.getBaseName(file.name)
            def ext = FilenameUtils.getExtension(file.name)
            render([ hash: hash, format: ext ] as JSON)
        } else {
            render([ error: "One of animal or entry must be provided" ] as JSON, status: SC_BAD_REQUEST)
        }

    }

}
