package au.org.ala.volunteer

import au.org.ala.volunteer.collectory.CollectoryProviderDto
import com.google.common.base.Strings
import grails.converters.JSON
import grails.gorm.transactions.Transactional
import org.springframework.web.multipart.MultipartFile
import org.springframework.web.multipart.MultipartHttpServletRequest
import retrofit2.Call

import static javax.servlet.http.HttpServletResponse.SC_BAD_REQUEST
import static javax.servlet.http.HttpServletResponse.SC_FORBIDDEN
import static org.springframework.http.HttpStatus.*

// For Institution Admins (DigiVol role), the SpringSecurity role annotation '@AlaSecured("ROLE_VP_ADMIN")'
// needed to be removed. Methods have been updated to do controller-level security checks.
class InstitutionAdminController {

    static allowedMethods = [save: "POST", update: "PUT", delete: "DELETE", quickCreate: "POST"]

    def collectoryClient
    def institutionService
    def userService
    def groovyPageRenderer

    def index() {
        if (!userService.isInstitutionAdmin()) {
            render status: SC_FORBIDDEN
            return
        }

        params.max = Math.min(params.max ? params.int('max') : 20, 100)
        if (!userService.isSiteAdmin()) {
            def institutionList = userService.getAdminInstitutionList()
            respond institutionList,
                model: [institutionInstanceCount: institutionList.size()]
        } else {
            if (!params.sort) params.sort = 'name'
            if (!params.order) params.order = 'asc'

            def searchQ = "%";
            if (params.q) {
                searchQ += "${params.q as String}%"
            }
            if (params.statusFilter && !Strings.isNullOrEmpty(params.statusFilter as String)) {
                respond Institution.findAllByIsInactiveAndIsApprovedAndNameIlike((params.statusFilter == 'inactive'), true, searchQ, params),
                        model: [institutionInstanceCount: Institution.countByIsInactiveAndIsApprovedAndNameIlike((params.statusFilter == 'inactive'), true, searchQ)]
            } else {
                respond Institution.findAllByIsApprovedAndNameIlike(true, searchQ, params),
                        model: [institutionInstanceCount: Institution.countByIsApprovedAndNameIlike(true, searchQ)]
            }
        }
    }

    def applications() {
        if (!userService.isSiteAdmin()) {
            log.error("Admin access requested by ${userService.getCurrentUser()}, failed security check, redirecting.")
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return
        }
        if (!params.sort) params.sort = 'name'
        if (!params.order) params.order = 'asc'
        respond Institution.findAllByIsApproved(false, params),
                model: [institutionInstanceCount: Institution.countByIsApproved(false)]
    }

    def apply() {
        respond new Institution(params)
    }

    def create() {
        if (!userService.isSiteAdmin()) {
            log.error("Admin access requested by ${userService.getCurrentUser()}, failed security check, redirecting.")
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return
        }
        respond new Institution(params)
    }

    def applyConfirm(Institution institution) {
        //Institution institution = Institution.get(params.long('institution'))
        if (!institution) {
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return
        }

        respond institution
    }

    @Transactional
    def save(Institution institution) {
        if (params.entry != 'APPLY' && !userService.isSiteAdmin() && !userService.isInstitutionAdmin(institution)) {
            log.error("Admin access requested by ${userService.getCurrentUser()}, failed security check, redirecting.")
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return
        }

        if (institution == null) {
            notFound()
            return
        }

        if (institution.hasErrors()) {
            respond institution.errors, view: 'create'
            return
        }

        institution.isApproved = (params.isApproved == 'true')
        institution.createdBy = userService.getCurrentUser()

        institution.save(flush: true)

        if (params.entry && params.entry == 'APPLY') {
            // Email notification to admins notifying of application.
            log.info("Sending email notification of new application: ${institution.name}")
            sendApplicationNotification(institution)

            // Email user submitting application for record keeping
            log.info("Sending applicant of new application: ${institution.createdBy}")
            sendApplicantNotification(institution.createdBy, institution)

            redirect(action: 'applyConfirm', id: institution.id)
        } else {
            redirect(action: 'edit', id: institution.id)
        }
    }

    private def sendApplicantNotification(User recipient, Institution institution) {
        if (!recipient || !institution) {
            log.error("Cannot send institution applicant notification as there's no recipient or no institution.")
            return
        }

        // send!
        def model = [institutionName: institution.name,
                     contactName: institution.contactName,
                     contactEmail: institution.contactEmail,
                     contactPhone: institution.contactPhone,
                     returnEmail: grailsApplication.config.grails.contact.emailAddress]
        def title = institutionService.NOTIFICATION_APPLICATION + ": ${institution.name}"
        def message = groovyPageRenderer.render(view: '/institutionAdmin/institutionApplicantNotification',
                model: model)
        institutionService.emailNotification(message, title, recipient.email)
    }

    private def sendApplicationNotification(Institution institution) {
        if (!institution) return
        def model = [institutionName: institution.name,
                contactName: institution.contactName,
                contactEmail: institution.contactEmail,
                contactPhone: institution.contactPhone]
        def title = institutionService.NOTIFICATION_APPLICATION + ": ${institution.name}"
        def message = groovyPageRenderer.render(view: '/institutionAdmin/institutionApplicationNotification',
                model: model)
        institutionService.emailNotification(message, title)
    }

    private def sendApplicationApprovalNotification(Institution institution, String recipient) {
        if (!institution) return
        def model = [institutionName: institution.name,
                     institutionId: institution.id,
                     contactName: institution.contactName,
                     contactEmail: institution.contactEmail,
                     contactPhone: institution.contactPhone]
        def title = institutionService.NOTIFICATION_APPLICATION_APPROVED + ": ${institution.name}"
        def message = groovyPageRenderer.render(view: '/institutionAdmin/institutionApplicationApprovalNotification',
                model: model)
        institutionService.emailNotification(message, title, recipient)
    }

    def edit(Institution institutionInstance) {
        if (!userService.isSiteAdmin() && !userService.isInstitutionAdmin(institutionInstance)) {
            log.error("Admin access requested by ${userService.getCurrentUser()}, failed security check, redirecting.")
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return
        }
        respond institutionInstance
    }

    @Transactional
    def approve(Institution institution) {
        if (institution == null) {
            notFound()
            return
        }

        if (!userService.isSiteAdmin() && !userService.isInstitutionAdmin(institution)) {
            log.error("Admin access requested by ${userService.getCurrentUser()}, failed security check, redirecting.")
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return
        }

        institution.isApproved = true
        institution.save(flush: true, failOnError: true)

        // Make creator Institution Admin
        def creator = institution.createdBy
        def currentUser = userService.getCurrentUser()
        def role = Role.findByName(BVPRole.INSTITUTION_ADMIN)
        def userRole = new UserRole(user: creator, role: role, institution: institution, createdBy: currentUser)
        userRole.save(flush: true, failOnError: true)

        // Email notification
        if (creator.email) {
            log.debug("Institution approved, Recipient: ${creator.email}")
            sendApplicationApprovalNotification(institution, creator.email)
        }

        flash.message = message(code: 'institution.approved.message',
                args: [institution.name]) as String
        redirect(action: 'edit', id: institution.id)
    }

    @Transactional
    def update(Institution institution) {
        if (institution == null) {
            notFound()
            return
        }

        if (!userService.isSiteAdmin() && !userService.isInstitutionAdmin(institution)) {
            log.error("Admin access requested by ${userService.getCurrentUser()}, failed security check, redirecting.")
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return
        }

        if (institution.hasErrors()) {
            respond institution.errors, view: 'edit'
            return
        }

        institution.save flush: true

        // If setting inactive = true, inactivate all child projects


        flash.message = message(code: 'default.updated.message',
                 args: [message(code: 'institution.label', default: 'Institution'), institution.name]) as String
        redirect(action: 'edit', id: institution.id)
    }

    @Transactional
    def delete(Institution institutionInstance) {

        if (institutionInstance == null) {
            notFound()
            return
        }

        if (!userService.isSiteAdmin() && !userService.isInstitutionAdmin(institutionInstance)) {
            log.error("Admin access requested by ${userService.getCurrentUser()}, failed security check, redirecting.")
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
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
                flash.message = message(code: 'default.deleted.message',
                         args: [message(code: 'institution.label', default: 'Institution'), institutionInstance.name]) as String
                redirect action: "index", method: "GET"
            }
            '*' { render status: NO_CONTENT }
        }
    }

    @Transactional
    def quickCreate(String cid) {
        if (!userService.isSiteAdmin()) {
            log.error("Admin access requested by ${userService.getCurrentUser()}, failed security check, redirecting.")
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return
        }
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
        if (!userService.isSiteAdmin() && !userService.isInstitutionAdmin(institution)) {
            log.error("Admin access requested by ${userService.getCurrentUser()}, failed security check, redirecting.")
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return
        }
        render(view: 'uploadInstitutionImageFragment', model: [institutionInstance: institution, imageType: 'banner'])
    }

    def uploadLogoImageFragment() {
        def institution = Institution.get(params.int("id"))
        if (!userService.isSiteAdmin() && !userService.isInstitutionAdmin(institution)) {
            log.error("Admin access requested by ${userService.getCurrentUser()}, failed security check, redirecting.")
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return
        }
        render(view: 'uploadInstitutionImageFragment', model: [institutionInstance: institution, imageType: 'logo'])
    }

    def uploadInstitutionImageFragment() {
        def institution = Institution.get(params.int("id"))
        if (!userService.isSiteAdmin() && !userService.isInstitutionAdmin(institution)) {
            log.error("Admin access requested by ${userService.getCurrentUser()}, failed security check, redirecting.")
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return
        }
        [institutionInstance: institution, imageType: 'main']
    }

    def clearLogoImage(Institution institutionInstance) {
        if (!userService.isSiteAdmin() && !userService.isInstitutionAdmin(institutionInstance)) {
            log.error("Admin access requested by ${userService.getCurrentUser()}, failed security check, redirecting.")
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return
        }
        if (institutionInstance) {
            institutionService.clearLogo(institutionInstance)
        }
        redirect(action: 'edit', id: institutionInstance.id)
    }

    def clearBannerImage(Institution institutionInstance) {
        if (!userService.isSiteAdmin() && !userService.isInstitutionAdmin(institutionInstance)) {
            log.error("Admin access requested by ${userService.getCurrentUser()}, failed security check, redirecting.")
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return
        }
        if (institutionInstance) {
            institutionService.clearBanner(institutionInstance)
        }
        redirect(action: 'edit', id: institutionInstance.id)
    }

    def clearImage(Institution institutionInstance) {
        if (!userService.isSiteAdmin() && !userService.isInstitutionAdmin(institutionInstance)) {
            log.error("Admin access requested by ${userService.getCurrentUser()}, failed security check, redirecting.")
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return
        }
        if (institutionInstance) {
            institutionService.clearImage(institutionInstance)
        }
        redirect(action: 'edit', id: institutionInstance.id)
    }

    def uploadInstitutionImage() {
        def institution = Institution.get(params.int("id"))
        if (!userService.isSiteAdmin() && !userService.isInstitutionAdmin(institution)) {
            log.error("Admin access requested by ${userService.getCurrentUser()}, failed security check, redirecting.")
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return
        }

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

    /**
     * AJAX Endpoint returning a JSON list of active projects.
     * @see {@link InstitutionService#getActiveProjectsForInstitution(Institution)}
     */
    def getActiveProjectsForInstitution(long id) {
        log.debug("AJAX getActiveProjects: ${id}")
        log.debug("Params: ${params}")
        if (!userService.isInstitutionAdmin()) {
            render status: SC_FORBIDDEN
            return
        }

        if (id <= 0) {
            render status: SC_BAD_REQUEST
        } else {
            Institution institution = Institution.get(id)
            if (institution) {
                def results = institutionService.getActiveProjectsForInstitution(institution)
                render(results as JSON)
            } else {
                render status: 404
            }
        }
    }

    /**
     * AJAX Endpoint for returning a JSON list of active users for a given institution.
     * @see {@link InstitutionService#getActiveUsersForInstitution(Institution)}
     * @param id the institution ID to query
     * @return a List (in JSON format) of users.
     */
    def getUsersForInstitution(long id) {
        log.debug("AJAX getActiveProjects: ${id}")
        log.debug("Params: ${params}")
        if (!userService.isInstitutionAdmin()) {
            render status: SC_FORBIDDEN
            return
        }

        if (id <= 0) {
            render status: SC_BAD_REQUEST
        } else {
            Institution institution = Institution.get(id)
            if (institution) {
                def usersForInstitution = institutionService.getActiveUsersForInstitution(institution)
                render(usersForInstitution as JSON)
            } else {
                render status: 404
            }
        }
    }
}