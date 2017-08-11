package au.org.ala.volunteer

import grails.converters.JSON

class LeaderBoardController {

    def userService
    def settingsService
    def leaderBoardService

    def leaderBoardFragment() {
        def institutionInstance = Institution.get(params.int("institutionId"))

        def legendName = institutionInstance ? institutionInstance.i18nAcronym : message(code:'default.application.name')
        def leaderBoardSections = [
            [category: LeaderBoardCategory.daily, label: message(code: 'daily.leader.label')],
            [category: LeaderBoardCategory.weekly, label:message(code: 'weekly.leader.label')],
            [category: LeaderBoardCategory.monthly, label:message(code: 'monthly.leader.label')],
            [category: LeaderBoardCategory.alltime, label:message(code: 'alltime.leader.label')]
        ]

        [leaderBoardSections : leaderBoardSections, institutionInstance: institutionInstance ]
    }

    def ajaxLeaderBoardCategoryWinner() {
        def category = params.category as LeaderBoardCategory
        def institution = Institution.get(params.int("institutionId"))

        def result = leaderBoardService.winner(category, institution)

        render(result as JSON)
    }

    def topList() {

        def category = params.category as LeaderBoardCategory

        def institution = Institution.get(params.int("institutionId"))

        leaderBoardService.topList(category, institution)
    }

    def describeBadges() {
        respond [:], model: [badges: AchievementDescription.findAllByEnabled(true, [sort: 'name'])]
    }

}

