package au.org.ala.volunteer

class AchievementAward {

    Date awarded
    boolean userNotified = false
    
    static belongsTo = [achievement: AchievementDescription, user: User]

    Long version
    
    Date dateCreated
    Date lastUpdated
    
    static constraints = {
    }

    public String toString() {
        "AchievementAward (${achievement}, ${user}, awarded: ${awarded}, userNotified: ${userNotified})"
    }
}
