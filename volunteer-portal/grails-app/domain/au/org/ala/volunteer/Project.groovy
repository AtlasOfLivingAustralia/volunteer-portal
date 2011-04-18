package au.org.ala.volunteer

class Project {

  String name
  String description
  Template template
  Date created

  static hasMany = [tasks:Task, projectAssociations:ProjectAssociation]

  static mapping = {
    version false
  }

  static constraints = {
    name maxSize: 200
    description nullable: true
    template nullable: true
    created nullable: true
  }
}
