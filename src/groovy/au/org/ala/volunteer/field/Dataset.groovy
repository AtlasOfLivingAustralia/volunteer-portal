package au.org.ala.volunteer.field

enum Dataset {
    catalogNumber("Catalog Number"), 
    institution("Institution"), 
    eventDate("Event Date"), 
    recordedBy("Collector"),
    typeStatus("Type Status")

    def label
    Dataset(label) { this.label = label }
}

enum Location {
    verbatimLocality("Verbatim Locality"),
    locationRemarks("Location Remarks"),
    verbatimLatitude("Verbatim Latitude"),
    verbatimLongitude("Verbatim Longitude"),
    country("Country"),
    //countryCode("Country Code"),
    stateProvince("State"),
    locality("Locality"),
    decimalLatitude("Decimal Latitude"),
    decimalLongitude("Decimal Longitude"),
    coordinatePrecision("Coordinate Precision")
    

    def label
    Location(label) { this.label = label }
}

enum Identification {
    scientificName("Scientific Name"),
    taxonConceptID("Taxon Concept ID"),
    scientificNameAuthorship("Authorship"),
    identifiedBy("Identified By"),
    dateIdentified("Date Identified"),
    identificationRemarks("Identification Remarks")

    def label
    Identification(label) { this.label = label }
}

