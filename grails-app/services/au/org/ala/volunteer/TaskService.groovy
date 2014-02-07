package au.org.ala.volunteer

import org.apache.commons.lang.StringUtils
import org.imgscalr.Scalr

import javax.imageio.ImageIO
import java.awt.image.BufferedImage
import groovy.sql.Sql

class TaskService {

    javax.sql.DataSource dataSource
    def logService
    def grailsApplication
    def multimediaService
    def grailsLinkGenerator

    static transactional = true

  /**
   * This could be a large result set for a system with many registered users.
   */
    Map getTasksTranscribedByCounts(){
        def userTaskCounts = Task.executeQuery(
            """select t.fullyTranscribedBy as userId, count(t.id) as taskCount from Task t
               where t.fullyTranscribedBy is not null
               group by t.fullyTranscribedBy""")
        userTaskCounts.toMap()
    }

  /**
   * Retrieve a count of tasks partially transcribed by a user.
   *
   * @param user
   * @return
   */
    Integer getPartiallyTranscribedByCountsForUser(String userId){
      def userTaskCounts = Task.executeQuery(
          """select count(distinct t.id) from Task t
             inner join t.fields fields
             where fields.transcribedByUserId = :userId""", [userId: userId])
      userTaskCounts.get(0)
    }

    /**
     *
     * @return Map of project id -> count
     */
    Map getProjectTaskCounts() {
        def projectTaskCounts = Task.executeQuery(
            """select t.project.id as projectId, count(t) as taskCount from Task t
               group by t.project.id""")
        projectTaskCounts.toMap()
    }

    /**
     *
     * @return Map of project id -> count
     */
    Map getProjectTaskTranscribedCounts() {
        def projectTaskCounts = Task.executeQuery(
            """select t.project.id as projectId, count(distinct t.id) as taskCount
               from Task t inner join t.fields as fields group by t.project.id""")
        projectTaskCounts.toMap()
    }

    /**
     *
     * @return Map of project id -> count
     */
    Map getProjectTaskFullyTranscribedCounts() {
        def projectTaskCounts = Task.executeQuery(
            """select t.project.id as projectId, count(t) as taskCount
               from Task t where t.fullyTranscribedBy is not null group by t.project.id""")
        projectTaskCounts.toMap()
    }

    Map getProjectVolunteerCounts() {
        def volunteerCounts = Task.executeQuery(
            """select t.project.id as projectId, count(distinct t.fullyTranscribedBy) as volunteerCount
               from Task t where t.fullyTranscribedBy is not null group by t.project.id"""
        )
        volunteerCounts.toMap()
    }

    /**
     *
     * @return Map of project id -> count
     */
    Map getProjectTaskValidatedCounts() {
        def projectTaskCounts = Task.executeQuery(
            """select t.project.id as projectId, count(t) as taskCount
               from Task t where t.fullyValidatedBy is not null group by t.project.id""")
        projectTaskCounts.toMap()
    }

    /**
     *
     * @param project
     * @return List of user id
     */
    List getUserIdsForProject(Project project) {
        def userIds = Task.executeQuery(
            """select distinct t.fullyTranscribedBy
               from Task t where t.fullyTranscribedBy is not null and
               t.project = :project order by t.fullyTranscribedBy""", [project: project])
        userIds.toList()
    }

    /**
     *
     * @param project
     * @return List of user id
     */
    List getUserIdsAndCountsForProject(Project project, Map params) {
        def userIds = Task.executeQuery(
            """select t.fullyTranscribedBy, count(t)
               from Task t where t.fullyTranscribedBy is not null and
               t.project = :project group by t.fullyTranscribedBy order by count(t) desc""", [project: project], params)
        userIds.toList()
    }

    /**
     *
     * @param project
     * @return List of user id
     */
    def getCountsForProjectAndUserId(Project project, String userId) {
        def userIds = Task.executeQuery(
            """select count(t)
               from Task t where t.fullyTranscribedBy = :userId and
               t.project = :project""", [userId: userId, project: project])
        userIds
    }

    /**
     *
     * @param project
     * @return List of user id
     */
    def getCountsForUserId(String userId) {
        def userIds = Task.executeQuery(
            """select count(t)
               from Task t where t.fullyTranscribedBy = :userId""", [userId: userId])
        userIds
    }

    /**
     * Get the next task for this user
     *
     * @param userId
     * @return
     */
    Task getNextTask(String userId) {

        def tasks = Task.executeQuery(
            """select t from Task t
               left outer join t.viewedTasks viewedTasks
               where t.fullyTranscribedBy is null
               and (viewedTasks.userId != :userId or viewedTasks.userId is null)
               order by viewedTasks.lastView""", [userId: userId, max: 1])
        if (tasks) {
            tasks.get(0)
        } else {
            //show
            tasks = Task.executeQuery(
            """select t from Task t
               left outer join t.viewedTasks viewedTasks
               where t.fullyTranscribedBy is null
               order by viewedTasks.lastView""", [max: 1])
            if(!tasks.isEmpty()){
              tasks.get(0)
            } else {
              null
            }
        }
    }

    /**
     * Get the next task for this user
     *
     * @param userId
     * @return
     */
    Task getNextTask(String userId, Project project) {

        if (!project || !userId) {
            return null;
        }

        def currentTime = System.currentTimeMillis() - grailsApplication.config.viewedTask.timeout
        def tasks = Task.executeQuery(
            """select t from Task t
               left outer join t.viewedTasks viewedTasks
               where
               t.project.id = :projectId
               and t.fullyTranscribedBy is null
               and (viewedTasks.userId is null or (viewedTasks.userId != :userId and viewedTasks.lastView < :currentTime))
               order by viewedTasks.lastView desc""", [projectId: project.id, userId: userId, currentTime: currentTime, max: 1])
        if (tasks) {
            log.info("getNextTask: project " + project.id + " - found task with " + tasks.get(0).viewedTasks.size() + " viewTasks.")
            tasks.get(0)
        } else {
            //show
            tasks = Task.executeQuery(
            """select t from Task t
               left outer join t.viewedTasks viewedTasks
               where
               t.project.id = :projectId
               and t.fullyTranscribedBy is null
               order by viewedTasks.lastView desc""", [projectId: project.id, max: 1])
            if(!tasks.isEmpty()){
                log.info("getNextTask: found task with " + tasks.get(0).viewedTasks.size() + " viewTasks.")
              tasks.get(0)
            } else {
              null
            }
        }
    }


    /**
     * Get the next task for this user
     *
     * @param userId
     * @return
     */
    Task getNextTaskForValidation() {

        def tasks = Task.executeQuery(
            """select t from Task t
               where t.fullyTranscribedBy is not null
               and t.fullyValidatedBy is null""", [max: 1])
        if (tasks) {
            tasks.get(0)
        } else {
            null
        }
    }

    /**
     * Get the next task for this user
     *
     * @param userId
     * @return
     */
    Task getNextTaskForValidationForProject(Project project, String taskId) {
        def previousTaskId = (taskId) ? taskId.toLong() : -1L
        log.debug("taskId = " + taskId + " || previousTaskId = " + previousTaskId)
        def tasks = Task.executeQuery(
            """select t from Task t
               where t.fullyTranscribedBy is not null
               and t.fullyValidatedBy is null and t.project = :project
               and t.id != :previousTaskId
               """, [project:project, previousTaskId: previousTaskId, max: 1])
        if (tasks) {
            tasks.get(0)
        } else {
            null
        }
    }

    /**
     * Get the next task for this user (with checking for concurrent access)
     *
     * @param userId
     * @param project
     * @return
     */
    Task getNextTaskForValidationForProject(String userId, Project project) {
        log.debug "getNextTaskForValidationForProject checking access..."
        def currentTime = System.currentTimeMillis() - grailsApplication.config.viewedTask.timeout
        def tasks = Task.executeQuery(
                """select t from Task t
               left outer join t.viewedTasks viewedTasks
               where
               t.project.id = :projectId
               and t.fullyTranscribedBy is not null
               and t.fullyValidatedBy is null
               and (viewedTasks.userId is null or (viewedTasks.userId != :userId and viewedTasks.lastView < :currentTime))
               order by viewedTasks.lastView desc""", [projectId: project.id, userId: userId, currentTime: currentTime, max: 1])
        if (tasks) {
            log.info("getNextTask: project " + project.id + " - found task with " + tasks.get(0).viewedTasks.size() + " viewTasks.")
            tasks.get(0)
        } else {
            //show
            tasks = Task.executeQuery(
                    """select t from Task t
               left outer join t.viewedTasks viewedTasks
               where
               t.project.id = :projectId
               and t.fullyTranscribedBy is not null
               and t.fullyValidatedBy is null
               order by viewedTasks.lastView desc""", [projectId: project.id, max: 1])
            if(!tasks.isEmpty()){
                log.info("getNextTask: found task with " + tasks.get(0).viewedTasks.size() + " viewTasks.")
                tasks.get(0)
            } else {
                null
            }
        }
    }

    /**
     * Get the next task for this user for this project.
     *
     * @param userId
     * @return
     */
    Task getNextTaskForProject(Project project, String userId) {

        def tasks = Task.executeQuery(
            """select t from Task t
               left outer join t.viewedTasks viewedTasks
               where t.project = :project and (viewedTasks.userId=:userId or viewedTasks.userId is null)
               order by viewedTasks.lastView""", [project:project, userId: userId, max: 1])
        if (tasks) {
            tasks.get(0)
        } else {
            null
        }
    }

    /**
     * Loads a CSV of external identifiers and external URLs
     * into the tables, loading the task and multimedia tables.
     *
     * @param projectId
     * @param text
     * @return
     */
    def loadCSV(Integer projectId, String text) {
        def flashMsg = ""
        log.debug("ProjectID: " + projectId)
        def project = Project.get(projectId)
        text.eachCsvLine { tokens ->
            //only one line in this case
            def task = new Task()
            task.project = project

            String imageUrl = ""
            List<Field> fields = new ArrayList<Field>()

            if(tokens.length == 1){
              task.externalIdentifier = tokens[0]
              imageUrl = tokens[0].trim()
            } else if(tokens.length == 2) {
              task.externalIdentifier = tokens[0]
              imageUrl = tokens[1].trim()
            } else if (tokens.length == 5) {
                def externalIdentifier = tokens[0].trim()
                task.externalIdentifier = externalIdentifier
                imageUrl = tokens[1].trim()
                // check for duplicate catalog number (overwrite duplicates)
                def dupes = Task.findAllByExternalIdentifier(externalIdentifier)
                for (Task t : dupes) {
                    def msg = "Duplicate found (will be deleted): " + t.id + " - " + t.externalIdentifier
                    flashMsg += msg + "<br/>"
                    log.warn msg
                    t.delete(flush: true)
                }
                // create associated fields
                fields.add(new Field(name: 'institutionCode', recordIdx: 0, transcribedByUserId: 'system', value: tokens[2].trim()).save(flush: true))
                fields.add(new Field(name: 'catalogNumber', recordIdx: 0, transcribedByUserId: 'system', value: tokens[3].trim()).save(flush: true))
                fields.add(new Field(name: 'scientificName', recordIdx: 0, transcribedByUserId: 'system', value: tokens[4].trim()).save(flush: true))
            } else {
                // error
                def msg = "CSV file has incorrect number of fields"
                flashMsg += msg + "<br/>"
                log.error msg
                task = null // force save to error
            }

            if (task && !task.hasErrors()) {

                task.save(flush: true)

                // add the fields now that task has an ID
                fields.each { field ->
                    field.task = task
                    field.save(flush: true)
                }
                task.fields = fields
                task.save(flush: true)

                def multimedia = new Multimedia()
                multimedia.task = task
                multimedia.filePath = imageUrl
                multimedia.save(flush: true)
                // GET the image via its URL and save various forms to local disk
                def filePath = copyImageToStore(imageUrl, task.projectId, task.id, multimedia.id)
                filePath = createImageThumbs(filePath) // creates thumbnail versions of images
                multimedia.filePath = filePath.dir + "/" +filePath.raw
                multimedia.filePathToThumbnail = filePath.dir + "/" +filePath.thumb
                multimedia.save(flush: true)
                log.info "Saved..." + tokens + " -> " + filePath['raw']
            } else {
                def msg = "Saving Task errors: " + task.errors
                flashMsg += msg + "<br/>"
                log.error msg
            }
        }

        return flashMsg
    }

  /**
   * Get tasks transcribed by this user. Includes partial edits and complete edits.
   *
   * @param userId
   * @return list of tasks
   */
    List<Task> getRecentlyTranscribedTasks(String userId, Map params) {
        def c = Task.createCriteria()

        c.list(params) {
            eq("fullyTranscribedBy", userId)
            isNotNull("dateFullyTranscribed")
        }
    }

  /**
   * Get tasks saved by this user. Includes partial edits.
   *
   * @param userId
   * @return list of tasks
   */
    List<Task> getRecentlySavedTasks(String userId, Map params) {
      Task.executeQuery("""select distinct t from Task t
        inner join t.fields fields
        where t.fullyTranscribedBy is null and
        fields.transcribedByUserId = :userId
        and fields.superceded = false""", [userId: userId], params)
    }

    /**
   * Get tasks saved by this user. Includes partial edits.
   *
   * @param userId
   * @return list of tasks
   */
    List<Task> getRecentlySavedTasksByProject(String userId, Project project, Map params) {
      Task.executeQuery("""select distinct t from Task t
        inner join t.fields fields
        where t.fullyTranscribedBy is null and
        t.project = :project and
        fields.transcribedByUserId = :userId
        and fields.superceded = false""", [userId: userId, project:project], params)
    }

    List<Task> getTranscribedTasksByUserAndProjectQuery(String userId, Project project, Map params) {

        String query = "%" + (params.q?:"") + "%";
        query= query.toLowerCase()

        def tasks = Task.executeQuery("""select t from Task t
                                         where t.fullyTranscribedBy = :userId and t.project = :project and
                                         (lower(t.project.name) like :query or lower(t.externalIdentifier) like :query)""",
                                        [userId: userId, project: project, query: query], params)
        return tasks.toList()
    }

    List<Task> getTranscribedTasksByUserQuery(String userId, Map params) {

        String query = "%" + (params.q?:"") + "%";
        query= query.toLowerCase()

        def tasks = Task.executeQuery("""select t from Task t
                                         where t.fullyTranscribedBy = :userId and
                                         (lower(t.project.name) like :query or lower(t.externalIdentifier) like :query)""",
                                        [userId: userId, query: query], params)
        return tasks.toList()
    }


    /**
     * GET the image via its URL and save various forms to local disk
     *
     * @param imageUrl
     * @return fileMap
     */
    def copyImageToStore = { String imageUrl, projectId, taskId, multimediaId ->
        def url = new URL(imageUrl)
        def filename = url.path.replaceAll(/\/.*\//, "") // get the filename portion of url
        if (!filename.trim()) {
            filename = "image_" + taskId;
        }
        def conn = url.openConnection()
        def fileMap = [:]

        String urlPrefix = grailsApplication.config.images.urlPrefix
        if (!urlPrefix.endsWith('/')) {
            urlPrefix += '/'
        }

        try {
            def dir = new File(grailsApplication.config.images.home + '/' + projectId + '/' + taskId + "/" + multimediaId)
            if (!dir.exists()) {
                logService.log "Creating dir ${dir.absolutePath}"
                dir.mkdirs()
            }
            fileMap.dir = dir.absolutePath
            def file = new File(dir, filename)
            file << conn.inputStream
            fileMap.raw = file.name
            fileMap.localPath = file.getAbsolutePath()
            fileMap.localUrlPrefix = urlPrefix + "${projectId}/${taskId}/${multimediaId}/"
            fileMap.contentType = conn.contentType
            return fileMap
            //file.close()
        } catch (Exception e) {
            logService.log "Failed to load URL: ${imageUrl} : ${e}"
        }
    }

    /**
     * Create cropped/scaled versions of the raw image
     *
     * @param fieMap
     * @return fileMap
     */
    def createImageThumbs = { Map fileMap ->
        BufferedImage srcImage = ImageIO.read(new FileInputStream(fileMap.dir + "/" +fileMap.raw))
        // Scale the image using the imgscalr library
        def sizes = ['thumb': 300, 'small': 600, 'medium': 1280, 'large': 2000]
        sizes.each{
            fileMap[it.key] = fileMap.raw.replaceFirst(/\.(.{3,4})$/,'_' + it.key +'.$1') // add _small to filename
            BufferedImage scaledImage = srcImage;
            if (srcImage.width > it.value /* || srcImage.height > it.value */) {
                scaledImage = Scalr.resize(srcImage, it.value)
            }
            ImageIO.write(scaledImage, "jpg", new File(fileMap.dir + "/" + fileMap[it.key]))
        }

        return fileMap
    }

    int countTranscribedByProjectType(String projectType) {
        Task.executeQuery("""
            select count(*) from Task t
            WHERE t.fullyTranscribedBy IS NOT NULL and t.project.id in (
              select id from Project p  where p.template.id  in (select id from Template where name = '${projectType}')
            )
        """)[0]
    }

    List<Map> transcribedDatesByUser(String userid) {
        String select = """
            SELECT t.id as id, t.is_valid as isValid, field2.lastEdit as lastEdit, p.name as project
            FROM Project p, Task t
            LEFT OUTER JOIN (SELECT task_id, max(updated) as lastEdit from field f where f.transcribed_by_user_id = '${userid}' group by f.task_id) as field2 on field2.task_id = t.id
            WHERE t.fully_transcribed_by = '${userid}' and p.id = t.project_id
            ORDER BY lastEdit ASC
        """

        def results = []

        def sql = new Sql(dataSource: dataSource)
        sql.eachRow(select) { row ->
            def taskRow = [id: row.id, lastEdit: row.lastEdit, isValid: row.isValid, project: row.project ]
            results.add(taskRow)
        }

        return results;
    }


    List<Map> transcribedDatesByUserAndProject(String userid, long projectId, String labelTextFilter) {
        String select = """
            SELECT t.id as id, t.is_valid as isValid, field2.lastEdit as lastEdit, p.name as project
            FROM Project p, Task t
            LEFT OUTER JOIN (SELECT task_id, max(updated) as lastEdit from field f where f.transcribed_by_user_id = '${userid}' group by f.task_id) as field2 on field2.task_id = t.id
            WHERE t.fully_transcribed_by = '${userid}' and p.id = t.project_id and p.id = ${projectId}
            ORDER BY lastEdit ASC
        """

        if (labelTextFilter) {
            select = """
                SELECT t.id as id, t.is_valid as isValid, field2.lastEdit as lastEdit, p.name as project
                FROM Project p, Task t
                INNER JOIN (select f.task_id, f.value from Field f where f.name = 'occurrenceRemarks' and f.superceded = false and f.value ilike '%${labelTextFilter}%') as field on field.task_id = t.id
                INNER JOIN (SELECT task_id, max(updated) as lastEdit from field f where f.transcribed_by_user_id = '${userid}' group by f.task_id) as field2 on field2.task_id = t.id
                WHERE t.fully_transcribed_by = '${userid}' and p.id = t.project_id and p.id = ${projectId}
            """
        }

        def results = []

        def sql = new Sql(dataSource: dataSource)
        sql.eachRow(select) { row ->
            def taskRow = [id: row.id, lastEdit: row.lastEdit, isValid: row.isValid, project: row.project ]
            results.add(taskRow)
        }

        return results;
    }



    public Task findByProjectAndFieldValue(Project project, String fieldName, String fieldValue) {
        String select ="""
            SELECT t.id as id
            FROM Project p, Task t
            LEFT OUTER JOIN (SELECT task_id, min(value) as value from field f where f.name = 'sequenceNumber' group by f.task_id) as fields on fields.task_id = t.id
            WHERE p.id = $project.id and p.id = t.project_id and fields.value = '$fieldValue'
        """

        def sql = new Sql(dataSource: dataSource)
        int taskId = -1;
        def row = sql.firstRow(select)
        if (row) {
            taskId = row[0]
        }
        return Task.findById(taskId)
    }


    public Map getImageMetaData(Task taskInstance) {
        def imageMetaData = [:]

        taskInstance.multimedia.each { multimedia ->
            imageMetaData[multimedia.id] = getImageMetaData(multimedia)
        }

        return imageMetaData
    }

    public ImageMetaData getImageMetaData(Multimedia multimedia, int rotate = 0) {
        def path = multimedia?.filePath
        if (path) {
            def imageUrl = multimediaService.getImageUrl(multimedia)

            if ([90,180,270].contains(rotate)) {
                imageUrl = grailsLinkGenerator.link(controller: 'multimedia', action:'imageDownload', id: multimedia.id, params:[rotate: rotate])
            }

            String urlPrefix = grailsApplication.config.images.urlPrefix
            String imagesHome = grailsApplication.config.images.home
            path = URLDecoder.decode(imagesHome + '/' + path.substring(urlPrefix?.length()))  // have to reverse engineer the files location on disk, this info should be part of the Multimedia structure!
            BufferedImage image = null

            try {
                image = ImageIO.read(new File(path))
            } catch (Exception ex) {
                logService.log("Exception trying to read image path: ${path} - ${ex}")
            }

            if (image) {
                def width = image.width
                def height = image.height
                if (rotate == 90 || rotate == 270) {
                    width = image.height
                    height = image.width
                }
                return new ImageMetaData(width: width, height: height, url: imageUrl)
            } else {
                logService.log("Could not read image file: ${path} - could not get image metadata")
            }
        }
        return null
    }

    def calculateTaskDates() {
        def taskList = Task.findAllByFullyTranscribedByIsNotNullAndDateFullyTranscribedIsNull()
        println "Processing ${taskList.size()} tasks..."
        def idList = taskList*.id

        int count = 0
        try {
            idList.each { taskId ->

                Task.withNewTransaction { status ->
                    def task = Task.get(taskId)
                    if (!task) {
                        println "No task ${taskId}"
                        return
                    }

                    // Find the most recent field whose transcribed by matches the tasks fully transcribed by...
                    def transcribedCriteria = Field.createCriteria()

                    def dateTranscribed = transcribedCriteria.list {
                        eq("task", task)
                        eq("transcribedByUserId", task.fullyTranscribedBy)

                        projections {
                            max("created")
                        }
                    }

                    if (dateTranscribed && dateTranscribed[0]) {
                        task.dateFullyTranscribed = dateTranscribed[0]
                    } else {
                        println "No transcription date ${task.id}. Using most recent created date"
                        task.dateFullyTranscribed = findMostRecentDate("created", task)
                    }

                    if (StringUtils.isNotEmpty(task.fullyValidatedBy)) {

                        def validatedCriteria = Field.createCriteria()
                        def dateValidated = validatedCriteria.list {
                            eq("task", task)
                            eq("validatedByUserId", task.fullyValidatedBy)
                            projections {
                                max("updated")
                            }
                        }

                        if (dateValidated && dateValidated[0]) {
                            task.dateFullyValidated = dateValidated[0]
                        } else {
                            println "No validation date! ${task.id}. Using most recent updated date."
                            task.dateFullyValidated = findMostRecentDate("updated", task)
                        }
                    }

                    task.save()

                    if (++count % 200 == 0) {
                        println "${count} tasks processed."
                    }

                }
            }

            println "Done."
        } catch (Exception ex) {
            ex.printStackTrace()
        }
    }


    private Date findMostRecentDate(String dateField, Task task) {
        def c = Field.createCriteria()
        def list = c.list {
            eq("task", task)
            projections {
                max(dateField)
            }

        }
        return list?.get(0)
    }

}

public class ImageMetaData {
    int height
    int width
    String url
}
