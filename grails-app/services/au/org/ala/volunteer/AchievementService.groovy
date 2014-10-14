package au.org.ala.volunteer

class AchievementService {

    static transactional = true

    def taskService
    def logService
    def grailsApplication

    def getAllAchievements() {
        def achievements = grailsApplication.config.achievements;
        return achievements
    }

    def calculateAchievements(User user) {

        def achievements = getAllAchievements()

        if (!user) {
            return
        }

        def results = []

        def existing = Achievement.findAllByUser(user)
        def tasks = taskService.transcribedDatesByUser(user.userId)

        for (Map desc : achievements) {
            Achievement ach = existing.find { it.name == desc.name }
            if (!ach) {
                def rule = this.metaClass.properties.find() { it.name == desc.name + "_rule" }

                if (rule) {
                    logService.log "Checking rule for achievement ${desc.name}"
                    AchievementRuleResult result = rule.getProperty(this)(user, tasks);
                    if (result && result.success) {
                        // TODO Get email from user details service
                        logService.log "${user.userId} (${user.email}) just achieved ${desc.name}!"
                        Date dateAchieved = result.dateAchieved ?: new Date();
                        def newAchievement = new Achievement( name: desc.name, user: user, dateAchieved: dateAchieved)
                        newAchievement.save(flush: true, failOnError: true)
                        ach = newAchievement
                    }
                } else {
                    logService.log "Rule for achievement ${desc.name} not found!"
                }
            }

            if (ach) {
                results.add(desc)
            }
        }

        return results
    }

    private AchievementRuleResult transcriptionRule(User user, List<Task> tasks, int threshold) {
        if (tasks.size() >= threshold) {
            return new AchievementRuleResult( success: true, dateAchieved: tasks[threshold-1].lastEdit );
        }
        return new AchievementRuleResult(success: false, dateAchieved: (Date) null );
    }

    def tenth_transcription_rule = { User user, List<Task> tasks ->
        return transcriptionRule(user, tasks, 10);
    }

    def hundredth_transcription_rule = { User user, List<Task> tasks ->
        return transcriptionRule(user, tasks, 100);
    }

    def fivehundredth_transcription_rule = { User user, List<Task> tasks ->
        return transcriptionRule(user, tasks, 500);
    }

    def three_projects_rule = { User user, List<Task> tasks ->
        def projects = tasks.groupBy { it.project }
        return new AchievementRuleResult( success: projects.size() >= 3, dateAchieved: null );
    }

    def five_projects_rule = { User user, List<Task> tasks ->
        def projects = tasks.groupBy { it.project }
        return new AchievementRuleResult( success: projects.size() >= 5, dateAchieved: null );
    }

    def seven_projects_rule = { User user, List<Task> tasks ->
        def projects = tasks.groupBy { it.project }
        return new AchievementRuleResult( success: projects.size() >= 7, dateAchieved: null );
    }


}
