package au.org.ala.volunteer

import com.google.common.io.Closer
import grails.events.EventPublisher
import grails.events.annotation.Subscriber
import grails.gorm.DetachedCriteria
import grails.gorm.transactions.Transactional
import groovy.time.TimeCategory
import groovy.util.logging.Slf4j
import org.apache.commons.pool2.impl.GenericKeyedObjectPool
import org.apache.commons.pool2.impl.GenericKeyedObjectPoolConfig
import org.elasticsearch.action.search.SearchResponse
import org.elasticsearch.action.search.SearchType
import org.hibernate.FetchMode
import org.hibernate.transform.DistinctRootEntityResultTransformer
import org.hibernate.transform.ResultTransformer
import org.ocpsoft.prettytime.PrettyTime
import org.springframework.web.multipart.MultipartFile
import reactor.spring.context.annotation.Consumer
import reactor.spring.context.annotation.Selector

import javax.annotation.PostConstruct
import javax.annotation.PreDestroy
import java.nio.file.DirectoryStream
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths

import static org.hibernate.FetchMode.*

@Consumer
@Transactional
@Slf4j
class AchievementService implements EventPublisher {

    public static final String ACHIEVEMENT_AWARDED = 'achievement.awarded'
    public static final String ACHIEVEMENT_VIEWED = 'achievement.viewed'

    def grailsApplication
    def fullTextIndexService
    def grailsLinkGenerator
    def freemarkerService
    def eventSourceService

    def scriptPool

    def eventSourceStartMessage

    @PostConstruct
    void init() {
        def config = new GenericKeyedObjectPoolConfig()
        config.maxTotalPerKey = 50 // TODO get values from config (or inject pool?)
        config.maxIdlePerKey = 50
        scriptPool = new GenericKeyedObjectPool<String, Script>(new GroovyScriptPooledObjectFactory(), config)

        eventSourceStartMessage = eventSourceService.addEventSourceStartMessage { userId ->
            final achievements
            if (userId) {
                log.debug("Get unnotified achievments for $userId")
                achievements = AchievementAward.withCriteria {
                    user {
                        eq('userId', userId)
                    }
                    eq('userNotified', false)
                    order('awarded')
                    fetchMode('achievement', JOIN)
                    resultTransformer(DistinctRootEntityResultTransformer.INSTANCE)
                }
                log.debug("Found ${achievements.size()} achievments")
            } else {
                achievements = []
            }
            achievements.collect { createAwardMessage(it) }
        }
    }

    @PreDestroy
    void destroy() {
        eventSourceService.removeEventSourceStartMessage(eventSourceStartMessage)
    }

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
        final achievements
        achievements = AchievementDescription.withCriteria {
            eq 'enabled', true
            if (alreadyAwarded) {
                not {
                    'in'('id', alreadyAwarded)
                }
            }
        }

        final newAchievements = achievements
                .find { evaluateAchievement(it as AchievementDescription, userId)}

        if (newAchievements) {
            final user = User.findByUserId(userId)
            newAchievements.each {
                log.debug("${user?.id} (${user?.displayName} ${user?.email}) achieved ${it.name}")
                def aa = new AchievementAward(achievement: it, user: user, awarded: new Date())
                def aaSaved = aa.save(true)

                if (!aaSaved || aa.hasErrors()) {
                    log.error("Couldn't save achievement {} for user {} due to {}", it, user, aa?.errors)
                } else {
                    notify(ACHIEVEMENT_AWARDED, aaSaved)
                }

            }
        }
    }

    def evalAndRecordAchievements(Set<String> userIds) {
        userIds.collectEntries { user ->
            def cheevs = evalAndRecordAchievementsForUser(user)
            [(user): cheevs]
        }
    }

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

    private def evaluateGroovyAchievement(AchievementDescription achievementDescription, String userId) {
        final code = achievementDescription.code
        return runScript(code, new Binding([applicationContext: grailsApplication.mainContext, userId: userId]))
    }

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
            return grailsLinkGenerator.resource([file: '/images/achievements/blank.png'])
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

    List<AchievementAward> newAchievementsForUser(User user) {
        AchievementAward.findAllByUserAndUserNotified(user, false)
    }

    def markAchievementsViewed(User user, List<Long> ids) {
        def criteria = new DetachedCriteria(AchievementAward).build {
            inList 'id', ids
            eq 'user', user
        }
        int total = criteria.updateAll(userNotified:true)
        if (total) {
            ids.each { notify(ACHIEVEMENT_VIEWED, [id: it, userId: user.userId]) }
        }
        log.debug("Marked ${total} achievements as seen for ${user.userId}")
    }

    def awardAchievementsToEligibleUsers (AchievementDescription achievementDescriptionInstance) {
        def awardedUsers = achievementDescriptionInstance.awards*.user*.id.toList()
        def eligibleUsers = User.withCriteria {
            if (awardedUsers) {
                not { inList('id', awardedUsers) }
            }
            projections {
                property('userId')
            }
        }

        def awards = eligibleUsers
                .findAll { evaluateAchievement(achievementDescriptionInstance, it) }
                .collect { new AchievementAward(user: User.findByUserId(it), achievement: achievementDescriptionInstance, awarded: new Date()) }

//        AchievementAward.saveAll(awards)
        awards*.save()

        awards.each { notify(AchievementService.ACHIEVEMENT_AWARDED, it) }

        return awards

    }

    def awardUser(User user, AchievementDescription achievementDescriptionInstance) {
        def award = new AchievementAward(user: user, achievement: achievementDescriptionInstance, awarded: new Date())
        award.save flush: true

        notify(AchievementService.ACHIEVEMENT_AWARDED, award)

        return award
    }

    def unawardAllUsers(AchievementDescription achievementDescriptionInstance) {
        def awards = AchievementAward.findAllByAchievement(achievementDescriptionInstance)
        log.debug("Removing awarded achievements: ${awards.join('\n')}")

        AchievementAward.deleteAll(awards)
    }

    def unaward(List<Long> awardIds, AchievementDescription achievementDescription) {
        def awards = AchievementAward.findAllByIdInListAndAchievement(awardIds, achievementDescriptionInstance)
        log.debug("Removing awarded achievements: ${awards.join('\n')}")

        AchievementAward.deleteAll(awards)

    }

    // TODO Update to @Subscriber
//    @Subscriber('achievement.awarded')
    @Selector('achievement.awarded')
    void achievementAwarded(AchievementAward award) {
        try {
            log.debug("On Achievement Awarded")
            notify(EventSourceService.NEW_MESSAGE, createAwardMessage(award))
        } catch (e) {
            log.error("Caught exception in $ACHIEVEMENT_AWARDED event listener", e)
        }
    }

    //    @Subscriber('achievement.viewed')
    @Selector('achievement.viewed')
    void achievementViewed(Map args) {
        try {
            log.debug("On Achievement Viewed")
            notify(EventSourceService.NEW_MESSAGE, new Message.EventSourceMessage(to: args.userId, event: ACHIEVEMENT_VIEWED, data: [id: args.id]))
        } catch (e) {
            log.error("Caught exception in $ACHIEVEMENT_VIEWED event listener", e)
        }
    }

    private createAwardMessage(AchievementAward award) {
        final message
        use (TimeCategory) {
            if ((new Date() - award.awarded) < 1.minute ) {
                message = "You were just awarded the ${award.achievement.name} achievement!"
            } else {
                message = "You were awarded the ${award.achievement.name} achievement ${new PrettyTime().format(award.awarded)}!"
            }
        }

        def data = [class     : 'achievement.award', badgeUrl: getBadgeImageUrl(award.achievement),
                   title: 'Congratulations!', id: award.id,
                   message   : message.toString(),
                   profileUrl: grailsLinkGenerator.link(controller: 'user', action: 'notebook')]
        def msg = new Message.EventSourceMessage(to: award.user.userId, event: ACHIEVEMENT_AWARDED, data: data)
        return msg
    }

    /**
     * Adds a badge to an Achievement description. Returns a map of fields that can be resolved to JSON.
     * @param f the MultipartFile object representing the badge image
     * @param achievement the AchivementDescription to attach the badge to
     * @return json Map containing the filename (if successful) or an error message.
     */
    def addBadgeToAchievement(MultipartFile f, AchievementDescription achievement) {
        boolean result
        def json = [:]

        String filename = UUID.randomUUID().toString() + '.' + contentTypeToExtension(f.contentType)
        result = uploadToLocalPath(f, filename)

        if (result) {
            json.put('filename', filename)
            if (achievement) {
                achievement.badge = filename
                achievement.save(flush: true)
            }
        } else {
            json.put('error', "Failed to upload image. Unknown error!")
        }

        json
    }

    /**
     * Uploads an image to the Achievment storage location
     * @param mpfile the MultipartFile object representing the image.
     * @param filename the name to give the file
     * @return true if uploaded successful, false if not.
     */
    private boolean uploadToLocalPath(MultipartFile mpfile, String filename) {
        if (!mpfile) {
            return false
        }

        try {
            def file = new File(badgeImageFilePrefix, filename)
            if (!file.getParentFile().exists() && !file.getParentFile().mkdirs()) {
                throw new RuntimeException("Failed to create institution directories: ${file.getParentFile().getAbsolutePath()}")
            }
            mpfile.transferTo(file);
            return true
        } catch (Exception ex) {
            log.error("AchievementService.uploadToLocalPath: Failed to upload achievement badge", ex)
            return false
        }
    }

    /**
     * Returns the specific file extension for the content type. Returns no-length string if content type isn't known.
     * Valid content types:
     * <ul><li>image/png</li>
     * <li>image/jpg</li>
     * <li>image/jpeg</li>
     * <li>image/gif</li>
     * <li>image/webp</li>
     * <li>image/tiff</li>
     * <li>image/tiff-fx</li>
     * <li>image/bmp</li>
     * <li>image/x-bmp</li></ul>
     * @param contentType the content type of the file
     * @return the selected file extension
     */
    private static String contentTypeToExtension(String contentType) {
        switch (contentType.toLowerCase()) {
            case 'image/png':
                return 'png'
            case 'image/jpeg':
                return 'jpg'
            case 'image/gif':
                return 'gif'
            case 'image/webp':
                return 'webp'
            case 'image/tiff':
            case 'image/tiff-fx':
                return 'tiff'
            case 'image/bmp':
            case 'image/x-bmp':
                return 'bmp'
            default:
                return ''
        }
    }
}
