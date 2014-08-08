package au.org.ala.volunteer

import au.org.ala.volunteer.collectory.CollectoryProviderDto
import au.org.ala.web.AlaSecured
import retrofit.RetrofitError

import static org.springframework.http.HttpStatus.*
import grails.transaction.Transactional

@Transactional(readOnly = true)
@AlaSecured("ROLE_VP_ADMIN")
class InstitutionController {

    static allowedMethods = [save: "POST", update: "PUT", delete: "DELETE", quickCreate: "POST"]

    def collectoryClient

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
}
