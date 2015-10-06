<style type="text/css">

#task_browser_controls, #current_task_header {
    background: #3D464C;
    text-align: center;
    margin: 0;
}

#task_browser_controls h3, #current_task_header h3 {
    color: white;
    padding-bottom: 6px;
    font-size: 1.2em;
    margin: 0;
}

#task_browser_controls hr, #current_task_header hr {
    clear: both;
    height: 1px;
    width: auto;
    background-color: #D1D1D1;
    margin-bottom: 6px;
    border: none;
}

#task_location {
    color: white;
}

#taskBrowserImage {
    height: 200px;
    width: 670px;
}

#taskBrowserImage img {
    max-width: inherit !important;
}


</style>

<div>
    <g:if test="${taskInstance}">
        <div id="current_task_header">
            <h3>Image from current task</h3>
        </div>

        <div class="dialog" id="imagePane">
            <g:set var="mm" value="${taskInstance.multimedia?.first()}"/>
            <div id="imageViewer" style="height: 200px; overflow: hidden">
                <g:imageViewer multimedia="${mm}" elementId="taskBrowserImage" hideControls="${true}"/>
            </div>
        </div>

    </g:if>

    <div id="task_browser_controls">
        <h3>Your previously transcribed tasks in ${projectInstance?.featuredLabel ?: "<project>"}</h3>

        <div id="tasklist_container" style="color: white">

        </div>


        <div>
            <span style="padding: 5px; float: left">
                <button class="btn btn-small" id="show_prev_task"><img
                        src="${resource(dir: 'images', file: 'left_arrow.png')}">&nbsp;Previous</button>
                <button class="btn btn-small" id="show_next_task">Next&nbsp;<img
                        src="${resource(dir: 'images', file: 'right_arrow.png')}"></button>
                <span id="task_location"></span>
            </span>
            <span style="padding: 5px;float:right">
                <span style="color: white;">Label text:</span>
                <span><g:textField style="width:120px;margin-bottom: 0" name="search_text" id="search_text"/></span>
                <button class="btn btn-small" style="margin-right: 10px" id="search_button">Search</button>
                <button class="btn btn-small" id="copy_task_data">Copy</button>
                <button class="btn btn-small" id="cancel_button">Cancel</button>
            </span>
        </div>
        <hr/>
    </div>

    <div id="task_content">
    </div>

</div>

<script type="text/javascript">

    function updateLocation() {
        var currentTaskIndex = $("#task_list").attr("currentTaskIndex");
        var taskListSize = parseInt($("#task_list").attr("taskCount"));
        $("#task_location").text((parseInt(currentTaskIndex) + 1) + " of " + taskListSize);

        if (currentTaskIndex <= 0) {
            $("#show_prev_task").attr("disabled", "true")
        } else {
            $("#show_prev_task").removeAttr("disabled")
        }

        if (currentTaskIndex >= taskListSize - 1) {
            $("#show_next_task").attr("disabled", "true")
        } else {
            $("#show_next_task").removeAttr("disabled")
        }

        if (taskListSize == 0) {
            $('#task_content').html("You have no matching previously transcribed tasks");
        }
    }

    function loadTask(taskIndex) {
        $("#task_list").attr("currentTaskIndex", taskIndex)
        var taskId = $("#task_" + taskIndex).attr("task_id")
        var taskUrl = "${createLink(controller: 'task', action:'taskDetailsFragment')}?taskId=" + taskId + "&taskIndex=" + taskIndex;
        $.ajax({
            url: taskUrl, success: function (data) {
                $("#task_content").html(data);
                updateLocation();
            }
        })
    }

    function clearTaskData() {

        $('[id*="recordValues\\."]').each(function (index, widget) {
            var clear = true;
            var jqWidget = $(widget);
            var widgetType = jqWidget.attr('type');
            // Don't clear the hidden fields, unless they are special transcribe widgets
            if (widgetType == 'hidden') {
                // transcribe widgets have a targetField attribute, so search upwards from this field to see if any of its parents have
                // a targetField
                var target = jqWidget.closest("div[targetField]");
                clear = target.length > 0;
            }

            if (clear) {
                if (widgetType == 'checkbox') {
                    jqWidget.prop("check", false);
                } else {
                    jqWidget.val('')
                }
                jqWidget.change();
            }

        });
    }

    function endsWith(str, suffix) {
        return str.indexOf(suffix, str.length - suffix.length) !== -1;
    }

    function copyDataFromTask(taskId) {
        // First we need to clear old data...
        clearTaskData();

        var taskDataUrl = "${createLink(controller: 'task', action:'ajaxTaskData')}?taskId=" + taskId;
        $.ajax({
            url: taskDataUrl, success: function (data) {
                // the data is the form of a dictionary with the keys being the form element id for each data element
                // being copied, and the value being the field value
                var excluded = ['locality', 'stateProvince', 'decimalLatitude', 'decimalLongitude', 'country', 'coordinateUncertaintyInMeters']
                for (var key in data) {
                    // copy over the data
                    var skip = false;
                    for (var excludeIdx in excluded) {
                        var exclude = excluded[excludeIdx]
                        if (endsWith(key, '.' + exclude)) {
                            skip = true;
                            break;
                        }
                    }
                    if (!skip) {
                        var selector = "#" + key;
                        var jq = $(selector);
                        if (jq.attr("type") == 'checkbox') {
                            jq.prop('checked', data[key] == 'true');
                        } else {
                            jq.val(data[key]);
                        }
                        jq.change();
                    }
                }
            }
        });

    }

    function findTasks() {

        $('#tasklist_container').html("");
        $('#task_content').html("Searching for tasks...");

        var taskFindUrl = "${createLink(controller: 'task', action:'taskBrowserTaskList')}?taskId=" + ${taskInstance?.id};
        var searchText = $("#search_text").val();
        if (searchText) {
            taskFindUrl += "&search_text=" + encodeURIComponent(searchText);
        }

        $.ajax(taskFindUrl).done(function (data) {
            $('#tasklist_container').html(data);
        });

    }

    $("#show_next_task").click(function (e) {
        e.preventDefault();
        var currentTaskIndex = $("#task_list").attr("currentTaskIndex");
        var nextTaskIndex = parseInt(currentTaskIndex) + 1;
        var taskListSize = parseInt($("#task_list").attr("taskCount"));
        if (nextTaskIndex < taskListSize) {
            loadTask(nextTaskIndex);
        }
    });

    $("#copy_task_data").click(function (e) {
        e.preventDefault();
        var currentTaskIndex = $("#task_list").attr("currentTaskIndex");
        var taskId = $("#task_" + currentTaskIndex).attr("task_id")
        copyDataFromTask(taskId)
        bvp.hideModal();
    });


    $("#cancel_button").click(function (e) {
        e.preventDefault();
        bvp.hideModal();
    });

    $("#show_prev_task").click(function (e) {
        e.preventDefault();
        var currentTaskIndex = $("#task_list").attr("currentTaskIndex");
        var prevTaskIndex = parseInt(currentTaskIndex) - 1;
        if (prevTaskIndex >= 0) {
            loadTask(prevTaskIndex);
        }
    });

    $("#search_button").click(function (e) {
        e.preventDefault();
        findTasks();
    });

    $("#search_text").keydown(function (e) {
        if (e.keyCode == 13) {
            findTasks();
        }
    });

    findTasks();

    var target = $("#taskBrowserImage img");

    target.panZoom({
        pan_step: 10,
        zoom_step: 10,
        min_width: 200,
        min_height: 200,
        mousewheel: true,
        mousewheel_delta: 4
    });

</script>
