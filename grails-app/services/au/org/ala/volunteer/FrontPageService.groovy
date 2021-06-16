package au.org.ala.volunteer

import groovy.sql.Sql
import reactor.spring.context.annotation.Consumer
import reactor.spring.context.annotation.Selector
import groovy.time.TimeCategory

import javax.annotation.PostConstruct
import javax.annotation.PreDestroy
import javax.sql.DataSource
import java.util.concurrent.ThreadLocalRandom

@Consumer
class FrontPageService {

    public static final String ALERT_MESSAGE = 'alertMessage'

    DataSource dataSource
    def projectService
    def eventSourceService
    def eventSourceStartMessage

    @PostConstruct
    void init() {
        eventSourceStartMessage = eventSourceService.addEventSourceStartMessage { userId ->
            log.debug("Getting Front Page System Message")
            def systemMessage = FrontPage.first().systemMessage
            log.debug("Got Front Page System Message")
            [createMessage(systemMessage)]
        }
    }

    @PreDestroy
    void destroy() {
        eventSourceService.removeEventSourceStartMessage(eventSourceStartMessage)
    }

    private static Message.EventSourceMessage createMessage(String message) {
        new Message.EventSourceMessage(event: ALERT_MESSAGE, data: message)
    }

    @Selector(FrontPageService.ALERT_MESSAGE)
    void alertMessage(String alert) {
        try {
            log.debug("On Alert Message")
            notify(EventSourceService.NEW_MESSAGE, createMessage(alert))
        } catch (e) {
            log.error("Exception caught while handling system message change", e)
        }
    }

    /**
     * Randomly select a project from active, non-archived projects. Only selects from projects that have not been
     * perviously selected in the last 5 days (to prevent frequent reselection) and is less than 90% completed.
     *
     * @return the randomly selected project. If no active, unarchived projects exist, return null.
     */
    def selectRandomProject() {
        def startDate = null
        def endDate = new Date()
        use(TimeCategory) {
            startDate = endDate - 5.days
        }
        if (!startDate) startDate = new Date()
        log.debug("Random project selection time frame: ${startDate}")

        def query = """\
            select p.id,
                   sum(case when ta.is_fully_transcribed = true then 1 else 0 end) as transcribed, 
                   sum(case when ta.fully_validated_by is not null then 1 else 0 end) as validated,
                   count(ta.id) as total_tasks,
                   (100.0*(cast(sum(case when ta.is_fully_transcribed = true then 1 else 0 end) as decimal(7,2)) / count(ta.id))) as completion
              from project p
              join task ta on (ta.project_id = p.id)
            where p.archived = false
              and p.inactive = false
              and (p.potd_last_selected <= :startDate or p.potd_last_selected is null)
            group by p.id, name
            having sum(case when ta.fully_validated_by is not null then 1 else 0 end) < count(ta.id) """.stripIndent()

        def sql = new Sql(dataSource)
        def projectList = []
        def backupList = []
        def results = sql.rows(query, [startDate: startDate.toTimestamp()])

        if (results.size() > 0) {
            results.each { row ->
                Project project = Project.get(row.id as long)
                if (project && row.completion < 100.0) projectList.add(project)
                else if (project) backupList.add(project)
            }
        }

        log.debug("Project Lists to choose from: projectList: ${projectList.size()}")
        log.debug("Project Lists to choose from: backupList: ${backupList.size()}")

        // Backup checking. If there are no projects that are open and yet to be transcribed, use the
        // backup list (projects needing validation). If that list is empty, just grab the list of projects.
        if (projectList.size() == 0 && backupList.size() > 0) {
            log.debug("Project list is empty, going to backupList")
            projectList = backupList
        } else if (projectList.size() == 0 && backupList.size() == 0) {
            log.debug("No projects to choose from, getting any project")
            projectList = Project.createCriteria().list {
                and {
                    eq('archived', false)
                    eq('inactive', false)
                    or {
                        lt('potdLastSelected', startDate)
                        isNull('potdLastSelected')
                    }
                }
            } as List
            log.debug("Projects list: ${projectList.size()}")
        }

        // Randomly select a project from the list.
        int randomIndex = ThreadLocalRandom.current().nextInt(0, projectList.size() + 1);
        Project projectToDisplay = projectList.get(randomIndex) as Project
        log.debug("Project selected: ${projectToDisplay}")
        projectToDisplay.potdLastSelected = new Date()
        projectToDisplay.save(failOnError: true, flush: true)

        return projectToDisplay
    }

    /**
     * Determines if the difference between the current datetime is a time that allows for a new random project to be
     * selected.
     * @param randomProjectDateUpdated the last datetime the random project was updated.
     * @return
     */
    def isTimeToUpdateRandomProject(Date randomProjectDateUpdated) {
        def currentDate = new Date().getAt(Calendar.DAY_OF_YEAR)
        if (!randomProjectDateUpdated) return true
        def lastDate = randomProjectDateUpdated.getAt(Calendar.DAY_OF_YEAR)
        // If we've gone over to the next year, return true.
        if (currentDate < lastDate) return true
        return currentDate - lastDate >= 1
    }

    /**
     * Intended to be called from index page, checks if time to update the project of the day. If so, gets a new
     * project and updates the frontpage parameter.
     * @param frontPage The front page details.
     */
    def checkProjectOfTheDay(FrontPage frontPage) {
        log.debug("Checking if it's time to change the PotD")
        if (isTimeToUpdateRandomProject(frontPage.randomProjectDateUpdated) ||
                projectService.isProjectComplete(frontPage.projectOfTheDay)) {
            log.debug("Updating PotD")
            def project = selectRandomProject()
            if (project) {
                frontPage.projectOfTheDay = project
                frontPage.randomProjectDateUpdated = new Date()
                frontPage.save(failOnError: true, flush: true)
            }
            log.debug("New PotD: ${frontPage.projectOfTheDay}")
            return frontPage.projectOfTheDay
        } else {
            return frontPage.projectOfTheDay
        }
    }


}
