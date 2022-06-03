package au.org.ala.volunteer

class UserOptOut {

    User user
    Date dateCreated

    static mapping = {
        table 'message_user_optout'
        version false
    }

    static constraints = {
        user nullable: false
        dateCreated nullable: false
    }


    @Override
    public String toString() {
        return "UserOptOut{" +
                "user=" + user +
                ", dateCreated=" + dateCreated +
                '}';
    }
}
