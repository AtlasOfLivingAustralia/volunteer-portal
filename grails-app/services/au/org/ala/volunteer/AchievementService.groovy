package au.org.ala.volunteer

import com.google.common.io.Closer
import grails.gorm.DetachedCriteria
import org.apache.commons.pool2.impl.GenericKeyedObjectPool
import org.apache.commons.pool2.impl.GenericKeyedObjectPoolConfig
import org.elasticsearch.action.search.SearchResponse
import org.elasticsearch.action.search.SearchType
import org.grails.plugins.metrics.groovy.Timed

import java.nio.file.DirectoryStream
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths

class AchievementService {

    static transactional = true

    def taskService
    def grailsApplication
    def fullTextIndexService
    def grailsLinkGenerator
    def freemarkerService

    def scriptPool

    AchievementService() {
        def config = new GenericKeyedObjectPoolConfig()
        config.maxTotalPerKey = 50 // TODO get values from config (or inject pool?)
        config.maxIdlePerKey = 50
        scriptPool = new GenericKeyedObjectPool<String, Script>(new GroovyScriptPooledObjectFactory(), config)
    }

    @Timed
    /**
     * @param userId The user's user.userId attribute (not the user.id attribute)
     */
    def evalAndRecordAchievementsForUser(String userId) {
        def alreadyAwarded = AchievementAward.withCriteria {
            user {
                eq('userId', userId)
            }
            projections {
                property 'achievement.id'
            }
        }
        final achievements = alreadyAwarded ?
                AchievementDescription.findAllByIdNotInListAndEnabled(alreadyAwarded, true)
                : AchievementDescription.findAllByEnabled(true)

        final newAchievements = achievements
                .find { evaluateAchievement(it, userId)}

        if (newAchievements) {
            final user = User.findByUserId(userId)
            newAchievements.collect {
                log.info("${user.id} (${user.displayName} ${user.email}) achieved ${it.name}")
                new AchievementAward(achievement: it, user: user, awarded: new Date())
            }*.save(true)
        }
    }

    @Timed
    def evalAndRecordAchievements(Set<String> userIds) {
        userIds.collectEntries { user ->
            def cheevs = evalAndRecordAchievementsForUser(user)
            [(user): cheevs]
        }
    }

    @Timed
    def evaluateAchievement(AchievementDescription cheev, String userId) {
        switch (cheev.type) {
            case AchievementType.ELASTIC_SEARCH_QUERY:
                return evaluateElasticSearchAchievement(cheev, userId)
            case AchievementType.GROOVY_SCRIPT:
                return evaluateGroovyAchievement(cheev, userId)
            case AchievementType.ELASTIC_SEARCH_AGGREGATION_QUERY:
                return evaluateElasticSearchAggregationAchievement(cheev, userId)
        }
    }

    @Timed
    def evaluateElasticSearchAggregationAchievement(AchievementDescription achievementDescription, String userId) {
        final template = achievementDescription.searchQuery
        final aggTemplate = achievementDescription.aggregationQuery

        final code = achievementDescription.code

        final count = achievementDescription.count
        final aggType = achievementDescription.aggregationType

        final binding = ["userId":userId]

        def query = freemarkerService.runTemplate(template, binding)

        def agg = freemarkerService.runTemplate(aggTemplate, binding)

        final closure
        if (aggType == AggregationType.CODE) {
            closure = { SearchResponse sr ->
                return runScript(code, new Binding([searchResponse: sr, userId: userId]))
            }
        } else {
            closure = fullTextIndexService.aggregationHitsGreaterThanOrEqual(count, aggType)
        }
        fullTextIndexService.rawSearch(query.toString(), SearchType.COUNT, agg.toString(), closure)
    }

    @Timed
    private def evaluateGroovyAchievement(AchievementDescription achievementDescription, String userId) {
        final code = achievementDescription.code
        return runScript(code, new Binding([applicationContext: grailsApplication.mainContext, userId: userId]))
    }

    @Timed
    private def evaluateElasticSearchAchievement(AchievementDescription achievementDescription, String userId) {
        final template = achievementDescription.searchQuery
        final count = achievementDescription.count

        final binding = ["userId":userId]

        def query = freemarkerService.runTemplate(template, binding)
        
        fullTextIndexService.rawSearch(query.toString(), SearchType.COUNT, fullTextIndexService.searchResponseHitsGreaterThanOrEqual(count))
    }

    private def runScript(String code, Binding binding) {
        def script = scriptPool.borrowObject(code)
        try {
            script.setBinding(binding)
            return script.run()
        } finally {
            scriptPool.returnObject(code, script)
        }
    }

    String getBadgeImageUrlPrefix() {
        "${grailsApplication.config.server.url}/${grailsApplication.config.images.urlPrefix}achievements/"
    }

    String getBadgeImageFilePrefix() {
        "${grailsApplication.config.images.home}/achievements/"
    }

    String getBadgeImagePath(AchievementDescription achievementDescription) {
        def prefix = badgeImageFilePrefix
        return "${prefix}${achievementDescription.badge}"
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

    def cleanImageDir(List<String> badges) {


        def stream
        def c = Closer.create()
        try {
            stream = c.register(Files.newDirectoryStream(Paths.get(badgeImageFilePrefix), { Path path -> !badges.contains(path.fileName.toString()) } as DirectoryStream.Filter))

            for (Path path : stream) {
                try { Files.delete(path) } catch (e) { log.warn("Couldn't delete ${path}", e) }
            }
        } catch (e) {
            log.error("Error with deleting unused achievement badges", e)
        } finally {
            c.close()
        }
    }

    @Timed
    List<AchievementAward> newAchievementsForUser(User user) {
        AchievementAward.findAllByUserAndUserNotified(user, false)
    }

    def markAchievementsViewed(List<Long> ids) {
        def criteria = new DetachedCriteria(AchievementAward).build {
            inList 'id', ids
        }
        int total = criteria.updateAll(userNotified:true)
        log.info("Marked ${total} achievements as seen")
    }
}
