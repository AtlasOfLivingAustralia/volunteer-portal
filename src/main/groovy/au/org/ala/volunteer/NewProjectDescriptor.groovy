package au.org.ala.volunteer

import groovy.transform.ToString

@ToString
class NewProjectDescriptor implements Serializable {

    String featuredOwner
    Long featuredOwnerId
    String stagingId
    String name
    String shortDescription
    String longDescription
    long templateId
    long projectTypeId

    String imageCopyright
    String backgroundImageCopyright
    boolean showMap
    int mapInitZoomLevel
    double mapInitLatitude
    double mapInitLongitude

    String picklistId
    List<Long> labelIds = []
    String tutorialLinks

    String createdBy

    static NewProjectDescriptor fromJson(String s, def p) {
        new NewProjectDescriptor(
                stagingId: s,
                featuredOwner: p.featuredOwner.name,
                featuredOwnerId: p.featuredOwner.id,
                name: p.name,
                shortDescription: p.shortDescription,
                longDescription: p.longDescription,
                templateId: p.templateId,
                projectTypeId: p.projectTypeId,
                imageCopyright: p.imageCopyright,
                backgroundImageCopyright: p.backgroundImageCopyright,
                showMap: p.showMap,
                mapInitLatitude: p.map.centre.latitude,
                mapInitLongitude: p.map.centre.longitude,
                mapInitZoomLevel: p.map.zoom,
                picklistId: p.picklistId,
                labelIds: p.labelIds,
                tutorialLinks: p.tutorialLinks,
                createdBy: p.createdBy
        )
    }
}
