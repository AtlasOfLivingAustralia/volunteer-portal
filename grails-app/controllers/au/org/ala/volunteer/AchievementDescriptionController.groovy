package au.org.ala.volunteer

import au.org.ala.web.AlaSecured
import grails.converters.JSON
import org.springframework.web.multipart.MultipartFile
import org.springframework.web.multipart.MultipartHttpServletRequest

import static org.springframework.http.HttpStatus.*
import grails.transaction.Transactional

@AlaSecured("ROLE_VP_ADMIN")
@Transactional(readOnly = true)
class AchievementDescriptionController {

    static allowedMethods = [save: "POST", update: "PUT", delete: "DELETE", uploadBadgeImage: "POST"]

    def achievementService
    def userService
    
    def index(Integer max) {
        params.max = Math.min(max ?: 10, 100)
        respond AchievementDescription.list(params), model: [achievementDescriptionInstanceCount: AchievementDescription.count()]
    }

    def show(AchievementDescription achievementDescriptionInstance) {
        respond achievementDescriptionInstance
    }
    
    def create() {
        respond new AchievementDescription()
    }

    @Transactional
    def save(AchievementDescription achievementDescriptionInstance) {
        if (achievementDescriptionInstance == null) {
            notFound()
            return
        }

        if (achievementDescriptionInstance.hasErrors()) {
            respond achievementDescriptionInstance.errors, view: 'create'
            return
        }

        achievementDescriptionInstance.save flush: true

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.created.message', args: [message(code: 'achievementDescription.label', default: 'AchievementDescription'), achievementDescriptionInstance.id])
                redirect achievementDescriptionInstance
            }
            '*' { respond achievementDescriptionInstance, [status: CREATED] }
        }
    }

    def edit(AchievementDescription achievementDescriptionInstance) {
        respond achievementDescriptionInstance
    }

    @Transactional
    def update(AchievementDescription achievementDescriptionInstance) {
        if (achievementDescriptionInstance == null) {
            notFound()
            return
        }

        if (achievementDescriptionInstance.hasErrors()) {
            respond achievementDescriptionInstance.errors, view: 'edit'
            return
        }

        achievementDescriptionInstance.save flush: true

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.updated.message', args: [message(code: 'achievementDescription.label', default: 'AchievementDescription'), achievementDescriptionInstance.id])
                redirect achievementDescriptionInstance
            }
            '*' { respond achievementDescriptionInstance, [status: OK] }
        }
    }

    @Transactional
    def delete(AchievementDescription achievementDescriptionInstance) {

        if (achievementDescriptionInstance == null) {
            notFound()
            return
        }

        achievementDescriptionInstance.delete flush: true

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.deleted.message', args: [message(code: 'achievementDescription.label', default: 'AchievementDescription'), achievementDescriptionInstance.id])
                redirect action: "index", method: "GET"
            }
            '*' { render status: NO_CONTENT }
        }
    }

    protected void notFound() {
        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.not.found.message', args: [message(code: 'achievementDescription.label', default: 'AchievementDescription'), params.id])
                redirect action: "index", method: "GET"
            }
            '*' { render status: NOT_FOUND }
        }
    }

    def run(Long achievementId, Long userId, Long taskId) {
        achievementService.evaluateAchievement(AchievementDescription.get(achievementId), User.get(userId), taskId)
    }

    def uploadBadgeImage() {
        def id = params.long("id");
        def achievement = id ? AchievementDescription.get(id) : null


        def json = [:]
        def status = OK
        if (request instanceof MultipartHttpServletRequest) {
            MultipartFile f = ((MultipartHttpServletRequest) request).getFile('imagefile')

            if (f != null && f.size > 0) {
                def allowedMimeTypes = ['image/jpeg', 'image/png']
                if (!allowedMimeTypes.contains(f.getContentType())) {
                    json.put("error", "Image must be one of: ${allowedMimeTypes}")
                    status = BAD_REQUEST
                } else {
                    boolean result
                    String filename = UUID.randomUUID().toString() + '.' + contentTypeToExtension(f.contentType)
                    result = uploadToLocalPath(f, filename)

                    if (result) {
                        json.put('filename', filename)
                        if (achievement) {
                            achievement.badge = filename
                            achievement.save()
                        }
                    } else {
                        json.put('error', "Failed to upload image. Unknown error!")
                        status = INTERNAL_SERVER_ERROR
                    }
                }
            } else {
                json.put('error', "Please select a file!")
                status = BAD_REQUEST
            }
        } else {
            json.put('error', "Form must be multipart file!")
            status = BAD_REQUEST
        }

        respond((Object)json, status: status.value())
    }

    private static String contentTypeToExtension(String contentType) {
        switch (contentType.toLowerCase()) {
            case 'image/png':
                return 'png'
            case 'image/jpeg':
                return 'jpg'
            case 'image/gif':
                return 'gif'
            case 'image/webp':
                return 'webp'
            case 'image/tiff':
            case 'image/tiff-fx':
                return 'tiff'
            case 'image/bmp':
            case 'image/x-bmp':
                return 'bmp'
            default:
                return ''
        }
    }

    private boolean uploadToLocalPath(MultipartFile mpfile, String localFile) {
        if (!mpfile) {
            return false
        }

        try {
            def file = new File(achievementService.badgeImageFilePrefix, localFile)
            if (!file.getParentFile().exists() && !file.getParentFile().mkdirs()) {
                throw new RuntimeException("Failed to create institution directories: ${file.getParentFile().getAbsolutePath()}")
            }
            mpfile.transferTo(file);
            return true
        } catch (Exception ex) {
            log.error("Failed to upload achievement badge", ex)
            return false
        }
    }
}
