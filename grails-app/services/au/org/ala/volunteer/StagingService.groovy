package au.org.ala.volunteer

import org.springframework.web.multipart.MultipartFile
import java.util.regex.Pattern

class StagingService {

    def grailsApplication

    String getStagingDirectory(Project project) {
        return "${grailsApplication.config.images.home}/${project.id}/staging"
    }

    String createStagedPath(Project project, String filename) {
        return getStagingDirectory(project) + "/" + filename
    }

    def stageImage(Project project, MultipartFile file) {
        def filePath = createStagedPath(project, file.originalFilename)
        println "copying image to " + filePath
        def newFile = new File(filePath);
        file.transferTo(newFile);
    }

    def listStagedFiles(Project project) {
        def dir = new File(getStagingDirectory(project))
        if (!dir.exists()) {
            dir.mkdirs();
        }

        def files = dir.listFiles()
        def images = []
        files.each {
            def url = grailsApplication.config.server.url + grailsApplication.config.images.urlPrefix + "/${project.id}/staging/" + it.name
            images << [file: it, name: it.name, url: url]
        }

        return images.sort { it.name }
    }

    def unstageImage(Project project, String imageName) {
        def file = new File(createStagedPath(project, imageName))
        if (file.exists()) {
            file.delete()
            return true
        }
        return false
    }

    def buildTaskMetaDataList(Project project) {
        def images = listStagedFiles(project)
        def profile = ProjectStagingProfile.findByProject(project)
        int sequenceNo = 0

        def patternMap = [:]
        profile.fieldDefinitions.each { field ->
            Pattern pattern = null
            switch (field.fieldDefinitionType) {
                case FieldDefinitionType.NameRegex:
                    try {
                        pattern = Pattern.compile(field.format)
                    } catch (Exception ex) {
                        println ex.message
                    }
                    break
                case FieldDefinitionType.NamePattern:
                    try {
                        pattern = SimplifiedPatternParser.compile(field.format)
                    } catch (Exception ex) {
                        println ex.message
                    }
                    break
            }
            if (pattern) {
                patternMap[field] = pattern
            }
        }

        images.each { image ->
            image.valueMap = [:]
            sequenceNo++
            profile.fieldDefinitions.each { field ->
                def value = ""
                switch (field.fieldDefinitionType) {
                    case FieldDefinitionType.NameRegex:
                    case FieldDefinitionType.NamePattern:
                        Pattern pattern = patternMap[field] as Pattern
                        if (field.format && pattern) {
                            def matcher = pattern.matcher(image.name)
                            if (matcher.matches()) {
                                if (matcher.groupCount() >= 1) {
                                    value = matcher.group(1)
                                }
                            }
                        } else {
                            value = image.name
                        }
                        break;
                    case FieldDefinitionType.Literal:
                        value = field.format
                        break;
                    case FieldDefinitionType.Sequence:
                        value = "${sequenceNo}"
                        break;
                    default:
                        value = "err"
                        break;
                }
                image.valueMap[field.fieldName] = value
            }
        }

    }

}
