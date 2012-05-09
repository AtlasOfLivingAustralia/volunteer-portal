package au.org.ala.volunteer

class FrontPage {

    Project projectOfTheDay    
    Project featuredProject1
    Project featuredProject2
    Project featuredProject3
    
    Boolean useGlobalNewsItem = false
    
    String newsTitle
    String newsBody
    Date newsCreated

    String systemMessage

    static constraints = {
        newsTitle nullable: true, maxSize: 100
        newsBody nullable: true, maxSize: 255
        newsCreated nullable: true
        systemMessage nullable:  true
    }

    static FrontPage instance() {
        return FrontPage.list()[0];
    }

}
