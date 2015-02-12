package au.org.ala.volunteer

import org.springframework.context.i18n.LocaleContextHolder

class ForumNotifierService {

    // This is deliberate so that if the mails service fails to send it wont kill the requests current transaction
    // This is useful if emails are being sent on the request thread rather than as background job
    static transactional = false

    def logService
    def userService
    def settingsService
    def CustomPageRenderer customPageRenderer
    def emailService
    def messageSource

    List<User> getModeratorsForTopic(ForumTopic topic) {
        List<User> results = []

        Project projectInstance = null

        if (topic?.instanceOf(ProjectForumTopic)) {
            projectInstance = (topic as ProjectForumTopic).project
        } else if (topic?.instanceOf(TaskForumTopic)) {
            projectInstance = (topic as TaskForumTopic).task?.project
        }
        results = userService.getUsersWithRole("forum_moderator", projectInstance)

        if (projectInstance) {
            def watchList = getUsersInterestedInProject(projectInstance)
            watchList?.each { user ->
                if (!results.contains(user)) {
                    results << user
                }
            }
        }

        return results
    }

    public List<User> getUsersInterestedInProject(Project projectInstance) {
        def list = new ArrayList<User>()
        ProjectForumWatchList watchList = ProjectForumWatchList.findByProject(projectInstance)
        if (watchList) {
            watchList.users?.each { user ->
                list << user
            }
        }
        return list
    }

    public getUsersInterestedInTopic(ForumTopic topic) {
        def c = UserForumWatchList.createCriteria()

        def watchLists = c {
            topics {
                eq('id', topic.id)
            }
        }

        List<User> interestedUsers = []

        watchLists.each { watchList ->
            if (!interestedUsers.contains(watchList.user)) {
                interestedUsers << watchList.user
            }
        }
        // Now the forum moderators and admins...
        def mods = getModeratorsForTopic(topic)
        mods.each { mod ->
            if (!interestedUsers.contains(mod)) {
                interestedUsers << mod
            }
        }

        if (topic.instanceOf(ProjectForumTopic)) {
            ProjectForumTopic projectTopic = topic as ProjectForumTopic
            def list = getUsersInterestedInProject(topic.project)

            if (list) {
                list.each { user ->
                    if (!interestedUsers.contains(user)) {
                        interestedUsers << user
                    }
                }
            }

        }

        return interestedUsers
    }

    def notifyInterestedUsersImmediately(ForumTopic topic, ForumMessage lastMessage) {
        try {
            if (FrontPage.instance().enableForum && settingsService.getSetting(SettingDefinition.ForumNotificationsEnabled)) {
                def interestedUsers = getUsersInterestedInTopic(topic)
                log.info("Sending notifications to users watching topic ${topic.id}: " + interestedUsers.collect { userService.detailsForUserId(it.userId).email })
                def message = customPageRenderer.render(view: '/forum/topicNotificationMessage', model: [messages: lastMessage])
                def appName = messageSource.getMessage("default.application.name", null, "DigiVol", LocaleContextHolder.locale)
                interestedUsers.each { user ->
                    emailService.sendMail(userService.detailsForUserId(user.userId).email, "${appName} Forum notification", message)
                }
            }
        } catch (Throwable ex) {
            log.error("Exception occurred sending notifications: ", e)
        }
    }

    def notifyNewTopicImmediately(ForumTopic topic, ForumMessage firstMessage) {
        try {
            if (FrontPage.instance().enableForum && settingsService.getSetting(SettingDefinition.ForumNotificationsEnabled)) {
                def interestedUsers = getModeratorsForTopic(topic)
                log.info("Sending notifications to moderators for new topic ${topic.id}: " + userService.getEmailAddressesForIds(interestedUsers*.userId))
                def message = customPageRenderer.render(view: '/forum/newTopicNotificationMessage', model: [messages: firstMessage])
                def appName = messageSource.getMessage("default.application.name", null, "DigiVol", LocaleContextHolder.locale)
                interestedUsers.each { user ->
                    emailService.sendMail(userService.detailsForUserId(user.userId).email, "${appName} Forum new topic notification", message)
                }
            }
        } catch (Throwable ex) {
            log.error("Exception occurred sending notifications: ", e)
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
                        def message = customPageRenderer.render(view: '/forum/topicNotificationMessage', model: [messages: messages])
                        emailService.sendMail(email, "${appName} Forum notification", message)
                    } catch (Exception ex) {
                        // TODO Get email from userdetails service
                        log.error("Failed to send email to ${user.userId} (${email}): ", e)
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
