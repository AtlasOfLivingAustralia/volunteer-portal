package au.org.ala.volunteer

class Setting {

    String key
    String value
    String comments

    static constraints = {
        key nullable: false
        value nullable: true
        comments nullable: true
    }

}
