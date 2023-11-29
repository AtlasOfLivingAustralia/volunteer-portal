package au.org.ala.volunteer

import grails.converters.JSON

class LeaderBoardController {

    def userService
    def settingsService
    def leaderBoardService

    def leaderBoardFragment() {
        def institutionInstance = Institution.get(params.int("institutionId"))

        def legendName = institutionInstance ? institutionInstance.acronym : message(code:'default.application.name')
        def leaderBoardSections = [
            [category: LeaderBoardCategory.daily, label:'Day Tripper'],
            [category: LeaderBoardCategory.weekly, label:'Weekly Wonder'],
            [category: LeaderBoardCategory.monthly, label:'Monthly Maestro'],
            [category: LeaderBoardCategory.alltime, label:"${legendName} Legend"]
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
        log.debug("Leaderboard top list")

        leaderBoardService.topList(category, institution)
    }

    def describeBadges() {
        respond [:], model: [badges: AchievementDescription.findAllByEnabled(true, [sort: 'name'])]
    }

}

