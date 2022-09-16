package au.org.ala.volunteer

import grails.gorm.async.AsyncEntity

class Field implements Serializable, AsyncEntity<Field> {

  String name
  String value
  Integer recordIdx
  String transcribedByUserId
  String validatedByUserId
  Boolean superceded = false
  Date created = new Date()
  Date updated = new Date()

  static belongsTo = [task: Task, transcription: Transcription]

  static mapping = {
    version false
    name index: 'field_name_index_superceeded_task_idx'
    recordIdx index: 'field_name_index_superceeded_task_idx'
    superceded index: 'field_name_index_superceeded_task_idx,field_task_superceded_idx,field_transcribed_by_user_id_superceded_idx'
    task index: 'field_name_index_superceeded_task_idx,field_task_superceded_idx'
    transcription index: 'field_transcription_id'
    name index: 'fieldnameidx'
    updated index: 'fieldupdatedidx'
    transcribedByUserId index: 'field_transcribed_by_user_id_superceded_idx'
  }

  static constraints = {
    task nullable: true
    transcription nullable: true
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
  // Fields are only deleted when a task is deleted so there is no
  // need to push an task update event on delete here


  @Override
  public String toString() {
    return "Field{" +
            "id: " + id +
            ", task: " + task?.id +
            ", transcription: " + transcription?.id +
            ", name: '" + name + '\'' +
            ", value: '" + value + '\'' +
            ", recordIdx: " + recordIdx +
            ", transcribedByUserId: '" + transcribedByUserId + '\'' +
            ", validatedByUserId: '" + validatedByUserId + '\'' +
            ", superceded: " + superceded +
            ", created: " + created +
            ", updated: " + updated +
            '}';
  }
}
