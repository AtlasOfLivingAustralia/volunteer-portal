package au.org.ala.volunteer

class Project {

  String name
  String description
  //Template template
  Date created

  static belongsTo = [template: Template]
  static hasMany = [tasks:Task, projectAssociations:ProjectAssociation]

  static mapping = {
    version false
    tasks cascade:'all-delete-orphan'
    projectAssociations cascade:'all-delete-orphan'
    template lazy:false
  }

  static constraints = {
    name maxSize: 200
    description nullable: true
    template nullable: true
    created nullable: true
  }
}
