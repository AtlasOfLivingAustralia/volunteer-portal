package au.org.ala.volunteer

import au.org.ala.volunteer.collectory.CollectoryProviderDto
import au.org.ala.web.AlaSecured
import org.springframework.web.multipart.MultipartFile
import org.springframework.web.multipart.MultipartHttpServletRequest
import retrofit2.Call

import static org.springframework.http.HttpStatus.*

@AlaSecured("ROLE_VP_ADMIN")
class InstitutionAdminController {

    static allowedMethods = [save: "POST", update: "PUT", delete: "DELETE", quickCreate: "POST"]

    def collectoryClient
    def institutionService

    def index() {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        [institutionInstanceList: Institution.list(params),institutionInstanceCount: Institution.count()]
    }

    def create() {
        respond new Institution(params)
    }

    def save(Institution institutionInstance) {
        if (institutionInstance == null) {
            notFound()
            return
        }

        if (institutionInstance.hasErrors()) {
            respond institutionInstance.errors, view: 'create'
            return
        }

        institutionInstance.save flush: true

        redirect(action: 'index')

    }

    def edit(Institution institutionInstance) {
        respond institutionInstance
    }

    def editNewsItems(Institution institutionInstance) {
        def newsItems = NewsItem.findAllByInstitution(institutionInstance)
        respond institutionInstance, model: [newsItems: newsItems]
    }

    def updateNewsItems() {
        def institutionInstance = Institution.get(params.id)
        if (!institutionInstance) {
            notFound()
            return
        }
        def pdni = params.getBoolean('disableNewsItems')
        if (institutionInstance.disableNewsItems != pdni) {
            institutionInstance.disableNewsItems = pdni
            institutionInstance.save()
        }
        redirect(action: 'editNewsItems', id: institutionInstance.id)
    }

    def update(Institution institutionInstance) {
        if (institutionInstance == null) {
            notFound()
            return
        }

        if (institutionInstance.hasErrors()) {
            respond institutionInstance.errors, view: 'edit'
            return
        }

        institutionInstance.save flush: true

        redirect(action: 'index')

    }

    def delete(Institution institutionInstance) {

        if (institutionInstance == null) {
            notFound()
            return
        }

        def projects = Project.findAllByInstitution(institutionInstance)
        if (projects) {
            flash.message = "This institution has projects associated with it, and cannot be deleted at this time."
            redirect action: "index", method: "GET"
            return
        }

        institutionInstance.delete flush: true

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.deleted.message', args: [message(code: 'Institution.label', default: 'Institution'), institutionInstance.id])
                redirect action: "index", method: "GET"
            }
            '*' { render status: NO_CONTENT }
        }
    }

    def quickCreate(String cid) {
        def existing = Institution.executeQuery("select id from Institution where collectoryUid = :cid", [cid: cid])
        if (existing) {
            response.setHeader('Location', createLink(action: 'edit', id: existing[0]))
            render status: SEE_OTHER
            return
        }
        CollectoryProviderDto collectoryObject
        try {

            Call<? extends CollectoryProviderDto> call
            if (cid.toLowerCase().startsWith("in")) {
                call = collectoryClient.getInstitution(cid)
            } else {
                call = collectoryClient.getCollection(cid)
            }
            def response = call.execute()
            if (!response.isSuccessful()) {
                render status: BAD_REQUEST
                return
            }

            collectoryObject = response.body()

        } catch (IOException e) {
            log.error("Couldn't connect to collectory", e)
            render status: INTERNAL_SERVER_ERROR
            return
        }
        def institutionInstance = new Institution(
                name: collectoryObject.name,
                description: collectoryObject.pubDescription,
                contactPhone: collectoryObject.phone,
                contactEmail: collectoryObject.email,
                acronym: collectoryObject.acronym,
                websiteUrl: collectoryObject.websiteUrl,
                collectoryUid: cid)

        if (!institutionInstance.validate()) {
            respond institutionInstance.errors, view: 'create'
            return
        }

        institutionInstance.save flush: true

        // Now try and copy any images accross...
        if (collectoryObject.imageRef?.uri) {
            institutionService.uploadImageFromUrl(institutionInstance, collectoryObject.imageRef.uri.toExternalForm())
        }

        if (collectoryObject.logoRef?.uri) {
            institutionService.uploadLogoImageFromUrl(institutionInstance, collectoryObject.logoRef.uri.toExternalForm())
        }

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.created.message', args: [message(code: 'institution.label', default: 'Institution'), institutionInstance.id])
                redirect action: 'index'
            }
            '*' { respond institutionInstance, [status: CREATED] }
        }
    }

    protected void notFound() {
        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.not.found.message', args: [message(code: 'institution.label', default: 'Institution'), params.id])
                redirect action: "index", method: "GET"
            }
            '*' { render status: NOT_FOUND }
        }
    }

    def uploadBannerImageFragment() {
        def institution = Institution.get(params.int("id"))
        render(view: 'uploadInstitutionImageFragment', model: [institutionInstance: institution, imageType: 'banner'])
    }

    def uploadLogoImageFragment() {
        def institution = Institution.get(params.int("id"))
        render(view: 'uploadInstitutionImageFragment', model: [institutionInstance: institution, imageType: 'logo'])
    }

    def uploadInstitutionImageFragment() {
        def institution = Institution.get(params.int("id"))
        [institutionInstance: institution, imageType: 'main']
    }

    def clearLogoImage(Institution institutionInstance) {
        if (institutionInstance) {
            institutionService.clearLogo(institutionInstance)
        }
        redirect(action: 'edit', id: institutionInstance.id)
    }

    def clearBannerImage(Institution institutionInstance) {
        if (institutionInstance) {
            institutionService.clearBanner(institutionInstance)
        }
        redirect(action: 'edit', id: institutionInstance.id)
    }

    def clearImage(Institution institutionInstance) {
        if (institutionInstance) {
            institutionService.clearImage(institutionInstance)
        }
        redirect(action: 'edit', id: institutionInstance.id)
    }

    def uploadInstitutionImage() {
        def institution = Institution.get(params.int("id"))
        def imageType = params.imageType ?: 'banner'

        if (!["banner", "logo", "main"].contains(imageType)) {
            flash.message = "Missing or invalid imageType parameter: " + imageType
            redirect(action: 'edit', id: institution.id)
            return
        }

        if (institution) {
            if (request instanceof MultipartHttpServletRequest) {
                MultipartFile f = ((MultipartHttpServletRequest) request).getFile('imagefile')

                if (f != null && f.size > 0) {
                    def allowedMimeTypes = ['image/jpeg', 'image/png']
                    if (!allowedMimeTypes.contains(f.getContentType())) {
                        flash.message = "Image must be one of: ${allowedMimeTypes}"
                    } else {
                        boolean result
                        switch (imageType) {
                            case "banner":
                                result = institutionService.uploadBannerImage(institution, f)
                                break;
                            case "logo":
                                result = institutionService.uploadLogoImage(institution, f)
                                break;
                            case "main":
                                result = institutionService.uploadImage(institution, f)
                                break;
                            default:
                                throw new RuntimeException("Unhandled image type: ${imageType}")
                        }

                        if (result) {
                            flash.message = "Image uploaded"
                        } else {
                            flash.message = "Failed to upload image. Unknown error!"
                        }
                    }
                } else {
                    flash.message = "Please select a file!"
                }
            } else {
                flash.message = "Form must be multipart file!"
            }
        }
        redirect(action: 'edit', id: institution.id)
    }

}