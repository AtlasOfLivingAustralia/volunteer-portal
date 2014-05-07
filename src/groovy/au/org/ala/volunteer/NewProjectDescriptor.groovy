package au.org.ala.volunteer

class NewProjectDescriptor implements Serializable {

    String stagingId
    String name
    String shortDescription
    String longDescription
    long templateId
    long projectTypeId

    String imageCopyright
    boolean showMap
    int mapInitZoomLevel
    double mapInitLatitude
    double mapInitLongitude

}
