package au.org.ala.volunteer

class Field implements Serializable {

  static belongsTo = [task:Task]

  String name
  String value
  Integer recordIdx
  String transcribedByUserId
  String validatedByUserId
  boolean superceded = false
  Date created = new Date()
  Date updated = new Date()

  static mapping = {
    version false
    name index: 'field_name_index_superceeded_task_idx'
    recordIdx index: 'field_name_index_superceeded_task_idx'
    superceded index: 'field_name_index_superceeded_task_idx,field_task_superceded_idx,field_transcribed_by_user_id_superceded_idx'
    task index: 'field_name_index_superceeded_task_idx,field_task_superceded_idx'
    name index: 'fieldnameidx'
    updated index: 'fieldupdatedidx'
    transcribedByUserId index: 'field_transcribed_by_user_id_superceded_idx'
  }

  static constraints = {
    task nullable: true
    name maxSize: 200
    value type:'text'
    recordIdx nullable: true
    transcribedByUserId maxSize: 200
    validatedByUserId nullable: true, maxSize: 200
    value nullable: true
    superceded nullable: true
  }

  // These events use a static method rather than an injected service
  // to prevent issues with serialisation in webflows
    
  // Executed after an object is persisted to the database
  def afterInsert() {
    def taskId = this.task?.id
    if (taskId) GormEventDebouncer.debounceTask(taskId)
  }
  // Executed after an object has been updated
  def afterUpdate() {
    def taskId = this.task?.id
    if (taskId) GormEventDebouncer.debounceTask(taskId)
  }
  // Executed after an object has been deleted
  def afterDelete() {
    def taskId = this.task?.id
    if (taskId) GormEventDebouncer.debounceTask(taskId)
  }
}
