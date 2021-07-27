package au.org.ala.volunteer

import grails.converters.JSON

class IndexController {

    def projectService
    def volunteerStatsService

    def index() {
        log.debug("Index Controller, Index action")
        def frontPage = FrontPage.instance()

        def featuredProjects = projectService.getFeaturedProjectList()

        // Check if random project of the day is switched on, if it is, grab one and display, else display the current
        // if set.
        def potdSummary = null
        def projectToDisplay
        log.debug("Random project of the day?")
        if (frontPage?.randomProjectOfTheDay) {
            log.debug("Selecing random...")
            projectToDisplay = projectService.checkProjectOfTheDay(frontPage)
        } else {
            log.debug("Project: ${frontPage?.projectOfTheDay}")
            projectToDisplay = frontPage?.projectOfTheDay
        }

        if (projectToDisplay) {
            log.debug("Getting project summary for [${projectToDisplay.name}]")
            potdSummary = projectService.makeSummaryListFromProjectList([projectToDisplay], null, null, null, null, null, null, null, null, false).projectRenderList?.get(0)
        }

        render(view: "/index", model: ['frontPage': frontPage, featuredProjects: featuredProjects, potdSummary: potdSummary] )
    }

    def leaderBoardFragment() {
        [:]
    }

    def stats(long institutionId, long projectId, String projectType) {
        List<String> tags = params.list('tags') ?: []
        def maxContributors = (params.maxContributors as Integer) ?: 5
        def disableStats = params.getBoolean('disableStats', false)
        def disableHonourBoard = params.getBoolean('disableHonourBoard', false)
        def result = volunteerStatsService.generateStats(institutionId, projectId, projectType, tags, maxContributors, disableStats, disableHonourBoard)
        render result as JSON
    }

 /*   private generateContributors(Institution institution, Project projectInstance, ProjectType pt, maxContributors) {

        def latestTranscribers = LatestTranscribers.withCriteria {
            if (institution) {
                project {
                    eq('institution', institution)
                    ne('inactive', true)
                }
            } else if (pt) {
                project {
                    eq('projectType', pt)
                    ne('inactive', true)
                }
            } else if (projectInstance) {
                eq('project', projectInstance)
            } else {
                project {
                    ne('inactive', true)
                }
            }
            order('maxDate', 'desc')
            maxResults(maxContributors)
        }

        def latestMessages

        if (institution) {
            latestMessages = ForumMessage.findAll('FROM ForumMessage fm WHERE fm.topic.project.institution = :institution ORDER BY date desc', [institution: institution], [max: maxContributors])
            latestMessages += ForumMessage.findAll('FROM ForumMessage fm WHERE fm.topic.task.project.institution = :institution ORDER BY date desc', [institution: institution], [max: maxContributors])
        } else if (pt) {
            latestMessages = ForumMessage.findAll('FROM ForumMessage fm WHERE fm.topic.project.projectType = :pt ORDER BY date desc', [pt: pt], [max: maxContributors])
            latestMessages += ForumMessage.findAll('FROM ForumMessage fm WHERE fm.topic.task.project.projectType = :pt ORDER BY date desc', [pt: pt], [max: maxContributors])
        } else if (projectInstance) {
            latestMessages = ForumMessage.withCriteria {
                or {
                    'in'('topic', new DetachedCriteria(ProjectForumTopic).build {
                        eq('project', projectInstance)
                        projections {
                            property('id')
                        }
                    })
                    'in'('topic', new DetachedCriteria(TaskForumTopic).build {
                        task {
                            eq('project', projectInstance)
                        }
                        projections {
                            property('id')
                        }
                    })
                }
                order('date', 'desc')
                maxResults(maxContributors)
            }
        } else {
            latestMessages = ForumMessage.withCriteria {
                order('date', 'desc')
                maxResults(maxContributors)
            }
        }

        def messages = latestMessages.collect {
            def topic = it.topic
            def topicId = topic.id
            def details = userService.detailsForUserId(it.user.userId)
            def timestamp = it.date.time / 1000
            def topicUrl = createLink(controller: 'forum', action: 'viewForumTopic', id: topic.id)

            def forumName
            def forumUrl
            def thumbnail = null

            if (topic instanceof ProjectForumTopic) {
                def project = ((ProjectForumTopic) topic).project
                forumName = project.name
                thumbnail = project.featuredImage
                forumUrl = createLink(controller: 'forum', action: 'projectForum', params: [projectId: project.id])
            } else if (topic instanceof TaskForumTopic) {
                def task = ((TaskForumTopic) topic).task
                forumName = task.project.name
                thumbnail = multimediaService.getImageThumbnailUrl(task.multimedia?.first())
                forumUrl = createLink(controller: 'forum', action: 'projectForum', params: [projectId: task.project.id, selectedTab: 1])
            } else {
                forumName = "General Discussion"
                forumUrl = createLink(controller: 'forum', action: 'index', params: [selectedTab: 1])
            }

            [type        : 'forum', topicId: topicId, topicUrl: topicUrl, forumName: forumName, forumUrl: forumUrl, userId: it.userId,
             displayName : details?.displayName, email: details?.email?.toLowerCase()?.encodeAsMD5(),
             thumbnailUrl: thumbnail, timestamp: timestamp]
        }

        def transcribers = latestTranscribers.collect {
            def proj = it.project
            def userId = it.fullyTranscribedBy
            def details = userService.detailsForUserId(userId)
            def tasks = LatestTranscribersTask.withCriteria() {
                            eq('project', proj)
                            eq('fullyTranscribedBy', userId)
                            order('dateFullyTranscribed', 'desc')
                        }

            def thumbnailLists = (tasks && (tasks.size() > 0)) ? tasks.subList(0, (tasks.size() < 5)? tasks.size(): 5): []

            def thumbnails = thumbnailLists.collect { LatestTranscribersTask t ->
                def taskMultimedia = t.multimedia[0] //Latest.findByTaskId(t.taskId)
                Multimedia multimedia = new Multimedia(
                                        task: new Task(id: t.id, project: t.project),
                                        id: taskMultimedia.id,
                                        filePath: taskMultimedia.filePath,
                                        filePathToThumbnail: taskMultimedia.filePathToThumbnail,
                                        mimeType: taskMultimedia.mimeType)

                [id: t.id, thumbnailUrl: multimediaService.getImageThumbnailUrl(multimedia)]
            }
            [type             : 'task', projectId: proj.id, projectName: proj.name, userId: User.findByUserId(userId)?.id ?: -1, displayName: details?.displayName, email: details?.email?.toLowerCase()?.encodeAsMD5(),
             transcribedThumbs: thumbnails, transcribedItems: tasks.size(), timestamp: it.maxDate.time / 1000]
        }

        def contributors = (messages + transcribers).sort { -it.timestamp }.take(maxContributors)
        return contributors
    } */

    def notPermitted() {
        render(view: '/notPermitted')
    }
}
