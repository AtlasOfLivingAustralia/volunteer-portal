package au.org.ala.volunteer

import com.google.common.base.Charsets
import org.apache.commons.io.ByteOrderMark
import org.apache.commons.io.FileUtils
import org.apache.commons.io.input.BOMInputStream
import org.springframework.web.multipart.MultipartFile

import java.util.regex.Pattern
import grails.plugins.csv.CSVMapReader

class StagingService {

    def grailsApplication
    def fieldService
    def fieldSyncService
    def taskService

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
        println "copying stagedFile to " + filePath
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
                def url = grailsApplication.config.server.url + '/' + grailsApplication.config.images.urlPrefix + "${project.id}/staging/" + URLEncoder.encode(it.name, "UTF-8").replaceAll("\\+", "%20")
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
                    if (map.externalId || map.filename) {

                        def externalIdCol = 'externalId'
                        if (!map.externalId) {
                            externalIdCol= 'filename'
                        }

                        if (!dataFileColumns) {
                            map.each {
                                if (it.key != externalIdCol) {
                                    dataFileColumns << it.key
                                }
                            }
                        }
                        dataFileMap[map.remove(externalIdCol)] = map
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
        def stagedFiles = listStagedFiles(project)
        def profile = ProjectStagingProfile.findByProject(project)

        int sequenceNo = taskService.findMaxSequenceNumber(project) ?: 0

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

                        def filename = map.get('filename')

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

        def images = []
        def shadowFiles =[:]

        def shadowFilePattern = Pattern.compile('^(.+?)__([A-Za-z]+)(?:__(\\d+))?[.]txt$')

        // First pass - computed defined field values (either literals, name captures etc...)
        stagedFiles.each { stagedFile ->

            def m = shadowFilePattern.matcher(stagedFile.name)
            if (m.matches()) {

                def parentFile = m.group(1)
                def shadowFile = [stagedFile: stagedFile, fieldName: m.group(2), recordIndex: Integer.parseInt(m.group(3) ?: '0'), parentFile: parentFile]
                if (!shadowFiles[parentFile]) {
                    shadowFiles[parentFile] = []
                }
                shadowFiles[parentFile] << shadowFile

                return
            }

            images << stagedFile

            stagedFile.valueMap = [:]
            sequenceNo++
            profile.fieldDefinitions.each { field ->
                def value = ""
                switch (field.fieldDefinitionType) {
                    case FieldDefinitionType.NameRegex:
                    case FieldDefinitionType.NamePattern:
                        Pattern pattern = patternMap[field] as Pattern
                        if (field.format && pattern) {
                            def matcher = pattern.matcher(stagedFile.name)
                            if (matcher.matches()) {
                                if (matcher.groupCount() >= 1) {
                                    value = matcher.group(1)
                                }
                            }
                        } else {
                            value = stagedFile.name
                        }
                        break;
                    case FieldDefinitionType.Literal:
                        value = field.format
                        break;
                    case FieldDefinitionType.Sequence:
                        value = "${sequenceNo}"
                        break;
                    case FieldDefinitionType.DataFileColumn:
                        def values = dataFileMap[stagedFile.name]
                        if (values) {
                            value = values[field.format ?: field.fieldName]
                        }
                        break;
                    default:
                        value = "err"
                        break;
                }
                stagedFile.valueMap[field.fieldName + "_" + field.recordIndex] = value
            }
        }

        // stage 2, process shadow files...
        images.each { imageFile ->
            imageFile.shadowFiles = shadowFiles[imageFile.name]
        }

        return images
    }

    public boolean projectHasDataFile(Project projectInstance) {
        def f = new File(createDataFilePath(projectInstance))
        return f.exists()
    }

    public List getDataFileColumns(Project projectInstance) {
        def f = new File(createDataFilePath(projectInstance))
        if (f.exists()) {
            def lines = FileUtils.readLines(f, Charsets.UTF_8)
            if (lines && lines.size() > 0) {
                return lines[0].split(",")
            }
        }

        return []
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
        f.parentFile?.mkdirs()
        file.transferTo(f)
    }

    public String dataFileUrl(Project project) {
        def url = grailsApplication.config.server.url + '/' + grailsApplication.config.images.urlPrefix + "/${project.id}/staging/datafile/datafile.csv"
        return url
    }

}
