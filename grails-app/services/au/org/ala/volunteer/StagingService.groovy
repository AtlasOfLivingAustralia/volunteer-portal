package au.org.ala.volunteer

import com.github.benmanes.caffeine.cache.CacheLoader
import com.github.benmanes.caffeine.cache.Caffeine
import com.github.benmanes.caffeine.cache.LoadingCache
import com.google.common.base.Charsets
import com.google.common.hash.Hashing
import com.google.common.io.Files
import groovy.transform.Canonical
import org.apache.commons.io.ByteOrderMark
import org.apache.commons.io.FileUtils
import org.apache.commons.io.FilenameUtils
import org.apache.commons.io.input.BOMInputStream
import org.springframework.web.multipart.MultipartFile

import java.util.concurrent.CompletionException
import java.util.concurrent.TimeUnit
import java.util.regex.Pattern
import grails.plugins.csv.CSVMapReader

class StagingService {

    def grailsApplication
    def fieldService
    def fieldSyncService
    def taskService

    /** If images were taken 3 more than 3 seconds apart they are assigned to separate burst event groups */
    static long DEFAULT_BURST_THRESHOLD = 3*1000

    String getStagingDirectory(Project project) {
        getStagingDirectory(project.id)
    }

    String getStagingDirectory(long projectId) {
        return "${grailsApplication.config.getProperty('images.home', String)}/${projectId}/staging"
    }

    String createStagedPath(Project project, String filename) {
        createStagedPath(project.id, filename)
    }

    String createStagedPath(long projectId, String filename) {
        return getStagingDirectory(projectId) + "/" + filename
    }

    String createUploadChunksPath(long projectId, String filename) {
        return "${grailsApplication.config.getProperty('images.home', String)}/${projectId}/chunks/$filename/"
    }

    String createDataFilePath(Project project) {
        return getStagingDirectory(project) + "/datafile/datafile.csv"
    }

    def stageImage(Project project, MultipartFile file) {
        def filePath = createStagedPath(project, file.originalFilename)
        log.debug("copying stagedFile to " + filePath)
        def newFile = new File(filePath);
        file.transferTo(newFile);
    }

    @Canonical
    static class HashKey {
        long length
        String filename
    }

    private LoadingCache<HashKey, String> md5s = Caffeine.newBuilder()
            .maximumSize(10_000)
            .expireAfterWrite(30, TimeUnit.MINUTES)
            .refreshAfterWrite(10, TimeUnit.MINUTES)
            .build({key -> md5Internal(key.filename) } as CacheLoader<HashKey, String>)

    private String md5Internal(String filename) {
        File file = new File(filename)
        if (!file.exists()) {
            throw new IOException("$filename doesn't exist")
        }
        return Files.hash(file, Hashing.md5()).toString()
    }

    def md5(File file) {
        try {
            md5s.get(new HashKey(length: file.length(), filename: file.absolutePath))
        } catch (CompletionException e) {
            log.error("md5 hash failed: ${e.message}", e)
            throw e.cause
        }
    }

    /**
     * Reads the files in the project staging directory and returns information about them.  The dateTaken will be
     * added to the returned file information if sortByDateTaken is true.
     * @param project the project to get staging data for.
     * @param sortByDateTaken if true, EXIF data will be read from the file to find the original_date_time field use it to sort.
     *
     * @return List<Map> containing file, name and url for each staging file.
     */
    List listStagedFiles(Project project, boolean sortByDateTaken = false) {
        def dir = new File(getStagingDirectory(project))
        if (!dir.exists()) {
            dir.mkdirs()
        }

        def files = dir.listFiles()
        def images = []
        files.each {
            if (!it.isDirectory()) {
                def url = grailsApplication.config.server.url + '/' + grailsApplication.config.images.urlPrefix + "${project.id}/staging/" + URLEncoder.encode(it.name, "UTF-8").replaceAll("\\+", "%20")
                Map image = [file: it, name: it.name, url: url]

                // If Audio project, check if it's an AAC file and rename to mp3.
                def extension = FilenameUtils.getExtension(it.getPath())
                log.debug("Extn: ${extension}")
                if (project.projectType.name == ProjectType.PROJECT_TYPE_AUDIO && 'aac' == extension.toLowerCase()) {
                    log.debug("Renaming aac file to mp3")
                    def newFile = changeFileExtension(it, 'mp3')
                    log.debug("Path: ${newFile.path}")
                    image.file = newFile
                    image.name = newFile.name
                    image.url = grailsApplication.config.server.url + '/' + grailsApplication.config.images.urlPrefix + "${project.id}/staging/" + URLEncoder.encode(newFile.name, "UTF-8").replaceAll("\\+", "%20")
                }
                log.debug("File details: ${image}")

                if (sortByDateTaken) {
                    Date dateTaken = ImageUtils.getDateTaken(it)
                    image.dateTaken = dateTaken ? dateTaken.getTime() : 0
                }
                images << image
            }
        }
        def sort = sortByDateTaken ? {it.dateTaken} : {it.name}

        log.debug("Staged files: ${images}")

        images.sort(sort)
    }

    /**
     * To cater for requirements for the WaveSurfer JS library, AAC files need to be renamed.
     * This method renames a file's extension to the provided extension.
     * @param oldFile
     * @param newExtension
     * @return
     */
    def changeFileExtension(File oldFile, String newExtension) {
        def filePath = oldFile.getPath() //createFilePath(oldname)
//        def file = new File(filePath)
        if (oldFile.exists()) {
            def extension = FilenameUtils.getExtension(filePath)
            def newFilePath = filePath.replace(extension, newExtension)
            def newFile = new File(newFilePath)
            if (!newFile.exists()) {
                oldFile.renameTo(newFile)
                return newFile
            }
        } else {
            return oldFile
        }
    }

    def unstageImage(long projectId, String imageName) {
        def file = new File(createStagedPath(projectId, imageName))
        if (file.exists()) {
            return file.delete()
        }
        return false
    }

    def unstageImage(Project project, String imageName) {
        unstageImage(project.id, imageName)
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

                fieldSyncService.syncFields(task, taskValueMap, UserService.SYSTEM_USER, null, null, null)
                taskCount++
            }
            totalRows++
        }

        return [success: true, message:"Total rows processed: ${totalRows}, tasks modified: ${taskCount}"]
    }

    private long getBurstGapThreshold(Project project) {
        long burstGapThreshold = DEFAULT_BURST_THRESHOLD
        String burstGapThresholdConfig = project.template?.viewParams?.burstGapThreshold
        if (burstGapThresholdConfig) {
            try {
                burstGapThreshold = Long.valueOf(burstGapThresholdConfig)
            }
            catch (NumberFormatException e) {
                log.warn("Invalid burst gap threshold configured for Project ${project.id} : ${burstGapThresholdConfig}")
            }

        }
        burstGapThreshold
    }

    def buildTaskMetaDataList(Project project) {
        def profile = ProjectStagingProfile.findByProject(project)
        boolean hasBurstEvent = (profile.fieldDefinitions.find{it.fieldDefinitionType == FieldDefinitionType.SequenceGroupId})

        List stagedFiles = listStagedFiles(project, hasBurstEvent)

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
                        log.error(ex.message, ex)
                    }
                    break
                case FieldDefinitionType.NamePattern:
                    try {
                        pattern = SimplifiedPatternParser.compile(field.format)
                    } catch (Exception ex) {
                        log.error(ex.message, ex)
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


        // These are used to assign a burst sequence number if one has been selected as(a field type.
        // The images will have already been sorted by date taken at this point.
        long previousDateTaken = stagedFiles ? (stagedFiles[0].dateTaken ?: 0) : 0
        int burstSequenceGroup = 0
        long burstGapThreshold = getBurstGapThreshold(project)

        // First pass - computed defined field values (either literals, name captures etc...)
        stagedFiles.each { stagedFile ->
            log.debug("Staged file: ${stagedFile}")

            def m = shadowFilePattern.matcher(stagedFile.name as CharSequence)
            if (m.matches()) {
                log.debug("File is a shadow file")
                def parentFile = m.group(1)
                def shadowFile = [stagedFile: stagedFile,
                                  fieldName: m.group(2),
                                  recordIndex: Integer.parseInt(m.group(3) ?: '0'),
                                  parentFile: parentFile]
                if (!shadowFiles[parentFile]) {
                    shadowFiles[parentFile] = []
                }
                log.debug("ShadowFile: ${shadowFile}")
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
                        value = "" + sequenceNo
                        break;
                    case FieldDefinitionType.SequenceGroupId:
                        long dateTaken = stagedFile.dateTaken ?: 0
                        if (dateTaken - previousDateTaken > burstGapThreshold) {
                            burstSequenceGroup++
                        }
                        value = Long.toString(burstSequenceGroup)
                        previousDateTaken = dateTaken
                        break
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
            //imageFile.shadowFiles = shadowFiles[imageFile.name]
            imageFile.shadowFiles = shadowFiles[FilenameUtils.removeExtension(imageFile.name as String)]
        }
        log.debug("Shadow Files: ${shadowFiles}")
        log.debug("Images: ${images}")
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
