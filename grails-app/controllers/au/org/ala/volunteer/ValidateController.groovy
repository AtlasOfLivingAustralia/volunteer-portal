package au.org.ala.volunteer

class ValidateController {

  def fieldSyncService
  def taskService
  def authService
  def userService

  def index = {
    redirect(action: "showNextTaskForValidation")
  }

  def task = {
    def taskInstance = Task.get(params.id)
    //retrieve the existing values
    Map recordValues = fieldSyncService.retrieveFieldsForTask(taskInstance)
    render(view:'../transcribe/specimenTranscribe',  model:[taskInstance:taskInstance, recordValues: recordValues, validator: true])
  }

  /**
   * Mark a task as validated, hence removing it from the list of tasks to be validated.
   */
  def validate = {
    def currentUser = authService.username()
    if(currentUser!=null){
      def taskInstance = Task.get(params.id)
      fieldSyncService.syncFields(taskInstance, params.recordValues, currentUser)
      taskInstance.fullyValidatedBy = currentUser
      taskInstance.save(flush:true)
      //update the count for validated tasks for the user who transcribed
      userService.updateUserValidatedCount(taskInstance.fullyTranscribedBy)
      redirect(view:'showNextFromAny')
    } else {
      redirect(view:'../index')
    }
  }

  def showNextTaskForValidation = {
    //need to check the user has sufficient privileges at a project level
    def taskInstance = taskService.getNextTaskForValidation()
    if(taskInstance!=null){
       redirect(action: 'task', id:taskInstance.id)
    } else {
        render(view:'noTasks')
    }
  }

  def list = {
    params.max = Math.min(params.max ? params.int('max') : 10, 100)
    def tasks = Task.findAllByFullyTranscribedByIsNotNull(params)
    def taskInstanceTotal = Task.countByFullyTranscribedByIsNotNull()
    render(view:'../task/list',model:[tasks: tasks, taskInstanceTotal:taskInstanceTotal])
  }

  def listForProject = {
    def projectInstance = Task.get(params.id)
    def tasks = Task.executeQuery(""""select t from Task t
         where t.project = :project and t.fullyTranscribedBy is not null""",
        project:projectInstance)
    render(view:'../task/list',  model:[tasks:tasks,project:projectInstance])
  }
}
