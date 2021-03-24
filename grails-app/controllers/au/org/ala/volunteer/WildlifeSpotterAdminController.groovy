package au.org.ala.volunteer

import com.google.common.hash.HashCode
import grails.converters.JSON
import grails.transaction.Transactional
import org.apache.commons.io.FilenameUtils
import org.springframework.web.multipart.MultipartFile

import static javax.servlet.http.HttpServletResponse.*

class WildlifeSpotterAdminController {

    def userService
    def fileUploadService

    def templateConfig(long id) {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def template = Template.get(id)
        def viewParams2 = template.viewParams2 ?: [ categories: [], animals: [] ]
        [id: id, templateInstance: template, viewParams2: viewParams2]
    }

    @Transactional
    def saveTemplateConfig(long id) {
        if (!userService.isAdmin()) {
            respond status: SC_UNAUTHORIZED
            return
        }

        def template = Template.get(id)
        template.viewParams2 = request.getJSON() as Map
        template.save()

        respond status: SC_NO_CONTENT
    }

    def uploadImage() {
        if (!userService.isAdmin()) {
            respond status: SC_UNAUTHORIZED
            return
        }

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
