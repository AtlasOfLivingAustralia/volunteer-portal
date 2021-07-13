package au.org.ala.volunteer

class FrontPage {

    Project projectOfTheDay
    Boolean randomProjectOfTheDay = false
    Date randomProjectDateUpdated
    Integer numberOfContributors = 10
    Boolean useGlobalNewsItem = false
    
    String newsTitle
    String newsBody
    Date newsCreated
    Boolean showAchievements = false
    Boolean enableTaskComments = false
    Boolean enableForum = false

    String heroImage
    String heroImageAttribution

    String systemMessage

    static mapping = {
        numberOfContributors defaultValue: '10'
        randomProjectOfTheDay column: 'random_project_otd', defaultValue: false
    }

    static constraints = {
        newsTitle nullable: true, maxSize: 100
        newsBody nullable: true, maxSize: 1024
        newsCreated nullable: true
        systemMessage nullable:  true
        showAchievements nullable: true
        enableTaskComments nullable:  true
        enableForum nullable: true
        projectOfTheDay nullable: true
        numberOfContributors nullable: false, min: 0, max: 20
        heroImage nullable: true
        heroImageAttribution nullable: true
        randomProjectOfTheDay nullable: false
        randomProjectDateUpdated nullable: true
    }

    static FrontPage instance() {
        return list().first();
    }

}
