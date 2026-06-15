package au.org.ala.volunteer

import groovy.transform.ToString

@ToString
class Multimedia implements Serializable {
  static belongsTo = [task:Task]
  //Task task
  String filePath
  String filePathToThumbnail
  String licence
  String mimeType
  Date created
  String creator

  static mapping = {
    cache true
    version false
    task index: 'multimedia_task_idx'
  }

  static constraints = {
    created nullable: true
    creator nullable: true, maxSize: 200
    filePath nullable: true, maxSize: 200
    filePathToThumbnail nullable: true, maxSize: 200
    licence nullable: true, maxSize: 200
    mimeType nullable: true, maxSize: 50
    task nullable: true
  }

  String toString() {
    // Multiline string for better readability in logs, especially when there are multiple multimedia items associated with a task.
    StringBuilder sb = new StringBuilder()
    sb.append("Multimedia [\n")
    sb.append("  id: ${id},\n")
    sb.append("  filePath: ${filePath},\n")
    sb.append("  filePathToThumbnail: ${filePathToThumbnail},\n")
    sb.append("]")
    return sb.toString()
  }
}
