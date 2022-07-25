package au.org.ala.volunteer

import com.google.common.base.Stopwatch
import grails.gorm.transactions.Transactional
import groovy.transform.ToString
import groovy.util.logging.Slf4j
import org.springframework.web.context.request.RequestContextHolder

import java.util.concurrent.ConcurrentLinkedQueue
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicInteger

//@Transactional(readOnly = true)
@Slf4j
class DomainUpdateService {

    def grailsApplication
    def fullTextIndexService
    def achievementService
    def settingsService
    def userService
    def validationService

    private static ConcurrentLinkedQueue<QueueTask> _backgroundQueue = new ConcurrentLinkedQueue<QueueTask>()
    // Used to show the currently processing size, which is the size of the background queue + the number of
    // tasks that have been removed from the queue but not yet completed
    private AtomicInteger currentlyProcessing = new AtomicInteger(0)

    def onTasksUpdated(Set<Long> taskSet) {
        if (taskSet) {
            taskSet.each { scheduleTaskUpdate(it) }
        }
    }

    private def postIndexTaskActions(Set<Long> taskSet) {
        def cheevs = []
        if (settingsService.getSetting(SettingDefinition.EnableAchievementCalculations)) {
            // TODO Replace with withCriteria
            def involvedUserIds =
                    Task.withCriteria {
                        inList('id', taskSet.toList())
                        or {
                            transcriptions {
                                isNotNull('fullyTranscribedBy')
                            }
                            isNotNull('fullyValidatedBy')
                        }
                        projections {
                            transcriptions {
                                property('fullyTranscribedBy')
                            }

                            property('fullyValidatedBy')
                        }
                    }
                    .collect { [it[0], it[1]] }
                    .flatten().findAll { it != null }
                    .toSet()

            def currentUserId
            if (RequestContextHolder.requestAttributes) {
                currentUserId = userService.currentUserId
            } else {
                log.debug("Not currently in a request context, there is no current user to add to achivement evaluation.")
            }
            if (currentUserId) {
                involvedUserIds.add(currentUserId)
            }
            cheevs = achievementService.evalAndRecordAchievements(involvedUserIds)
        }
        cheevs
    }

    def static scheduleProjectUpdate(long id) {
        _backgroundQueue.add(new UpdateProjectTask(projectId: id))
    }

    def static scheduleTaskUpdate(long id) {
        _backgroundQueue.add(new UpdateTaskTask(taskId: id))
    }

    def static scheduleTaskIndex(Task task) {
        _backgroundQueue.add(new IndexTaskTask(taskId: task.id))
    }

    def static scheduleTaskIndex(long taskId) {
        _backgroundQueue.add(new IndexTaskTask(taskId: taskId))
    }

    static def scheduleTaskDeleteIndex(long taskId) {
        _backgroundQueue.add(new DeleteTaskTask(taskId: taskId))
    }

    def getQueueLength() {
        return _backgroundQueue.size() + currentlyProcessing.get()
    }

    @Transactional
    def processTaskQueue(int maxTasks = 10000) {
        int taskCount = 0
        QueueTask jobDescriptor = null

        Set<Long> deletes = new HashSet<>()
        Set<Long> updates = new HashSet<>()
        Set<Long> indexes = new HashSet<>()
        Set<Long> validations = new HashSet<>()

        Stopwatch sw = Stopwatch.createStarted()

        while (taskCount < maxTasks && (jobDescriptor = _backgroundQueue.poll()) != null) {
            if (jobDescriptor) {
                switch (jobDescriptor) {
                    case DeleteTaskTask:
                        deletes.add(jobDescriptor.taskId)
                        break
                    case UpdateTaskTask:
                        updates.add(jobDescriptor.taskId)
                        indexes.add(jobDescriptor.taskId)
                        validations.add(jobDescriptor.taskId)
                        taskCount++
                        currentlyProcessing.set(indexes.size())
                        break
                    case IndexTaskTask:
                        indexes.add(jobDescriptor.taskId)
                        taskCount++
                        currentlyProcessing.set(indexes.size())
                        break
                    case UpdateProjectTask:
                        def tasks = Task.withCriteria {
                            project {
                                eq 'id', jobDescriptor.projectId
                            }
                            projections {
                                property 'id'
                            }
                        }
                        updates.addAll(tasks)
                        indexes.addAll(tasks)
                        taskCount+= tasks.size()
                        currentlyProcessing.set(indexes.size())
                        break
                    default:
                        log.warn("Unrecognised object ${jobDescriptor} on queue")
                }
            }
        }
        log.trace("Took ${sw.stop().elapsed(TimeUnit.MILLISECONDS)}ms to get tasks from queue")

        currentlyProcessing.set(indexes.size())
        log.debug("Took ${indexes.size()} jobs from queue, current queue length: $queueLength")

        sw.reset().start()
        if (deletes) fullTextIndexService.deleteTasks(deletes)
        if (indexes) fullTextIndexService.indexTasks(indexes) { currentlyProcessing.decrementAndGet() }
        if (updates) postIndexTaskActions(updates)  
        if (validations) validationService.autoValidate(validations)
        if (deletes || indexes || updates) log.debug("Took ${sw.stop().elapsed(TimeUnit.MILLISECONDS)}ms to process ${deletes.size()} deletes, ${indexes.size()} indexes, ${updates.size()} post-index updates, ${validations.size()} task validations")
    }
}

public abstract class QueueTask { }

@ToString
public class UpdateProjectTask extends QueueTask { public long projectId }

public abstract class QueueTaskTask extends QueueTask { public long taskId }

@ToString
public class DeleteTaskTask extends QueueTaskTask { }

@ToString
public class UpdateTaskTask extends QueueTaskTask{ }

@ToString
public class IndexTaskTask extends QueueTaskTask { }
