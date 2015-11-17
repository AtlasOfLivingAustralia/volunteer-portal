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
    version false
  }

  static constraints = {
    created maxSize: 19, nullable: true
    creator nullable: true, maxSize: 200
    filePath nullable: true, maxSize: 200
    filePathToThumbnail nullable: true, maxSize: 200
    licence nullable: true, maxSize: 200
    mimeType nullable: true, maxSize: 50
    task nullable: true
  }
}
