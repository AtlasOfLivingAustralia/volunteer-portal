package au.org.ala.volunteer

import org.springframework.web.multipart.MultipartFile
import java.util.regex.Pattern

class TutorialService {

    def grailsApplication

    private String getTutorialDirectory() {
        return grailsApplication.config.getProperty('images.home', String) + "/tutorials"
    }

    private String createFilePath(String name) {
        return tutorialDirectory + "/" + name
    }

    def listTutorials(String searchTerm) {
        def dir = new File(tutorialDirectory)
        if (!dir.exists()) {
            dir.mkdirs();
        }

        def files = dir.listFiles()
        def tutorials = []
        files.each {
            def url = grailsApplication.config.getProperty('server.url', String) +
                    grailsApplication.config.getProperty('images.urlPrefix', String) + "tutorials/" + it.name
            tutorials << [file: it, name: it.name, url: url]
        }

        if (searchTerm) {
            def filteredList = tutorials.findAll { it.name.toLowerCase().contains(searchTerm.toLowerCase()) }
            return filteredList.sort { it.name }
        } else {
            return tutorials.sort { it.name }
        }
        //return tutorials.sort { it.name }
    }

    def uploadTutorialFile(MultipartFile file) {
        // Check if there's a file extension. If not, add it.
        def fileExtn = '.pdf'
        def fileName = file.originalFilename
        if (!file.originalFilename.contains(fileExtn)) {
            fileName += fileExtn
        }
        def filePath = createFilePath(fileName)
        def newFile = new File(filePath);
        file.transferTo(newFile);
    }

    def deleteTutorial(String name) {
        def filePath = createFilePath(name)
        def file = new File(filePath)
        if (file.exists()) {
            file.delete()
            return true
        }

        return false
    }

    def renameTutorial(String oldname, String newname) {
        def filePath = createFilePath(oldname)
        def file = new File(filePath)
        if (file.exists()) {
            def newFile = new File(createFilePath(newname))
            if (!newFile.exists()) {
                file.renameTo(newFile)
            }
        }
    }

    def getTutorialGroups() {
        def dir = new File(tutorialDirectory)
        if (!dir.exists()) {
            dir.mkdirs();
        }

        def files = dir.listFiles()
        def tutorials = [:]

        def regex = Pattern.compile("^(.*)_(.*)\$")
        files.each {
            def url = grailsApplication.config.getProperty('server.url', String) +
                    grailsApplication.config.getProperty('images.urlPrefix', String) + "tutorials/" + it.name
            def group = "-" // no group
            def title = it.name
            def matcher = regex.matcher(it.name)
            if (matcher.matches()) {
                group = matcher.group(1)
                title = matcher.group(2)
            }

            // If there's no file extension, make sure we don't throw an exception.
            int fileExtnSep = title.lastIndexOf('.')
            if (fileExtnSep > 0) title = title.subSequence(0, fileExtnSep)

            if (!tutorials[group]) {
                tutorials[group] = []
            }

            tutorials[group] << [file: it, name: it.name, url: url, title:title]
        }

        if (!tutorials.containsKey('-')) {
            tutorials['-'] = []
        }

        return tutorials
    }
}
