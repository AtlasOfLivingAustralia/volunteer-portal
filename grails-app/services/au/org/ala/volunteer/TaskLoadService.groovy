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

        csv.eachCsvLine { tokens ->
            //only one line in this case
            def taskDesc = new TaskDescriptor()
            taskDesc.project = project

            String imageUrl = ""
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
                return [false, "CSV file has incorrect number of fields"]
            }

            _loadQueue.put(taskDesc)
        }

        backgroundProcessQueue(replaceDuplicates)

        return [true, ""]
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
                                def filePath = taskService.copyImageToStore(taskDesc.imageUrl, t.id, multimedia.id)
                                filePath = taskService.createImageThumbs(filePath) // creates thumbnail versions of images
                                multimedia.filePath = filePath.dir + "/" + filePath.raw
                                multimedia.filePathToThumbnail = filePath.dir + "/" + filePath.thumb
                                multimedia.save()

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
                                // Something bad happened. If it is failing consistently we don't want this thread
                                // killing everything, so we'll sleep and try again
                                println(ex)
                                ex.printStackTrace();
                                status.setRollbackOnly()
                                Thread.sleep(1000);
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
