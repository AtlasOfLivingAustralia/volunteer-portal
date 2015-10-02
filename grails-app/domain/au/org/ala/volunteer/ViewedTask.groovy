package au.org.ala.volunteer

class ViewedTask implements Serializable {

  String userId
  Task task
  Integer numberOfViews = 0
  Date dateCreated
  Date lastUpdated
  Long lastView

  static mapping = {
    version false
    task index:'viewed_task_task_id_idx'
  }

  static constraints = {
    userId nullable: true
    task nullable: true
    numberOfViews nullable: true
    dateCreated nullable: true
    lastUpdated nullable: true
    lastView nullable: true
  }
}
