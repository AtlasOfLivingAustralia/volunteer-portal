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
  
  def showNextAction = {
      println("rendering view: nextAction")
      render(view:'nextAction')
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
      render(view:'noTasks')
    }
  }

  /**
   * Sync fields.
   * TODO record validation using the template information. Hoping some data validation
   *
   * done in the form.
   */
  def save = {
    def currentUser = authService.username()
    if(currentUser!=null){
      def taskInstance = Task.get(params.id)
      fieldSyncService.syncFields(taskInstance, params.recordValues, currentUser)
      taskInstance.fullyTranscribedBy = currentUser
      //reset the fully validated flag
      taskInstance.fullyValidatedBy = null
      taskInstance.save(flush:true)
      //update the users stats
      userService.updateUserTranscribedCount(currentUser)
      userService.updateUserValidatedCount(currentUser)
      redirect(action:'showNextAction') // showNextFromAny
    } else {
      redirect(view:'../index')
    }
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
    } else {
      redirect(view:'/index')
    }
  }

  /**
   * Show the next task for the supplied project.
   */
  def showNextFromProject = {
    def currentUser = authService.username()
    def project = Project.get(params.id)

    def taskInstance = taskService.getNextTask(currentUser, project)

    //retrieve the details of the template
    if(taskInstance){
      redirect(action: 'task', id:taskInstance.id)
    } else {
      render(view:'noTasks')
    }
  }
}