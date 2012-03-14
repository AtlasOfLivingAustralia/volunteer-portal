package au.org.ala.volunteer

import org.codehaus.groovy.grails.commons.ConfigurationHolder
import javax.imageio.ImageIO
import java.awt.image.BufferedImage
import com.thebuzzmedia.imgscalr.Scalr
import org.codehaus.groovy.grails.web.servlet.mvc.GrailsParameterMap

class TaskService {

    javax.sql.DataSource dataSource
    def config = ConfigurationHolder.config
    def fieldService

    def LAST_VIEW_TIMEOUT_MINUTES = ConfigurationHolder.config.viewedTask.timeout

    static transactional = true

    def serviceMethod() {}

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
        def currentTime = System.currentTimeMillis() - LAST_VIEW_TIMEOUT_MINUTES
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
        def currentTime = System.currentTimeMillis() - LAST_VIEW_TIMEOUT_MINUTES
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
                println("CSV has 5 token: " + tokens.join('|'))
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
                def filePath = copyImageToStore(imageUrl, task.id, multimedia.id)
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
      Task.executeQuery("""select distinct t from Task t
        inner join t.fields fields
        where fields.transcribedByUserId = :userId""", [userId: userId], params)
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

    /**
     * GET the image via its URL and save various forms to local disk
     *
     * @param imageUrl
     * @return fileMap
     */
    def copyImageToStore = { String imageUrl, taskId, multimediaId ->
        def url = new URL(imageUrl)
        def filename = url.path.replaceAll(/\/.*\//, "") // get the filename portion of url
        def conn = url.openConnection()
        def fileMap = [:]
        try {
            println("content type = " + conn.contentType + " | " + filename)
            def dir = new File(config.images.urlPrefix + taskId + "/" + multimediaId)
            if (!dir.exists()) {
                println("Creating dir " + dir.absolutePath)
                dir.mkdirs()
            }
            fileMap.dir = dir.absolutePath
            def file = new File(dir, filename)
            file << conn.inputStream
            fileMap.raw = file.name
            return fileMap
            //file.close()
        } catch (Exception e) {
            println("Failed to load URL: " + imageUrl + ". " + e)
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
            if (srcImage.width > it.value || srcImage.height > it.value) {
                fileMap[it.key] = fileMap.raw.replaceFirst(/\.(.{3,4})$/,'_' + it.key +'.$1') // add _small to filename
                BufferedImage scaledImage = Scalr.resize(srcImage, it.value)
                ImageIO.write(scaledImage, "jpg", new File(fileMap.dir + "/" + fileMap[it.key]))
            }
        }

        return fileMap
    }
}
