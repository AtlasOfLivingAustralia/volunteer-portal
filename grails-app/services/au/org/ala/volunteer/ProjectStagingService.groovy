package au.org.ala.volunteer

import grails.gorm.transactions.Transactional
import org.apache.commons.io.FileUtils
import org.springframework.web.multipart.MultipartFile

@Transactional
class ProjectStagingService {

    def grailsApplication
    def projectService
    def institutionService
    def forumService

    public Project createProject(NewProjectDescriptor projectDescriptor) {

        def project = new Project(name: projectDescriptor.name)

        project.featuredOwner = projectDescriptor.featuredOwner
        project.institution = projectDescriptor.featuredOwnerId ? institutionService.findByIdOrName(projectDescriptor.featuredOwnerId, projectDescriptor.featuredOwner) : null
        project.featuredLabel = projectDescriptor.name
        project.shortDescription = projectDescriptor.shortDescription
        project.description = projectDescriptor.longDescription
        project.template = Template.get(projectDescriptor.templateId)
        project.projectType = ProjectType.get(projectDescriptor.projectTypeId)
        project.showMap = projectDescriptor.showMap
        project.mapInitLatitude = projectDescriptor.mapInitLatitude
        project.mapInitLongitude = projectDescriptor.mapInitLongitude
        project.mapInitZoomLevel = projectDescriptor.mapInitZoomLevel
        project.featuredImageCopyright = projectDescriptor.imageCopyright
        project.backgroundImageAttribution = projectDescriptor.backgroundImageCopyright
        project.tutorialLinks = projectDescriptor.tutorialLinks
        project.extractImageExifData = projectDescriptor.extractImageExifData
        if (project.template.supportMultipleTranscriptions) {
            project.thresholdMatchingTranscriptions = projectDescriptor.thresholdMatchingTranscriptions?: Project.DEFAULT_THRESHOLD_MATCHING_TRANSCRIPTIONS
            project.transcriptionsPerTask = projectDescriptor.transcriptionsPerTask?: Project.DEFAULT_TRANSCRIPTIONS_PER_TASK
        } else {
            project.thresholdMatchingTranscriptions = Project.DEFAULT_THRESHOLD_MATCHING_TRANSCRIPTIONS
            project.transcriptionsPerTask = Project.DEFAULT_TRANSCRIPTIONS_PER_TASK
        }

        project.inactive = true
        def user = User.findByUserId(Long.parseLong(projectDescriptor.createdBy?.toString()))
        project.createdBy = user

        if (projectDescriptor.labelIds) {
            Label.findAllByIdInList(projectDescriptor.labelIds).each { project.addToLabels(it) }
        }
        if (projectDescriptor.picklistId) {
            project.picklistInstitutionCode = projectDescriptor.picklistId
        }

        project.save(failOnError: true, flush: true)

        // Now we have a project id we can copy over the file system artifacts
        // 1. Expedition Image
        def imageFile = new File(getProjectImagePath(projectDescriptor))
        if (imageFile && imageFile.exists()) {
            def destPath = "${grailsApplication.config.images.home}/project/${project.id}/expedition-image.jpg"
            def destFile = new File(destPath)
            destFile.getParentFile().mkdirs()
            FileUtils.copyFile(imageFile, destFile)
            projectService.checkAndResizeExpeditionImage(project)
        }
        // 2. Background Image
        def backgroundImageFile = new File(getProjectBackgroundImagePath(projectDescriptor))
        if (backgroundImageFile?.exists()) {
            backgroundImageFile.withInputStream {
                //project.setBackgroundImage(it, backgroundImageFile.name.endsWith('png') ? 'image/png' : 'image/jpg')
                projectService.setBackgroundImage(project, it, backgroundImageFile.name.endsWith('png') ? 'image/png' : 'image/jpg')
            }
        }

        // if we get here we can clean up the staging area...
        purgeProject(projectDescriptor)

        // sign the creator up for project forum topic notifications
        forumService.watchProject(user, project, true)

        return project
    }

    def purgeProject(NewProjectDescriptor project) {

        def folder = getStagingRootFile(project)
        if (folder && folder.exists()) {
            FileUtils.deleteQuietly(folder);
        }

    }

    def uploadProjectImage(NewProjectDescriptor project, MultipartFile file) {
        def destFile = new File(getProjectImagePath(project))
        file.transferTo(destFile)
    }

    def uploadProjectBackgroundImage(NewProjectDescriptor project, MultipartFile file) {
        def destFile = new File(getProjectBackgroundImagePath(project, file.contentType))
        file.transferTo(destFile)
    }

    def clearProjectImage(NewProjectDescriptor project) {
        def imageFile = new File(getProjectImagePath(project))
        FileUtils.deleteQuietly(imageFile)
    }

    def clearProjectBackgroundImage(NewProjectDescriptor project) {
        def imageFile = new File(getProjectBackgroundImagePath(project))
        FileUtils.deleteQuietly(imageFile)
    }

    def hasProjectImage(NewProjectDescriptor project) {
        def f = new File(getProjectImagePath(project))
        return f.exists()
    }

    def getProjectImageUrl(NewProjectDescriptor project) {
        return grailsApplication.config.server.url + '/' + grailsApplication.config.images.urlPrefix + "projectStaging/${project.stagingId}/expedition-image.jpg"
    }

    def getProjectBackgroundImageUrl(NewProjectDescriptor project) {
        return grailsApplication.config.server.url + '/' + grailsApplication.config.images.urlPrefix + "projectStaging/${project.stagingId}/expedition-background-image.jpg"
    }

    private String getProjectImagePath(NewProjectDescriptor project) {
        def folder = getStagingRootFile(project)
        return folder.getAbsolutePath() + "/expedition-image.jpg"
    }

    private String getProjectBackgroundImagePath(NewProjectDescriptor project, String contentType) {
        def folder = getStagingRootFile(project)
        return folder.getAbsolutePath() + "/expedition-background-image.${contentType == 'image/png' ? 'png' : 'jpg'}"
    }

    private String getProjectBackgroundImagePath(NewProjectDescriptor project) {
        def folder = getStagingRootFile(project)
        def f = new File(folder, 'expedition-background-image.png')
        return f.exists() ? f.absolutePath : folder.absolutePath + File.separator + 'expedition-background-image.jpg'
    }

    public void saveTempProjectDescriptor(String id, Reader body) {
        new File(getStagingRootFile(new NewProjectDescriptor(stagingId: id)), "autosave.json").withWriter {
            it << body
        }
    }

    public String getTempProjectDescriptor(String id) {
        def f = new File(getStagingRootFile(new NewProjectDescriptor(stagingId: id)), "autosave.json")
        return f.exists() ? f.text : null
    }

    public boolean stagingDirectoryExists(String stagingId) {
        new File(getStagingRootPath(stagingId)).exists()
    }

    private File getStagingRootFile(NewProjectDescriptor project) {
        ensureStagingDirectoryExists(project.stagingId)
    }

    public File ensureStagingDirectoryExists(String stagingId) {
        def f = new File(getStagingRootPath(stagingId))
        if (!f.exists()) {
            f.mkdirs()
        }
        return f;
    }

    private String getStagingRootPath(String stagingId) {
        return "${grailsApplication.config.images.home}/projectStaging/${stagingId}"
    }

    /**
     * Searches for an existing ProjectStagingProfile for the given project. If none exists, one is created.
     * @param project The project tasks are being added to
     * @return the ProjectStagingProfile
     */
    def findProjectStagingProfile(Project project) {
        def profile = ProjectStagingProfile.findByProject(project)
        if (!profile) {
            profile = new ProjectStagingProfile(project: project)
            profile.save(flush: true, failOnError: true)
        }

        if (!profile.fieldDefinitions.find { it.fieldName == 'externalIdentifier'}) {
            profile.addToFieldDefinitions(new StagingFieldDefinition(fieldDefinitionType: FieldDefinitionType.NameRegex,
                    format: "^(.*)\$", fieldName: "externalIdentifier"))
        }
        profile
    }
}
