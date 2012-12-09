package au.org.ala.volunteer

import org.springframework.web.multipart.MultipartFile
import java.util.regex.Pattern
import org.grails.plugins.csv.CSVMapReader

class StagingService {

    def grailsApplication
    def fieldService

    String getStagingDirectory(Project project) {
        return "${grailsApplication.config.images.home}/${project.id}/staging"
    }

    String createStagedPath(Project project, String filename) {
        return getStagingDirectory(project) + "/" + filename
    }

    String createDataFilePath(Project project) {
        return getStagingDirectory(project) + "/datafile/datafile.csv"
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
            if (!it.isDirectory()) {
                def url = grailsApplication.config.server.url + grailsApplication.config.images.urlPrefix + "/${project.id}/staging/" + it.name
                images << [file: it, name: it.name, url: url]
            }
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

        int sequenceNo = fieldService.getLastSequenceNumberForProject(project)

        def columnNames = []

        def patternMap = [:]
        profile.fieldDefinitions.each { field ->
            columnNames << field.fieldName
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

        // The data file, if it exists
        def dataFile = new File(createDataFilePath(project))
        def dataFileMap = [:]
        def dataFileColumns = []
        if (dataFile.exists()) {

            new CSVMapReader(new FileReader(dataFile)).each { Map map ->
                if (map.filename) {
                    if (!dataFileColumns) {
                        map.each {
                            if (it.key != 'filename') {
                                columnNames << it.key
                                dataFileColumns << it.key
                            }
                        }
                    }

                    def filename = map.remove('filename')

                    if (filename) {
                        dataFileMap[filename] = map
                    }
                }
            }
        }

        images.each { image ->
            image.valueMap = [:]

            // Data File fields, if there are any
            if (dataFileColumns) {
                def values = dataFileMap[image.name]
                if (values) {
                    dataFileColumns.each {
                        image.valueMap[it] = values[it]
                    }
                }
            }

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

        println columnNames

        return images
    }

    public boolean projectHasDataFile(Project projectInstance) {
        def f = new File(createDataFilePath(projectInstance))
        return f.exists()
    }

    public void clearDataFile(Project projectInstance) {
        def f = new File(createDataFilePath(projectInstance))
        if (f.exists()) {
            f.delete()
        }
    }

    public void uploadDataFile(Project project, MultipartFile file) {
        clearDataFile(project)
        def f = new File(createDataFilePath(project))
        f.mkdirs()
        file.transferTo(f)
    }

    public String dataFileUrl(Project project) {
        def url = grailsApplication.config.server.url + grailsApplication.config.images.urlPrefix + "/${project.id}/staging/datafile/datafile.csv"
        return url
    }

}
