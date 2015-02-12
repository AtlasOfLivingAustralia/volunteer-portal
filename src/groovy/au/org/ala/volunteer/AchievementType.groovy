package au.org.ala.volunteer

import org.springframework.context.ApplicationContext

enum AchievementType {
    ELASTIC_SEARCH_QUERY,
    GROOVY_SCRIPT
    
    def run(ApplicationContext context, Task task, User user, String achievement) {
        switch (this) {
            case ELASTIC_SEARCH_QUERY:
                return context.getBean(FullTextIndexService).evaluateAchievement(task, user, achievement)
                break
            case GROOVY_SCRIPT:
                def script = new GroovyShell().parse(achievement)
                script.setBinding(new Binding([applicationContext: context, task: task, user: user]))
                return script.run()
                break
        }
    }
}
