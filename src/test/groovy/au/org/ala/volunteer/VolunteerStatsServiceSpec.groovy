package au.org.ala.volunteer

import grails.testing.gorm.DataTest
import grails.testing.services.ServiceUnitTest
import spock.lang.Specification

class VolunteerStatsServiceSpec extends Specification implements ServiceUnitTest<VolunteerStatsService>, DataTest {

    def setup() {
        mockDomains(Institution)
    }

    def "generateStats assembles full site stats and leaderboard data"() {
        given:
        def leaderboard = [
                daily  : [userId: 1, name: 'Daily', email: 'DAILY@EXAMPLE.COM', score: 9],
                weekly : [userId: 2, name: 'Weekly', email: 'WEEKLY@EXAMPLE.COM', score: 8],
                monthly: [userId: 3, name: 'Monthly', email: 'MONTHLY@EXAMPLE.COM', score: 7],
                alltime: [userId: 4, name: 'All Time', email: 'ALLTIME@EXAMPLE.COM', score: 6]
        ]

        service.metaClass.loadSiteStats = { ->
            [totalTasks: 10,
             completedTasks: 5,
             transcriberCount: 4,
             transcriptionCount: 11,
             institutionCount: 6,
             projectCount: 7,
             templates: 8,
             speciesTranscribed: 9,
             avgTranscriptionTime: 125,
             maxTranscriptionTime: 300]
        }
        service.metaClass.loadLeaderBoardStats = { Institution institution, String projectTempTable, boolean disableHonourBoard ->
            assert institution == null
            assert projectTempTable == null
            assert !disableHonourBoard
            leaderboard
        }

        when:
        def result = service.generateStats(-1L, null, null, false, false)

        then:
        result.totalTasks == 10
        result.completedTasks == 5
        result.percentageComplete == 50
        result.transcriberCount == 4
        result.transcriptionCount == 11
        result.institutionCount == 6
        result.projectCount == 7
        result.templates == 8
        result.speciesTranscribed == 9
        result.avgTranscriptionTime == 125
        result.avgTranscriptionTimeString == '2m 5s'
        result.avgTimeAsPercentOfMax == 40
        result.daily.name == 'Daily'
        result.daily.email == 'daily@example.com'.encodeAsMD5()
        result.weekly.email == 'weekly@example.com'.encodeAsMD5()
        result.monthly.email == 'monthly@example.com'.encodeAsMD5()
        result.alltime.email == 'alltime@example.com'.encodeAsMD5()
    }

    def "generateStats assembles institution stats and leaderboard data"() {
        given:
        def institution = new Institution(name: 'Test Institution', acronym: 'TI').save(validate: false, flush: true)
        def leaderboard = [
                daily  : [userId: 10, name: 'Daily', email: 'DAILY@EXAMPLE.COM', score: 9],
                weekly : [userId: 11, name: 'Weekly', email: 'WEEKLY@EXAMPLE.COM', score: 8],
                monthly: [userId: 12, name: 'Monthly', email: 'MONTHLY@EXAMPLE.COM', score: 7],
                alltime: [userId: 13, name: 'All Time', email: 'ALLTIME@EXAMPLE.COM', score: 6]
        ]

        service.metaClass.loadInstitutionStats = { Institution inst ->
            assert inst.id == institution.id
            [totalTasks: 20,
             completedTasks: 10,
             transcriberCount: 12,
             transcriptionCount: 14,
             institutionCount: 1,
             projectCount: 15,
             templates: 16,
             speciesTranscribed: 17,
             avgTranscriptionTime: 90,
             maxTranscriptionTime: 180]
        }
        service.metaClass.loadLeaderBoardStats = { Institution inst, String projectTempTable, boolean disableHonourBoard ->
            assert inst.id == institution.id
            assert projectTempTable == null
            assert !disableHonourBoard
            leaderboard
        }

        when:
        def result = service.generateStats(institution.id, null, null, false, false)

        then:
        result.totalTasks == 20
        result.completedTasks == 10
        result.percentageComplete == 50
        result.transcriberCount == 12
        result.transcriptionCount == 14
        result.institutionCount == 1
        result.projectCount == 15
        result.templates == 16
        result.speciesTranscribed == 17
        result.avgTranscriptionTime == 90
        result.avgTranscriptionTimeString == '1m 30s'
        result.avgTimeAsPercentOfMax == 50
        result.daily.email == 'daily@example.com'.encodeAsMD5()
        result.weekly.email == 'weekly@example.com'.encodeAsMD5()
        result.monthly.email == 'monthly@example.com'.encodeAsMD5()
        result.alltime.email == 'alltime@example.com'.encodeAsMD5()
    }

    def "generateStats assembles project-type stats using a session filter table"() {
        given:
        def leaderboard = [
                daily  : [userId: 21, name: 'Daily', email: 'DAILY@EXAMPLE.COM', score: 9],
                weekly : [userId: 22, name: 'Weekly', email: 'WEEKLY@EXAMPLE.COM', score: 8],
                monthly: [userId: 23, name: 'Monthly', email: 'MONTHLY@EXAMPLE.COM', score: 7],
                alltime: [userId: 24, name: 'All Time', email: 'ALLTIME@EXAMPLE.COM', score: 6]
        ]
        def capturedSessionId = null

        service.metaClass.getProjectsForLabels = { String sessionId, List<String> tags, String projectType ->
            capturedSessionId = sessionId
            assert tags == ['cameratraps']
            assert projectType == 'camera'
            [sessionId: sessionId, projectCount: 2]
        }
        service.metaClass.getStatsForProjects = { String sessionId, int projectCount ->
            assert sessionId == capturedSessionId
            assert projectCount == 2
            [totalTasks: 10,
             completedTasks: 6,
             transcriberCount: 4,
             transcriptionCount: 12,
             templates: 2,
             speciesTranscribed: 8,
             avgTranscriptionTime: 45,
             maxTranscriptionTime: 120,
             institutionCount: 1]
        }
        service.metaClass.loadLeaderBoardStats = { Institution institution, String sessionId, boolean disableHonourBoard ->
            assert institution == null
            assert sessionId == capturedSessionId
            assert !disableHonourBoard
            leaderboard
        }
        service.metaClass.cleanUpTables = { String sessionId ->
            assert sessionId == capturedSessionId
        }

        when:
        def result = service.generateStats(-1L, 'camera', ['cameratraps'], false, false)

        then:
        result.totalTasks == 10
        result.completedTasks == 6
        result.percentageComplete == 60
        result.transcriberCount == 4
        result.transcriptionCount == 12
        result.projectCount == 2
        result.templates == 2
        result.speciesTranscribed == 8
        result.avgTranscriptionTime == 45
        result.avgTranscriptionTimeString == '0m 45s'
        result.avgTimeAsPercentOfMax == 40
        result.daily.email == 'daily@example.com'.encodeAsMD5()
        result.weekly.email == 'weekly@example.com'.encodeAsMD5()
        result.monthly.email == 'monthly@example.com'.encodeAsMD5()
        result.alltime.email == 'alltime@example.com'.encodeAsMD5()
    }

    def "generateStats respects disabled stats and honour board flags"() {
        given:
        service.metaClass.loadDisabledStats = {
            [totalTasks: 0,
             completedTasks: 0,
             transcriberCount: 0,
             transcriptionCount: 0,
             institutionCount: 0,
             projectCount: 0,
             templates: 0,
             speciesTranscribed: 0,
             avgTranscriptionTime: 0,
             maxTranscriptionTime: 0]
        }
        service.metaClass.loadLeaderBoardStats = { Institution institution, String projectTempTable, boolean disableHonourBoard ->
            assert institution == null
            assert projectTempTable == null
            assert disableHonourBoard
            [daily: [userId: 0, name: '', email: '', score: 0],
             weekly: [userId: 0, name: '', email: '', score: 0],
             monthly: [userId: 0, name: '', email: '', score: 0],
             alltime: [userId: 0, name: '', email: '', score: 0]]
        }

        when:
        def result = service.generateStats(-1L, null, null, true, true)

        then:
        result.totalTasks == 0
        result.completedTasks == 0
        result.percentageComplete == 0
        result.avgTranscriptionTimeString == '0m 0s'
        result.avgTimeAsPercentOfMax == 0
        result.daily.name == ''
        result.weekly.score == 0
        result.monthly.email == ''.encodeAsMD5()
        result.alltime.userId == 0
    }

    def "getStatsForProjects gathers project type stats from async aggregate queries"() {
        given:
        def sessionId = 'session-123'
        def sql = new Object() {
            def firstRow(String query, Map params = [:]) {
                assert query.contains('stats_session_filter')
                assert params.sessionId == sessionId
                if (query.contains('task_count') && query.contains('transcribed_count')) return [task_count: 10, transcribed_count: 6]
                if (query.contains('transcription_count') && query.contains('transcriber_count')) return [transcription_count: 12, transcriber_count: 4]
                if (query.contains('avg_time') && query.contains('max_time')) return [avg_time: 45, max_time: 120]
                if (query.contains('template_count')) return [template_count: 2]
                if (query.contains('species_count')) return [species_count: 8]
                if (query.contains('institution_count')) return [institution_count: 1]
                throw new IllegalStateException("Unexpected query: ${query}")
            }

            def close() {
            }
        }

        service.metaClass.runConcurrentTasks = { Map<String, Closure> operations ->
            operations.collectEntries { key, work -> [(key): work.call()] }
        }
        service.metaClass.withSql = { Closure work ->
            work.call(sql)
        }

        when:
        def result = service.getStatsForProjects(sessionId, 2)

        then:
        result.totalTasks == 10
        result.completedTasks == 6
        result.transcriberCount == 4
        result.transcriptionCount == 12
        result.projectCount == 2
        result.templates == 2
        result.speciesTranscribed == 8
        result.avgTranscriptionTime == 45
        result.maxTranscriptionTime == 120
        result.institutionCount == 1
        result.projectsInLabels == []
        result.projectTempTable == 'stats_session_filter'
    }

    def "buildMultiParamSearchClause repeats each field for every tag value"() {
        given:
        def method = VolunteerStatsService.getDeclaredMethod('buildMultiParamSearchClause', List, List, String)
        method.accessible = true

        when:
        def result = method.invoke(service, ['institution.name', 'project.name'], ['cameratraps', 'bush'], 'tag')

        then:
        result.clause == '(institution.name ilike :tag0 or institution.name ilike :tag1 or project.name ilike :tag0 or project.name ilike :tag1)'
        result.params == [tag0: '%cameratraps%', tag1: '%bush%']
    }

}



