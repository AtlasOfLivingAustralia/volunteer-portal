package au.org.ala.volunteer

public class TaskDescriptor {

    Project project
    String externalIdentifier
    String imageUrl
    ArrayList<Map> fields = new ArrayList<Map>()

}

public class TaskLoadStatus {
    TaskDescriptor taskDescriptor
    boolean succeeded
    Date time
    String message
}
