package au.org.ala.volunteer

import com.google.common.collect.Lists
import grails.transaction.Transactional
import groovy.time.TimeCategory
import groovy.time.TimeDuration
import org.apache.commons.io.FileUtils
import org.codehaus.groovy.runtime.DefaultGroovyMethods
import org.springframework.transaction.TransactionStatus

import java.text.SimpleDateFormat
import java.util.concurrent.BlockingQueue
import java.util.concurrent.LinkedBlockingQueue
import java.util.regex.Pattern

@Transactional
class TaskLoadService {

    private static BlockingQueue<TaskDescriptor> _loadQueue = new LinkedBlockingQueue<TaskDescriptor>()

    private static int _currentBatchSize = 0;
    private static Date _currentBatchStart = null;
    private static String _currentItemMessage = null;
    private static String _currentBatchInstigator = null;
    private static String _timeRemaining = ""
    private final static List<TaskLoadStatus> _report = new ArrayList<TaskLoadStatus>();
    private static boolean _cancel = false;

    def taskService
    def userService
    def logService
    def stagingService
    def fieldService

    def status() {
        def completedTasks = _currentBatchSize - _loadQueue.size();
        def startTime = ""

        if (_currentBatchStart) {
            SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss yyyy/MM/dd")
            startTime = sdf.format(_currentBatchStart)
        }

        int errorCount = 0l
        synchronized (_report) {
            errorCount = _report.findAll( { !it.succeeded }).size();
        }

        [   startTime: startTime,
            totalTasks: _currentBatchSize,
            currentItem: _currentItemMessage,
            queueLength: _loadQueue.size(),
            tasksLoaded: completedTasks,
            startedBy: _currentBatchInstigator,
            timeRemaining: _timeRemaining,
            errorCount: errorCount
        ]

    }

    /**
     * Returns a defensive copy of the current queue
     * @return
     */
    List<TaskDescriptor> currentQueue() {
        Lists.newArrayList(_loadQueue.iterator())
    }

    def loadTaskFromCSV(Project project, String csv, boolean replaceDuplicates) {

        if (_loadQueue.size() > 0) {
            return [false, 'Load operation already in progress!']
        }

        Closure importClosure = default_csv_import

        log.info "Looking for import function for template: ${project.template.name}"

        MetaProperty importClosureProperty = this.metaClass.properties.find() { it.name == "import_" + project.template.name }
        if (importClosureProperty) {
            log.info("Using 'import_${project.template.name} for import")
            importClosure = importClosureProperty.getProperty(this) as Closure
        } else {
            log.info "Using default CSV import routine"
        }

        try {
            def linenumber = 0;
            csv.eachCsvLine { String[] tokens ->
                //only one line in this case
                if (tokens.length > 1) {
                    def taskDesc = createTaskDescriptorFromTokens(project, tokens, importClosure, ++linenumber)
                    if (taskDesc) {
                        _loadQueue.put(taskDesc)
                    }
                } else {
                    log.info 'Skipping empty line'
                }
            }
        } catch (Exception ex) {
            return [false, ex.message]
        }

        backgroundProcessQueue(replaceDuplicates)

        return [true, ""]
    }

    def loadTasksFromStaging(Project project) {

        if (_loadQueue.size() > 0) {
            return [success: false, message: 'Load operation already in progress!']
        }

        def results = [message:'Tasks Queued for load.', success: false]
        def imageData = stagingService.buildTaskMetaDataList(project)

        def nameIndexRegex = Pattern.compile("^([A-Za-z]+)_(\\d+)")

        imageData.each { imgData ->

            def taskDesc = new TaskDescriptor(projectId: project.id, projectName: project.name, imageUrl: imgData.url, externalIdentifier: imgData.valueMap["externalIdentifier"] ?: imgData.valueMap["externalIdentifier_0"])
            imgData.valueMap.each { kvp ->
                def fieldName = kvp.key
                def recordIndex = 0

                def matcher = nameIndexRegex.matcher(fieldName)
                if (matcher.matches()) {
                    fieldName = matcher.group(1)
                    recordIndex = Integer.parseInt(matcher.group(2))
                }

                if (fieldName != 'externalIdentifier') {
                    taskDesc.fields.add([name: fieldName, recordIdx: recordIndex, transcribedByUserId: 'system', value: kvp.value])
                }
            }

            taskDesc.afterLoad = { Task task ->
                // Process shadow file entries after the task has been created. They will replace any defined field assignments
                try {
                    // Add shadow file contents...
                    imgData.shadowFiles?.each { shadowFile ->
                        log.info("Processing shadow files post task import ${task.id}: ${shadowFile.stagedFile.file}")
                        def file = new File(shadowFile.stagedFile.file as String)
                        if (file && file.exists()) {
                            def fieldValue = FileUtils.readFileToString(file)
                            if (fieldValue) {
                                fieldService.setFieldValueForTask(task, shadowFile.fieldName as String, shadowFile.recordIndex as Integer, fieldValue)
                            }
                            file.delete()
                        }
                    }
                    try {
                        // Load EXIF data from the image if the Project is configured to do so.
                        if (project.extractImageExifData) {
                            Map exif = ImageUtils.getExifMetadata(imgData.file)
                            exif.each { exifTag, value ->
                                fieldService.setFieldValueForTask(task, exifTag, 0, value)
                            }
                        }
                    }
                    catch (Exception e) {
                        log.error("Failed to extract EXIF data for task ${task.id}, image: ${imgData.file.name}", e)
                    }

                    imgData.file.delete()
                } catch (Exception ex) {
                    log.error("afterLoad for task ${task.id} failed:", ex)
                }
            }

            _loadQueue.put(taskDesc)
        }
        backgroundProcessQueue(true)
        results.success = true
        return results;
    }

    def default_csv_import = { TaskDescriptor taskDesc, String[] tokens, int linenumber ->
        List<Field> fields = new ArrayList<Field>()

        if (tokens.length == 1) {
            taskDesc.externalIdentifier = tokens[0]
            taskDesc.imageUrl = tokens[0].trim()
        } else if (tokens.length == 2) {
            taskDesc.externalIdentifier = tokens[0]
            taskDesc.imageUrl = tokens[1].trim()
        } else if (tokens.length == 5) {
            taskDesc.externalIdentifier = tokens[0].trim()
            taskDesc.imageUrl = tokens[1].trim()

            // create associated fields
            taskDesc.fields.add([name: 'institutionCode', recordIdx: 0, transcribedByUserId: 'system', value: tokens[2].trim()])
            taskDesc.fields.add([name: 'catalogNumber', recordIdx: 0, transcribedByUserId: 'system', value: tokens[3].trim()])
            taskDesc.fields.add([name: 'scientificName', recordIdx: 0, transcribedByUserId: 'system', value: tokens[4].trim()])
        } else {
            // error
            throw new RuntimeException("CSV has the incorrect number of fields! (has ${tokens.length}, expected 1, 2 or 5")
        }
    }

    private TaskDescriptor createTaskDescriptorFromTokens(Project project, String[] tokens, Closure importClosure, int lineNumber) {
        def taskDesc = new TaskDescriptor()
        taskDesc.projectId = project.id
        taskDesc.projectName = project.name

        if (importClosure) {
            importClosure(taskDesc, tokens, lineNumber)
        }

        return taskDesc;
    }

    def import_FieldNoteBook = { TaskDescriptor taskDesc, String[] tokens, int linenumber ->
        List<Field> fields = new ArrayList<Field>()
        if (tokens.length >= 4) {
            taskDesc.imageUrl = tokens[0].trim()
            taskDesc.externalIdentifier = tokens[1].trim()

            // create associated fields
            taskDesc.fields.add([name: 'institutionCode', recordIdx: 0, transcribedByUserId: 'system', value: tokens[2].trim()])
            taskDesc.fields.add([name: 'sequenceNumber', recordIdx: 0, transcribedByUserId: 'system', value: tokens[3].trim()])

            if (tokens.length >= 5) {
                def pageUrl = tokens[4].trim()
                if (pageUrl) {
                    taskDesc.media.add(new MediaLoadDescriptor(mediaUrl: pageUrl, mimeType: "text/plain", afterDownload: { Task t, Multimedia media, Map fileMap ->
                        def text = new File(fileMap.localPath).getText("utf-8")
                        def field = new Field(task: t, name: 'occurrenceRemarks', recordIdx: 0, transcribedByUserId: 'system', value: text)
                        field.save(flush: true)
                    }))
                }
            }

        } else {
            // error
            throw new RuntimeException("CSV has the incorrect number of fields for import into template journalDoublePage! (has ${tokens.length}, expected 3 or 4")
        }
    }

    def import_AerialObservations = { TaskDescriptor taskDesc, String[] tokens, lineNumber ->
        List<Field> fields = new ArrayList<Field>()
        if (tokens.length >= 6) {

            taskDesc.externalIdentifier = tokens[0].trim()
            taskDesc.imageUrl = tokens[1].trim()

            taskDesc.fields.add([name: 'institutionCode', recordIdx: 0, transcribedByUserId: 'system', value: tokens[2].trim()])
            taskDesc.fields.add([name: 'year', recordIdx: 0, transcribedByUserId: 'system', value: tokens[3].trim()])
            String dataSetId = "${taskDesc.externalIdentifier} page ${tokens[4].trim()} line ${tokens[5].trim()}"
            taskDesc.fields.add([name: 'datasetID', recordIdx: 0, transcribedByUserId: 'system', value: dataSetId])
            taskDesc.fields.add([name: 'sequenceNumber', recordIdx: 0, transcribedByUserId: 'system', value: lineNumber])


        } else {
            // error
            throw new RuntimeException("CSV has the incorrect number of fields for import into template AerialObservations! (has ${tokens.length}, expected 6")
        }
    }

    def import_ObservationDiary  = { TaskDescriptor taskDesc, String[] tokens, lineNumber ->
        List<Field> fields = new ArrayList<Field>()
        if (tokens.length >= 4) {
            taskDesc.externalIdentifier = tokens[0].trim()
            taskDesc.imageUrl = tokens[1].trim()
            taskDesc.fields.add([name: 'institutionCode', recordIdx: 0, transcribedByUserId: 'system', value: tokens[2].trim()])
            String dataSetId = "${taskDesc.externalIdentifier} page ${tokens[3].trim()}"
            taskDesc.fields.add([name: 'datasetID', recordIdx: 0, transcribedByUserId: 'system', value: dataSetId])
            taskDesc.fields.add([name: 'sequenceNumber', recordIdx: 0, transcribedByUserId: 'system', value: tokens[4]])
        } else {
            // error
            throw new RuntimeException("CSV has the incorrect number of fields for import into template AerialObservations! (has ${tokens.length}, expected 4")
        }

    }

    def import_ObservationDiaryWithMonth = import_ObservationDiary

    def import_FieldNoteBookDoublePage = { TaskDescriptor taskDesc, String[] tokens, int linenumber ->
        List<Field> fields = new ArrayList<Field>()
        if (tokens.length >= 4) {
            taskDesc.imageUrl = tokens[0].trim()
            taskDesc.externalIdentifier = tokens[1].trim()

            taskDesc.fields.add([name: 'institutionCode', recordIdx: 0, transcribedByUserId: 'system', value: tokens[2].trim()])
            taskDesc.fields.add([name: 'sequenceNumber', recordIdx: 0, transcribedByUserId: 'system', value: tokens[3].trim()])

            // Additional media (ocr text - loading to be deferred)
            if (tokens.length >= 5) {
                def lhpageUrl = tokens[4].trim()
                if (lhpageUrl) {
                    taskDesc.media.add(new MediaLoadDescriptor(mediaUrl: lhpageUrl, mimeType: "text/plain", afterDownload: { Task t, Multimedia media, Map fileMap ->
                        def text = new File(fileMap.localPath).getText("utf-8")
                        def field = new Field(task: t, name: 'occurrenceRemarks', recordIdx: 0, transcribedByUserId: 'system', value: text)
                        field.save(flush: true)
                    }))
                }
            }

            if (tokens.length >= 6) {
                def rhpageUrl = tokens[5]
                if (rhpageUrl) {
                    taskDesc.media.add(new MediaLoadDescriptor(mediaUrl: rhpageUrl, mimeType: "text/plain", afterDownload: { Task t, Multimedia media, Map fileMap ->
                        def text = new File(fileMap.localPath).getText("utf-8")
                        def field = new Field(task: t, name: 'occurrenceRemarks', recordIdx: 1, transcribedByUserId: 'system', value: text)
                        field.save(flush: true)
                    }))
                }
            }

        } else {
            // error
            throw new RuntimeException("CSV has the incorrect number of fields for import into template journalDoublePage! (has ${tokens.length}, expected 4,5 or 6")
        }
    }

    private static String replaceSpecialCharacters(String value) {
        def newValue = value?.replaceAll("\\\\n", "\n")
        return newValue
    }

    private Task createTaskFromTaskDescriptor(Project project, TaskDescriptor taskDesc) {
        Task t = new Task()
        t.project = project
        t.externalIdentifier = taskDesc.externalIdentifier
        t.save(flush: true)
        for (Map fd : taskDesc.fields) {
            fd.task = t

            // Check value for special character replacements...
            fd.value = replaceSpecialCharacters(fd.value ?: "")

            new Field(fd).save(flush: true)
        }

        def multimedia = new Multimedia()
        multimedia.task = t
        multimedia.filePath = taskDesc.imageUrl
        multimedia.save()
        // GET the image via its URL and save various forms to local disk
        def filePath = taskService.copyImageToStore(taskDesc.imageUrl, t.projectId, t.id, multimedia.id)
        filePath = taskService.createImageThumbs(filePath) // creates thumbnail versions of images
        multimedia.filePath = filePath.localUrlPrefix + filePath.raw   // This contains the url to the image without the server component
        multimedia.filePathToThumbnail = filePath.localUrlPrefix  + filePath.thumb  // Ditto for the thumbnail
        multimedia.mimeType = filePath.contentType
        multimedia.save()


        if (taskDesc.media) {
            for (MediaLoadDescriptor md : taskDesc.media) {
                multimedia = new Multimedia()
                multimedia.task = t
                multimedia.mimeType = md.mimeType
                multimedia.save() // need to get an id...
                // GET the image via its URL and save various forms to local disk
                filePath = taskService.copyImageToStore(md.mediaUrl, t.projectId, t.id, multimedia.id)
                multimedia.filePath = filePath.localUrlPrefix + filePath.raw   // This contains the url to the image without the server component
                multimedia.mimeType = filePath.contentType
                multimedia.save()
                if (md.afterDownload) {
                    try {
                        md.afterDownload(t, multimedia, filePath)
                    } catch (Exception ex) {
                        log.info "Error calling after media download hook: ${ex.message}"
                    }
                }
            }
        }

        if (t) {
            if (taskDesc.afterLoad) {
                taskDesc.afterLoad(t)
            }
        }

        return t
    }

    private def backgroundProcessQueue(boolean replaceDuplicates) {

        if (_loadQueue.size() > 0) {

            _currentBatchSize = _loadQueue.size()
            _currentBatchStart = Calendar.instance.time
            _currentBatchInstigator = userService.currentUserId
            synchronized (_report) {
                _report.clear()
            }
            _cancel = false
            runAsync {
                Map<Long, Project> projects = [:].withDefault { Long id -> Project.get(id) }
                try {
                    TaskDescriptor taskDesc
                    while ((taskDesc = _loadQueue.poll()) && !_cancel) {
                        _currentItemMessage = "${taskDesc.externalIdentifier}"

                        def project = projects[taskDesc.projectId]
                        def existing = Task.findAllByExternalIdentifierAndProject(taskDesc.externalIdentifier, project)

                        if (existing && existing.size() > 0) {
                            if (replaceDuplicates) {
                                Task.deleteAll(existing)
                            } else {
                                synchronized (_report) {
                                    _report.add(new TaskLoadStatus(succeeded: false, taskDescriptor: taskDesc, message: "Skipped because task id already exists", time: Calendar.instance.time))
                                }
                                continue
                            }
                        }

                        try {
                            Task.withNewTransaction { status ->

                                def t = createTaskFromTaskDescriptor(project, taskDesc)

                                // Attempt to predict when the import will complete
                                def now = Calendar.instance.time
                                def remainingMillis = _loadQueue.size() * ((now.time - _currentBatchStart.time) / (_currentBatchSize - _loadQueue.size()))
                                def expectedEndTime = new Date((long) (now.time + remainingMillis))
                                _timeRemaining = formatDuration(TimeCategory.minus(expectedEndTime, now))
                                synchronized (_report) {
                                    _report.add(new TaskLoadStatus(succeeded: true, taskDescriptor: taskDesc, message: "", time: Calendar.instance.time))
                                }
                            }
                        } catch (Exception ex) {
                            log.error("Exception while creating new task for $taskDesc", ex)
                            synchronized (_report) {
                                _report.add(new TaskLoadStatus(succeeded: false, taskDescriptor: taskDesc, message: ex.toString(), time: Calendar.instance.time))
                            }
                        }
                    }
                } catch (Exception e) {
                    log.error("Exception running task loading async job", e)
                    def tl = []
                    def drained = _loadQueue.drainTo(tl)
                    log.debug("Drained ${drained} tasks")
                    tl.each {
                        _report.add(new TaskLoadStatus(succeeded: false, taskDescriptor: it, message: e.message, time: Calendar.instance.time))
                    }
                } finally {
                    _currentItemMessage = ""
                    _currentBatchSize = 0
                    _currentBatchStart = null
                    _currentBatchInstigator = ""
                    if (_cancel) _loadQueue.clear()
                }
            }
        }
    }

    public def cancelLoad() {
        _cancel = true
    }

    List<TaskDescriptor> clearQueue() {
        def tasks = []
        _loadQueue.drainTo(tasks)
        tasks
    }

    def List<TaskLoadStatus> getLastReport() {
        synchronized (_report) {
            return new ArrayList<TaskLoadStatus>(_report)
        }
    }

    def formatDuration(TimeDuration d) {
        List buffer = new ArrayList()

        if (d.years != 0) buffer.add(d.years + " years");
        if (d.months != 0) buffer.add(d.months + " months");
        if (d.days != 0) buffer.add(d.days + " days");
        if (d.hours != 0) buffer.add(d.hours + " hours");
        if (d.minutes != 0) buffer.add(d.minutes + " minutes");

        if (d.seconds != 0)
            buffer.add(d.seconds + " seconds");

        if (buffer.size() != 0) {
            return DefaultGroovyMethods.join(buffer, ", ");
        } else {
            return "0";
        }
    }

}
