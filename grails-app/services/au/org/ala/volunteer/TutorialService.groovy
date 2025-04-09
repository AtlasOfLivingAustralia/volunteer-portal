package au.org.ala.volunteer

import com.google.common.base.Strings
import groovy.sql.Sql
import org.springframework.web.multipart.MultipartFile

import javax.sql.DataSource
import java.util.regex.Pattern

class TutorialService {

    DataSource dataSource
    def grailsApplication
    def institutionService

    /**
     * Returns the Tutorial directory
     * @return the tutorial directory
     */
    private String getTutorialDirectory() {
        return grailsApplication.config.getProperty('images.home', String) + "/tutorials"
    }

    /**
     * Returns the filepath for the tutorial directory
     * @param name the tutorial filename
     * @return the filepath
     */
    private String createFilePath(String name) {
        return tutorialDirectory + "/" + name
    }

    /**
     * Returns a list of Tutorials in a directory
     * @param searchTerm an optional search term
     * @return the list of Tutorials
     */
    def listTutorials(String searchTerm) {
        def dir = new File(tutorialDirectory)
        if (!dir.exists()) {
            dir.mkdirs();
        }

        def files = dir.listFiles()
        def tutorials = []
        files.each {
            // Check if the file is already in the DB
            def tutorial = Tutorial.findByFilename(it.name as String)
            if (!tutorial) {
                def url = grailsApplication.config.getProperty('server.url', String) +
                        grailsApplication.config.getProperty('images.urlPrefix', String) + "tutorials/" + it.name
                tutorials << [file: it, name: it.name, url: url]
            }
        }

        if (searchTerm) {
            def filteredList = tutorials.findAll { it.name.toLowerCase().contains(searchTerm.toLowerCase()) }
            return filteredList.sort { it.name }
        } else {
            return tutorials.sort { it.name }
        }
    }

    /**
     * Uploads a file to the Tutorial file directory
     * @param file the file to upload
     */
    def uploadTutorialFile(MultipartFile file) {
        // Check if there's a file extension. If not, add it.
        def fileExt = '.pdf'

        def fileName = file.originalFilename
        if (!file.originalFilename.contains(fileExt)) {
            fileName += fileExt
        }
        def filePath = createFilePath(fileName)
        def newFile = new File(filePath);
        file.transferTo(newFile);
        return newFile
    }

    /**
     * Deletes a file from the Tutorial directory
     * @param name the name of the file
     */
    def deleteTutorial(String name) {
        def filePath = createFilePath(name)
        def file = new File(filePath)
        if (file.exists()) {
            file.delete()
            return true
        }

        return false
    }

    /**
     * Renames a file.
     * @param oldname the old name
     * @param newname the new name
     */
    def renameTutorial(String oldname, String newname) {
        def filePath = createFilePath(oldname)
        def file = new File(filePath)
        if (file.exists()) {
            def newFile = new File(createFilePath(newname))
            if (!newFile.exists()) {
                file.renameTo(newFile)
            }
        }
    }

    /**
     * Renames tutorial to specified structure
     * @param tutorial the tutorial to update
     */
    def migrateTutorialName(Tutorial tutorial) {
        def updatedName = generateTutorialFilename(tutorial)
        if (updatedName) {
            renameTutorial(tutorial.filename, updatedName)
            tutorial.filename = updatedName
            tutorial.save(flush: true, failOnError: true)
        }
    }

    /**
     * Returns Institutions that have tutorials.
     * @return the list of institutions
     */
    def getTutorialGroups() {
        def institutionIds = Institution.createCriteria().list {
            createAlias('tutorials', 't')
            projections {
                distinct('id')
            }
            eq('isInactive', false)
            eq('isApproved', true)
            eq('t.isActive', true)
        } as List<Long>

        def tutorialList = Institution.getAll(institutionIds)
        tutorialList = tutorialList.sort {a, b ->
            a.name <=> b.name
        }

        tutorialList
    }

    /**
     * Returns all Admin tutorials (that do not have an institution)
     * @return the list of tutorials.
     */
    def getAdminTutorials() {
        def criteria = Tutorial.createCriteria()
        def adminTutorials = criteria.list {
            and {
                isNull('institution')
                eq('isActive', true)
            }
        } as List<Tutorial>

        adminTutorials
    }

    /**
     * Get Tutorial groups from the file directory.
     * @deprecated
     */
    def getTutorialGroupsOld() {
        def dir = new File(tutorialDirectory)
        if (!dir.exists()) {
            dir.mkdirs();
        }

        def files = dir.listFiles()
        def tutorials = [:]

        def regex = Pattern.compile("^(.*)_(.*)\$")
        files.each {
            def url = grailsApplication.config.getProperty('server.url', String) +
                    grailsApplication.config.getProperty('images.urlPrefix', String) + "tutorials/" + it.name
            def group = "-" // no group
            def title = it.name
            def matcher = regex.matcher(it.name)
            if (matcher.matches()) {
                group = matcher.group(1)
                title = matcher.group(2)
            }

            // If there's no file extension, make sure we don't throw an exception.
            int fileExtnSep = title.lastIndexOf('.')
            if (fileExtnSep > 0) title = title.subSequence(0, fileExtnSep)

            if (!tutorials[group]) {
                tutorials[group] = []
            }

            tutorials[group] << [file: it, name: it.name, url: url, title:title]
        }

        if (!tutorials.containsKey('-')) {
            tutorials['-'] = []
        }

        return tutorials
    }

    /**
     * Retrieves tutorials for the manage admin UI. A list of tutorials that is filtered on the provided search
     * parameters; institution, search query, or status
     * @param institutionFilter the institution list available to the user.
     * @param statusFilter the status filter requested by the user.
     * @param params the query string parameters.
     * @param admin true to return all admin tutorials (no institution) false to return normal list
     * @param migration true to return tutorials with no institution or project (intended for migration process)
     * @return a Map containing the query results (limited to max records) and the total count of records for pagination
     */
    def getTutorialsForManagement(def institutionFilter, def statusFilter, def params, def admin = false, def migration = false) {
        Closure fetchTutorials = {
            if (migration) {
                and {
                    isEmpty('projects')
                    isNull('institution')
                }
            } else if (admin) {
                isNull('institution')
            } else {
                if (institutionFilter?.size() > 0) {
                    'in'('institution', institutionFilter)
                }
                if (!Strings.isNullOrEmpty(params.q as String)) {
                    or {
                        ilike('name', "%${params.q}%")
                    }
                }
                if (statusFilter) {
                    switch (statusFilter) {
                        case 'active':
                            eq('isActive', true)
                            break
                        case 'inactive':
                            eq('isActive', false)
                            break
                        case 'hasProjects':
                            isNotEmpty('projects')
                            break
                        case 'noProjects':
                            isEmpty('projects')
                            break
                    }
                }
            }
        }

        List tutorials = Tutorial.createCriteria().list {
            fetchTutorials.delegate = delegate
            fetchTutorials()
            maxResults(params.int('max') ?: 0)
            firstResult(params.int('offset') ?: 0)
            if (params.sortFields) {
                params.sortFields.each {
                    order(it as String, params.order as String)
                }
            } else {
                order(params.sort as String, params.order as String)
            }
        } as List

        int tutorialListCount = Tutorial.createCriteria().get() {
            fetchTutorials.delegate = delegate
            fetchTutorials()
            projections {
                count('id')
            }
        } as int

        return [tutorialList: tutorials, count: tutorialListCount]
    }

    /**
     * Generates a filename for a tutorial for a given structure of <pre>&lt;institution_acronym&gt;_&lt;tutorial_id&gt;_tutorial_&lt;timestamp&gt;.pdf</pre>
     * @param tutorial The tutorial to name
     * @return the generated name.
     */
    def generateTutorialFilename(Tutorial tutorial) {
        if (!tutorial) {
            return null
        }

        def newFileName = new StringBuilder()
        def acronym = "admin"
        if (tutorial.institution) acronym = institutionService.generateAcronym(tutorial.institution.name)
        newFileName.append("${acronym.toLowerCase()}_")
                .append("${tutorial.id}_")
                .append("tutorial_")
                .append("${new Date().getTime()}")
                .append(".pdf")

        return newFileName.toString()
    }

    /**
     * Returns the URL for a Tutorial
     * @param tutorial the tutorial to retrieve.
     * @return the HTTP url for the tutorial.
     */
    def getTutorialUrl(Tutorial tutorial) {
        return grailsApplication.config.getProperty('server.url', String) +
                grailsApplication.config.getProperty('images.urlPrefix', String) + "tutorials/" + tutorial.filename
    }

    def findProjectsForMigration(Tutorial tutorial) {
        String query = """\
            WITH tokenized AS (
                SELECT t.id AS tutorial_id,
                       t.filename,
                       LOWER(unnest(regexp_split_to_array(t.filename, '[ _\\-\\(\\)]+'))) AS token
                FROM tutorial t
                WHERE t.id = :tutorial_id
            ),
            distinct_tokens AS (
                SELECT DISTINCT token FROM tokenized
            ),
            matched_tokens_per_project AS (
                SELECT
                    p.id AS project_id,
                    p.tutorial_links,
                    dt.token
                FROM project p
                JOIN distinct_tokens dt
                  ON LOWER(p.tutorial_links) ILIKE '%' || dt.token || '%'
            ),
            token_count AS (
                SELECT COUNT(*) AS total_tokens FROM distinct_tokens
            ),
            matched_projects AS (
                SELECT
                    project_id,
                    tutorial_links,
                    COUNT(DISTINCT token) AS matched_tokens,
                    STRING_AGG(DISTINCT token, ', ') AS matched_token_list
                FROM matched_tokens_per_project
                GROUP BY project_id, tutorial_links
            )
            SELECT
                mp.project_id,
                mp.tutorial_links,
                mp.matched_tokens,
                tc.total_tokens,
                mp.matched_token_list,
                ROUND(100.0 * mp.matched_tokens / NULLIF(tc.total_tokens, 0), 2) AS match_percentage
            FROM matched_projects mp
            CROSS JOIN token_count tc
            WHERE mp.matched_tokens >= tc.total_tokens / 2.0
            ORDER BY match_percentage DESC;
        """.stripIndent()
        def sql = new Sql(dataSource)
        def results = sql.rows(query, [tutorial_id: tutorial.id])

        def projectList = []
        if (results.size() > 0) {
            results.each { row ->
                //log.debug("Project match: ${row}")
                Project project = Project.get(row.project_id as long)
                def projectRow = [:]
                projectRow.project = project
                projectRow.matches = row.matched_tokens
                projectRow.totalTokens = row.total_tokens
                projectRow.matchedTokenList = row.matched_token_list
                projectRow.matchPercentage = row.match_percentage as Integer
                projectList.add(projectRow)
            }
        }

        sql.close()
        return projectList
    }

    /**
     * Synchronises the list of projects related to a tutorial.
     * @param tutorial the tutorial to be updated
     * @param projectList the list of projects to synchronise
     */
    def syncTutorialProjects(Tutorial tutorial, List<Project> projectList) {
        if (!tutorial || projectList == null) return
        def currentProjects = tutorial.projects as Set
        def updatedProjectSet = projectList as Set

        (updatedProjectSet - currentProjects).each { projectToAdd ->
            tutorial.addToProjects(projectToAdd)
        }

        (currentProjects - updatedProjectSet).each { projectToRemove ->
            tutorial.removeFromProjects(projectToRemove)
        }

        tutorial.save(flush: true, failOnError: true)
    }
}
