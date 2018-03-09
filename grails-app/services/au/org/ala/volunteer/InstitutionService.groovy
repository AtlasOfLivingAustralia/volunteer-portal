package au.org.ala.volunteer

import au.org.ala.volunteer.collectory.CollectoryDto
import au.org.ala.volunteer.collectory.CollectoryProviderDto
import org.apache.commons.io.FileUtils
import org.springframework.web.multipart.MultipartFile

class InstitutionService {

    def grailsApplication
    def collectoryClient
    def grailsLinkGenerator
    def sessionFactory

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

    public uploadImageFromUrl(Institution institution, String url) {
        uploadtoLocalPathFromUrl(url, getImagePath(institution.id))
    }

    public uploadBannerImageFromUrl(Institution institution, String url) {
        uploadtoLocalPathFromUrl(url, getBannerImagePath(institution.id))
    }

    public uploadLogoImageFromUrl(Institution institution, String url) {
        uploadtoLocalPathFromUrl(url, getLogoImagePath(institution.id))
    }

    public clearImage(Institution institution) {
        deleteLocalFile(getImagePath(institution.id))
    }

    public clearLogo(Institution institution) {
        deleteLocalFile(getLogoImagePath(institution.id))
    }

    public clearBanner(Institution institution) {
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

    public uploadImage(Institution institution, MultipartFile mpfile) {
        uploadToLocalPath(mpfile, getImagePath(institution?.id))
    }

    public uploadBannerImage(Institution institution, MultipartFile mpfile) {
        uploadToLocalPath(mpfile, getBannerImagePath(institution.id))
    }

    public uploadLogoImage(Institution institution, MultipartFile mpfile) {
        uploadToLocalPath(mpfile, getLogoImagePath(institution.id))
    }

    public boolean hasImage(Institution institution) {
        def f = new File(getImagePath(institution?.id))
        return f.exists()
    }

    public boolean hasBannerImage(Institution institution) {
        def f = new File(getBannerImagePath(institution?.id))
        return f.exists()
    }

    public boolean hasLogoImage(Institution institution) {
        def f = new File(getLogoImagePath(institution?.id))
        return f.exists()
    }

    public String getImageUrl(Institution institution) {
        if (hasImage(institution)) {
            return "${grailsApplication.config.server.url}/${grailsApplication.config.images.urlPrefix}institution/${institution.id}/image.jpg"
        } else {
            return grailsLinkGenerator.resource([file: '/images/banners/default-institution-banner.jpg'])
        }
    }

    public String getBannerImageUrl(Institution institution) {
        if (hasBannerImage(institution)) {
            return "${grailsApplication.config.server.url}/${grailsApplication.config.images.urlPrefix}institution/${institution.id}/banner-image.jpg"
        }
    }

    public String getLogoImageUrl(Institution institution) {
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


    public CollectoryProviderDto getCollectoryObjectFromUid(String uid) {

        CollectoryProviderDto provider = null
        if (uid?.toLowerCase()?.startsWith("in")) {
            provider = collectoryClient.getInstitution(uid).execute().body()
        } else if (uid?.toLowerCase()?.startsWith("co")) {
            provider = collectoryClient.getCollection(uid).execute().body()
        }

        return provider
    }

    public List<CollectoryDto> getCombinedInsitutionsAndCollections() {
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
                isNull('fullyTranscribedBy')
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
  NOT EXISTS (SELECT * FROM task t WHERE t.project_id = p.id AND t.fully_transcribed_by IS NULL)
'''

        // Create native SQL query.
        final sqlQuery = session.createSQLQuery(query)

        final results = sqlQuery.with {
            setLong('instId', institution.id)
            uniqueResult()
        }

        return results
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
        Task.executeQuery("select count(distinct fullyTranscribedBy) from Task where project.institution = :institution", [institution: institution]).get(0)
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
        Task.executeQuery("select count(*) from Task where fullyTranscribedBy is not null and project.institution = :institution", [institution: institution])?.get(0)
    }

    int countValidatedTasksForInstitution(Institution institution) {
        Task.executeQuery("select count(*) from Task where fullyValidatedBy is not null and project.institution = :institution", [institution: institution])?.get(0)
    }

}
