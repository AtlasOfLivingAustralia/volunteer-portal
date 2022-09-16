package au.org.ala.volunteer

import au.org.ala.volunteer.collectory.CollectoryProviderDto
import au.org.ala.web.UserDetails
import com.google.common.base.Stopwatch
import com.google.common.base.Suppliers
import com.google.common.cache.CacheBuilder
import com.google.common.collect.ImmutableMap
import com.google.common.collect.Sets
import com.google.gson.Gson
import grails.converters.JSON
import grails.converters.XML
import groovy.util.logging.Slf4j
import org.springframework.web.multipart.MultipartHttpServletRequest

import java.sql.Timestamp
import java.text.SimpleDateFormat
import groovy.sql.Sql
import javax.sql.DataSource
import java.sql.ResultSet
import grails.plugins.csv.CSVWriter
import grails.plugins.csv.CSVWriterColumnsBuilder

import java.util.concurrent.TimeUnit

import static grails.async.Promises.*
import static javax.servlet.http.HttpServletResponse.SC_BAD_REQUEST
import static javax.servlet.http.HttpServletResponse.SC_CREATED
import static javax.servlet.http.HttpServletResponse.SC_FORBIDDEN
import static javax.servlet.http.HttpServletResponse.SC_INTERNAL_SERVER_ERROR
import static javax.servlet.http.HttpServletResponse.SC_NOT_FOUND
import static javax.servlet.http.HttpServletResponse.SC_NO_CONTENT
import static javax.servlet.http.HttpServletResponse.SC_PRECONDITION_FAILED
import static javax.servlet.http.HttpServletResponse.SC_UNAUTHORIZED

@Slf4j
class AjaxController {

    def taskService
    def userService
    def taskLoadService
    def statsService
    DataSource dataSource
    def multimediaService
    def institutionService
    def domainUpdateService
    def authService
    def settingsService
    def achievementService
    def sessionFactory
    def projectService

    static responseFormats = ['json', 'xml']
    static final String UNAUTH_MSG = "Must be logged in as an administrator to use this service!"

    def index() {
        def results = [ (message(code:"default.application.name")) : 'Version 1.0']
        respond results
    }

    private def statsCache = Suppliers.memoizeWithExpiration(this.&statsInternal, 1, TimeUnit.MINUTES)

    def stats() {
        setNoCache()
        log.debug("stats")
        def stats = statsCache.get()
        respond stats
    }

    private Map<String, ?> statsInternal() {

        log.debug("statsInternal")

        Map<String, ?> stats = [:]

        def projectTypes = ProjectType.list()

        projectTypes.each {
            def projects = Project.findAllByProjectType(it)
            stats[it.description ?: it.name] = (projects.size() > 0) ? Task.countByProjectInList(projects) : 0
        }

        stats.volunteerCount = userService.countActiveUsers()
        // def topVolunteers = userService.getUserCounts([], 10)
        // stats.topTenVolunteers = topVolunteers

        stats.expeditionCount = Project.count()
        // def inactiveCount = taskService.countInactiveProjects()
        def projectCounts = taskService.getProjectTaskTranscribedCounts(true)
        def projectTranscribedCounts = taskService.getProjectTaskFullyTranscribedCounts(true)

        def counts = projectCounts.keySet().countBy {
            (projectCounts[it] ?: 0) == (projectTranscribedCounts[it] ?: 0)
        }
        int completedCount = counts[true]
        int incompleteCount = counts[false]

        stats.activeExpeditionsCount = incompleteCount
        stats.completedExpeditionsCount = completedCount
        // stats.deactivatedExpeditionsCount = inactiveCount

        return stats
    }

    def userReport() {
        setNoCache()

        if (!userService.isAdmin()) {
            render ("${UNAUTH_MSG}")
            return
        }

        // Pre-create the writer and write the headings straight away to prevent a read timeout.
        def writer
        if (params.wt && params.wt == 'csv') {
            def nodata = params.nodata ?: 'nodata'

            response.addHeader("Content-type", "text/plain")

            writer = new CSVHeadingsWriter((Writer) response.writer, {
                'user_id' { it[0] }
                'email' { it[1] }
                'display_name' { it[2] }
                'organisation' { it[3] }
                'location' { it[4] }
                'transcribed_count' { it[5] }
                'validated_count' { it[6] }
                'last_activity' { it[7] ?: nodata }
                'projects_count' { it[8] }
                'volunteer_since' { it[9] }
                'is_admin' { it[10] }
                'is_institution_admin' { it[11] }
                'is_ala_validator' { it[12] }
                'is_validator' { it[13] }
                'is_forum_mod' { it[14] }
            })
            writer.writeHeadings()
            response.flushBuffer()
        }

        def asyncCounts = Task.async.withStatelessSession {
            def sw1 = Stopwatch.createStarted()
            def vs = (Task.withCriteria {
                projections {
                    groupProperty('fullyValidatedBy')
                    count('id')
                }
            }).collectEntries { [(it[0]): it[1]] }
            def ts = (Transcription.withCriteria {
                projections {
                    groupProperty('fullyTranscribedBy')
                    count('id')
                }
            }).collectEntries { [(it[0]): it[1]] }
            sw1.stop()
            log.debug("UserReport counts took ${sw1.toString()}")
            [vs: vs, ts: ts]
        }

        def asyncLastActivities = ViewedTask.async.withStatelessSession {
            def sw2 = Stopwatch.createStarted()
            def lastActivities = ViewedTask.executeQuery("select vt.userId, to_timestamp(max(vt.lastView)/1000) from ViewedTask vt group by vt.userId").collectEntries { [(it[0]): it[1]] }
            sw2.stop()
            log.debug("UserReport viewedTasks took ${sw2.toString()}")
            lastActivities
        }

        def asyncProjectCounts = Transcription.async.withStatelessSession {
            def sw4 = Stopwatch.createStarted()
            def projectCounts = Transcription.executeQuery("select t.fullyTranscribedBy, count(distinct t.project) from Transcription t where t.fullyTranscribedBy is not null group by t.fullyTranscribedBy").collectEntries { [(it[0]): it[1]] }
            sw4.stop()
            log.debug("UserReport projectCounts took ${sw4.toString()}")
            projectCounts
        }

        def sw3 = Stopwatch.createStarted()
        def asyncUserDetails = User.async.task {
            def users = User.list(fetch:[userRoles:"eager", "userRoles.role": "eager"])
            def serviceResults = [:]
            try {
                serviceResults = authService.getUserDetailsById(users*.userId, true)
            } catch (Exception e) {
                log.warn("couldn't get user details from web service", e)
            }
            sw3.stop()
            log.debug("UserReport user details took ${sw3.toString()}")

            [users: users, results: serviceResults]
        }

        def asyncResults = waitAll(asyncCounts, asyncLastActivities, asyncProjectCounts, asyncUserDetails)

        // transform raw results into map(id -> count)
        def validateds = asyncResults[0].vs
        def transcribeds = asyncResults[0].ts

        def lastActivities = asyncResults[1]
        def projectCounts = asyncResults[2]

        def users = asyncResults[3].users
        def serviceResults = asyncResults[3].results

        def report = []

        final realAdminRole = 'ROLE_ADMIN'
        final adminRole = CASRoles.ROLE_ADMIN
        final validatorRole = CASRoles.ROLE_VALIDATOR

        def sw5 = Stopwatch.createStarted()
        for (User user: users) {
            def id = user.userId
            def transcribedCount = transcribeds[id] ?: 0
            def validatedCount = validateds[id] ?: 0
            def lastActivity = lastActivities[id]
            def projectCount = projectCounts[id]?: 0

            def serviceResult = serviceResults?.users?.get(id)
            def location = (serviceResult?.city && serviceResult?.state) ? "${serviceResult?.city}, ${serviceResult?.state}" : (serviceResult?.city ?: (serviceResult?.state ?: ''))

            def userRoles = user.userRoles
            def roleObjs = userRoles*.role
            def roles = (roleObjs*.name + serviceResult?.roles).toSet()
            def isAdmin = !roles.intersect([realAdminRole, adminRole]).isEmpty()
            def isAlaValidator = !roles.intersect([validatorRole]).isEmpty()
            def isValidator = !roles.intersect([BVPRole.VALIDATOR]).isEmpty()
            def isForumModerator = !roles.intersect([BVPRole.FORUM_MODERATOR]).isEmpty()
            def isInstitutionAdmin = !roles.intersect([BVPRole.INSTITUTION_ADMIN]).isEmpty()

            report.add([serviceResult?.userId ?: id,
                        serviceResult?.userName ?: user.email,
                        serviceResult?.displayName ?: user.displayName,
                        serviceResult?.organisation ?: user.organisation ?: '',
                        location,
                        transcribedCount,
                        validatedCount,
                        lastActivity,
                        projectCount,
                        user.created,
                        isAdmin,
                        isInstitutionAdmin,
                        isAlaValidator,
                        isValidator,
                        isForumModerator])
        }
        sw5.stop()
        log.debug("UserReport generate report took ${sw5}")

        sw5.reset().start()
        // Sort by the transcribed count
        report.sort({ row1, row2 -> row2[5] - row1[5]})
        sw5.stop()
        log.debug("UserReport sort took ${sw5.toString()}")

        if (params.wt && params.wt == 'csv') {
            for (def row : report) {
                writer << row
            }
            response.flushBuffer()
        } else {
            respond report
        }
    }

    def loadProgress(long id) {
        if (!projectService.isAdminForProject(Project.get(id))) {
            render ("${UNAUTH_MSG}")
            return
        }
        setNoCache()
        respond taskLoadService.status(id)
    }

    def expeditionInfo() {
        setNoCache()
        def sql = new Sql(dataSource:dataSource)

        def projects = Project.list()
        def results = []
        for (Project p : projects) {
            def project = [:]
            project.name = p.name
            project.description = p.description
            project.expeditionPageURL = createLink(controller: 'project', action: 'index', id: p.id, absolute: true)
            project.taskCount = Task.countByProject(p)
            project.transcribedCount = Task.countByProjectAndIsFullyTranscribed(p, true)
            project.validatedCount = Task.countByProjectAndFullyValidatedByIsNotNull(p)

            sql.query("select count(distinct(fully_transcribed_by)) from task where project_id = ${p.id} and length(fully_transcribed_by) > 0") { ResultSet rs ->
                if (rs.next()) {
                    project.volunteerCount = rs.getInt(1)
                }
            }

            project.dataURL = createLink(controller: 'ajax', action: 'expeditionBiocacheData', id: p.id, absolute: true)

            results.add(project)
        }

        sql.close()
        render results as JSON
    }

    def expeditionBiocacheData() {
        setNoCache()
        response.addHeader("Content-type", "text/plain")

        if (params.id) {
            def projectInstance = Project.get(params.id)
            if (projectInstance) {

                def findValue = { List<Field> fieldValues, String name ->
                    fieldValues.find { it.name == name } ?.value?:""
                }

                def columns = {
                    'catalogNumber' { findValue(it.fieldValues, 'catalogNumber') }
                    'institutionCode' { findValue(it.fieldValues, 'institutionCode') }
                    'scientificName' { findValue(it.fieldValues, 'scientificName') }
                    'decimalLatitude' { findValue(it.fieldValues, 'decimalLatitude') }
                    'decimalLongitude' { findValue(it.fieldValues, 'decimalLongitude') }
                    'locality' { findValue(it.fieldValues, 'locality')}
                    'transcribers' { it.task.transcriptions*.fullyTranscribedBy.join(',') }
                    'eventDate' { findValue(it.fieldValues, 'eventDate') }
                    'associatedMedia' { multimediaService.getImageUrl((Multimedia) it.task?.multimedia?.first()) }
                    'occurrenceId' { createLink(controller: 'task', action: 'show', id: it?.task?.id, absolute: true ) }
                }

                def fieldNames = new CSVWriterColumnsBuilder(columns).columns.collect { it.key }
                def writer = new CSVWriter(response.writer, columns)
                def fields = Field.findAll("from Field as f where f.task in (from Task as task where task.project = :project) and f.transcription is null and f.superceded = false and f.name in (:fields)",[project: projectInstance, fields: fieldNames]).groupBy { it.task }

                for (Task t : fields.keySet()) {
                    writer << [task: t, fieldValues: fields[t]]
                }

                response.writer.flush()
            }
        } else {
            render([success: false, message:"Unable to retrieve project with id '${params.id}'"] as JSON)
        }
    }

    def keepSessionAlive() {
        def results = ['success':'true', 'currentTime': formatDate(date: new Date(), format: DateConstants.DATE_TIME_FORMAT), systemMessage: flash.systemMessage ]
        respond results
    }

    private def setNoCache() {
        response.setHeader("Pragma", "no-cache");
        response.setHeader("Cache-Control", "no-cache");
        response.addHeader("Cache-Control", "no-store");
    }

    def statsTranscriptionsByMonth() {
        def results = statsService.transcriptionsByMonth()
        respond results
    }

    def statsValidationsByMonth() {
        def results = statsService.validationsByMonth()
        respond results
    }

    def taskInfo() {
        def task = Task.get(params.int("id") ?: params.int("taskId"))
        if (task) {
            def taskInfo = [:]
            taskInfo.projectId = task.project.id
            taskInfo.externalIdentifier = task.externalIdentifier
            taskInfo.externalUrl = task.externalUrl
            taskInfo.fullyTranscribedBy = task.transcriptions*.fullyTranscribedBy.join(', ')
            taskInfo.fullyValidatedBy = task.fullyValidatedBy
            taskInfo.isValid = task.isValid
            taskInfo.created = task.created?.format("yyyy-MM-dd HH:mm:ss")
            taskInfo.fields = []
            task.fields.each { field ->
                def fieldInfo = [fieldId: field.id ]
                fieldInfo.name = field.name
                fieldInfo.value = field.value
                fieldInfo.recordIdx = field.recordIdx
                fieldInfo.transcribedByUserId = field.transcribedByUserId
                fieldInfo.validatedByUserId = field.validatedByUserId
                fieldInfo.superceded = field.superceded
                fieldInfo.created = field.created?.format("yyyy-MM-dd HH:mm:ss")
                fieldInfo.updated = field.updated?.format("yyyy-MM-dd HH:mm:ss")
                taskInfo.fields << fieldInfo
            }
            taskInfo.multimedia = []
            task.multimedia.each { mm ->
                def mmInfo = [multimediaId: mm.id]
                mmInfo.licence = mm.licence
                mmInfo.mimeType = mm.mimeType
                mmInfo.created = mm.created?.format("yyyy-MM-dd HH:mm:ss")
                mmInfo.creator = mm.creator
                mmInfo.url = multimediaService.getImageUrl(mm)
                taskInfo.multimedia << mmInfo
            }
            respond taskInfo
        } else {
            respond null // 404
        }
    }

    def harvest() {
        harvesting()
    }

    def i18nService

    def harvesting() {
        def results = projectService.harvestProjects()

        respond results
    }

    def collectoryObjectDetails(String id) {
        final gson = new Gson()
        CollectoryProviderDto provider = institutionService.getCollectoryObjectFromUid(id)
        withFormat {
            json { render(text: gson.toJson(provider), contentType: 'application/json', encoding: 'UTF-8') }
            xml { render provider as XML }
        }
    }

    def availableCollectoryProviders() {

        def collectoryObjects = institutionService.getCombinedInsitutionsAndCollections()

        def instById = collectoryObjects.collectEntries { ImmutableMap.of(it.uid, it) }
        def ids = instById.keySet()
        def existing = Institution.executeQuery("select collectoryUid from Institution where collectoryUid in :ids", [ids: ids])
        def missing = Sets.difference(ids, existing.toSet())

        def results = missing.collect {
            def inst = instById[it]
            [id: it, name: inst.name]
        }
        respond results
    }

    def getUpdateQueueLength() {
        def length = domainUpdateService.getQueueLength()
        def results = ['success': true, 'queueLength': length]
        respond results
    }

    def acceptAchievements() {
        def cu = userService.currentUser
        if (cu) {
            def ids = params.list('ids[]') ?: []
            def longIds = ids*.toLong()
            if (!longIds) {
                render status: 204
                return
            }

            //def validAwards = AchievementAward.findAllByIdInListAndUser(longIds, cu)
            achievementService.markAchievementsViewed(cu, longIds)
            render status: 204
        } else {
            render status: 403
        }
    }

    def transcriptionFeed(String timestampStart, String timestampEnd, Integer rowStart, String sort) {
        final sw = Stopwatch.createStarted()
        final udsw = Stopwatch.createUnstarted()
        final Date startTs
        final Date endTs
        final pageSize = 100
        sort = sort ?: 'dateFullyTranscribed'
        final sortOrder = params.order ?: 'desc'
        rowStart = rowStart ?: 0

        log.debug("Transcription Feed Start")

        if (timestampStart) {
            startTs = toTimestamp(timestampStart)
        } else {
            startTs = new Timestamp(0) // Jan 1, 1970 UTC
        }
        if (timestampEnd) {
            endTs = toTimestamp(timestampEnd)
        } else {
            endTs = new Timestamp(System.currentTimeMillis())
        }

        final count = Transcription.countByDateFullyTranscribedBetween(startTs, endTs)
        final transcribers = [] as Set
        final taskIds = [] as Set
        final ids = [] as Set

        def items = Transcription.withCriteria {
            between('dateFullyTranscribed', startTs, endTs)
            join('task')
            join('task.project')
            maxResults(pageSize)
            firstResult(rowStart)
            order(sort, sortOrder)
        }.collect { Transcription transcription ->
            def id = transcription.id
            def taskId = transcription.task.id
            def projectId = transcription.task.project.id
            def projectName = transcription.task.project.name
            def transcriber = transcription.fullyTranscribedBy
            def timestamp = transcription.dateFullyTranscribed
            def ipAddress = transcription.fullyTranscribedIpAddress
            def uuid = transcription.transcribedUUID.toString()

            transcribers << transcriber
            taskIds << taskId
            ids << id
            [
                id: id,
                taskId: taskId,
                projectId: projectId,
                project: projectName,
                guid: uuid,
                timestamp: timestamp,
                subject: [
                    link: createLink(absolute: true, controller: 'task', action: 'show', id: taskId),
                ],
                contributor: [
                    id: transcriber,
//                    decimalLatitude: "Lat. of collecting event",
//                    decimalLongitude: "Long. of collecting event",
                    ipAddress: ipAddress
                ],
                transcriptionContent: [:],
                discretionaryState: "Transcribed"
            ]
        }

        log.debug("Transcription feed got tasks ${sw}")

        final allFields
        final usersDetails
        final mm
        if (ids) {
            allFields = Field.where {
                transcription.id in ids && superceded == false
            }.collect { field ->
                [id: field.transcriptionId, recordIdx: field.recordIdx, name: field.name, value: field.value]
            }.groupBy { it.id }
            udsw.start()
            usersDetails = authService.getUserDetailsById(transcribers.toList(), true) ?: [users:[:]]
            udsw.stop()
            mm = Multimedia.where { task.id in taskIds }.collect { [id: it.taskId, thumbUrl: multimediaService.getImageThumbnailUrl(it), url: multimediaService.getImageUrl(it) ] }.groupBy { it.id }
        } else {
            allFields = [:]
            usersDetails = [users:[]]
            mm = [:]
        }

        final defaultCountry = 'AU' // TODO externalise

        items.each {
            def id = it.id
            def transcriber = it.contributor.id
            def itemMM = mm[it.taskId] ? mm[it.taskId][0] : null
            def thumbnailUrl = itemMM?.thumbUrl ?: itemMM?.url
            def userDetails = usersDetails.users[transcriber]
            def displayName = userDetails?.displayName ?: User.findByUserId(transcriber)?.displayName ?: ''
            def userCountry = userDetails?.country
            def userState = userDetails?.state
            def userCity = userDetails?.city
            def fields = allFields[id]
            def taxon = getNamedFieldValues(fields, 'scientificName') ?: getNamedFieldValues(fields, 'vernacularName')
            def locality = getNamedFieldValues(fields, 'locality')
            def municipality = getNamedFieldValues(fields, 'municipality')
            def county = getNamedFieldValues(fields, 'county')
            def stateProvince = getNamedFieldValues(fields, 'stateProvince')
            def country = getNamedFieldValues(fields, 'country')
            def longitude = getNamedFieldValues(fields, 'decimalLongitude') ?: getNamedFieldValues(fields, 'verbatimLongitude')
            def latitude = getNamedFieldValues(fields, 'decimalLatitude') ?: getNamedFieldValues(fields, 'verbatimLatitude')
            def date = getNamedFieldValues(fields, 'eventDate') ?: getNamedFieldValues(fields, 'dateIdentified') ?: getNamedFieldValues(fields, 'verbatimEventDate') ?: getNamedFieldValues(fields, 'measurementDeterminedDate')
            def recordedBy = getNamedFieldValues(fields, 'recordedBy')

            final lowerProjectName = it.project.toLowerCase().trim()
            final descriptionSuffix = lowerProjectName.endsWith('expedition') || lowerProjectName.endsWith('project') ? '' : ' expedition'
            if (taxon && recordedBy) it.description = "$displayName transcribed a $taxon recorded by $recordedBy from the ${it.project}$descriptionSuffix"
            else if (taxon) it.description = "$displayName transcribed a $taxon from the ${it.project}$descriptionSuffix"
            else if (recordedBy) it.description = "$displayName transcribed a record recorded by $recordedBy from the ${it.project}$descriptionSuffix"
            else it.description = "$displayName transcribed a record from the ${it.project}$descriptionSuffix"

            if (thumbnailUrl) it.subject.thumbnailUrl = thumbnailUrl
            if (displayName) it.contributor.transcriber = displayName
            if (userCity || userState || userCountry) it.contributor.physicalLocation = [
                    country: userCountry ?: defaultCountry,
                    state: userState,
                    municipality: userCity
            ]
            if (taxon) it.transcriptionContent.taxon = taxon
            if (locality) it.transcriptionContent.locality = locality
            if (municipality) it.transcriptionContent.municipality = municipality
            if (county) it.transcriptionContent.county = county
            if (stateProvince) it.transcriptionContent.province = stateProvince
            if (country) it.transcriptionContent.country = country
            if (longitude) it.transcriptionContent.long = longitude
            if (latitude) it.transcriptionContent.lat = latitude
            if (date) it.transcriptionContent.date = date
            if (recordedBy) it.transcriptionContent.collector = recordedBy
        }

        sw.stop()

        log.debug("Took $sw to get ${items.size()} results since $startTs.  ${sw.elapsed(TimeUnit.MILLISECONDS) / (items.size() ?: 1)}ms / result.")
        log.debug("Userdetails took $udsw for ${items.size()}.  ${udsw.elapsed(TimeUnit.MILLISECONDS) / (items.size() ?: 1)}ms / result.")

        final results = [
            numFound: count,
            start: rowStart,
            rows: items.size(),
            items: items
        ]

        respond results
    }

    private static def getNamedFieldValues(List fields, String name) {
        fields?.findAll { it.name == name && it.value }?.sort { it.recordIdx }?.collect { it.value }?.join(', ')
    }

    private static Timestamp toTimestamp(String timestamp) {
        final Timestamp result
        if (timestamp.isNumber()) {
            final dateLong = timestamp as Long
            // determine if this is unix time or java time
            final factor = dateLong > 1000000000000 ? 0 : 1000
            result = new Timestamp(dateLong * factor)
        } else {
            final format = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssXXX")
            result = format.parse(timestamp).toTimestamp()
        }
        return result
    }

    def resumableUploadImage(ResumableUploadCommand cmd) {
        def allowedMimeTypes = ['image/jpeg', 'image/gif', 'image/png', 'text/plain']
        resumableUploadFile(cmd, allowedMimeTypes)
    }

    def resumableUploadAudio(ResumableUploadCommand cmd) {
        def allowedMimeTypes = ['audio/aac', 'audio/wav', 'audio/mpeg', 'audio/x-m4a', 'audio/ogg', 'audio/vnd.dlna.adts']
        resumableUploadFile(cmd, allowedMimeTypes)
    }

    def resumableUploadFile(ResumableUploadCommand cmd, def allowedMimeTypes) {
        if (cmd.hasErrors()) {
            log.error("Resumable params are not valid {}", cmd)
            return render(status: SC_BAD_REQUEST, text: "Params aren't valid")
        }

        if (!allowedMimeTypes.contains(cmd.type)) {
            log.error("Resumable file content-type is not valid {}", cmd)
            return render(status: SC_BAD_REQUEST, text: "The file must be one of: ${allowedMimeTypes}")
        }

        if (!Project.exists(cmd.projectId)) {
            return render(status: SC_NOT_FOUND, text: "Expedition doesn't exist")
        }

        if (!projectService.isAdminForProject(Project.get(cmd.projectId))) {
            return render(status: request.userPrincipal ? SC_FORBIDDEN : SC_UNAUTHORIZED, text: 'Access denied')
        }

        log.debug("Uploading {}:{} identifier {} size {} checksum {}", cmd.filename, cmd.resumableChunkNumber, cmd.identifier, cmd.resumableCurrentChunkSize, cmd.checksum)

        if (request.method == 'POST') {
            try {
                def resumableStream = getResumableStream()
                if (resumableStream != null) {
                    def chunkCheck = cmd.uploadAndCheckChunk(resumableStream)
                    if (chunkCheck) {
                        render status: SC_CREATED, text: ''
                    } else {
                        render status: SC_PRECONDITION_FAILED, text: 'Chunk checksum does not match'
                    }
                } else {
                    render status: SC_BAD_REQUEST, text: 'No file part found'
                }
            } catch (e) {
                log.error("Couldn't save uploaded chunk {}", cmd, e)
                render status: SC_INTERNAL_SERVER_ERROR, text: "Couldn't save uploaded chunk ${cmd.filename}:${cmd.resumableChunkNumber}"
            }
        } else if (request.method == 'GET') {
            if (cmd.isChunkComplete()) {
                render(status: SC_NO_CONTENT, text: '')
            } else {
                render(status: SC_NOT_FOUND, text: '')
            }
        }
    }

    private getResumableStream() {
        if (request instanceof MultipartHttpServletRequest) {
            // theoretically there's only one chunk being sent in this request, so just find the first file part
            def mfm = request.getMultiFileMap()
            mfm.values().collectMany { it }.find()?.inputStream
        } else {
            request.inputStream
        }
    }
}
