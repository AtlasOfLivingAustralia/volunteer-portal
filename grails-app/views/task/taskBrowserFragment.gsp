<div>
  <h3>Previous tasks for ${projectInstance}</h3>

  <g:if test="${taskList?.size}">
    <div id="task_list" style="display: none" currentTaskIndex="0" taskCount="${taskList.size}">
      <g:each in="${taskList}" var="task" status="index">
        <div id="task_${index}" task_id="${task.id}">${task.id}</div>
      </g:each>
    </div>
    <div style="">
      <span style="padding: 5px;float:right">
        <button id="cancel_button">Cancel</button>
        <button id="copy_task_data">Copy</button>
        <button id="show_prev_task"><img src="${resource(dir:'images',file:'left_arrow.png')}">&nbsp;Previous</button>
        <button id="show_next_task">Next&nbsp;<img src="${resource(dir:'images',file:'right_arrow.png')}"></button>
      </span>
      <span style="padding: 5px;float:left;" id="task_location"></span>
    </div>
    <hr />
    <div id="task_content" />


    </div>
    <script type="text/javascript">

      function updateLocation() {
        var currentTaskIndex = $("#task_list").attr("currentTaskIndex");
        var taskListSize = parseInt($("#task_list").attr("taskCount"));
        $("#task_location").text((parseInt(currentTaskIndex) + 1) + " of " + taskListSize);
      }

      $("#show_next_task").click(function(e) {
        e.preventDefault();
        var currentTaskIndex = $("#task_list").attr("currentTaskIndex");
        var nextTaskIndex = parseInt(currentTaskIndex) + 1;
        var taskListSize = parseInt($("#task_list").attr("taskCount"));
        if (nextTaskIndex < taskListSize) {
          loadTask(nextTaskIndex);
        }
      });

      $("#copy_task_data").click(function(e) {
        var currentTaskIndex = $("#task_list").attr("currentTaskIndex");
        var taskId = $("#task_" + currentTaskIndex).attr("task_id")
        copyDataFromTask(taskId)
        $.fancybox.close();
      });


      $("#cancel_button").click(function(e) {
        $.fancybox.close();
      });

      $("#show_prev_task").click(function(e) {
        e.preventDefault();
        var currentTaskIndex = $("#task_list").attr("currentTaskIndex");
        var prevTaskIndex = parseInt(currentTaskIndex) - 1;
        if (prevTaskIndex >= 0) {
          loadTask(prevTaskIndex);
        }
      });


      loadTask(0)

      function loadTask(taskIndex) {
        $("#task_list").attr("currentTaskIndex", taskIndex)
        var taskId = $("#task_" + taskIndex).attr("task_id")
        var taskUrl = "${createLink(controller: 'task', action:'taskDetailsFragment')}?taskId=" + taskId + "&taskIndex=" + taskIndex;
        $.ajax({url:taskUrl, success: function(data) {
          $("#task_content").html(data);
        }})
        updateLocation();
      }

      function copyDataFromTask(taskId) {

        var taskDataUrl = "${createLink(controller: 'task', action:'ajaxTaskData')}?taskId=" + taskId;
        $.ajax({url:taskDataUrl, success: function(data) {
          // the data is the form of a dictionary with the keys being the form element id for each data element
          // being copied, and the value being the field value
          for (key in data) {
            // copy over the data
            var selector = "#" + key;
            $(selector).val(data[key])
          }
        }});

      }


    </script>
  </g:if>
  <g:else>
    You have no previously transcribed tasks for this project!
  </g:else>

</div>