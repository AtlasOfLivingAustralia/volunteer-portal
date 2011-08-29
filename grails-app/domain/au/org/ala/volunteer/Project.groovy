package au.org.ala.volunteer

class Project {

  String name
  String description
  //Template template
  Date created

  static belongsTo = [template: Template]
  static hasMany = [tasks:Task, projectAssociations:ProjectAssociation, newsItems: NewsItem]

  static mapping = {
    version false
    tasks cascade:'all-delete-orphan'
    projectAssociations cascade:'all-delete-orphan'
    template lazy:false
    newsItems sort: 'created', order: 'desc'
  }

  static constraints = {
    name maxSize: 200
    description nullable: true, maxSize: 2000, widget:'textarea'
    template nullable: true
    created nullable: true
  }
}
