package au.org.ala.volunteer

import org.apache.commons.io.FileUtils
import org.springframework.web.multipart.MultipartFile

class ProjectStagingService {

    def grailsApplication
    def projectService

    public Project createProject(NewProjectDescriptor projectDescriptor) {

        def project = new Project(name: projectDescriptor.name)

        project.featuredOwner = projectDescriptor.featuredOwner
        project.institution = projectDescriptor.featuredOwnerId ? Institution.get(projectDescriptor.featuredOwnerId) : null
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
        project.inactive = true

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

        // if we get here we can clean up the staging area...
        purgeProject(projectDescriptor)

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

    def clearProjectImage(NewProjectDescriptor project) {
        def imageFile = new File(getProjectImagePath(project))
        FileUtils.deleteQuietly(imageFile)
    }

    def hasProjectImage(NewProjectDescriptor project) {
        def f = new File(getProjectImagePath(project))
        return f.exists()
    }

    def getProjectImageUrl(NewProjectDescriptor project) {
        return grailsApplication.config.server.url + grailsApplication.config.images.urlPrefix + "projectStaging/${project.stagingId}/expedition-image.jpg"
    }

    private String getProjectImagePath(NewProjectDescriptor project) {
        def folder = getStagingRootFile(project)
        return folder.getAbsolutePath() + "/expedition-image.jpg"
    }

    private File getStagingRootFile(NewProjectDescriptor project) {
        def f = new File(getStagingRootPath(project))
        if (!f.exists()) {
            f.mkdirs()
        }
        return f;
    }

    private String getStagingRootPath(NewProjectDescriptor project) {
        return "${grailsApplication.config.images.home}/projectStaging/${project.stagingId}"
    }
}
