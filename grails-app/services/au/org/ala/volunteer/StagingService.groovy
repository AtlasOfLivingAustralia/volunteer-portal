package au.org.ala.volunteer

import org.apache.commons.io.ByteOrderMark
import org.apache.commons.io.input.BOMInputStream
import org.codehaus.groovy.grails.web.servlet.mvc.GrailsParameterMap
import org.springframework.web.multipart.MultipartFile
import java.util.regex.Pattern
import org.grails.plugins.csv.CSVMapReader

class StagingService {

    def grailsApplication
    def fieldService
    def fieldSyncService

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
                def url = grailsApplication.config.server.url + grailsApplication.config.images.urlPrefix + "${project.id}/staging/" + URLEncoder.encode(it.name, "UTF-8").replaceAll("\\+", "%20")
                images << [file: it, name: it.name, url: url]
            }
        }

        return images.sort { it.name }
    }

    def unstageImage(Project project, String imageName) {
        def file = new File(createStagedPath(project, imageName))
        if (file.exists()) {
            return file.delete()
        }
        return false
    }

    def deleteStagedImages(Project project) {
        if (!project) {
            return
        }

        def stagedFiles = listStagedFiles(project)
        stagedFiles.each {
            if (it.file?.exists()) {
                it.file.delete()
            }
        }
    }

    def buildTaskFieldValuesFromDataFile(Project project) {
        def dataFile = new File(createDataFilePath(project))
        def dataFileMap = [:]
        def dataFileColumns = []
        if (dataFile.exists()) {
            FileInputStream fis = new FileInputStream(dataFile)
            BOMInputStream bomInputStream = new BOMInputStream(fis, ByteOrderMark.UTF_8) // Ignore any UTF-8 Byte Order Marks, as they will stuff up the mapping!
            try {
                new CSVMapReader(new InputStreamReader(bomInputStream)).each { Map map ->
                    if (map.externalId) {
                        if (!dataFileColumns) {
                            map.each {
                                if (it.key != 'externalId') {
                                    dataFileColumns << it.key
                                }
                            }
                        }
                        dataFileMap[map.remove('externalId')] = map
                    }
                }
            } finally {

                if (bomInputStream) {
                    bomInputStream.close()
                }

                if (fis) {
                    fis.close()
                }
            }
        }
        return dataFileMap

    }

    def loadTaskDataFromFile(Project project) {

        if (!project) {
            return [success:false, message:'Project instance not specified for task data load!']
        }

        def fieldValueMap = buildTaskFieldValuesFromDataFile(project)

        def totalRows = 0
        def taskCount = 0

        fieldValueMap.keySet().each { externalId ->
            def task = Task.findByExternalIdentifierAndProject(externalId, project)
            if (task) {
                // The value maps for the tasks built from the file needs to placed in a nested map, keyed by record
                // index as a string, so that it can be passed the the syncFields method of the fieldSyncService
                // The alternative is to duplicate the fieldSync function, but that seems to be a worse solution

                // if multiple record indexes are every required from the functionality this will need to be modified
                // to reflect that

                def taskValueMap = ["0": fieldValueMap[externalId] ]

                fieldSyncService.syncFields(task, taskValueMap, "system", null, null, null)
                taskCount++
            }
            totalRows++
        }

        return [success: true, message:"Total rows processed: ${totalRows}, tasks modified: ${taskCount}"]
    }

    def buildTaskMetaDataList(Project project) {
        def images = listStagedFiles(project)
        def profile = ProjectStagingProfile.findByProject(project)

        int sequenceNo = fieldService.getLastSequenceNumberForProject(project)

        // The data file, if it exists
        def dataFile = new File(createDataFilePath(project))
        def dataFileMap = [:]
        def dataFileColumns = []
        if (dataFile.exists()) {
            FileInputStream fis = new FileInputStream(dataFile)
            BOMInputStream bomInputStream = new BOMInputStream(fis, ByteOrderMark.UTF_8) // Ignore any UTF-8 Byte Order Marks, as they will stuff up the mapping!
            try {
                new CSVMapReader(new InputStreamReader(bomInputStream)).each { Map map ->
                    if (map.filename) {
                        if (!dataFileColumns) {
                            map.each {
                                if (it.key != 'filename') {
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
            } finally {
                if (bomInputStream) {
                    bomInputStream.close()
                }

                if (fis) {
                    fis.close()
                }
            }
        }

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
                    case FieldDefinitionType.DataFileColumn:
                        def values = dataFileMap[image.name]
                        if (values) {
                            value = values[field.fieldName]
                        }
                        break;
                    default:
                        value = "err"
                        break;
                }
                image.valueMap[field.fieldName] = value
            }

        }

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
