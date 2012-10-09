package au.org.ala.volunteer

import groovy.time.TimeCategory
import groovy.time.TimeDuration
import org.codehaus.groovy.runtime.DefaultGroovyMethods

import java.text.SimpleDateFormat
import java.util.concurrent.BlockingQueue
import java.util.concurrent.LinkedBlockingQueue

class TaskLoadService {

    private static BlockingQueue<TaskDescriptor> _loadQueue = new LinkedBlockingQueue<TaskDescriptor>()

    private static int _currentBatchSize = 0;
    private static Date _currentBatchStart = null;
    private static String _currentItemMessage = null;
    private static String _currentBatchInstigator = null;
    private static String _timeRemaining = ""
    private static List<TaskLoadStatus> _report = new ArrayList<TaskLoadStatus>();
    private static boolean _cancel = false;

    def taskService
    def authService
    def logService
    def executorService

    static transactional = true

    def status = {
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

    def loadTaskFromCSV(Project project, String csv, boolean replaceDuplicates) {

        if (_loadQueue.size() > 0) {
            return [false, 'Load operation already in progress!']
        }

        Closure importClosure = default_csv_import

        logService.log "Looking for import function for template: ${project.template.name}"

        MetaProperty importClosureProperty = this.metaClass.properties.find() { it.name == "import_" + project.template.name }
        if (importClosureProperty) {
            logService.log("Using 'import_${project.template.name} for import")
            importClosure = importClosureProperty.getProperty(this) as Closure
        } else {
            logService.log "Using default CSV import routine"
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
                    logService.log 'Skipping empty line'
                }
            }
        } catch (Exception ex) {
            return [false, ex.message]
        }

        backgroundProcessQueue(replaceDuplicates)

        return [true, ""]
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
        taskDesc.project = project

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

    private def backgroundProcessQueue(boolean replaceDuplicates) {

        if (_loadQueue.size() > 0) {

            _currentBatchSize = _loadQueue.size();
            _currentBatchStart = Calendar.instance.time;
            _currentBatchInstigator = authService.username()
            synchronized (_report) {
                _report.clear()
            }
            _cancel = false;
            runAsync {
                TaskDescriptor taskDesc
                while ((taskDesc = _loadQueue.poll()) && !_cancel) {
                    _currentItemMessage = "${taskDesc.externalIdentifier}"

                    def existing = Task.findAllByExternalIdentifierAndProject(taskDesc.externalIdentifier, taskDesc.project);

                    if (existing && existing.size() > 0) {
                        if (replaceDuplicates) {
                            for (Task t : existing) {
                                t.delete();
                            }
                        } else {
                            synchronized (_report) {
                                _report.add(new TaskLoadStatus(succeeded:false, taskDescriptor: taskDesc, message: "Skipped because task id already exists", time: Calendar.instance.time))
                            }
                            continue
                        }
                    }

                    Task.withTransaction { status ->

                        try {
                            Task t = new Task()
                            t.project = taskDesc.project
                            t.externalIdentifier = taskDesc.externalIdentifier
                            t.save(flush: true)
                            for (Map fd : taskDesc.fields) {
                                fd.task = t;
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
                                            logService.log "Error calling after media download hook: ${ex.message}"
                                        }
                                    }
                                }
                            }

                            // Attempt to predict when the import will complete
                            def now = Calendar.instance.time;
                            def remainingMillis = _loadQueue.size() * ((now.time - _currentBatchStart.time) / (_currentBatchSize - _loadQueue.size()))
                            def expectedEndTime = new Date((long) (now.time + remainingMillis))
                            _timeRemaining = formatDuration(TimeCategory.minus(expectedEndTime, now))
                            synchronized (_report) {
                                _report.add(new TaskLoadStatus(succeeded:true, taskDescriptor: taskDesc, message: "", time: Calendar.instance.time))
                            }

                        } catch (Exception ex) {
                            synchronized (_report) {
                                _report.add(new TaskLoadStatus(succeeded:false, taskDescriptor: taskDesc, message: ex.toString(), time: Calendar.instance.time))
                            }
                        }
                    }
                }

                if (_cancel) {
                    _loadQueue.clear();
                }

                _currentItemMessage = ""
                _currentBatchSize = 0;
                _currentBatchStart = null;
                _currentBatchInstigator = ""
            }
        }
    }

    public def cancelLoad() {
        _cancel = true;
    }

    def List<TaskLoadStatus> getLastReport() {
        synchronized (_report) {
            return new ArrayList<TaskLoadStatus>(_report)
        }
    }

    def formatDuration(TimeDuration d) {
        List buffer = new ArrayList();

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
