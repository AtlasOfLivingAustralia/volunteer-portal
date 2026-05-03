package au.org.ala.volunteer

import au.org.ala.volunteer.jooq.tables.records.FieldRecord
import au.org.ala.volunteer.jooq.tables.records.MediaLoadDescriptorRecord
import au.org.ala.volunteer.jooq.tables.records.MultimediaRecord
import au.org.ala.volunteer.jooq.tables.records.ProjectRecord
import au.org.ala.volunteer.jooq.tables.records.ShadowFileDescriptorRecord
import au.org.ala.volunteer.jooq.tables.records.TaskDescriptorRecord
import au.org.ala.volunteer.jooq.tables.records.TaskRecord
import com.google.common.base.Stopwatch
import grails.events.EventPublisher
import groovy.json.JsonSlurper
import groovy.transform.stc.ClosureParams
import groovy.transform.stc.FirstParam
import groovy.util.logging.Slf4j
import org.apache.commons.io.FileUtils
import org.jooq.Configuration
import org.jooq.DSLContext
import org.jooq.JSONB
import org.jooq.SortOrder
import org.jooq.TransactionalCallable
import org.jooq.TransactionalRunnable
import org.jooq.impl.DSL
import org.jooq.tools.json.JSONArray
import org.springframework.beans.factory.annotation.Value
import org.springframework.context.i18n.LocaleContextHolder

import java.nio.charset.StandardCharsets
import java.sql.Timestamp
import java.time.LocalDateTime
import java.util.regex.Pattern

import static au.org.ala.volunteer.jooq.Sequences.HIBERNATE_SEQUENCE
import static au.org.ala.volunteer.jooq.Tables.PROJECT
import static au.org.ala.volunteer.jooq.Tables.INSTITUTION
import static au.org.ala.volunteer.jooq.Tables.SHADOW_FILE_DESCRIPTOR
import static au.org.ala.volunteer.jooq.tables.Field.FIELD
import static au.org.ala.volunteer.jooq.tables.MediaLoadDescriptor.MEDIA_LOAD_DESCRIPTOR
import static au.org.ala.volunteer.jooq.tables.Multimedia.MULTIMEDIA
import static au.org.ala.volunteer.jooq.tables.Task.TASK
import static au.org.ala.volunteer.jooq.tables.TaskDescriptor.TASK_DESCRIPTOR
import static au.org.ala.volunteer.jooq.tables.TaskDescriptorError.TASK_DESCRIPTOR_ERROR
import static org.jooq.impl.DSL.count
import static org.jooq.impl.DSL.currentTimestamp
import static org.jooq.impl.DSL.defaultValue
import static org.jooq.impl.DSL.min
import static org.jooq.impl.DSL.row
import static org.jooq.impl.DSL.select
import static org.jooq.impl.DSL.val
import static org.jooq.impl.DSL.when
import static org.jooq.impl.DSL.or as jOr

// Transactions will be controlled explicitly
@Slf4j
class TaskLoadService implements EventPublisher {

    // explicity control transactions with jooq
    def taskService
    def stagingService
    Closure<DSLContext> jooqContext
    def projectService
    def groovyPageRenderer
    def grailsApplication
    def emailService
    def messageSource
    def s3Service

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

    /**
     * Get a paginated list of tasks waiting to be processed.
     *
     * @param params A map of parameters including:
     *   - offset: The offset for pagination (default: 0)
     *   - limit: The maximum number of records to return (default: 20)
     *   - sortColumn: The column to sort by (default: 'timeCreated')
     *   - sortOrder: The order of sorting, either 'ASC' or 'DESC' (default: 'DESC')
     * @return A list of task records waiting to be processed.
     */
    def getTaskUploadQueue(Map params = [:]) {
        DSLContext create = jooqContext()
        def whereClause = []

        // Institution Filter
        Long institutionFilter = params.institutionFilter ? Long.valueOf(params.institutionFilter as String) : null
        if (institutionFilter) {
            whereClause << PROJECT.INSTITUTION_ID.eq(institutionFilter)
        }

        if (params.q) {
            def queryOr = []
            queryOr << PROJECT.NAME.likeIgnoreCase("%${params.q}%".toString().toLowerCase())
            queryOr << TASK_DESCRIPTOR.EXTERNAL_IDENTIFIER.likeIgnoreCase("%${params.q}%".toString().toLowerCase())
            whereClause << jOr(queryOr)
        }

        int offset = (params.offset ?: 0) as Integer
        int limit = (params.limit ?: 20) as Integer

        String sortColumn = (params.sort ?: 'dateUpdated').toString()
        String sortOrder = (params.order ?: 'DESC').toString().toUpperCase()
        log.debug("Sorting task upload queue by ${sortColumn} ${sortOrder}")

        // Map friendly column names to jOOQ fields
        def columnMap = [
                'projectId'         : PROJECT.ID,
                'project'           : PROJECT.NAME,
                'id'                : TASK_DESCRIPTOR.ID,
                'timeCreated'       : TASK_DESCRIPTOR.TIME_CREATED,
                'dateUpdated'       : TASK_DESCRIPTOR.DATE_UPDATED,
                'retriesRemaining'  : TASK_DESCRIPTOR.RETRIES_REMAINING,
                'externalIdentifier': TASK_DESCRIPTOR.EXTERNAL_IDENTIFIER,
                'imageUrl'          : TASK_DESCRIPTOR.IMAGE_URL,
                'replaceDuplicates' : TASK_DESCRIPTOR.REPLACE_DUPLICATES
        ]

        def sortField = columnMap[sortColumn] ?: TASK_DESCRIPTOR.TIME_CREATED
        def order = (sortOrder == 'ASC') ? SortOrder.ASC : SortOrder.DESC
        log.debug("Sorting task upload queue by field ${sortField} ${order}")

        // Get a list of tasks waiting to be processed
        def taskQueueQuery = create
                .select(
                        PROJECT.ID,
                        PROJECT.NAME,
                        INSTITUTION.NAME,
                        TASK_DESCRIPTOR.ID,
                        TASK_DESCRIPTOR.TIME_CREATED,
                        TASK_DESCRIPTOR.DATE_UPDATED,
                        TASK_DESCRIPTOR.RETRIES_REMAINING,
                        TASK_DESCRIPTOR.EXTERNAL_IDENTIFIER,
                        TASK_DESCRIPTOR.IMAGE_URL,
                        count(TASK_DESCRIPTOR_ERROR.ID).as("error_count")
                )
                .from(TASK_DESCRIPTOR)
                .join(PROJECT).on(PROJECT.ID.eq(TASK_DESCRIPTOR.PROJECT_ID))
                .join(INSTITUTION).on(INSTITUTION.ID.eq(PROJECT.INSTITUTION_ID))
                .leftJoin(TASK_DESCRIPTOR_ERROR).on(TASK_DESCRIPTOR_ERROR.TASK_DESCRIPTOR_ID.eq(TASK_DESCRIPTOR.ID))
                .where(whereClause)
                .groupBy(PROJECT.ID,
                        PROJECT.NAME,
                        INSTITUTION.NAME,
                        TASK_DESCRIPTOR.ID,
                        TASK_DESCRIPTOR.TIME_CREATED,
                        TASK_DESCRIPTOR.DATE_UPDATED,
                        TASK_DESCRIPTOR.RETRIES_REMAINING,
                        TASK_DESCRIPTOR.EXTERNAL_IDENTIFIER,
                        TASK_DESCRIPTOR.IMAGE_URL)
                .orderBy(sortField.sort(order))
//                .limit(limit)
//                .offset(offset)

        def results = [:]
        results.taskCount = create.fetchCount(taskQueueQuery)
        def taskQueryWithPagination = taskQueueQuery.limit(limit).offset(offset)

        results.taskList = taskQueryWithPagination.fetch().collect {row ->
            [
                projectId         : row.get(PROJECT.ID),
                project           : row.get(PROJECT.NAME),
                institution       : row.get(INSTITUTION.NAME),
                id                : row.get(TASK_DESCRIPTOR.ID),
                timeCreated       : row.get(TASK_DESCRIPTOR.TIME_CREATED),
                dateUpdated       : row.get(TASK_DESCRIPTOR.DATE_UPDATED),
                retriesRemaining  : row.get(TASK_DESCRIPTOR.RETRIES_REMAINING),
                externalIdentifier: row.get(TASK_DESCRIPTOR.EXTERNAL_IDENTIFIER),
                imageUrl          : row.get(TASK_DESCRIPTOR.IMAGE_URL),
                errorCount        : row.get("error_count")
            ]
        }

        return results
    }

    /**
     * Deletes task descriptors with the given IDs from the database.
     *
     * @param taskDescriptorIds A list of task descriptor IDs to be deleted.
     * @return The number of task descriptors deleted.
     */
    def deleteTaskDescriptors(List<Long> taskDescriptorIds) {
        log.debug("Deleting task descriptors with IDs: ${taskDescriptorIds}")
        DSLContext create = jooqContext()

        // Check for and delete associated records in TASK_DESCRIPTOR_ERROR
        def errorRecordsCount = create
                .deleteFrom(TASK_DESCRIPTOR_ERROR)
                .where(TASK_DESCRIPTOR_ERROR.TASK_DESCRIPTOR_ID.in(taskDescriptorIds))
                .execute()
        log.debug("Deleted ${errorRecordsCount} associated error records.")

        def deletedCount = create
                .deleteFrom(TASK_DESCRIPTOR)
                .where(TASK_DESCRIPTOR.ID.in(taskDescriptorIds))
                .execute()

        return deletedCount
    }

    def getTaskDescriptorErrors(Long taskDescriptorId) {
        log.debug("Fetching errors for task descriptor ID: ${taskDescriptorId}")
        DSLContext create = jooqContext()

        def errors = create
                .select(TASK_DESCRIPTOR_ERROR.ERROR_MESSAGE, TASK_DESCRIPTOR_ERROR.STACK_TRACE, TASK_DESCRIPTOR_ERROR.DATE_CREATED)
                .from(TASK_DESCRIPTOR_ERROR)
                .where(TASK_DESCRIPTOR_ERROR.TASK_DESCRIPTOR_ID.eq(taskDescriptorId))
                .orderBy(TASK_DESCRIPTOR_ERROR.DATE_CREATED.desc())
                .fetch()
                .collect { row ->
                    [
                        message    : row.get(TASK_DESCRIPTOR_ERROR.ERROR_MESSAGE),
                        stacktrace: row.get(TASK_DESCRIPTOR_ERROR.STACK_TRACE),
                        dateCreated: row.get(TASK_DESCRIPTOR_ERROR.DATE_CREATED)
                    ]
                }

        return errors
    }

    /**
     * Resets the retries remaining for a specific task descriptor to 3.
     *
     * @param taskDescriptorId The ID of the task descriptor to reset.
     * @return The number of task descriptors updated (should be 1 if successful).
     */
    def resetTaskDescriptorRetries(Long taskDescriptorId) {
        log.debug("Resetting retries for task descriptor ID: ${taskDescriptorId}")
        DSLContext create = jooqContext()

        def updatedCount = create
                .update(TASK_DESCRIPTOR)
                .set(TASK_DESCRIPTOR.RETRIES_REMAINING, 3)
                .set(TASK_DESCRIPTOR.DATE_UPDATED, val(LocalDateTime.now()))
                .where(TASK_DESCRIPTOR.ID.eq(taskDescriptorId))
                .execute()

        return updatedCount
    }

    // deprecated
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
                    fields = JSONB.jsonb("[]")
                    replaceDuplicates = true
                    externalIdentifier = imgData.valueMap["externalIdentifier"] ?: imgData.valueMap["externalIdentifier_0"]
                    it
                }
                def fieldList = []
                imgData.valueMap.each { kvp ->
                    def fieldName = kvp.key
                    def recordIndex = 0

                    def matcher = nameIndexRegex.matcher(fieldName as CharSequence)
                    if (matcher.matches()) {
                        fieldName = matcher.group(1)
                        recordIndex = Integer.parseInt(matcher.group(2))
                    }

                    if (fieldName != 'externalIdentifier') {
                        def fieldMap = [name: fieldName, recordIdx: recordIndex, transcribedByUserId: 'system', value: kvp.value]
                        fieldList.add(fieldMap)
                    }
                }

                // Convert fieldList to JSON
                if (fieldList.size() > 0) {
                    JSONArray fieldArray = new JSONArray(fieldList)
                    taskDesc.fields = JSONB.jsonb(fieldArray.toString())
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
        return results
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
        List<LoadStatusFailure> failures = []
    }

    static class LoadStatusFailure {
        String message
        String stacktrace
    }

    static class MultimediaLoadStatus {
        MultimediaRecord multimediaRecord
        TaskService.FileMap fileMap
    }

    static class MediaLoadStatus extends MultimediaLoadStatus {
        MediaLoadDescriptorRecord mediaLoadDescriptorRecord
    }

    def doTaskLoad(Long projectId = null) {
        int dequeuedTasks
        while ((dequeuedTasks = doTaskLoadIteration(projectId)) != 0) {
            log.info("Completed loading {} tasks for project {}", dequeuedTasks, projectId)

            // TODO This needs to be removed or updated to query S3
            def projectSizeInBytes = projectService.getProjectSizeInBytes(projectId)
            log.info("Updating project disk usage: ${projectSizeInBytes}")

            DSLContext create = jooqContext()
            def updateProjectSize = create
                    .update(PROJECT)
                    .set(PROJECT.SIZE_IN_BYTES, projectSizeInBytes)
                    .where(PROJECT.ID.eq(projectId))
                    .execute()
            log.info("Updated ${updateProjectSize} projects.")
        }
    }

    private int doTaskLoadIteration(Long projectId = null) {
        def ctx = jooqContext.call()

        final List<LoadStatus> jobsStatuses = []

        def rollback = false
        int dequeuedTasks = 0
        try {
            def sw = Stopwatch.createStarted()
            dequeuedTasks = ctx.transactionResult(taskLoadTransaction.curry(jobsStatuses, projectId) as TransactionalCallable<Integer>)
            log.debug("Task load completed successfully in {}", sw.stop())
        } catch (RuntimeException e) {
            log.error("Task load aborted with rollback", e)
            rollback = true
        }

        if (!rollback) {

            def failedUploadTasks = [:]
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

                        if (!failedUploadTasks.containsKey(status.taskDescriptorRecord.externalIdentifier)) {
                            failedUploadTasks[status.taskDescriptorRecord.externalIdentifier] = status.projectId
                        }
                    } catch (e) {
                        log.error("Caught exception rolling back {}", status, e)
                    }
                }
            }

            if (failedUploadTasks.size() > 0) {
                log.warn("Task load completed with {} failed uploads: {}", failedUploadTasks.size(), failedUploadTasks)
                def errorInfo = []
                failedUploadTasks.each { externalIdentifier, failedTaskProjectId ->
                    errorInfo.add([projectId: failedTaskProjectId, projectName: Project.get(failedTaskProjectId as Long)?.name, externalIdentifier: externalIdentifier])
                }

                notifyForFailures(errorInfo)
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

    /**
     * Persist any failures recorded on a {@code LoadStatus} into the
     * {@code TASK_DESCRIPTOR_ERROR} table.
     *
     * <p>This method checks {@code status.failures} and, when present,
     * inserts one row per failure containing:
     * - a generated id using {@code HIBERNATE_SEQUENCE.nextval()}
     * - the creation timestamp in milliseconds
     * - the id of the related task descriptor
     * - the failure message
     * - the failure stacktrace
     *
     * @param create the jOOQ {@code DSLContext} used to build and execute the insert
     * @param status the {@code LoadStatus} instance whose {@code failures} will be persisted;
     *               each failure is expected to have {@code message} and {@code stacktrace} properties
     */
    private void saveLoadStatusFail(DSLContext create, LoadStatus status) {
        log.debug( "Saving load status failure for task descriptor id {}: {}", status.taskDescriptorRecord?.id, status.failures*.message)
        if (status.failures) {
            status.failures.inject(
                create.insertInto(TASK_DESCRIPTOR_ERROR,
                    TASK_DESCRIPTOR_ERROR.ID,
                    TASK_DESCRIPTOR_ERROR.DATE_CREATED,
                    TASK_DESCRIPTOR_ERROR.TASK_DESCRIPTOR_ID,
                    TASK_DESCRIPTOR_ERROR.ERROR_MESSAGE,
                    TASK_DESCRIPTOR_ERROR.STACK_TRACE)) { insert, row ->
                insert.values(HIBERNATE_SEQUENCE.nextval(), val(new Date()), val(status.taskDescriptorRecord.id), val(row.message), val(row.stacktrace))
            }.execute()
        }
    }

    private Closure<Integer> taskLoadTransaction = { List<LoadStatus> jobsStatuses, Long projectId, Configuration cfg ->
        def sw = Stopwatch.createStarted()
        def create = DSL.using(cfg)
        def jobFilter = TASK_DESCRIPTOR.RETRIES_REMAINING.gt(0)
        if (projectId) jobFilter = jobFilter & TASK_DESCRIPTOR.PROJECT_ID.eq(projectId)

        // Select a batch of jobs to process where retries remain - decrementing retries in the same transaction
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
        log.debug("taskLoadTransaction: Got jobs in {}", sw.stop())

        sw.reset().start()
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
        log.debug("taskLoadTransaction: Removed duplicates in {}", sw.stop())

        sw.reset().start()
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
        log.debug("taskLoadTransaction: Marked duplicates to skip in {}", sw.stop())

        if (jobs.isEmpty()) {
            log.debug("No more jobs")
            return dequeuedTasks
        }

        sw.reset().start()
        // Load projects for project settings
        def projectIds = (jobsStatuses*.projectId as Set).findAll { it != null }
        def projects = create.selectFrom(PROJECT).where(PROJECT.ID.in(projectIds)).fetch().<Long, ProjectRecord, ProjectRecord> collectEntries { [(it.id): it ]}
        log.debug("taskLoadTransaction: Loaded projects in {}", sw.stop())

        sw.reset().start()
        // Generate initial task objects
        continueAndSkipStatuses(jobsStatuses, taskLoadStepGenerateTasks.curry(create))
        log.debug("taskLoadTransaction: Load Step Generate Tasks in {}", sw.stop())

        Map<Long, Long> taskDescriptorIdToTaskIdMap = continueAndSkipStatuses(jobsStatuses) { statuses ->
            statuses.<Long, Long, LoadStatus> collectEntries { [(it.taskDescriptorRecord.id): it.taskRecord.id] }
        }

        sw.reset().start()
        continueAndSkipStatuses(jobsStatuses, taskLoadStepImportImage.curry(create))
        log.debug("taskLoadTransaction: Load Step Import Image in {}", sw.stop())

//        sw.reset().start()
//        continueAndSkipStatuses(jobsStatuses, taskLoadStepUpdateMultimedia.curry(create))
//        log.debug("taskLoadTransaction: Load Step Update Multimedia in {}", sw.stop())

        sw.reset().start()
        continueAndSkipStatuses(jobsStatuses, taskLoadStepGenerateFields.curry(create))
        log.debug("taskLoadTransaction: Load Step Generate Fields in {}", sw.stop())

        // This is deprecated
        //sw.reset().start()
        //continueAndSkipStatuses(jobsStatuses, taskLoadStepGenerateExtraMedia.curry(create, taskDescriptorIdToTaskIdMap))
        //log.debug("taskLoadTransaction: Load Step Generate Extra Media in {}", sw.stop())

        // Deprecated
        //sw.reset().start()
        //continueAndSkipStatuses(jobsStatuses, taskLoadStepInsertExtraMedia.curry(create))
        //log.debug("taskLoadTransaction: Load Step Insert Extra Media in {}", sw.stop())

        sw.reset().start()
        continueAndSkipStatuses(jobsStatuses, taskLoadStepShadowFiles.curry(create))
        log.debug("taskLoadTransaction: Load Step Shadow Files in {}", sw.stop())

        sw.reset().start()
        continueAndSkipStatuses(jobsStatuses, taskLoadStepExtractExifData.curry(create, projects))
        log.debug("taskLoadTransaction: Load Step Extract Exif Data in {}", sw.stop())

        sw.reset().start()
        continueAndSkipStatuses(jobsStatuses, taskLoadStepInsertExtraFields.curry(create))
        log.debug("taskLoadTransaction: Load Step Insert Extra Fields in {}", sw.stop())

        sw.reset().start()
        continueAndSkipStatuses(jobsStatuses, taskLoadStepUploadToS3.curry(create))
        log.debug("taskLoadTransaction: Load Step Upload to S3 if Enabled in {}", sw.stop())

        sw.reset().start()
        continueAndSkipStatuses(jobsStatuses, taskLoadStepUpdateMultimedia.curry(create))
        log.debug("taskLoadTransaction: Load Step Update Multimedia in {}", sw.stop())

        // DONE

        // Any failed tasks we roll back any created database records here
        // Media byte objects rollback to be performed outside db transaction context
        sw.reset().start()
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

                saveLoadStatusFail(create, status)
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
        log.debug("taskLoadTransaction: Failed Task loads manual roll back in {}", sw.stop())

        // All successful jobs, delete the task descriptor from the queue
        // and notify project owner.
        sw.reset().start()
        continueStatuses(jobsStatuses) { statuses ->
            def taskDescriptorIds = statuses*.taskDescriptorRecord*.id

            // Check for and delete any associated records in TASK_DESCRIPTOR_ERROR table
            def existingErrors = create.selectFrom(TASK_DESCRIPTOR_ERROR)
                    .where(TASK_DESCRIPTOR_ERROR.TASK_DESCRIPTOR_ID.in(taskDescriptorIds))
                    .fetch()
            if (existingErrors) {
                def errorDeletes = create
                        .deleteFrom(TASK_DESCRIPTOR_ERROR)
                        .where(TASK_DESCRIPTOR_ERROR.TASK_DESCRIPTOR_ID.in(taskDescriptorIds))
                        .execute()
                log.debug("Deleted {} existing task descriptor error records", errorDeletes)
            }

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

        log.debug("taskLoadTransaction: Finalise load queue entries in {}", sw.stop())
        return dequeuedTasks
    }

    /**
     * Notify of failed uploads, with a link to the project and external identifier for each failed task.
     *
     * @param errorInfo a list of maps containing projectId, projectName and externalIdentifier for each failed task
     */
    private void notifyForFailures(List<Map<String, Object>> errorInfo) {
        log.debug("Notifying of failed uploads: {}", errorInfo)
        String template = '/task/failedUploadNotification'
        def message = groovyPageRenderer.render(view: template, model: [errors: errorInfo])
        def appName = messageSource.getMessage("default.application.name", null, "DigiVol", LocaleContextHolder.locale)
        emailService.pushMessageOnQueue(grailsApplication.config.getProperty('grails.contact.emailAddress', String) as String,
                "${appName} Failed Task Uploads",
                message,
                30)
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
                // Copies image to store long with a thumbnail and updates the multimedia record with the file path and
                // mime type. This is done in a loop after the batch insert of multimedia records so that if any single
                // image fails to copy, the whole transaction can be rolled back, avoiding orphan multimedia records with no file.
                status.mediaLoadStatus.fileMap = completeMultimediaRecord(status.mediaLoadStatus.multimediaRecord, status.projectId)
            } catch (e) {
                log.error("Exception while completing multimedia record {}", status.taskDescriptorRecord, e)
                status.success = false
                status.message = e.message
                def failureMessage = "Import Image: ${e.message}"
                if (!status.failures.any { it.message == failureMessage }) {
                    status.failures.add(new LoadStatusFailure(
                            message: failureMessage,
                            stacktrace: ExceptionUtils.getStackTraceAsString(e)))
                }
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

    // Deprecated
    /*
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
                def failureMessage = "Generate Extra Media: ${e.message}"
                if (!status.failures.any { it.message == failureMessage }) {
                    status.failures.add(new LoadStatusFailure(
                            message: failureMessage,
                            stacktrace: ExceptionUtils.getStackTraceAsString(e)))
                }
            }
        }
    }*/

    // Deprecated
    /*
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
                status.failures.add(new LoadStatusFailure(
                        message: e.message,
                        stacktrace: ExceptionUtils.getStackTraceAsString(e)))
            }
        }
    }*/

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
                def filePath = status.mediaLoadStatus.fileMap.localPath
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

    private Closure taskLoadStepUploadToS3 = { DSLContext create, List<LoadStatus> statuses ->
        statuses.each {status ->
            def s3Enabled = grailsApplication.config.getProperty('aws.s3.enabled', Boolean, false)
            log.debug("S3 upload step for task {}, S3 enabled: {}", status.taskId, s3Enabled)

            // Only upload if S3 is enabled and we have a local file path for an image type multimedia record. If the
            // multimedia record doesn't have a local file path, it likely means the file copy to store failed in the
            // previous step, which should have caused the transaction to roll back, so we shouldn't have any records
            // in this state unless there is some unexpected edge case.
            if (s3Enabled && 'image' == status.mediaLoadStatus?.fileMap?.type && status.mediaLoadStatus?.fileMap?.localPath) {
                try {
                    def diskFile = new File(status.mediaLoadStatus.fileMap.localPath)
                    def diskDir = diskFile.parentFile

                    if (!diskFile.exists()) {
                        throw new IOException("Disk file not found for upload to S3: ${diskFile.absolutePath}")
                    }

                    // Prepare S3 upload parameters
                    def fileKeyStr = "${status.projectId}/${status.taskId}/${status.mediaLoadStatus.multimediaRecord.id}"
                    def s3FileKey = "${fileKeyStr}/${status.mediaLoadStatus.fileMap.raw}"
                    def contentType = status.mediaLoadStatus.fileMap.contentType ?: "image/jpeg"

                    log.debug("Uploading multimedia file to S3: key=${s3FileKey}, contentType=${contentType}, localPath=${diskFile.absolutePath}")

                    // Upload the file to S3
                    s3Service.upload(s3FileKey, new FileInputStream(diskFile), contentType)

                    // Upload thumbnails if they exist
                    TaskService.THUMB_SIZES.each { size ->
                        def thumbnailFilename = status.mediaLoadStatus.fileMap[size.key] as String
                        if (thumbnailFilename) {
                            def thumbnailFile = new File(diskDir, thumbnailFilename)
                            if (thumbnailFile.exists()) {
                                def thumbnailS3Key = "${fileKeyStr}/${thumbnailFilename}"
                                log.debug("Uploading thumbnail to S3: key=${thumbnailS3Key}, diskPath=${thumbnailFile.absolutePath}")
                                s3Service.upload(thumbnailS3Key, new FileInputStream(thumbnailFile), contentType)
                            } else {
                                log.warn("Thumbnail file not found for S3 upload: ${thumbnailFile.absolutePath}")
                            }
                        }
                    }

                    // Update the URL path to point to S3
                    status.mediaLoadStatus.fileMap.localUrlPrefix = S3Service.S3_PREFIX + "${fileKeyStr}/"

                    // Update multimedia records with new S3 file path and content type
                    status.mediaLoadStatus.multimediaRecord.filePathToThumbnail = status.mediaLoadStatus.fileMap.localUrlPrefix + status.mediaLoadStatus.fileMap.thumb
                    status.mediaLoadStatus.multimediaRecord.filePath = status.mediaLoadStatus.fileMap.localUrlPrefix + status.mediaLoadStatus.fileMap.raw

                    // Delete the local disk files after successful upload to S3
                    def filesDeleted = 0
                    if (diskFile.delete()) {
                        filesDeleted++
                        log.debug("Deleted original image from disk: ${diskFile.absolutePath}")
                    }

                    TaskService.THUMB_SIZES.each { size ->
                        def thumbnailFilename = status.mediaLoadStatus.fileMap[size.key] as String
                        if (thumbnailFilename) {
                            def thumbnailFile = new File(diskDir, thumbnailFilename)
                            if (thumbnailFile.exists() && thumbnailFile.delete()) {
                                filesDeleted++
                                log.debug("Deleted thumbnail from disk: ${thumbnailFile.absolutePath}")
                            }
                        }
                    }

                    // Delete multimedia directory if empty
                    def projectDir = new File("${grailsApplication.config.getProperty('images.home', String)}/${status.projectId}/")
                    def taskDir = new File(projectDir, "${status.taskId}/")
                    if (taskDir.exists() && taskDir.isDirectory() && taskDir.list().length == 0) {
                        if (taskDir.delete()) {
                            log.debug("Deleted empty task directory from disk: ${taskDir.absolutePath}")
                        } else {
                            log.warn("Failed to delete empty task directory from disk: ${taskDir.absolutePath}")
                        }
                    }

                    log.debug("Successfully uploaded ${filesDeleted} file(s) to S3 and cleaned up disk")

                } catch (Exception e) {
                    log.error("Exception while uploading multimedia to S3 for task {}, MM: {}", status.taskId, status.mediaLoadStatus.multimediaRecord.id, e)
                    status.success = false
                    status.message = e.message
                    def failureMessage = "Upload to S3: ${e.message}"
                    if (!status.failures.any { it.message == failureMessage }) {
                        status.failures.add(new LoadStatusFailure(
                                message: failureMessage,
                                stacktrace: ExceptionUtils.getStackTraceAsString(e)))
                    }
                }
            }
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
        def json = fields.data()
        def slurper = new JsonSlurper()
        def fieldData = slurper.parseText(json)
        if (fieldData instanceof List) {
            fieldData.collectMany { fd ->
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

    /**
     * Complete the multimedia record by copying the file to the store, creating thumbnails if required and updating the multimedia record with the file path and mime type.
     *
     * @param multimedia the multimedia record to complete
     * @param projectId the project id for the multimedia record, used for determining where to copy the file and whether to create thumbnails
     * @return a FileMap containing details of the copied file, including content type for updating the multimedia record and local path for cleanup if required
     */
    private TaskService.FileMap completeMultimediaRecord(MultimediaRecord multimedia, long projectId) {
        Project project = Project.get(projectId)

        def fileMap = taskService.copyImageToStore(multimedia.filePath, projectId, multimedia.taskId, multimedia.id)
        if (!fileMap) throw new IOException("Unable to complete copyImageToStore for ${multimedia.filePath}, Project: ${projectId}, Task: ${multimedia.taskId}, MM: ${multimedia.id}")

        if (project.projectType.name == ProjectType.PROJECT_TYPE_AUDIO) {
            fileMap.type = "audio"
            multimedia.filePathToThumbnail = null
        } else {
            fileMap = taskService.createImageThumbs(fileMap) // creates thumbnail versions of images
            multimedia.filePathToThumbnail = fileMap.localUrlPrefix  + fileMap.thumb  // Ditto for the thumbnail
        }
        multimedia.filePath = fileMap.localUrlPrefix + fileMap.raw   // This contains the url to the image without the server component
        multimedia.mimeType = fileMap.contentType
        return fileMap
    }


}
