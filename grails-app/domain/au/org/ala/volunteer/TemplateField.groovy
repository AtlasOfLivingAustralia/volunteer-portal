package au.org.ala.volunteer

class TemplateField {

  String dataType
  String defaultValue
  Boolean mandatory
  Boolean multiValue
  String name
  Template template

  static mapping = {
    version false
  }

  static constraints = {
    dataType nullable: true, maxSize: 200
    defaultValue maxSize: 200
    mandatory nullable: true
    multiValue nullable: true
    name maxSize: 200
    template nullable: true
  }
}
