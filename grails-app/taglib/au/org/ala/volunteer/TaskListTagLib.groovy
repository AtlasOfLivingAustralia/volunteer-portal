package au.org.ala.volunteer

import groovy.time.TimeCategory

class TaskListTagLib {

  def grailsApplication

  def renderTaskList = { attrs, body ->

    def tasks = attrs.taskInstanceList
    int taskIndex = 0
    out << """<table class="taskTable">"""
    use(TimeCategory){
      for(taskInstance in tasks){

        Date lastUpdated = null
        if(taskInstance.viewedTasks){
            // TODO: wtf?
          lastUpdated = taskInstance.viewedTasks?.lastUpdated?.sort().get(0)
        }
        boolean addLink = (taskInstance.fullyTranscribedBy==null && (lastUpdated==null || lastUpdated.before(30.minutes.from.now)))
        if(taskIndex.mod(attrs.noOfColumns.asType(Integer.class)) == 0){
          if(taskIndex>0)
            out << """</tr>"""
          out << """<tr>"""
        }

        out << """<td class="${addLink ? 'editable task': 'task'}">"""
        if(addLink){
          out << """<a href="${createLink(uri: '/transcribe/task/'+taskInstance.id)}">"""
        }

        def imgUrl = grailsApplication.config.server.url + taskInstance?.multimedia?.filePathToThumbnail?.iterator().next()
        out << """<img src="${imgUrl}" class="taskListImg" />"""

        if(addLink){
          out << """</a>"""
        }

        out << """<p>"""
        out << """Task ID: ${taskInstance.id} </br/>"""
        if(taskInstance.fullyTranscribedBy){
          out << """Transcriber:&nbsp;${taskInstance.fullyTranscribedBy.replace("@", "...")} </br/>"""
        }
        if(lastUpdated!=null){
          out << """Last viewed: ${prettytime.display (date: lastUpdated) } </br/>"""
        }
        if(addLink){
          out << """<a href="${createLink(uri: '/transcribe/task/'+taskInstance.id)}">Transcribe</a>"""
        } else {
          out << """<span>Status: complete</span>"""
        }


        out << """</p>"""
        out << """</td>"""
        taskIndex++
      }
      out << """</tr>"""
      out << """</table>"""
    }

  }
}
