package au.org.ala.volunteer

import au.org.ala.volunteer.collectory.CollectoryDto
import au.org.ala.volunteer.collectory.CollectoryProviderDto
import groovy.sql.Sql
import org.apache.commons.io.FileUtils
import org.springframework.web.multipart.MultipartFile

class InstitutionService {

    def dataSource
    def grailsApplication
    def collectoryClient
    def grailsLinkGenerator
    def sessionFactory
    def taskService
    def emailService

    static final String NOTIFICATION_DEFAULT = "New Institution Notification"
    static final String NOTIFICATION_APPLICATION = "New Institution Application"
    static final String NOTIFICATION_APPLICATION_APPROVED = "New Institution Approved"

    def emailNotification(String message, String title = NOTIFICATION_DEFAULT, String recipient = null) {
        // Send email to grailsApplication.config.notifications.default.address
        log.debug("Sending institution notification")
        def to = recipient
        if (!recipient) to = grailsApplication.config.notifications.default.address as String
        DetailedEmailMessage email = new DetailedEmailMessage(emailAddress: to, subject: title, message: message)
        emailService.sendMail(email)
    }

    private boolean uploadtoLocalPathFromUrl(String url, String localPath) {
        if (url && localPath) {
            try {
                FileUtils.copyURLToFile(new URL(url), new File(localPath), 30 * 1000, 30 * 1000)
                return true
            } catch (Exception ex) {
                log.error("Failed to transfer image file from url for institution", ex)
            }
        }
        return false
    }

    def uploadImageFromUrl(Institution institution, String url) {
        uploadtoLocalPathFromUrl(url, getImagePath(institution.id))
    }

    def uploadBannerImageFromUrl(Institution institution, String url) {
        uploadtoLocalPathFromUrl(url, getBannerImagePath(institution.id))
    }

    def uploadLogoImageFromUrl(Institution institution, String url) {
        uploadtoLocalPathFromUrl(url, getLogoImagePath(institution.id))
    }

    def clearImage(Institution institution) {
        deleteLocalFile(getImagePath(institution.id))
    }

    def clearLogo(Institution institution) {
        deleteLocalFile(getLogoImagePath(institution.id))
    }

    def clearBanner(Institution institution) {
        deleteLocalFile(getBannerImagePath(institution.id))
    }

    private static deleteLocalFile(String filename) {
        if (filename) {
            def file = new File(filename)
            if (file.exists()) {
                file.delete()
                return true
            }
        }
        return false
    }

    private boolean uploadToLocalPath(MultipartFile mpfile, String localFile) {
        if (!mpfile) {
            return false
        }

        try {
            def file = new File(localFile);
            if (!file.getParentFile().exists()) {
                if (!file.getParentFile().mkdirs()) {
                    throw new RuntimeException("Failed to create institution directories: ${file.getParentFile().getAbsolutePath()}")
                }
            }
            mpfile.transferTo(file);
            return true
        } catch (Exception ex) {
            log.error("Failed to upload image file for institution", ex)
        }
    }

    def uploadImage(Institution institution, MultipartFile mpfile) {
        uploadToLocalPath(mpfile, getImagePath(institution?.id))
    }

    def uploadBannerImage(Institution institution, MultipartFile mpfile) {
        uploadToLocalPath(mpfile, getBannerImagePath(institution.id))
    }

    def uploadLogoImage(Institution institution, MultipartFile mpfile) {
        uploadToLocalPath(mpfile, getLogoImagePath(institution.id))
    }

    boolean hasImage(Institution institution) {
        def f = new File(getImagePath(institution?.id))
        return f.exists()
    }

    boolean hasBannerImage(Institution institution) {
        def f = new File(getBannerImagePath(institution?.id))
        return f.exists()
    }

    boolean hasLogoImage(Institution institution) {
        def f = new File(getLogoImagePath(institution?.id))
        return f.exists()
    }

    String getImageUrl(Institution institution) {
        if (hasImage(institution)) {
            return "${grailsApplication.config.server.url}/${grailsApplication.config.images.urlPrefix}institution/${institution.id}/image.jpg"
        } else {
            return grailsLinkGenerator.resource([file: '/images/banners/default-institution-banner.jpg'])
        }
    }

    String getBannerImageUrl(Institution institution) {
        if (hasBannerImage(institution)) {
            return "${grailsApplication.config.server.url}/${grailsApplication.config.images.urlPrefix}institution/${institution.id}/banner-image.jpg"
        }
    }

    String getLogoImageUrl(Institution institution) {
        if (institution && hasLogoImage(institution)) {
            return "${grailsApplication.config.server.url}/${grailsApplication.config.images.urlPrefix}institution/${institution.id}/logo-image.jpg"
        } else {
            return grailsLinkGenerator.resource([file: '/images/banners/default-institution-logo.png'])
        }
    }

    private String getImagePath(long institutionId) {
        return "${grailsApplication.config.images.home}/institution/${institutionId}/image.jpg"
    }

    private String getBannerImagePath(long institutionId) {
        return "${grailsApplication.config.images.home}/institution/${institutionId}/banner-image.jpg"
    }

    private String getLogoImagePath(long institutionId) {
        return "${grailsApplication.config.images.home}/institution/${institutionId}/logo-image.jpg"
    }


    CollectoryProviderDto getCollectoryObjectFromUid(String uid) {

        CollectoryProviderDto provider = null
        if (uid?.toLowerCase()?.startsWith("in")) {
            provider = collectoryClient.getInstitution(uid).execute().body()
        } else if (uid?.toLowerCase()?.startsWith("co")) {
            provider = collectoryClient.getCollection(uid).execute().body()
        }

        return provider
    }

    List<CollectoryDto> getCombinedInsitutionsAndCollections() {
        def results = collectoryClient.getInstitutions().execute().body()
        def collections = collectoryClient.getCollections().execute().body()
        // Merge the two lists
        results.addAll(collections)
        results.sort { it.name }

        return results
    }

    Institution findByIdOrName(Long id, String name) {
        Institution retVal
        if (id)  {
            retVal = Institution.get(id)
        } else {
            try {
               retVal = Institution.findByName(name)
            } catch (Exception e) {
                log.error("Exception", e)
                throw e
            }
        }
        return retVal
    }

    /**
     * Returns a list of all projects for a given list of institutions.
     * @param institutionList the list of institutions for the user
     * @return the list of projects for the provided institutions
     */
    def listProjectsForInstititutionList(def institutionList) {
        if (!institutionList || institutionList?.size() == 0) {
            return []
        }

        def result = Project.createCriteria().list {
            'in'("institution", institutionList)
            order('id', 'asc')
        }

        result
    }

    /**
     * Returns a simple count of projects within a given institution.
     * @param institution the institution to query.
     * @return the number of projects
     */
    def getProjectCount(Institution institution) {
        if (!institution) return 0
        def result = Project.createCriteria().get {
            'institution' {
                eq('id', institution.id)
            }
            projections {
                count('id')
            }
        }

        return result
    }

    /**
     * Returns a map of project counts, keyed by institution
     *
     * @param institutions
     */
    def getProjectCounts(List<Institution> institutions, boolean includeDeactivated = false) {
        if (!institutions) {
            return [:]
        }

        def c = Project.createCriteria()
        def results = c.list {
            'in'("institution", institutions)
            if (!includeDeactivated) {
                or {
                    isNull("inactive")
                    eq("inactive", false)
                }
            }
            projections {
                groupProperty("institution")
                count("id")
            }
        }

        return results.collectEntries {
            [it[0], it[1]]
        }
    }

    def getProjectUnderwayCount(Institution institution) {
        def c = Project.createCriteria()
        c.get {
            eq('institution', institution)
            or {
                eq('inactive', false)
                isNull('inactive')
            }
            tasks {
                isNull('fullyValidatedBy')
            }
            projections {
                countDistinct('id')
            }
        }
    }

    def getProjectCompletedCount(Institution institution) {
        //select count(p.id) from project p where (select count(t.id) from task t where t.project_id = p.id and t.fully_transcribed_by is not null) = (select count(t.id) from task t where t.project_id = p.id) and p.inactive = false and p.institution_id = 5590558;

        // Get the current Hiberante session.
        final session = sessionFactory.currentSession
        // TODO Do this with Detached Criteria
        // see: https://jira.grails.org/browse/GRAILS-9223
        final String query = '''
            SELECT COUNT(p.id)
            FROM project p
            WHERE
              p.institution_id = :instId
              AND
              EXISTS (SELECT * FROM task t WHERE t.project_id = p.id)
              AND
              NOT EXISTS (SELECT * FROM task t WHERE t.project_id = p.id AND t.fully_validated_by IS NULL)
            '''.stripIndent()

        // Create native SQL query.
        final sqlQuery = session.createSQLQuery(query)

        final results = sqlQuery.with {
            setLong('instId', institution.id)
            uniqueResult()
        }

        return results
    }

    /**
     * Returns a list of active projects for a given institution. Return list includes project ID, name and it's
     * status: open, completed (100% transcribed but < 100% validated) or finished (100% both transcribed and validated).
     * List omits archived and inactive projects.
     * @param institution the institution to query
     * @return a list of maps containing id, name and status.
     */
    def getActiveProjectsForInstitution(Institution institution) {
        if (!institution) return null

        String query = """\
            SELECT p.id,
                p.name,
                COUNT(ta.id) AS total, 
                (COUNT(is_fully_transcribed) filter (where is_fully_transcribed = true)) as fully_transcribed, 
                count(fully_validated_by) as validated,
                case when archived = true then 's5'
                     when inactive = true and archived = false then 's4'
                     when (count(is_fully_transcribed) filter (where is_fully_transcribed = true)) < count(ta.id) then 's1'
                     when ((count(is_fully_transcribed) filter (WHERE is_fully_transcribed = true)) = count(ta.id)
                            AND count(fully_validated_by) < count(ta.id)) then 's2'
                     else 's3' 
                END as status_type
            FROM project p
            JOIN task ta ON ( ta.project_id = p.id )
            WHERE p.institution_id = :institutionId
            GROUP BY p.id, p.name
            order by status_type """.stripIndent()

        def sql = new Sql(dataSource)
        def results = []
        sql.eachRow(query, [institutionId: institution.id]) { row ->
            def projectMap = [id: row.id, name: row.name]
            switch (row.status_type) {
                case 's1':
                    projectMap.status = 'open'
                    break
                case 's2':
                    projectMap.status = 'completed'
                    break
                case 's3':
                    projectMap.status = 'finished'
                    break
                case 's4':
                    projectMap.status = 'inactive'
                    break
                case 's5':
                    projectMap.status = 'archived'
                    break
            }

            results.add(projectMap)
        }

        sql.close()

        results
    }

    /**
     * Returns a list of all users that have been active for a given institution (transcribers AND validators)
     * @param institution the institution to query
     * @return a Map containing id, firstName, and lastName.
     */
    def getActiveUsersForInstitution(Institution institution) {
        if (!institution) return null

        String query = """\
            select distinct u.id, 
                case when o.date_created is not null then true
                else false end as opt_out
            from transcription tr
            join task ta on (ta.id = tr.task_id)
            join project p on (p.id = tr.project_id)
            join vp_user u on (tr.fully_transcribed_by = u.user_id)
            left join message_user_optout o on (o.user_id = u.id)
            where tr.fully_transcribed_by is not null
              and p.institution_id = :institutionId
            union
            select distinct u.id,
                case when o.date_created is not null then true
                else false end as opt_out
            from transcription tr
            join task ta on (ta.id = tr.task_id)
            join project p on (p.id = tr.project_id)
            join vp_user u on (tr.fully_validated_by = u.user_id)
            left join message_user_optout o on (o.user_id = u.id)
            where tr.fully_validated_by is not null
              and p.institution_id = :institutionId """.stripIndent()

        def sql = new Sql(dataSource)
        def results = []

        sql.eachRow(query, [institutionId: institution.id]) { row ->
            User user = User.findById(row.id as long)
            if (user) {
                def attributes = [id: user.id,
                                  firstName: user.firstName.capitalize(),
                                  lastName: user.lastName.capitalize(),
                                  optOut: (row.opt_out)]
                results.add(attributes)
            }
        }

        // Sort on name
        results.sort { a, b ->
            "${a.lastName}${a.firstName}" <=> "${b.lastName}${b.firstName}"
        }

        sql.close()
        results as List<Map>
    }

    Map getTranscriberCounts(List<Institution> institutions, boolean includeDeactivated = false) {
        Map counts = [:]

        institutions.each {
            if (includeDeactivated) {
                log.warn "includeDeactivated not yet implemented" // TODO implement this
            }
            counts[it.id] = getTranscriberCount(it)
        }

        counts
    }

    Long getTranscriberCount(Institution institution) {
        Task.executeQuery("select count(distinct fullyTranscribedBy) from Transcription where project.institution = :institution", [institution: institution]).get(0)
    }

    Map countTasksForInstitutions(List<Institution> institutions, boolean includeDeactivated = false) {
        Map counts = [:]

        institutions.each {
            if (includeDeactivated) {
                log.warn "includeDeactivated not yet implemented" // TODO implement this
            }
            counts[it.id] = countTasksForInstitution(it)
        }

        counts
    }

    TaskCounts getTaskCounts(Institution institution) {
        def totalTasks = countTasksForInstitution(institution)
        def transcribedTasks = countTranscribedTasksForInstitution(institution)
        def validatedTasks = countValidatedTasksForInstitution(institution)
        new TaskCounts(taskCount: totalTasks, transcribedCount: transcribedTasks, validatedCount: validatedTasks)
    }

    int countTasksForInstitution(Institution institution) {
        Task.executeQuery("select count(*) from Task where project.institution = :institution", [institution: institution])?.get(0)
    }

    int countTranscribedTasksForInstitution(Institution institution) {

        // TODO this isn't great, we should probably use either the search index or denormalise a bit and add
        // a fullyTranscribed flag into the Task table.
        int transcribedCount = 0
        List projects = Project.findAllByInstitution(institution)
        projects.each { project ->
            transcribedCount += taskService.getNumberOfFullyTranscribedTasks(project)

        }
        transcribedCount
    }

    int countValidatedTasksForInstitution(Institution institution) {
        Task.executeQuery("select count(*) from Task where fullyValidatedBy is not null and project.institution = :institution", [institution: institution])?.get(0)
    }

}
