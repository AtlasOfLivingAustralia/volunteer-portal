package au.org.ala.volunteer

class CollectionEvent {

    String eventDate
    String collector
    String locality
    String state
    String country
    String township
    String latitudeDMS
    String longitudeDMS
    Double latitude
    Double longitude
    Long externalEventId
    Long externalLocalityId
    String institutionCode
    String collectorNormalised

    static constraints = {
        township nullable: true
        state nullable:  true
        country nullable:  true
        latitude nullable: true
        longitude nullable: true
        externalEventId nullable: true
        externalLocalityId nullable: true
        collectorNormalised nullable: true
        institutionCode nullable: true;
    }

    static mapping = {
        eventDate column: 'Event_Date', index: 'Event_Date_idx'
        collector column: 'Collector', index: 'Collector_idx'
        institutionCode column: 'Institution', index: 'Institution_Code_idx'
    }
}
