package au.org.ala.volunteer

import grails.gorm.DetachedCriteria
import grails.transaction.Transactional
import grails.plugin.cache.Cacheable
import javax.annotation.PostConstruct

@Transactional
class VolunteerContributionService {

    def multimediaService
    def userService

    private g

    @PostConstruct
    def initialise() {
        g = applicationContext.getBean('org.grails.plugins.web.taglib.ApplicationTagLib')
        log.info('test')
    }

    @Cacheable(value = 'MainVolunteerContribution')
    def generateContributors(Institution institution, Project projectInstance, ProjectType pt, maxContributors) {

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
            def topicUrl = g.createLink(controller: 'forum', action: 'viewForumTopic', id: topic.id)

            def forumName
            def forumUrl
            def thumbnail = null

            if (topic instanceof ProjectForumTopic) {
                def project = ((ProjectForumTopic) topic).project
                forumName = project.name
                thumbnail = project.featuredImage
                forumUrl = g.createLink(controller: 'forum', action: 'projectForum', params: [projectId: project.id])
            } else if (topic instanceof TaskForumTopic) {
                def task = ((TaskForumTopic) topic).task
                forumName = task.project.name
                thumbnail = multimediaService.getImageThumbnailUrl(task.multimedia?.first())
                forumUrl = g.createLink(controller: 'forum', action: 'projectForum', params: [projectId: task.project.id, selectedTab: 1])
            } else {
                forumName = "General Discussion"
                forumUrl = g.createLink(controller: 'forum', action: 'index', params: [selectedTab: 1])
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
    }

}
