package au.org.ala.volunteer

public class TaskDescriptor {

    long projectId
    String projectName
    String externalIdentifier
    String imageUrl
    ArrayList<Map> fields = new ArrayList<Map>()
    ArrayList<MediaLoadDescriptor> media = new ArrayList<MediaLoadDescriptor>();
    Closure afterLoad

    @Override
    String toString() {
        "{ project.name:'$projectName', externalIdentifier:'$externalIdentifier', imageUrl:$imageUrl }"
    }
}

public class MediaLoadDescriptor {
    String mediaUrl
    String mimeType
    Closure afterDownload
}

public class TaskLoadStatus {
    TaskDescriptor taskDescriptor
    boolean succeeded
    Date time
    String message
}
