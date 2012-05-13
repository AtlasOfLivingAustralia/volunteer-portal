package au.org.ala.volunteer

class Achievement {

    User user
    String name
    Date dateAchieved

    static constraints = {
        dateAchieved nullable: true
    }

}
