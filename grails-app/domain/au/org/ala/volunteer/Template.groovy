package au.org.ala.volunteer

class Template {

  String name
  String viewName
  String fieldOrder // JSON encoded list

  String author
  Date created

  static mapping = {
    version false
  }

  static constraints = {
    author maxSize: 200, email:true
    created maxSize: 19
    name maxSize: 200
    viewName nullable: true
  }
}
