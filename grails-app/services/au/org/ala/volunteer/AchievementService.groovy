package au.org.ala.volunteer

import groovy.text.SimpleTemplateEngine
import org.elasticsearch.action.search.SearchResponse
import org.elasticsearch.action.search.SearchType

class AchievementService {

    static transactional = true

    def taskService
    def grailsApplication
    def fullTextIndexService
    def grailsLinkGenerator

    def evaluateAchievements(User user, Long taskId) {
        def alreadyAwarded = AchievementAward.withCriteria {
            eq 'user', user
            projections {
                property 'achievementId'
            }
        }
        AchievementDescription.findAllByIdNotInList(alreadyAwarded)
                .find { evaluateAchievement(it, user, taskId)}
                .collect {
                    log.info("${user.id} (${user.email} achieved ${it.name}")
                    new AchievementAward(achievement: it, user: user, awarded: new Date())
                }*.save(true)
    }
    
    def evaluateAchievement(AchievementDescription cheev, User user, Long taskId) {
        switch (cheev.type) {
            case AchievementType.ELASTIC_SEARCH_QUERY:
                return evaluateElasticSearchAchievement(cheev, user, taskId)
            case AchievementType.GROOVY_SCRIPT:
                return evaluateGroovyAchievement(cheev, user, taskId)
            case AchievementType.ELASTIC_SEARCH_AGGREGATION_QUERY:
                return evaluateElasticSearchAggregatuibAchievement(cheev, user, taskId)
        }
    }

    def evaluateElasticSearchAggregatuibAchievement(AchievementDescription achievementDescription, User user, Long taskId) {
        final template = achievementDescription.searchQuery
        final aggTemplate = achievementDescription.aggregationQuery

        final code = achievementDescription.code

        final count = achievementDescription.count
        final aggType = achievementDescription.aggregationType

        final binding = ["userId":user.id, "taskId":taskId]

        def engine = new SimpleTemplateEngine()
        def query = engine.createTemplate(template).make(binding)

        def agg = engine.createTemplate(aggTemplate).make(binding)

        final closure
        if (aggType == AggregationType.CODE) {
            closure = {SearchResponse sr ->
                def script = new GroovyShell().parse(code)
                script.setBinding(new Binding([searchResponse: sr, taskId: taskId, user: user]))
                return script.run()
            }
        } else {
            closure = fullTextIndexService.aggregationHitsGreaterThan(count, aggType)
        }
        fullTextIndexService.rawSearch(query.toString(), SearchType.COUNT, agg.toString(), closure)
    }

    private def evaluateGroovyAchievement(AchievementDescription achievementDescription, User user, Long taskId) {
        final code = achievementDescription.code
        def script = new GroovyShell().parse(code)
        script.setBinding(new Binding([applicationContext: grailsApplication.mainContext, taskId: taskId, user: user]))
        return script.run()
    }

    private def evaluateElasticSearchAchievement(AchievementDescription achievementDescription, User user, Long taskId) {
        final template = achievementDescription.searchQuery
        final count = achievementDescription.count

        final binding = ["userId":user.id, "taskId":taskId]

        def engine = new SimpleTemplateEngine()
        def query = engine.createTemplate(template).make(binding)
        
        fullTextIndexService.rawSearch(query.toString(), SearchType.COUNT, fullTextIndexService.searchResponseHitsGreaterThan(count))
    }

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
                    log.debug "Checking rule for achievement ${desc.name}"
                    AchievementRuleResult result = rule.getProperty(this)(user, tasks)
                    if (result && result.success) {
                        log.info "${user.userId} (${user.email}) just achieved ${desc.name}!"
                        Date dateAchieved = result.dateAchieved ?: new Date();
                        def newAchievement = new Achievement( name: desc.name, user: user, dateAchieved: dateAchieved)
                        newAchievement.save(flush: true, failOnError: true)
                        ach = newAchievement
                    }
                } else {
                    log.warn "Rule for achievement ${desc.name} not found!"
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

    String getBadgeImageUrlPrefix() {
        "${grailsApplication.config.server.url}/${grailsApplication.config.images.urlPrefix}achievements/"
    }

    String getBadgeImageFilePrefix() {
        "${grailsApplication.config.images.home}/achievements/"
    }

    String getBadgeImagePath(AchievementDescription achievementDescription) {
        def prefix = badgeImageFilePrefix
        return "${}${achievementDescription.badge}"
    }

    boolean hasBadgeImage(AchievementDescription achievementDescription) {
        def f = new File(getBadgeImagePath(achievementDescription))
        return f.exists()
    }

    public String getBadgeImageUrl(AchievementDescription achievementDescription) {
        def prefix = badgeImageUrlPrefix
        if (hasBadgeImage(achievementDescription)) {
            return "${prefix}${achievementDescription.badge}"
        } else {
            return grailsLinkGenerator.resource([dir: '/images/achievements', file: 'blank.png'])
        }
    }
}
