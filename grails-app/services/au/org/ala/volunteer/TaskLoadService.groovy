package au.org.ala.volunteer

import au.org.ala.volunteer.jooq.tables.records.FieldRecord
import au.org.ala.volunteer.jooq.tables.records.MediaLoadDescriptorRecord
import au.org.ala.volunteer.jooq.tables.records.MultimediaRecord
import au.org.ala.volunteer.jooq.tables.records.ProjectRecord
import au.org.ala.volunteer.jooq.tables.records.ShadowFileDescriptorRecord
import au.org.ala.volunteer.jooq.tables.records.TaskDescriptorRecord
import au.org.ala.volunteer.jooq.tables.records.TaskRecord
import grails.events.EventPublisher
import groovy.transform.stc.ClosureParams
import groovy.transform.stc.FirstParam
import groovy.util.logging.Slf4j
import org.apache.commons.io.FileUtils
import org.apache.commons.lang.StringUtils
import org.jooq.Configuration
import org.jooq.DSLContext
import org.jooq.TransactionalCallable
import org.jooq.TransactionalRunnable
import org.jooq.impl.DSL
import org.springframework.beans.factory.annotation.Value

import java.nio.charset.StandardCharsets
import java.sql.Timestamp
import java.util.regex.Pattern

import static au.org.ala.volunteer.jooq.Sequences.HIBERNATE_SEQUENCE
import static au.org.ala.volunteer.jooq.Tables.PROJECT
import static au.org.ala.volunteer.jooq.Tables.SHADOW_FILE_DESCRIPTOR
import static au.org.ala.volunteer.jooq.tables.Field.FIELD
import static au.org.ala.volunteer.jooq.tables.MediaLoadDescriptor.MEDIA_LOAD_DESCRIPTOR
import static au.org.ala.volunteer.jooq.tables.Multimedia.MULTIMEDIA
import static au.org.ala.volunteer.jooq.tables.Task.TASK
import static au.org.ala.volunteer.jooq.tables.TaskDescriptor.TASK_DESCRIPTOR
import static org.jooq.impl.DSL.count
import static org.jooq.impl.DSL.currentTimestamp
import static org.jooq.impl.DSL.defaultValue
import static org.jooq.impl.DSL.min
import static org.jooq.impl.DSL.now
import static org.jooq.impl.DSL.row
import static org.jooq.impl.DSL.select
import static org.jooq.impl.DSL.val
import static org.jooq.impl.DSL.when

// Transactions will be controlled explicitly
@Slf4j
class TaskLoadService implements EventPublisher {

    // explicity control transactions with jooq
    def taskService
    def stagingService
    Closure<DSLContext> jooqContext
    def assetResourceLocator
    def projectService

    @Value('${digivol.ingest.queue.size:200}')
    Integer batchSize = 100

    static class Status {
        int count
        Timestamp timeStarted
        int retryCount
        int errorCount
    }

    Status status(long projectId) {

        DSLContext create = jooqContext()

        create
                .select(
                        count().as('count'),
                        min(TASK_DESCRIPTOR.TIME_CREATED).as('time_started'),
                        count(when(TASK_DESCRIPTOR.RETRIES_REMAINING.gt(0) & TASK_DESCRIPTOR.RETRIES_REMAINING.lt(3), 1)).as('retry_count'),
                        count(when(TASK_DESCRIPTOR.RETRIES_REMAINING.eq(0), 1)).as('error_count')
                )
                .from(TASK_DESCRIPTOR)
                .where(TASK_DESCRIPTOR.PROJECT_ID.eq(projectId))
                .fetchOne().into(Status)
    }

    def isProjectLoadingAlready(long projectId) {
        DSLContext create = jooqContext()

        return create.fetchExists(TASK_DESCRIPTOR, TASK_DESCRIPTOR.PROJECT_ID.eq(projectId))
    }

    def loadTaskFromCSV(Project project, String csv, boolean replaceDuplicates) {

        Closure<List<MediaLoadDescriptorRecord>> importClosure = default_csv_import

        log.info "Looking for import function for template: ${project.template.name}"

        MetaProperty importClosureProperty = this.metaClass.properties.find() { it.name == "import_" + project.template.name }
        if (importClosureProperty) {
            log.debug("Using 'import_${project.template.name} for import")
            importClosure = importClosureProperty.getProperty(this) as Closure
        } else {
            log.debug "Using default CSV import routine"
        }

        DSLContext create = jooqContext()
        create.settings().updatablePrimaryKeys = true

        try {
            def linenumber = 0
            def taskDescs = []

            create.transaction({ cfg ->
                def ctx = DSL.using(cfg)

                csv.eachCsvLine { String[] tokens ->
                    //only one line in this case
                    if (tokens.length > 1) {
                        def taskDescContainer = createTaskDescriptorFromTokens(ctx, project, tokens, importClosure, ++linenumber, replaceDuplicates)
                        taskDescs.add(taskDescContainer)
                    } else {
                        log.info 'Skipping empty line'
                    }
                }

                ctx.batchInsert(taskDescs*.mediaDescs).execute()

            } as TransactionalRunnable)

            TaskIngestJob.triggerNow([project: project.id])
        } catch (Exception ex) {
            log.error("Creating CSV failed: ${ex.message}", ex)
            return [false, ex.message]
        }

        return [true, ""]
    }

    def loadTasksFromStaging(Project project) {

        def results = [message:'Tasks Queued for load.', success: false]
        def imageData = stagingService.buildTaskMetaDataList(project)

        def nameIndexRegex = Pattern.compile("^([A-Za-z]+)_(\\d+)")

        DSLContext create = jooqContext()

        create.settings().updatablePrimaryKeys = true

        create.transaction({ cfg ->
            def txContext = DSL.using(cfg)
            imageData.each { imgData ->

                def taskDesc = txContext.newRecord(TASK_DESCRIPTOR).with {
                    projectId = project.id
                    projectName = project.name
                    imageUrl = imgData.url
                    fields = []
                    replaceDuplicates = true
                    externalIdentifier = imgData.valueMap["externalIdentifier"] ?: imgData.valueMap["externalIdentifier_0"]
                    it
                }
                imgData.valueMap.each { kvp ->
                    def fieldName = kvp.key
                    def recordIndex = 0

                    def matcher = nameIndexRegex.matcher(fieldName as CharSequence)
                    if (matcher.matches()) {
                        fieldName = matcher.group(1)
                        recordIndex = Integer.parseInt(matcher.group(2))
                    }

                    if (fieldName != 'externalIdentifier') {
                        taskDesc.fields.add([name: fieldName, recordIdx: recordIndex, transcribedByUserId: 'system', value: kvp.value])
                    }
                }

                taskDesc.store()

                def shadowFileRecords = imgData.shadowFiles?.collect { shadowFile ->
                    log.info("Adding shadow files pre task import ${taskDesc.id}: ${shadowFile.stagedFile.file}")
                    def filePath = shadowFile.stagedFile.file as String
                    txContext.newRecord(SHADOW_FILE_DESCRIPTOR).with {
                        taskDescriptorId = taskDesc.id
                        name = shadowFile.fieldName as String
                        recordIdx = shadowFile.recordIndex as Integer
                        value = filePath
                        it
                    }
                }

                if (shadowFileRecords) {
                    txContext.batchInsert(shadowFileRecords).execute()
                }
            }
        } as TransactionalRunnable)

        TaskIngestJob.triggerNow([project: project.id])

//        backgroundProcessQueue(true)
        results.success = true
        return results;
    }

    def default_csv_import = { DSLContext ctx, TaskDescriptorRecord taskDesc, String[] tokens, int linenumber ->
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
            def fields = [
                    [name: 'institutionCode', recordIdx: 0, transcribedByUserId: 'system', value: tokens[2].trim()],
                    [name: 'catalogNumber', recordIdx: 0, transcribedByUserId: 'system', value: tokens[3].trim()],
                    [name: 'scientificName', recordIdx: 0, transcribedByUserId: 'system', value: tokens[4].trim()]
            ]

            taskDesc.fields = fields
        } else {
            // error
            throw new RuntimeException("CSV has the incorrect number of fields! (has ${tokens.length}, expected 1, 2 or 5")
        }
    }

    static class TaskDescriptorRecordContainer {
        TaskDescriptorRecord taskDesc
        List<MediaLoadDescriptorRecord> mediaDescs
    }

    private TaskDescriptorRecordContainer createTaskDescriptorFromTokens(DSLContext ctx, Project project, String[] tokens, Closure<List<MediaLoadDescriptorRecord>> importClosure, int lineNumber, boolean replaceDuplicates) {
        def taskDesc = ctx.newRecord(TASK_DESCRIPTOR)
        taskDesc.projectId = project.id
        taskDesc.projectName = project.name
        taskDesc.replaceDuplicates = replaceDuplicates
        taskDesc.fields = []

        taskDesc.store()

        def mediaDescs = []
        if (importClosure) {
            mediaDescs = importClosure(taskDesc, tokens, lineNumber)
        }

        return new TaskDescriptorRecordContainer(taskDesc: taskDesc, mediaDescs: mediaDescs)
    }

    final Map<String, Closure<List<FieldRecord>>> mediaAfterLoadTable = [
            'import_FieldNoteBookMedia': import_FieldNoteBookMedia(0),
            'import_FieldNoteBookDoublePageMediaPage1': import_FieldNoteBookMedia(0),
            'import_FieldNoteBookDoublePageMediaPage2': import_FieldNoteBookMedia(1),
    ]

    def import_FieldNoteBook = { DSLContext ctx, TaskDescriptorRecord taskDesc, String[] tokens, int linenumber ->
        def mediaDesc = []
        if (tokens.length >= 4) {
            taskDesc.imageUrl = tokens[0].trim()
            taskDesc.externalIdentifier = tokens[1].trim()

            // create associated fields
            taskDesc.fields.add([name: 'institutionCode', recordIdx: 0, transcribedByUserId: 'system', value: tokens[2].trim()])
            taskDesc.fields.add([name: 'sequenceNumber', recordIdx: 0, transcribedByUserId: 'system', value: tokens[3].trim()])

            if (tokens.length >= 5) {
                def pageUrl = tokens[4].trim()
                if (pageUrl) {
                    mediaDesc.add(ctx.newRecord(MEDIA_LOAD_DESCRIPTOR).with {
                        taskDescriptorId = taskDesc.id
                        mediaUrl = pageUrl
                        mimeType = "text/plain"
                        afterDownload = 'import_FieldNoteBookMedia'
                        it
                    })
                }
            }

            return mediaDesc
        } else {
            // error
            throw new RuntimeException("CSV has the incorrect number of fields for import into template journalDoublePage! (has ${tokens.length}, expected 3 or 4")
        }
    }

    def import_FieldNoteBookMedia(int page) {
        { TaskRecord task, MultimediaRecord media, Map fileMap ->
            def text = new File(fileMap.localPath).getText("utf-8")
            [new FieldRecord(taskId: task.id, name: 'occurrenceRemarks', recordIdx: page, transcribedByUserId: 'system', value: text)]
        }
    }

    def import_AerialObservations = { DSLContext ctx, TaskDescriptorRecord taskDesc, String[] tokens, lineNumber ->
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
        return []
    }

    def import_ObservationDiary  = { DSLContext ctx, TaskDescriptorRecord taskDesc, String[] tokens, lineNumber ->
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
        return []
    }

    def import_ObservationDiaryWithMonth = import_ObservationDiary

    def import_FieldNoteBookDoublePage = { DSLContext ctx, TaskDescriptorRecord taskDesc, String[] tokens, int linenumber ->
//        List<Field> fields = new ArrayList<Field>()
        def mediaDesc = []
        if (tokens.length >= 4) {
            taskDesc.imageUrl = tokens[0].trim()
            taskDesc.externalIdentifier = tokens[1].trim()

            taskDesc.fields.add([name: 'institutionCode', recordIdx: 0, transcribedByUserId: 'system', value: tokens[2].trim()])
            taskDesc.fields.add([name: 'sequenceNumber', recordIdx: 0, transcribedByUserId: 'system', value: tokens[3].trim()])

            // Additional media (ocr text - loading to be deferred)
            if (tokens.length >= 5) {
                def lhpageUrl = tokens[4].trim()
                if (lhpageUrl) {
                    taskDesc.store()
                    mediaDesc.add(ctx.newRecord(MEDIA_LOAD_DESCRIPTOR).with {
                        taskDescriptorId = taskDesc.id
                        mediaUrl = lhpageUrl
                        mimeType = "text/plain"
                        afterDownload = 'import_FieldNoteBookDoublePageMediaPage1'
                        it
                    })
                }
            }

            if (tokens.length >= 6) {
                def rhpageUrl = tokens[5]
                if (rhpageUrl) {
                    mediaDesc.add(ctx.newRecord(MEDIA_LOAD_DESCRIPTOR).with {
                        taskDescriptorId = taskDesc.id
                        mediaUrl = rhpageUrl
                        mimeType = "text/plain"
                        afterDownload = 'import_FieldNoteBookDoublePageMediaPage2'
                        it
                    })
                }
            }

            return mediaDesc
        } else {
            // error
            throw new RuntimeException("CSV has the incorrect number of fields for import into template journalDoublePage! (has ${tokens.length}, expected 4,5 or 6")
        }
    }

    private static String replaceSpecialCharacters(String value) {
        def newValue = value?.replaceAll("\\\\n", "\n")
        return newValue
    }

    static class LoadStatus {
        TaskDescriptorRecord taskDescriptorRecord
        TaskRecord taskRecord
        MultimediaLoadStatus mediaLoadStatus = new MultimediaLoadStatus()
        List<FieldRecord> fieldRecords = []
        List<MediaLoadStatus> mediaRecords = []
        List<FieldRecord> extraFieldRecords = []
        List<ShadowFileDescriptorRecord> shadowFiles = []

        Long getProjectId() {
            taskDescriptorRecord?.projectId
        }

        Long getTaskId() {
            taskRecord?.id
        }

        boolean skip = false
        boolean success = true
        String message
    }

    static class MultimediaLoadStatus {
        MultimediaRecord multimediaRecord
        TaskService.FileMap filePath
    }

    static class MediaLoadStatus extends MultimediaLoadStatus {
        MediaLoadDescriptorRecord mediaLoadDescriptorRecord
    }

    def doTaskLoad(Long projectId = null) {
        int dequeuedTasks
        while ((dequeuedTasks = doTaskLoadIteration(projectId)) != 0) {
            // Calculate project directory disk usage after completion
            def project = Project.get(projectId)
            if (project) {
                def projectSize = projectService.projectSize(project).size as long
                log.info("Project size: ${projectSize}")
            }

            log.info("Completed loading {} tasks for project {}", dequeuedTasks, projectId)
        }
    }

    private int doTaskLoadIteration(Long projectId = null) {
        def ctx = jooqContext.call()

        final List<LoadStatus> jobsStatuses = []

        def rollback = false
        int dequeuedTasks = 0
        try {
            dequeuedTasks = ctx.transactionResult(taskLoadTransaction.curry(jobsStatuses, projectId) as TransactionalCallable<Integer>)
            log.debug("Task load completed successfully")
        } catch (RuntimeException e) {
            log.error("Task load aborted with rollback", e)
            rollback = true
        }

        if (!rollback) {

            failedStatuses(jobsStatuses) { statuses ->
                statuses.each { status ->
                    // Manually roll back singly failed job
                    // Media byte objects rollback to be performed outside db transaction context
                    try {

                        log.info("Rolling back byte objects {}", status)

                        def taskId = status.taskId
                        def statusProjectId = status.projectId

                        def mediaRecords = status.mediaRecords.findAll { it.multimediaRecord.id }
                        mediaRecords.each {

                            def mediaUrl = it.mediaLoadDescriptorRecord?.mediaUrl
                            def multimediaId = it.multimediaRecord?.id

                            if (mediaUrl && multimediaId && taskId && statusProjectId) {
                                taskService.rollbackMultimediaTransaction(mediaUrl, statusProjectId, taskId, multimediaId)
                            }
                        }
                        def mediaUrl = status.taskDescriptorRecord?.imageUrl
                        def multimediaId = status.mediaLoadStatus?.multimediaRecord?.id

                        if (mediaUrl && multimediaId && taskId && statusProjectId) {
                            taskService.rollbackMultimediaTransaction(mediaUrl, statusProjectId, taskId, multimediaId)
                        }
                    } catch (e) {
                        log.error("Caught exception rolling back {}", status, e)
                    }
                }
            }

            continueStatuses(jobsStatuses) { statuses ->
                // clean up staging files on success

                statuses.each { status ->

                    try {
                        status.shadowFiles.each {
                            def file = new File(it.value)
                            def success = file.delete()
                            if (success) {
                                log.debug("Deleted shadow file {}", file)
                            } else {
                                log.error("Deleting shadow file {} failed", file)
                            }
                        }

                        // media records not supported via staging area, no need to clean up files.

                        if (status.taskDescriptorRecord.externalIdentifier) {
                            def success = stagingService.unstageImage(status.projectId, status.taskDescriptorRecord.externalIdentifier)
                            if (success) {
                                log.debug("Deleted staged task file {}:{}", status.projectId, status.taskDescriptorRecord.externalIdentifier)
                            } else {
                                log.error("Deleting staged task file {}:{} failed", status.projectId, status.taskDescriptorRecord.externalIdentifier)
                            }
                        }
                    } catch (e) {
                        log.error("Caught exception cleaing up staging area for {}", status, e)
                    }
                }

                (statuses*.projectId as Set).each {
                    try {
                        taskService.clearMaxSequenceNumber(it ?: -1)
                    } catch (e) {
                        log.error("Couldn't clear max sequence number cache for project id {}", it, e)
                    }
                }

            }
        }

        return dequeuedTasks

    }

    private Closure<Integer> taskLoadTransaction = { List<LoadStatus> jobsStatuses, Long projectId, Configuration cfg ->
        def create = DSL.using(cfg)
        def jobFilter = TASK_DESCRIPTOR.RETRIES_REMAINING.gt(0)
        if (projectId) jobFilter = jobFilter & TASK_DESCRIPTOR.PROJECT_ID.eq(projectId)
        def jobs = create
                .update(TASK_DESCRIPTOR)
                .set([(TASK_DESCRIPTOR.RETRIES_REMAINING) : TASK_DESCRIPTOR.RETRIES_REMAINING - 1])
                .where(
                        TASK_DESCRIPTOR.ID.in(
                                select(TASK_DESCRIPTOR.ID)
                                        .from(TASK_DESCRIPTOR)
                                        .where(jobFilter)
                                        .orderBy(TASK_DESCRIPTOR.ID)
                                        .limit(batchSize)
                                        .forUpdate().skipLocked() // <-- row locks to prevent duplicate processing
                        )
                )
                .returning()
                .fetch()

        // Just to be sure the list is in this order
        jobs.sortAsc(TASK_DESCRIPTOR.ID)
        final dequeuedTasks = jobs.size()
        // handle duplicate tasks

        def jobsByReplaceDuplicates = jobs.groupBy { it.replaceDuplicates }
        def deleteDuplicates = jobsByReplaceDuplicates[true]
        if (deleteDuplicates) {
            def duplicateFinder = deleteDuplicates.collect { row(it.projectId, it.externalIdentifier) }

            def deletes = create.deleteFrom(TASK).where(row(TASK.PROJECT_ID, TASK.EXTERNAL_IDENTIFIER).in(duplicateFinder)).execute()
            log.info("Deleting {} duplicates for task load", deletes)
        }

        jobsStatuses.addAll(jobs.collect { job -> new LoadStatus(taskDescriptorRecord: job) })

        def statusByJobBusinessKey = jobsStatuses.<List<Object>, LoadStatus, LoadStatus> collectEntries { LoadStatus status ->
            [([status.taskDescriptorRecord.projectId, status.taskDescriptorRecord.imageUrl]): status]
        }

        def skipDuplicates = jobsByReplaceDuplicates[false]
        if (skipDuplicates) {
            def duplicateFinder = skipDuplicates.collect { row(it.projectId, it.imageUrl) }
            def skips = create.select(TASK.PROJECT_ID, TASK.EXTERNAL_IDENTIFIER).from(TASK).where(row(TASK.PROJECT_ID, TASK.EXTERNAL_IDENTIFIER).in(duplicateFinder)).fetch()
            skips.each {
                def job = statusByJobBusinessKey[[it.value1(), it.value2()]]
                job?.skip = true
            }
            log.info("Skipping {} duplicates", skips)
        }

        if (jobs.isEmpty()) {
            log.debug("No more jobs")
            return dequeuedTasks
        }

        // Load projects for project settings
        def projectIds = (jobsStatuses*.projectId as Set).findAll { it != null }
        def projects = create.selectFrom(PROJECT).where(PROJECT.ID.in(projectIds)).fetch().<Long, ProjectRecord, ProjectRecord> collectEntries { [(it.id): it ]}

        // Generate initial task objects
        continueAndSkipStatuses(jobsStatuses, taskLoadStepGenerateTasks.curry(create))

        Map<Long, Long> taskDescriptorIdToTaskIdMap = continueAndSkipStatuses(jobsStatuses) { statuses ->
                statuses.<Long, Long, LoadStatus> collectEntries { [(it.taskDescriptorRecord.id): it.taskRecord.id] }
        }

        continueAndSkipStatuses(jobsStatuses, taskLoadStepImportImage.curry(create))
        continueAndSkipStatuses(jobsStatuses, taskLoadStepUpdateMultimedia.curry(create))
        continueAndSkipStatuses(jobsStatuses, taskLoadStepGenerateFields.curry(create))

        continueAndSkipStatuses(jobsStatuses, taskLoadStepGenerateExtraMedia.curry(create, taskDescriptorIdToTaskIdMap))
        continueAndSkipStatuses(jobsStatuses, taskLoadStepInsertExtraMedia.curry(create))
        continueAndSkipStatuses(jobsStatuses, taskLoadStepShadowFiles.curry(create))
        continueAndSkipStatuses(jobsStatuses, taskLoadStepExtractExifData.curry(create, projects))
        continueAndSkipStatuses(jobsStatuses, taskLoadStepInsertExtraFields.curry(create))
        // DONE

        // Any failed tasks we roll back any created database records here
        // Media byte objects rollback to be performed outside db transaction context
        failedStatuses(jobsStatuses) { statuses ->
            statuses.each { status ->
                // Manually roll back single failed job
                log.info("Rolling back {} with message", status)

                def extraFields = status.extraFieldRecords.findAll { it.id }
                if (extraFields) {
                    create.batchDelete(extraFields).execute()
                }

                def mediaRecords = status.mediaRecords.findAll { it.multimediaRecord.id }
                if (mediaRecords) {
                    create.batchDelete(mediaRecords*.multimediaRecord).execute()
                }

                if (status.mediaLoadStatus.multimediaRecord.id) {
                    taskService.rollbackMultimediaTransaction(status.taskDescriptorRecord.imageUrl, status.projectId, status.taskId, status.mediaLoadStatus.multimediaRecord.id)
                    create.executeDelete(status.mediaLoadStatus.multimediaRecord)
                }

                if (status.taskRecord.id) {
                    create.executeDelete(status.taskRecord)
                }

            }
            def byProject = statuses.groupBy { it.projectId }

            projectIds.each { id ->
                def project = projects[id]
                def count = byProject[id].size()
                if (count) {
                    notify(EventSourceService.NEW_MESSAGE, new Message.EventSourceMessage(to: project.createdById, event: 'createTasks', data: [project: project.name, count: count, success: false]))
                }
            }
        }

        // All successful jobs, delete the task descriptor from the queue
        // and notify project owner.
        continueStatuses(jobsStatuses) { statuses ->
            def taskDescriptorIds = statuses*.taskDescriptorRecord*.id

            def deletes = create
                    .deleteFrom(TASK_DESCRIPTOR)
                    .where(TASK_DESCRIPTOR.ID.in(taskDescriptorIds))
                    .execute()
            log.debug("Completed {} job(s)", deletes)

            def byProject = statuses.groupBy { it.projectId }

            projectIds.each { id ->
                def project = projects[id]
                def count = byProject[id].size()
                if (count) {
                    notify(EventSourceService.NEW_MESSAGE, new Message.EventSourceMessage(to: project.createdById, event: 'createTasks', data: [project: project.name, count: count, success: true]))
                }
            }
        }

        return dequeuedTasks
    }

    private Closure taskLoadStepGenerateTasks = { DSLContext create, List<LoadStatus> statuses ->
        statuses.each { LoadStatus status ->
            status.taskRecord = createInitialTaskRecordFromDescriptor(status.taskDescriptorRecord)
        }

        def taskRecords = statuses*.taskRecord.inject(create.insertInto(TASK, TASK.ID, TASK.PROJECT_ID, TASK.EXTERNAL_IDENTIFIER, TASK.VIEWED, TASK.IS_FULLY_TRANSCRIBED, TASK.CREATED, TASK.DATE_LAST_UPDATED)) { insert, taskRecord ->
            insert.values(HIBERNATE_SEQUENCE.nextval(), val(taskRecord.projectId), val(taskRecord.externalIdentifier), defaultValue(TASK.VIEWED), defaultValue(TASK.IS_FULLY_TRANSCRIBED), currentTimestamp(), currentTimestamp())
        }.returning().fetch()

        statuses.eachWithIndex { LoadStatus status, int i ->
            status.taskRecord = taskRecords[i]
        }
    }

    private Closure taskLoadStepImportImage = { DSLContext create, List<LoadStatus> statuses ->
        statuses.each { status ->
            status.mediaLoadStatus.multimediaRecord = createInitialMultimediaRecordFromDescriptor(status.taskDescriptorRecord, status.taskRecord)
        }

        def multimediaRecords = statuses*.mediaLoadStatus*.multimediaRecord.inject(create.insertInto(MULTIMEDIA, MULTIMEDIA.ID, MULTIMEDIA.TASK_ID, MULTIMEDIA.FILE_PATH, MULTIMEDIA.CREATED)) { insert, mmPojo ->
            insert.values(HIBERNATE_SEQUENCE.nextval(), val(mmPojo.taskId), val(mmPojo.filePath), currentTimestamp())
        }.returning().fetch()

        statuses.eachWithIndex { LoadStatus status, int i ->
            status.mediaLoadStatus.multimediaRecord = multimediaRecords[i]
        }

        // First real failure point, until now an SQL exception will rollback the transaction
        statuses.each { status ->
            try {
                status.mediaLoadStatus.filePath = completeMultimediaRecord(status.mediaLoadStatus.multimediaRecord, status.projectId)
            } catch (e) {
                log.error("Exception while completing multimedia record {}", status.taskDescriptorRecord, e)
                status.success = false
                status.message = e.message
            }
        }
    }

    private Closure taskLoadStepUpdateMultimedia = { DSLContext create, List<LoadStatus> statuses ->
        create.batchUpdate(statuses*.mediaLoadStatus*.multimediaRecord).execute()
    }

    private Closure taskLoadStepGenerateFields = { DSLContext create, List<LoadStatus> statuses ->
        statuses.each { status ->
            status.fieldRecords = createInitialFieldRecordsFromDescriptor(status.taskDescriptorRecord, status.taskRecord)
        }

        def fieldsRecords = insertFields(create, statuses*.fieldRecords)

        def fieldsByTaskId = fieldsRecords.groupBy { it.taskId }

        statuses.each { status ->
            status.fieldRecords = fieldsByTaskId[status.taskRecord.id] ?: []
        }
    }

    private Closure taskLoadStepGenerateExtraMedia = { DSLContext create, Map<Long, Long> taskDescriptorIdToTaskIdMap, List<LoadStatus> statuses ->
        def mediaDescriptors = create.fetch(MEDIA_LOAD_DESCRIPTOR, MEDIA_LOAD_DESCRIPTOR.TASK_DESCRIPTOR_ID.in(statuses*.taskDescriptorRecord*.id))

        def mediaRecords = mediaDescriptors.inject(create.insertInto(MULTIMEDIA, MULTIMEDIA.ID, MULTIMEDIA.TASK_ID, MULTIMEDIA.CREATED)) { insert, md ->
            insert.values(HIBERNATE_SEQUENCE.nextval(), val(taskDescriptorIdToTaskIdMap[md.taskDescriptorId]), currentTimestamp())
        }.returning().fetch()

        def mediaDescriptorToRecordPair = [mediaDescriptors, mediaRecords].transpose()
        def mediaGroups = mediaDescriptorToRecordPair.groupBy { it[0].taskDescriptorId }

        // Second failure point - extra media objects
        statuses.each { status ->
            def mediaGroup = mediaGroups[status.taskDescriptorRecord.id]

            // abort the whole job if any media record throws
            try {
                status.mediaRecords = mediaGroup.collect { mediaPair ->
                    MediaLoadDescriptorRecord desc = mediaPair[0]
                    MultimediaRecord rec = mediaPair[1]

                    try {
                        def filePath = taskService.copyImageToStore(desc.mediaUrl, status.projectId, status.taskId, rec.id)
                        rec.filePath = filePath.localUrlPrefix + filePath.raw
                        rec.mimeType = filePath.contentType ?: desc.mimeType
                        new MediaLoadStatus(multimediaRecord: rec, filePath: filePath, mediaLoadDescriptorRecord: desc)
                    } catch (e) {
                        log.error("Exception while completing media record {} {}", status.taskDescriptorRecord, rec, e)
                        throw e
                    }
                }
            } catch (e) {
                log.error("Copying image to store failed: ${e.message}", e)
                status.success = false
                status.message = e.message
            }
        }
    }

    private Closure taskLoadStepInsertExtraMedia = { DSLContext create, List<LoadStatus> statuses ->
        // Third failure point, Media After Load callback
        create.batchUpdate(statuses*.mediaRecords*.multimediaRecord.collectMany { it })

        statuses.each { status ->

            try {
                status.extraFieldRecords = status.mediaRecords.collectMany { mr ->
                    mediaAfterLoadTable[mr.mediaLoadDescriptorRecord.afterDownload]?.call(status.taskRecord, mr.multimediaRecord, mr.filePath)
                }
            } catch (e) {
                log.error("Error calling after media load hook", e)
                status.success = false
                status.message = e.message
            }
        }
    }

    private Closure taskLoadStepShadowFiles = { DSLContext create, List<LoadStatus> statuses ->
        def shadowDescriptors = create.fetch(SHADOW_FILE_DESCRIPTOR, SHADOW_FILE_DESCRIPTOR.TASK_DESCRIPTOR_ID.in(statuses*.taskDescriptorRecord*.id)).groupBy { it.taskDescriptorId }

        statuses.each { status ->

            def taskShadows = shadowDescriptors[status.taskDescriptorRecord.id]

            if (taskShadows) {

                // shadow field failures didn't cause rollback in previous version
                // TODO may need to update existing fields?
                def shadowFields = taskShadows.collectMany { shadowDesc ->
                    def file = new File(shadowDesc.value)

                    List<FieldRecord> result
                    if (file.exists()) {
                        try {
                            def shadowValue = FileUtils.readFileToString(file, StandardCharsets.UTF_8)
                            def field = new FieldRecord().with {
                                name = WebUtils.stripNonPrintableCharacters(shadowDesc.name ?: '')
                                taskId = status.taskId
                                recordIdx = shadowDesc.recordIdx
                                superceded = false
                                value = WebUtils.stripNonPrintableCharacters(shadowValue?.toString() ?: '')
                                transcribedByUserId = UserService.SYSTEM_USER
                                it
                            }
                            result = [field]
                        } catch (Exception e) {
                            log.error("Failed to extract shadow file data for task {}, shadow: {}", status.taskId, file, e)
                            result = []
                        }
                    } else {
                        result = []
                    }
                    result
                }
                status.extraFieldRecords.addAll(shadowFields)
            }
        }
    }

    private Closure taskLoadStepExtractExifData = { DSLContext create, Map<Long, ProjectRecord> projects, List<LoadStatus> statuses ->

        statuses.each { status ->
            def project = projects[status.projectId]
            if (project == null) {
                log.error("Null project???")
            }
            def extractExif = project.extractImageExifData

            // exif field failures didn't cause rollback in previous version
            // TODO may need to update existing fields?
            if (extractExif) {
                def filePath = status.mediaLoadStatus.filePath.localPath
                try {
                    // Load EXIF data from the image if the Project is configured to do so.
                    Map exif = ImageUtils.getExifMetadata(new File(filePath))

                    def exifFields = exif.collect { exifTag, exifValue ->
                        new FieldRecord().with {
                            taskId = status.taskId
                            name = WebUtils.stripNonPrintableCharacters(exifTag?.toString() ?: '')
                            recordIdx = 0
                            value = WebUtils.stripNonPrintableCharacters(exifValue?.toString() ?: '')
                            superceded = false
                            transcribedByUserId = UserService.SYSTEM_USER
                            it
                        }
                    }

                    status.extraFieldRecords.addAll(exifFields)
                }
                catch (Exception e) {
                    log.error("Failed to extract EXIF data for task {}, image: {}", status.taskId, filePath, e)
                }
            }
        }
    }

    private Closure taskLoadStepInsertExtraFields = { DSLContext create, List<LoadStatus> statuses ->

        def extraFieldsRecords = insertFields(create, statuses*.extraFieldRecords)

        def extraFieldsByTaskId = extraFieldsRecords.groupBy { it.taskId }

        statuses.each { status ->
            status.extraFieldRecords = extraFieldsByTaskId[status.taskRecord.id] ?: []
        }
    }

    private static List<FieldRecord> insertFields(DSLContext create, List<List<FieldRecord>> fieldRecords) {
        def flattenedRecords = fieldRecords.collectMany { it }
        if (flattenedRecords) {
            flattenedRecords.inject(create.insertInto(FIELD, FIELD.ID, FIELD.TASK_ID, FIELD.NAME, FIELD.RECORD_IDX, FIELD.SUPERCEDED, FIELD.TRANSCRIBED_BY_USER_ID, FIELD.VALIDATED_BY_USER_ID, FIELD.VALUE, FIELD.CREATED, FIELD.UPDATED)) { insert, pojo ->
                insert.values(HIBERNATE_SEQUENCE.nextval(), val(pojo.taskId), val(pojo.name), val(pojo.recordIdx), val(pojo.superceded), val(pojo.transcribedByUserId), val(pojo.validatedByUserId), val(pojo.value), currentTimestamp(), currentTimestamp())
            }.returning().fetch()
        } else {
            []
        }
    }

    private <T> T continueAndSkipStatuses(List<LoadStatus> statuses, @ClosureParams(FirstParam) Closure<T> continuation) {
        def results = statuses.groupBy { it.success && !it.skip }[true]
        if (results) continuation(results)
        else null
    }

    private <T> T continueStatuses(List<LoadStatus> statuses, @ClosureParams(FirstParam) Closure<T> continuation) {
        def results = statuses.groupBy { it.success }[true]
        if (results) continuation(results)
        else null
    }

    private <T> T failedStatuses(List<LoadStatus> statuses, @ClosureParams(FirstParam) Closure<T> continuation) {
        def results = statuses.groupBy { it.success }[false]
        if (results) continuation(results)
        else null
    }

    private TaskRecord createInitialTaskRecordFromDescriptor(TaskDescriptorRecord taskDescriptor) {
        return new TaskRecord().with {
            projectId = taskDescriptor.projectId
            externalIdentifier = taskDescriptor.externalIdentifier
            it
        }
    }

    private MultimediaRecord createInitialMultimediaRecordFromDescriptor(TaskDescriptorRecord job, TaskRecord record) {
        return new MultimediaRecord().with {
            taskId = record.id
            filePath = job.imageUrl
            it
        }
    }

    private List<FieldRecord> createInitialFieldRecordsFromDescriptor(TaskDescriptorRecord job, TaskRecord record) {
        def fields = job.fields
        if (fields instanceof List) {
            fields.collectMany { fd ->
                if (fd instanceof Map) {
                    fd['value'] = replaceSpecialCharacters(fd['value'] ?: "")
                    [new FieldRecord().with {
                        taskId = record.id
                        name = fd['name']
                        recordIdx = (fd['recordIdx'] ?: 0) as Integer
                        superceded = fd['superceded'] ?: false
                        transcribedByUserId = fd['transcribedByUserId']
                        validatedByUserId = fd['validatedByUserId']
                        value = fd['value']
                        return it
                    }]
                } else {
                    log.warn("Task Descriptor {} field {} is not an object", job.externalIdentifier, fd)
                    []
                }
            }
        } else {
            log.warn("Task Descriptor {} fields is not an array {}", job.externalIdentifier, job.fields)
            []
        }
    }

    private TaskService.FileMap completeMultimediaRecord(MultimediaRecord multimedia, long projectId) {
        Project project = Project.get(projectId)

        def filePath = taskService.copyImageToStore(multimedia.filePath, projectId, multimedia.taskId, multimedia.id)
        if (!filePath) throw new IOException("Unable to complete copyImageToStore for ${multimedia.filePath}, ${projectId}, ${multimedia.taskId}, ${multimedia.id}")

        if (project.projectType.name == ProjectType.PROJECT_TYPE_AUDIO) {
            multimedia.filePathToThumbnail = null
        } else {
            filePath = taskService.createImageThumbs(filePath) // creates thumbnail versions of images
            multimedia.filePathToThumbnail = filePath.localUrlPrefix  + filePath.thumb  // Ditto for the thumbnail
        }
        multimedia.filePath = filePath.localUrlPrefix + filePath.raw   // This contains the url to the image without the server component
        multimedia.mimeType = filePath.contentType
        return filePath
    }


}
