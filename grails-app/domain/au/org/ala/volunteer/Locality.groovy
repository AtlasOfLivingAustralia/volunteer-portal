package au.org.ala.volunteer

class Locality {

    String institutionCode
    Long externalLocalityId
    String country
    String state
    String township
    String locality
    String latitudeDMS
    String longitudeDMS
    Double latitude
    Double longitude

    static constraints = {
        country nullable: true
        state nullable:  true
        township nullable: true
        locality nullable: true
        latitude nullable: true
        longitude nullable: true
        latitudeDMS nullable: true
        longitudeDMS nullable: true
        externalLocalityId nullable: true
    }

}
