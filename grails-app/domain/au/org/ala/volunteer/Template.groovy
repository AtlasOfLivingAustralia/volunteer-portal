package au.org.ala.volunteer

class Template {

  String name
  String viewName  //this should be the GSP in use for this template
  String fieldOrder // JSON encoded list
  String author

  static mapping = {
    version false
  }

  static constraints = {
    author maxSize: 200, email:true, nullable: true
    name maxSize: 200
    viewName nullable: true
  }
}
