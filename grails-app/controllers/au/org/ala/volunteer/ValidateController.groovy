package au.org.ala.volunteer

class ValidateController {

  def fieldSyncService
  def taskService

  def index = {
    redirect(action: "validateTask")
  }

  def task = {

    def taskInstance = Task.get(params.id)

    //retrieve the existing values
    Map recordValues = fieldSyncService.retrieveFieldsForTask(taskInstance)

    render(view:'../transcribe/specimenTranscribe',  model:[taskInstance:taskInstance, recordValues: recordValues, validator: true])
  }

  def validateTask = {

    //need to check the user has sufficient privileges at a project level
    def taskInstance = taskService.getNextTaskForValidation()
    if(taskInstance!=null){
       redirect(action: 'task', id:taskInstance.id)
    }
  }

  def list = {
    params.max = Math.min(params.max ? params.int('max') : 10, 100)
    def tasks = Task.findAllByFullyTranscribedAndFullyValidated(true, false, params)
    [tasks: tasks]
  }

  def listForProject = {

    //Task.findAllByProjectAndFullyTranscribed(true, false)
    def tasks = Task.executeQuery("select t from Task t " +
         "where t.project = :project and t.fullyTranscribed = true and t.fullValidated = true",
        project:project)

    [tasks: tasks]
  }

}
