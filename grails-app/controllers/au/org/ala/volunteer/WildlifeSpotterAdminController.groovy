package au.org.ala.volunteer

import com.google.common.hash.HashCode
import grails.converters.JSON
import grails.transaction.Transactional
import org.apache.commons.io.FilenameUtils
import org.springframework.web.multipart.MultipartFile

import javax.imageio.ImageIO

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
        MultipartFile animal = request.getFile('animal')
        if (animal) {
            def file = fileUploadService.uploadImage('wildlifespotter', animal) { MultipartFile f, HashCode h ->
                h.toString() + "." + fileUploadService.extension(f)
            }
            def hash = FilenameUtils.getBaseName(file.name)
            def ext = FilenameUtils.getExtension(file.name)
            // 446 x 305
//            def image = ImageIO.read(file)
//            if (!image) {
//                log.warn("WildlifeSpotter animal upload ${animal.originalFilename} could not be read as an image")
//                render([error: "${animal.originalFilename} could not be read as an image"] as JSON, status: 500)
//            }
//            def scaledFile = fileWithClassifier(file, 'scaled', 'jpg')
//            if (!scaledFile.exists()) {
//                def scaled = ImageUtils.centreCropAndScale(image, 446, 305)
//                ImageIO.write(scaled, "jpg", scaledFile)
//                scaled.flush()
//                log.info("Scaled and saved $scaledFile")
//            } else {
//                log.info("$scaledFile already exists so skipping generating it")
//            }
//            // Orig WS: 146 x 107, Digivol WS: 150 x 150
//            def thumbFile = fileWithClassifier(file, 'thumb', 'jpg')
//            if (!thumbFile.exists()) {
//                def thumb = ImageUtils.centreCropAndScale(image, 150, 150)
//                ImageIO.write(thumb, 'jpg', thumbFile)
//                thumb.flush()
//                log.info("Scaled and saved $thumbFile")
//            } else {
//                log.info("$thumbFile already exists so skipping generating it")
//            }
//            image.flush()
            render([ hash: hash, format: ext ] as JSON)
        } else {
            MultipartFile entry = request.getFile('entry')
            def file = fileUploadService.uploadImage('wildlifespotter', entry) { MultipartFile f, HashCode h ->
                h.toString() + "." + fileUploadService.extension(f)
            }
            def hash = FilenameUtils.getBaseName(file.name)
            def ext = FilenameUtils.getExtension(file.name)
            // 156 x 52
//            def image = ImageIO.read(file)
//            if (!image) {
//                log.warn("WildlifeSpotter entry upload ${entry.originalFilename} could not be read as an image")
//                render([error: "${entry.originalFilename} could not be read as an image"] as JSON, status: 500)
//            }
//            def scaledFile = fileWithClassifier(file, 'category', 'png')
//            if (!scaledFile.exists()) {
//                def scaled = ImageUtils.centreCropAndScale(image, 156, 52)
//                ImageIO.write(scaled, "png", scaledFile)
//                scaled.flush()
//                log.info("Scaled and saved $scaledFile")
//            } else {
//                log.info("$scaledFile already exists so skipping generating it")
//            }
            render([ hash: hash, format: ext ] as JSON)
        }

    }

    static File fileWithClassifier(File file, String classifier, String ext) {
        def fullname = file.name
//        def ext = FilenameUtils.getExtension(fullname)
        def name = FilenameUtils.getBaseName(fullname)
        new File(file.parentFile, "${name}_${classifier}.${ext}")
    }

}
