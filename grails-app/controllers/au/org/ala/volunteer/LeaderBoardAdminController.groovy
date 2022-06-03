package au.org.ala.volunteer

import au.org.ala.web.AlaSecured
import grails.converters.JSON
import grails.gorm.transactions.Transactional

@AlaSecured(value="ROLE_VP_ADMIN", redirectController = "index", redirectAction="notPermitted")
class LeaderBoardAdminController {

    def settingsService
    def userService
    def authService
    
    def index() {
        def ids = settingsService.getSetting(SettingDefinition.IneligibleLeaderBoardUsers)
        [users: ids ? userService.detailsForUserIds(ids) : []]
    }

    def findEligibleUsers(String term) {
        // todo search Atlas User Details
        def ineligible = settingsService.getSetting(SettingDefinition.IneligibleLeaderBoardUsers) ?: []
        def search = "%${term}%"
        def users = User.withCriteria {
            or {
                ilike 'displayName', search
                ilike 'email', search
            }
            if (ineligible) {
                not {
                    inList 'userId', ineligible
                }
            }
            maxResults 20
            order "displayName", "desc"
        }

        render users as JSON
    }

    def addIneligibleUser(int id) {
        def newSetting = settingsService.getSetting(SettingDefinition.IneligibleLeaderBoardUsers) + (Integer.toString(id))
        log.debug("Setting ineligible leaderboard users to {}", newSetting)
        settingsService.setSetting(SettingDefinition.IneligibleLeaderBoardUsers.key, newSetting)
        render status: 204
    }

    def removeIneligibleUser(int id) {
        def newSetting = settingsService.getSetting(SettingDefinition.IneligibleLeaderBoardUsers) - (Integer.toString(id))
        log.debug("Setting ineligible leaderboard users to {}", newSetting)
        settingsService.setSetting(SettingDefinition.IneligibleLeaderBoardUsers.key, newSetting)
        render status: 204
    }
}
