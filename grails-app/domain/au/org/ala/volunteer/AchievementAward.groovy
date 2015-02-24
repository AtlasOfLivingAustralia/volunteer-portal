package au.org.ala.volunteer

class AchievementAward {

    Date awarded
    
    static belongsTo = [achievement: AchievementDescription, user: User]

    Long version
    
    Date dateCreated
    Date lastUpdated
    
    static constraints = {
    }
}
