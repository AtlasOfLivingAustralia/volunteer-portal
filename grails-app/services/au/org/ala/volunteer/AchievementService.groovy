package au.org.ala.volunteer

import org.codehaus.groovy.grails.commons.ConfigurationHolder

class AchievementService {

    static transactional = true

    def calculateAchievements(User user) {

        def achievements = ConfigurationHolder.config.achievements;

        if (!user) {
            return
        }

        def results = []

        def existing = Achievement.findByUser(user)
        def tasks = Task.findAllByFullyTranscribedBy(user.userId)
        for (Map desc : achievements) {
            if (!existing.find() { it.name == desc.name }) {
                def rule = this.metaClass.properties.find() { it.name == desc.name + "_rule" }

                if (rule) {
                    println "Checking rule for achievement ${desc.name}"
                    if (rule.getProperty(this)(user, tasks)) {
                        println "${user.userId} just achieved ${desc.name}!"

                        Achievement ach = new Achievement( name: desc.name, user: user, dateAchieved: new Date())
                        ach.save()
                        results.add(desc)
                    }
                } else {
                    println "Rule for achievement ${desc.name} not found!"
                }
            } else {
                results.add(desc)
            }
        }

        return results
    }

    def first_transcription_rule = { User user, List<Task> tasks ->
        return tasks.size() >= 1
    }

    def tenth_transcription_rule = { User user, List<Task> tasks ->
        return tasks.size() >= 10;
    }

    def hundredth_transcription_rule = { User user, List<Task> tasks ->
        return tasks.size() >= 100;
    }

    def three_projects_rule = { User user, List<Task> tasks ->
        def projects = tasks.groupBy { it.projectId }
        return projects.size() >= 3;
    }




}
