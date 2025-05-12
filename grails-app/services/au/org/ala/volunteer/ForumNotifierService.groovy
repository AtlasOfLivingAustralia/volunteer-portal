package au.org.ala.volunteer

import groovy.util.logging.Slf4j
import org.springframework.context.i18n.LocaleContextHolder

@Slf4j
class ForumNotifierService {

    // This is deliberate so that if the mails service fails to send it wont kill the requests current transaction
    // This is useful if emails are being sent on the request thread rather than as background job
    def userService
    def settingsService
    //def CustomPageRenderer customPageRenderer
    def groovyPageRenderer
    def emailService
    def messageSource

    def getModeratorsForTopic(ForumTopic topic) {
        log.debug("Getting moderators for forum topic")
        def results = []

        Project project = null

        if (topic?.instanceOf(ProjectForumTopic)) {
            project = (topic as ProjectForumTopic).project
        } else if (topic?.instanceOf(TaskForumTopic)) {
            project = (topic as TaskForumTopic).task?.project
        }
        results = userService.getUsersWithRole("forum_moderator", project).collect {
            [user: it, type: 'moderator']
        }

        if (project) {
            // Include institution admins for the project's institution
            def institutionAdmins = userService.getInstitutionAdminsForProject(project)
            institutionAdmins.each {
                log.debug("Adding institution admin: ${it.displayName}")
                results << [user: it, type: 'moderator']
            }

            // And people watching the forum
            def watchList = getUsersInterestedInProject(project)
            watchList?.each { user ->
                def foundUser = results.find { it.user.userId == user.userId }
                if (!foundUser) {
                    results << [user: user, type: 'projectWatcher']
                }
            }
        }

        return results
    }

    def getUsersInterestedInProject(Project project) {
        def list = new ArrayList<User>()
        ProjectForumWatchList watchList = ProjectForumWatchList.findByProject(project)
        if (watchList) {
            watchList.users?.each { user ->
                list << user
            }
        }
        return list
    }

    def getUsersInterestedInTopic(ForumTopic topic) {
        def c = UserForumWatchList.createCriteria()

        // TODO This returns a row for every message in the topic for each user watching.
        // Rewrite in JOOQ.
        def watchLists = c {
            topics {
                eq('id', topic.id)
            }
        }
        log.debug("Watch lists for topic ${topic.id}: " + watchLists)

        def interestedUsers = []
        watchLists.each { watchList ->
            def foundUser = interestedUsers.find { it.user.userId == watchList.user.userId }
            if (!foundUser) {
                interestedUsers << [user: watchList.user, type: 'watcher']
            }
        }
        log.debug("Interested users for topic ${topic.id}: " + interestedUsers.collect { it.user.displayName })

        // Now the forum moderators and admins...
        def mods = getModeratorsForTopic(topic)
        mods.each { mod ->
            def foundUser = interestedUsers.find { it.user.userId == mod.user.userId }
            if (!foundUser) {
                interestedUsers << mod
            }
        }
        log.debug("Interested users for topic ${topic.id} after moderators: " + interestedUsers.collect { it.user.displayName })

        if (topic.instanceOf(ProjectForumTopic)) {
            ProjectForumTopic projectTopic = topic as ProjectForumTopic
            def list = getUsersInterestedInProject(projectTopic.project)

            if (list) {
                list.each { user ->
                    def foundUser = interestedUsers.find { it.user.userId == user.userId }
                    if (!foundUser) {
                        interestedUsers << [user: user, type: 'projectWatcher']
                    }
                }
            }
        }
        log.debug("Interested users for topic ${topic.id} after project watchers: " + interestedUsers.collect { it.user.displayName })

        return interestedUsers
    }

    def notifyInterestedUsersImmediately(ForumTopic topic, ForumMessage lastMessage) {
        try {
            if (FrontPage.instance().enableForum && settingsService.getSetting(SettingDefinition.ForumNotificationsEnabled)) {
                def interestedUsers = getUsersInterestedInTopic(topic)
                log.info("Sending notifications to users watching topic ${topic.id}: " + interestedUsers.collect { userService.detailsForUserId(it.user.userId).email })
                String template = '/forum/topicNotificationMessage'
                def modMessage = groovyPageRenderer.render(view: template, model: [messages: lastMessage, type: 'moderator'])
                def watcherMessage = groovyPageRenderer.render(view: template, model: [messages: lastMessage, type: 'watcher'])
                def projectWatcherMessage = groovyPageRenderer.render(view: template, model: [messages: lastMessage, type: 'projectWatcher'])
                def appName = messageSource.getMessage("default.application.name", null, "DigiVol", LocaleContextHolder.locale)
                interestedUsers.each { userRow ->
                    if (lastMessage.user.userId != userRow.user.userId) {
                        if (userRow.type == 'moderator') {
                            emailService.sendMail(userService.detailsForUserId(userRow.user.userId).email, "${appName} Forum notification", modMessage)
                        } else if (userRow.type == 'watcher') {
                            emailService.sendMail(userService.detailsForUserId(userRow.user.userId).email, "${appName} Forum notification", watcherMessage)
                        } else if (userRow.type == 'projectWatcher') {
                            emailService.sendMail(userService.detailsForUserId(userRow.user.userId).email, "${appName} Forum notification", projectWatcherMessage)
                        }
                    } else {
                        log.debug("Skipping notification to ${userRow.user.userId} as they are the author of the message")
                    }
                }
            }
        } catch (Throwable ex) {
            log.error("Exception occurred sending notifications: ", ex)
        }
    }

    def notifyNewTopicImmediately(ForumTopic topic, ForumMessage firstMessage) {
        try {
            if (FrontPage.instance().enableForum && settingsService.getSetting(SettingDefinition.ForumNotificationsEnabled)) {
                def interestedUsers = getModeratorsForTopic(topic)
                log.info("Sending notifications to moderators for new topic ${topic.id}: " + userService.getEmailAddressesForIds(interestedUsers*.user.userId))
                String template = '/forum/newTopicNotificationMessage'
                def message = groovyPageRenderer.render(view: template, model: [messages: firstMessage, type: 'projectWatcher'])
                def moderatorMessage = groovyPageRenderer.render(view: template, model: [messages: firstMessage, type: 'moderator'])
                def appName = messageSource.getMessage("default.application.name", null, "DigiVol", LocaleContextHolder.locale)
                interestedUsers.each { userRow ->
                    if (firstMessage.user.userId != userRow.user.userId) {
                        log.debug("Sending notification to ${userRow.user.userId} (${userService.detailsForUserId(userRow.user.userId).email})")
                        if (userRow.type == 'projectWatcher') {
                            emailService.sendMail(userService.detailsForUserId(userRow.user.userId).email, "${appName} Forum new topic notification", message)
                        } else if (userRow.type == 'moderator') {
                            emailService.sendMail(userService.detailsForUserId(userRow.user.userId).email, "${appName} Forum new topic notification", moderatorMessage)
                        }
                    } else {
                        log.debug("Skipping notification to ${userRow.user.userId} as they are the author of the message")
                    }
                }
            }
        } catch (Throwable ex) {
            log.error("Exception occurred sending notifications: ", ex)
        }
    }

    def processPendingNotifications() {
        // Only process notifications if the forum is enabled...
        if (FrontPage.instance().enableForum && settingsService.getSetting(SettingDefinition.ForumNotificationsEnabled)) {
            log.info("Processing Forum Message Notifications")
            def messageList = ForumTopicNotificationMessage.list()
            if (messageList) {
                def userMap = messageList.groupBy { it.user }
                log.info("Forum Topic Notification Sender: ${messageList.size()} message(s) found across ${userMap.keySet().size()} user(s).")
                def appName = messageSource.getMessage("default.application.name", null, "DigiVol", LocaleContextHolder.locale)
                userMap.keySet().each { user ->
                    def email = user.email
                    try {
                        email = userService.detailsForUserId(user.userId).email
                        log.info("Processing messages for ${user.userId} (${email}) ...")
                        def messages = userMap[user]?.sort { it.message.date }
                        def message = groovyPageRenderer.render(view: '/forum/topicNotificationMessage', model: [messages: messages])
                        emailService.sendMail(email, "${appName} Forum notification", message)
                    } catch (Exception ex) {
                        // TODO Get email from userdetails service
                        log.error("Failed to send email to ${user.userId} (${email}): ", ex)
                    }
                }

                // now clean up the notification list
                log.debug("Purging notification list")
                messageList.each {
                    it.delete()
                }
            }
        }
    }

}
