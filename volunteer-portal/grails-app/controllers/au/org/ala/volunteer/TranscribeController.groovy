package au.org.ala.volunteer

import org.springframework.validation.Errors

class TranscribeController {

  def fieldSyncService
  def auditService
  def taskService
  def authService
  def userService

  static allowedMethods = [saveTranscription: "POST"]

  def index = {
      if (params.id) {
          redirect(action: "showNextFromProject", params: params)
      } else {
          redirect(action: "showNextFromAny", params: params)
      }

  }

  def task = {

    def taskInstance = Task.get(params.id)
    def currentUser = authService.username()
    userService.registerCurrentUser()

    if(taskInstance){
      //record the viewing of the task
      auditService.auditTaskViewing(taskInstance, currentUser)
      def project = Project.findById(taskInstance.project.id)
      def template = Template.findById(project.template.id)
      def isReadonly

      if (taskInstance.fullyTranscribedBy && taskInstance.fullyTranscribedBy != currentUser) {
        isReadonly = "readonly"
      }

      //retrieve the existing values
      Map recordValues = fieldSyncService.retrieveFieldsForTask(taskInstance)
      render(view:template.viewName,  model:[taskInstance:taskInstance, recordValues: recordValues, isReadonly: isReadonly])
    } else {
      redirect(view:'list', controller: "task")
    }
  }
  
  def showNextAction = {
      println("rendering view: nextAction")
      def taskInstance = Task.get(params.id)
      render(view:'nextAction', model:[id:params.id, taskInstance: taskInstance, userId: authService.username()])
  }

  /**
   * Retrieve the next un-transcribed record from any project, but supply one I havent seen,
   * or the least recently seen record.
   */
  def showNextFromAny = {

    def currentUser = authService.username()
    //println "current user = "+currentUser
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
      def project = Project.findById(taskInstance.project.id)
      def template = Template.findById(project.template.id)

      fieldSyncService.syncFields(taskInstance, params.recordValues, currentUser, true, false)
      if (!taskInstance.hasErrors()) {
          redirect(action:'showNextAction', id:params.id)
      }
      else {
          render(view:template.viewName,  model:[taskInstance:taskInstance, recordValues: params.recordValues])
      }
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
      fieldSyncService.syncFields(taskInstance, params.recordValues, currentUser, false, false)
      redirect(action:'showNextAction', id:params.id)
    } else {
      redirect(view:'/index')
    }
  }

    def savePartial2 = {
        redirect(action:'savePartial', id:params.id)
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