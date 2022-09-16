package au.org.ala.volunteer

import grails.gorm.async.AsyncEntity

class Transcription implements Serializable, AsyncEntity<Transcription> {

    Long id
  //  Long taskId
    String fullyTranscribedBy
    Date dateFullyTranscribed
    String fullyTranscribedIpAddress
    UUID transcribedUUID // unique id for the transcription
    UUID validatedUUID
    String fullyValidatedBy
    Date dateFullyValidated
    Integer timeToTranscribe
    Integer timeToValidate

    void recordTranscriptionTime(int timeInSeconds) {
        timeToTranscribe = (timeToTranscribe ?: 0) + timeInSeconds
    }

    static belongsTo = [task:Task, project: Project]
    static hasMany = [fields:Field]

    static constraints = {
        task nullable: false
        fullyTranscribedBy nullable: true
        dateFullyTranscribed nullable: true
        fullyTranscribedIpAddress nullable: true
        transcribedUUID nullable: true
        validatedUUID nullable: true
        timeToTranscribe nullable: true
        timeToValidate nullable: true
        dateFullyValidated nullable: true
        fullyValidatedBy nullable: true
    }

    static mapping = {
        task lazy: false, index: 'transcription_task,transcription_task_project'
        project lazy: false, index: 'transcription_project'
        transcribedUUID type: 'pg-uuid'
        validatedUUID type: 'pg-uuid'
    }

    def afterInsert() {
//        GormEventDebouncer.debounceDeleteTask(this.task.id)
        GormEventDebouncer.debounceTask(this.task.id)
    }
    // Executed after an object has been updated
    def afterUpdate() {
        GormEventDebouncer.debounceDeleteTask(this.task.id)
        GormEventDebouncer.debounceTask(this.task.id)
    }

    // Executed after an object has been deleted
    def afterDelete() {
        GormEventDebouncer.debounceDeleteTask(this.task.id)
        GormEventDebouncer.debounceTask(this.task.id)
    }
}