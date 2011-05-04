package au.org.ala.volunteer

class TranscribeController {

  def fieldSyncService
  def auditService
  def taskService
  def authService
  def userService

  static allowedMethods = [saveTranscription: "POST"]

  def index = {
    redirect(action: "showNextFromAny", params: params)
  }

  def showBreakdown = {

    //retrieve counts of transcribed records by project

    //retrieve counts of transcribed records by user

    //retrieve counts of transcribed & validated records by project

    //retrieve counts of transcribed & validated records by user
  }

  def task = {

    def taskInstance = Task.get(params.id)
    def currentUser = authService.username()
    userService.registerCurrentUser()

    if(taskInstance){
      //record the viewing of the task
      auditService.auditTaskViewing(taskInstance, currentUser)

      println(authService.username())

      //retrieve the existing values
      Map recordValues = fieldSyncService.retrieveFieldsForTask(taskInstance)
      render(view:'specimenTranscribe',  model:[taskInstance:taskInstance, recordValues: recordValues])
    } else {
      redirect(view:'list', controller: "task")
    }
  }

  /**
   * Retrieve the next un-transcribed record from any project, but supply one I havent seen,
   * or the least recently seen record.
   */
  def showNextFromAny = {

    def currentUser = authService.username()
    def taskInstance = taskService.getNextTask(currentUser)

    //retrieve the details of the template
    if(taskInstance){
      redirect(action: 'task', id:taskInstance.id)
    } else {
      //TODO retrieve this information from the template
      render(view:'specimenTranscribe')
    }
  }

  /**
   * Sync fields.
   *
   * TODO handle multiple records per submit.
   * TODO record validation using the template information. Hoping some data validation
   * done in the form.
   */
  def save = {
    def currentUser = authService.username()
    def taskInstance = Task.get(params.id)
    fieldSyncService.syncFields(taskInstance, params.recordValues, currentUser)
    taskInstance.fullyTranscribed = true
    taskInstance.save(flush:true)
    redirect(view:'showNextFromAny')
  }

  /**
   * Sync fields.
   *
   * TODO handle multiple records per submit.
   */
  def savePartial = {
    def currentUser = authService.username()
    if(currentUser){
      def taskInstance = Task.get(params.id)
      fieldSyncService.syncFields(taskInstance, params.recordValues, currentUser)
      redirect(view:'showNextFromAny')
    }
  }

  def showNextFromProject = {
    //retrieve the next un-transcribed record from the project with the supplied ID


  }
}