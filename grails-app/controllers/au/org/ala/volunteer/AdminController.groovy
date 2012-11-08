package au.org.ala.volunteer

import org.apache.commons.io.FileUtils

class AdminController {

    def authService
    def taskService
    def grailsApplication

    def index = {
        checkAdmin()
    }

    def mailingList = {
        if (checkAdmin()) {
            def userIds = User.all.collect{ it.userId }
            def list = userIds.join(";\n")
            render(text:list, contentType: "text/plain")
        }
    }

    def reorganiseFileSystem = {
        def ct = new CodeTimer("Filesystem Restructure")
        def results = []
        if (checkAdmin()) {
            def imagesHome = grailsApplication.config.images.home as String;
            def rootDir = new File(imagesHome)
            if (rootDir && rootDir.exists()) {

                def unsortedDirectory = new File(rootDir.getAbsolutePath() + '/lost_found')
                if (!unsortedDirectory.exists()) {
                    unsortedDirectory.mkdirs()
                }

                if (!unsortedDirectory.exists()) {
                    throw new RuntimeException("Could not locate or create the lost and found directory. This probably means there are not enough free inodes to perform the restructure")
                }

                def taskCount = 0
                def existingProjectDirectories = []
                def nonTaskDirectories = []

                def t = new CodeTimer("Counting subdirectories")
                println "Counting subdirectories in " + rootDir.getAbsolutePath()
                def subdirCount = 0
                rootDir.eachDir {
                    subdirCount++
                }

                println subdirCount + " subdirectories found."
                t.stop(true)

                rootDir.eachDir { candidateDir ->
                    if (candidateDir.name.isNumber()) {
                        def candidateId = candidateDir.name.toInteger()
                        def task = Task.get(candidateId)
                        if (task) {
                            taskCount++
                            moveTaskToProjectDirectory(rootDir, candidateDir, task)
                        } else {
                            def project = Project.get(candidateId)
                            if (project) {
                                existingProjectDirectories.add(candidateDir.name)
                            } else {
                                nonTaskDirectories.add(candidateDir.name)
                                def targetDir = new File(unsortedDirectory.getAbsolutePath() + '/' + candidateDir.name)
                                println 'Moving non-task/project dir to unsorted: ' + candidateDir + " => " + targetDir.getAbsolutePath()
                                if (!targetDir.exists()) {
                                    FileUtils.moveDirectory(candidateDir, targetDir)
                                } else {
                                    println("Failed to move non-task/project directory to unsorted: target direcory already exists")
                                }
                            }

                        }
                    }
                }
                results = [taskCount: taskCount, nonTaskDirectories: nonTaskDirectories, existingProjectDirectories: existingProjectDirectories]
            }
        }
        ct.stop(true)
        return results
    }

    private moveTaskToProjectDirectory(File rootDir, File oldTaskDir, Task task) {
        def projectPath = rootDir.getAbsolutePath() + "/" + task.projectId
        def file = new File(projectPath)
        if (!file.exists()) {
            println "Creating project path: " + projectPath
            file.mkdirs();
        }

        if (!file.exists()) {
            throw new RuntimeException("Failed to find or create the project directory. This probably indicates that there are not enough inodes left in the parent folder to perform the restructure")
        }

        def targetPath = rootDir.getAbsolutePath() + '/' + task.projectId + '/' + task.id
        def targetDir = new File(targetPath)
        if (!targetDir.exists()) {
            println "Copying " + oldTaskDir.getAbsolutePath() + " => " + targetPath
            FileUtils.copyDirectory(oldTaskDir, targetDir)
        } else {
            println("skipping - target path already exists: " + targetDir.getAbsoluteFile())
        }

        if (!targetDir.exists()) {
            throw new RuntimeException("Failed to create/location target path. Probably because there are no inodes left.")
        }

        String urlPrefix = grailsApplication.config.images.urlPrefix
        if (!urlPrefix.endsWith('/')) {
            urlPrefix += '/'
        }
        String imagesHome = grailsApplication.config.images.home

        // confirm/update multimedia records...
        task.multimedia.each { mm ->
            // Main image

            if (mm.filePath) {
                def imagePath = URLDecoder.decode(imagesHome + '/' + mm.filePath.substring(urlPrefix.length()))  // have to reverse engineer the files location on disk, this info should be part of the Multimedia structure!
                def oldImageFile = new File(mm.filePath)
                def targetImageFile = new File(targetDir.getAbsolutePath() + "/" + mm.id + "/" + oldImageFile.name)
                if (!targetImageFile.exists()) {
                    if (oldImageFile.exists()) {
                        throw new RuntimeException("The old image exists, but the new one doesn't - there has been a move error! halting: Task " + task.id + " - image " + oldImageFile.absolutePath)
                    }
                }
                mm.filePath = urlPrefix + "${mm.task.projectId}/${mm.task.id}/${mm.id}/" + targetImageFile.name
            }

            // Thumbnail
            if (mm.filePathToThumbnail) {
                def oldImageFile = new File(mm.filePathToThumbnail)
                def targetImageFile = new File(targetDir.getAbsolutePath() + "/" + mm.id + "/" + oldImageFile.name)
                if (!targetImageFile.exists()) {
                    if (oldImageFile.exists()) {
                        throw new RuntimeException("The old image thumbnail exists, but the new one doesn't - there has been a move error! halting: Task " + task.id + " - image " + oldImageFile.absolutePath)
                    }
                }
                mm.filePathToThumbnail = urlPrefix + "${mm.task.projectId}/${mm.task.id}/${mm.id}/" + targetImageFile.name
            }

            println "Updating multimedia ${mm.id}. filePath = ${mm.filePath}, thumbnail = ${mm.filePathToThumbnail}"

            mm.save(flush: true, failOnError: true)
        }

        // if we get here we can delete the original...
        try {
            oldTaskDir.deleteDir()
        } catch (Exception ex) {
            println "Failed to delete original task directory: " + ex.message
        }

    }

    boolean checkAdmin() {
        def currentUser = authService.username()
        if (currentUser != null && authService.userInRole(CASRoles.ROLE_ADMIN)) {
            return true;
        }

        flash.message = "You do not have permission to view this page (${CASRoles.ROLE_ADMIN} required)"
        redirect(uri:"/")
    }

    def taskConsistencyReport = {

        def results = []
        def taskCount = 0
        def errorCount = 0
        String urlPrefix = grailsApplication.config.images.urlPrefix
        String imagesHome = grailsApplication.config.images.home

        Task.list().each { task ->
            taskCount++
            def message = ""
            task.multimedia.each { mm ->
                def path = URLDecoder.decode(imagesHome + '/' + mm.filePath.substring(urlPrefix.length()))  // have to reverse engineer the files location on disk, this info should be part of the Multimedia structure!
                def f = new File(path)
                if (!f.exists()) {
                    errorCount++
                    message = "Image file does not exist for task ${mm.filePath} (mmid=${mm.id})"
                }
            }
            if (message) {
                results.add([task: task, message: message])
            }
        }

        return [results: results, taskCount: taskCount, errorCount: errorCount]
    }

}
