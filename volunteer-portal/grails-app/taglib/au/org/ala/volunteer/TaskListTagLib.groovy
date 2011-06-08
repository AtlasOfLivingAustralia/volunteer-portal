package au.org.ala.volunteer

import groovy.time.TimeCategory
import org.codehaus.groovy.grails.commons.ConfigurationHolder

class TaskListTagLib {

  def renderTaskList = { attrs, body ->

    def tasks = attrs.taskInstanceList
    int taskIndex = 0
    out << """<table class="taskTable">"""
    use(TimeCategory){
      for(taskInstance in tasks){

        Date lastUpdated = null
        if(taskInstance.viewedTasks){
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

        def imgUrl = ConfigurationHolder.config.server.url + taskInstance?.multimedia?.filePathToThumbnail?.iterator().next()
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

//          <g:link controller="transcribe" action="task" id="${taskInstance.id}">
//            <img src="${ConfigurationHolder.config.server.url}/${taskInstance?.multimedia?.filePathToThumbnail?.iterator().next()}"
//                 width="200px"/>
//          </g:link>
//          <p>ID: ${fieldValue(bean: taskInstance, field: "id")}
//            <g:if test="${taskInstance.fullyTranscribedBy}">
//              <br/><span>
//              Transcriber: ${fieldValue(bean: taskInstance, field: "fullyTranscribedBy")}
//            </span>
//            </g:if>
//            <g:if test="${taskInstance?.viewedTasks?.lastView?.sort().get(0)}">
//                <br/>
//                Last viewed: ${taskInstance?.viewedTasks?.lastUpdated?.sort().get(0)}
//            </g:if>
//            <g:else>
//              <span style="padding: 0; margin: 0;">
//                <g:link controller="transcribe" action="task" id="${taskInstance.id}">Transcribe</g:link>
//              </span>
//            </g:else>
//            <g:if test="${taskInstance.fullyTranscribedBy != null && taskInstance.fullyValidatedBy == null}">
//              <!--<span style="padding: 0; margin: 0;"><g:link controller="validate" action="validate"
//                                                               id="${taskInstance.id}">Validate</g:link></span>-->
//            </g:if>



  }
}
