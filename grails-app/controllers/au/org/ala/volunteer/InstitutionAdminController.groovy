package au.org.ala.volunteer

import au.org.ala.volunteer.collectory.CollectoryProviderDto
import au.org.ala.web.AlaSecured
import grails.converters.JSON
import org.springframework.web.multipart.MultipartFile
import org.springframework.web.multipart.MultipartHttpServletRequest
import retrofit.RetrofitError

import static org.springframework.http.HttpStatus.*
import grails.transaction.Transactional

@Transactional(readOnly = true)
@AlaSecured("ROLE_VP_ADMIN")
class InstitutionAdminController {

    static allowedMethods = [save: "POST", update: "PUT", delete: "DELETE", quickCreate: "POST"]

    def collectoryClient
    def institutionService

    def index(Integer max) {
        params.max = Math.min(max ?: 10, 100)
        respond Institution.list(params), model:[institutionInstanceCount: Institution.count()]
    }

    def show(Institution institutionInstance) {
        respond institutionInstance
    }

    def create() {
        respond new Institution(params)
    }

    @Transactional
    def save(Institution institutionInstance) {
        if (institutionInstance == null) {
            notFound()
            return
        }

        if (institutionInstance.hasErrors()) {
            respond institutionInstance.errors, view:'create'
            return
        }

        institutionInstance.save flush:true

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.created.message', args: [message(code: 'institution.label', default: 'Institution'), institutionInstance.id])
                redirect institutionInstance
            }
            '*' { respond institutionInstance, [status: CREATED] }
        }
    }

    def edit(Institution institutionInstance) {
        respond institutionInstance
    }

    @Transactional
    def update(Institution institutionInstance) {
        if (institutionInstance == null) {
            notFound()
            return
        }

        if (institutionInstance.hasErrors()) {
            respond institutionInstance.errors, view:'edit'
            return
        }

        institutionInstance.save flush:true

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.updated.message', args: [message(code: 'Institution.label', default: 'Institution'), institutionInstance.id])
                redirect institutionInstance
            }
            '*'{ respond institutionInstance, [status: OK] }
        }
    }

    @Transactional
    def delete(Institution institutionInstance) {

        if (institutionInstance == null) {
            notFound()
            return
        }

        institutionInstance.delete flush:true

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.deleted.message', args: [message(code: 'Institution.label', default: 'Institution'), institutionInstance.id])
                redirect action:"index", method:"GET"
            }
            '*'{ render status: NO_CONTENT }
        }
    }

    @Transactional
    def quickCreate(String cid) {
        def existing = Institution.executeQuery("select id from Institution where collectoryUid = :cid", [cid: cid])
        if (existing) {
            response.setHeader('Location', createLink(action: 'show', id: existing[0]))
            render status: SEE_OTHER
            return
        }
        CollectoryProviderDto collectoryObject = null;
        try {

            if (cid.toLowerCase().startsWith("in")) {
                collectoryObject = collectoryClient.getInstitution(cid)
            } else {
                collectoryObject = collectoryClient.getCollection(cid)
            }
        } catch (RetrofitError e) {
            render status: e.networkError ? INTERNAL_SERVER_ERROR : BAD_REQUEST
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
            respond institutionInstance.errors, view:'create'
            return
        }

        institutionInstance.save flush:true

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
            '*'{ render status: NOT_FOUND }
        }
    }

    def uploadBannerImageFragment() {
        def institution = Institution.get(params.int("id"))
        [institutionInstance: institution]
    }

    def uploadLogoImageFragment() {
        def institution = Institution.get(params.int("id"))
        [institutionInstance: institution]
    }


    def uploadInstitutionImage() {
        def institution = Institution.get(params.int("id"))
        def imageType = params.imageType ?: 'banner'

        if (!["banner", "logo"].contains(imageType)) {
            flash.message = "Missing or invalid imageType parameter: " + imageType
            redirect(action:'edit', id: institution.id)
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
                        def result = false
                        if (imageType == 'banner') {
                            result = institutionService.uploadBannerImage(institution, f)
                        } else if (imageType == 'logo') {
                            result = institutionService.uploadLogoImage(institution, f)
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
        redirect(action:'edit', id: institution.id)
    }

}
