package au.org.ala.volunteer

import au.com.bytecode.opencsv.CSVWriter
import au.org.ala.web.UserDetails

import java.util.regex.Pattern
import java.util.zip.ZipOutputStream
import java.util.zip.ZipEntry
import org.springframework.context.i18n.LocaleContextHolder

class ExportService {

    static transactional = true

    def grailsApplication
    def grailsLinkGenerator
    def taskService
    def multimediaService
    def messageSource
    def userService

    private String getUserDisplayName(String userId, Map<String, UserDetails> usersMap = [:]) {
        return usersMap[userId]?.displayName ?: userService.propertyForUserId(userId, 'displayName')
    }

    private String getTaskField(Task task, String fieldName, Map<String, UserDetails> usersMap = [:]) {

        def result = ""
        switch (fieldName.toLowerCase()) {
            case "taskid":
                result = task.id
                break;
            case "taskurl":
                result = grailsLinkGenerator.link(absolute: true, controller: 'validate', action: 'task', id: task.id)
                break
            case "transcriberid":
                result = getUserDisplayName(task.fullyTranscribedBy, usersMap)
                break;
            case "validatorid":
                result = getUserDisplayName(task.fullyValidatedBy, usersMap)
                break;
            case "externalidentifier":
                result = task.externalIdentifier
                break;
            case "exportcomment":
                def sb = new StringBuilder()
                if (task.fullyTranscribedBy) {
                    sb.append("Fully transcribed by ${getUserDisplayName(task.fullyTranscribedBy, usersMap)}. ")
                }
                def date = new Date().format("dd-MMM-yyyy")
                def appName = messageSource.getMessage("default.application.name", null, "DigiVol", LocaleContextHolder.locale)
                sb.append("Exported on ${date} from ${appName} (http://volunteer.ala.org.au)")
                result = sb.toString()
                break;
            case "datetranscribed":
                result = task.dateFullyTranscribed?.format("dd-MMM-yyyy HH:mm:ss") ?: ""
                break;
            case "datevalidated":
                result = task.dateFullyValidated?.format("dd-MMM-yyyy HH:mm:ss") ?: ""
                break;
            case "validationstatus":
                result = taskValidationStatus(task)
        }
        return result
    }

    def export_zipFile = { Project project, taskList, valueMap, fieldNames, response ->

        def c = Field.createCriteria()
        def databaseFieldNames = c {
            task {
                eq("project", project)
            }
            projections {
                groupProperty("name")
                max("recordIdx")
            }
        }

        def fieldIndexMap = databaseFieldNames.collectEntries { [ it[0], it[1] ] }
        def repeatingFields = []
        fieldNames.each { fieldName ->
            if (fieldIndexMap[fieldName] > 0) {
                repeatingFields << fieldName
            }
        }
        repeatingFields.each {
            fieldNames.remove(it)
        }

        zipExport(project, taskList, valueMap, fieldNames, response, ["dataset"], repeatingFields)
    }

    def export_default = { Project project, taskList, taskMap, fieldNames, response ->

        def c = Field.createCriteria()

        def databaseFieldNames = c {
            task {
                eq("project", project)
            }
            projections {
                groupProperty("name")
                max("recordIdx")
            }
        }

        def fieldIndexMap = databaseFieldNames.collectEntries { [ it[0], it[1] ] }

        List<String> columnNames = []

        if (project.template.viewParams.exportGroupByIndex=="true") {
            fieldNames.each {
                if (!(fieldIndexMap.containsKey(it) && fieldIndexMap[it])) columnNames << it
            }
            def maxIdx = fieldIndexMap.values().max()
            for (int i = 0 ; i < maxIdx; ++i) {
                fieldNames.each {
                    if (fieldIndexMap.containsKey(it) && fieldIndexMap[it] && fieldIndexMap[it] >= i) columnNames << "${it}_$i"
                }
            }
        } else {
            fieldNames.each {
                if (fieldIndexMap.containsKey(it)) {
                    if (fieldIndexMap[it]) {
                        for (int i = 0; i <= fieldIndexMap[it]; ++i) {
                            columnNames << "${it}_${i}"
                        }
                    } else {
                        columnNames << it
                    }
                } else {
                    columnNames << it
                }
            }
        }

        def usersMap = getUserMapFromTaskList(taskList)

        def filename = "Project-" + project.id + "-DwC"
        response.setHeader("Content-Disposition", "attachment;filename=" + filename +".csv");
        response.setContentType("text/plain");
        OutputStream fout = response.getOutputStream();
        OutputStream bos = new BufferedOutputStream(fout);
        OutputStreamWriter outputwriter = new OutputStreamWriter(bos);

        CSVWriter writer = new CSVWriter(outputwriter);
        // write header line (field names)
        writer.writeNext(columnNames as String[])
        def columnIndexRegex = Pattern.compile("^(\\w+)_(\\d+)\$")
        taskList.each { Task task ->
            def fieldMap = taskMap[task.id]
            def values = []
            columnNames.each { columnName ->
                def fieldName = columnName
                def recordIndex = 0
                def matcher = columnIndexRegex.matcher(columnName)
                if (matcher.matches()) {
                    fieldName = matcher.group(1)
                    recordIndex = matcher.group(2) as int
                }

                String value
                if (fieldIndexMap.containsKey(fieldName)) {
                    def valueMap = fieldMap?.getAt(fieldName)
                    value = valueMap?.getAt(recordIndex) ?: ""
                } else {
                    value = getTaskField(task, fieldName, usersMap)
                }
                values << value
            }
            writer.writeNext(values as String[])
        }
        writer.close()
    }

    private void zipExport(Project project, taskList, valueMap, List fieldNames, response, List<FieldCategory> datasetCategories, List<String> otherRepeatingFields) {
        def datasetCategoryFields = [:]
        if (datasetCategories) {
            datasetCategories.each { category ->
                // Work out which fields are a repeating group...
                def templateFields = TemplateField.findAllByTemplate(project.template)
                def dataSetFields = templateFields.findAll {
                                        it.category.name() == category
                                    }
                def dataSetFieldNames = dataSetFields.collect { it.fieldType.toString() }
                // These fields are in a repeating group, and will be exported in a separate (normalized) file, so remove
                // them from the list of columns to go in the main file...
                fieldNames.removeAll { dataSetFieldNames.contains(it) }
                datasetCategoryFields[category] = dataSetFieldNames
            }
        }

        if (otherRepeatingFields) {
            otherRepeatingFields.each {
                fieldNames.remove(it)  // this will get export in its own file
            }
        }
        log.debug("Got datasetCategories and otherRepeatingFields for export ${project.id}")

        def usersMap = getUserMapFromTaskList(taskList)

        log.debug("Got usersMap for export ${project.id}")

        // Prepare the response for a zip file - use the project name as a basis of the filename
        def filename = "Project-" + project.featuredLabel.replaceAll(" ","") + "-DwC"
        response.setHeader("Content-Disposition", "attachment;filename=" + filename +".zip");
        response.setContentType("application/zip");

        // First up write out the main tasks file -all the remaining fields are single value only
        def zipStream = new ZipOutputStream(response.getOutputStream())
        OutputStream bos = new BufferedOutputStream(zipStream);
        OutputStreamWriter outputwriter = new OutputStreamWriter(bos);

        CSVWriter writer = new CSVWriter(outputwriter);

        zipStream.putNextEntry(new ZipEntry("tasks.csv"));
        // write header line (field names)
        writer.writeNext((String[]) fieldNames.toArray(new String[0]))

        log.debug("Wrote tasks.csv headers for export ${project.id}")

        taskList.each { task ->
            String[] values = getFieldsForTask(task, fieldNames, valueMap, usersMap)
            writer.writeNext(values)
        }
        writer.flush();
        zipStream.closeEntry();

        log.debug("Wrote tasks.csv for export ${project.id}")

        // now for each repeating field category...
        if (datasetCategoryFields) {
            datasetCategoryFields.keySet().each { category ->
                // Dataset files...
                def dataSetFieldNames = datasetCategoryFields[category]
                zipStream.putNextEntry(new ZipEntry(category.toString() +".csv"))
                exportDataSet(taskList, valueMap, writer, dataSetFieldNames)
                writer.flush();
                zipStream.closeEntry();
                log.debug("Wrote ${category}.csv for export ${project.id}")
            }
        }
        // Now for the other repeating fields...
        if (otherRepeatingFields) {
            log.debug("Writing otherRepeatingFields for export ${project.id}")
            otherRepeatingFields.each {
                zipStream.putNextEntry(new ZipEntry("${it}.csv"))
                exportDataSet(taskList, valueMap, writer, [it])
                writer.flush();
                zipStream.closeEntry();
                log.debug("Wrote ${it}.csv for export ${project.id}")
            }
            log.debug("Finished writing otherRepeatingFields for export ${project.id}")
        }

        // Export multimedia as 'associatedMedia'. There may be more than one piece of multimedia per task
        // so we do it in a separate file...

        zipStream.putNextEntry(new ZipEntry("associatedMedia.csv"))
        exportMultimedia(taskList, writer);
        writer.flush();
        zipStream.closeEntry()
        log.debug("Wrote associatedMedia.csv for export ${project.id}")

        // And finally the task comments, if any
        zipStream.putNextEntry(new ZipEntry("taskComments.csv"))
        exportTaskComments(taskList, writer, usersMap);
        writer.flush();
        zipStream.closeEntry()
        log.debug("Wrote taskComments.csv for export ${project.id}")

        zipStream.close();

    }

    def exportTaskComments(List<Task> taskList, CSVWriter writer, Map<String, UserDetails> usersMap = [:]) {
        String[] columnNames = ['taskID', 'externalIdentifier','userId', 'userDisplayName', 'date', 'comment']

        writer.writeNext(columnNames)
        def c = TaskComment.createCriteria();
        def comments = c {
            inList("task", taskList)
            order('task', 'asc')
            order('date', 'asc')
        }

        for (TaskComment comment : comments) {
            def userId = comment.user.userId
            def props = usersMap[userId] ?: userService.detailsForUserId(userId)

            def task = comment.task
            String[] outputValues = [task.id.toString(), task.externalIdentifier, props.email, props.displayName, comment.date.format("yyyy-MM-dd HH:mm:ss"), cleanseValue(comment.comment)]
            writer.writeNext(outputValues)
        }
    }

    def exportMultimedia(List<Task> taskList, CSVWriter writer) {
        String[] columnNames = ['taskID', 'externalIdentifier', 'recordIdx', 'associatedMedia', 'mimetype', 'licence']
        writer.writeNext(columnNames)
        def c = Multimedia.createCriteria()
        def mms = c.list {
            inList('task', taskList)
            order('task', 'asc')
        }
        log.debug("Got ${mms.size()} multimedia for export")
        def recordIdx = 0
        def lastTaskId = null
        def count = 0
        mms.each { multimedia ->
//            def multimedia = mms.get()[0]
            def url = multimediaService.getImageUrl(multimedia)
            def taskId = multimedia.task.id
            String[] values = [multimedia.task.id.toString(), multimedia.task.externalIdentifier, recordIdx.toString(), url, multimedia.mimeType, multimedia.licence]
            writer.writeNext(values)
            recordIdx = taskId == lastTaskId ? recordIdx + 1 : 0
            if (count % 100 == 0) log.debug("Wrote $count mms")
            count++
        }
    }

    private void exportDataSet(List<Task> taskList, Map valueMap, CSVWriter writer, List dataSetFieldNames) {

        def columnNames = ['taskID', 'externalIdentifier','recordIdx'] + dataSetFieldNames;

        writer.writeNext(columnNames.toArray(new String[0]))
        taskList.each { Task task ->
            Map<String, Map> values = valueMap[task.id]
            if (values) {
                int recordIdx = 0;
                def finished = false;
                while (!finished) {
                    boolean hasRecordForIndex = false;
                    List<String> outputValues = [task.id.toString(), task.externalIdentifier, recordIdx.toString()]
                    for (String fieldName : dataSetFieldNames) {
                        Map fieldValues = values[fieldName]
                        if (fieldValues?.containsKey(recordIdx)) {
                            hasRecordForIndex = true;
                            outputValues.add(cleanseValue(fieldValues[recordIdx]))
                        } else {
                            outputValues.add("")
                        }
                    }
                    if (hasRecordForIndex) {
                        writer.writeNext(outputValues.toArray(new String[0]))
                        recordIdx++
                    }
                    finished = !hasRecordForIndex;
                }
            }
        }

    }

    private String cleanseValue(Object value) {
        if (value == null) {
            return null;
        }
        return value.toString().replaceAll("\r\n|\n\r|\n|\r", '\\\\n')
    }

    private String[] getFieldsForTask(Task task, List fields, Map taskMap, Map<String, UserDetails> usersMap = [:]) {
        List fieldValues = []
        def taskId = task.id

        if (taskMap.containsKey(taskId)) {
            Map fieldMap = taskMap.get(taskId)
            fields.eachWithIndex { String fieldName, fieldIndex ->

                switch (fieldName.toLowerCase()) {
                    case "taskid":
                        fieldValues.add(taskId.toString())
                        break;
                    case "transcriberid":
                        fieldValues.add(getUserDisplayName(task.fullyTranscribedBy, usersMap))
                        break;
                    case "validatorid":
                        fieldValues.add(getUserDisplayName(task.fullyValidatedBy, usersMap))
                        break;
                    case "externalidentifier":
                        fieldValues.add(task.externalIdentifier)
                        break;
                    case "exportcomment":
                        def sb = new StringBuilder()
                        if (task.fullyTranscribedBy) {
                            sb.append("Fully transcribed by ${getUserDisplayName(task.fullyTranscribedBy, usersMap)}. ")
                        }
                        def date = new Date().format("dd-MMM-yyyy")
                        def appName = messageSource.getMessage("default.application.name", null, "DigiVol", LocaleContextHolder.locale)
                        sb.append("Exported on ${date} from ${appName} (http://volunteer.ala.org.au)")
                        fieldValues.add((String) sb.toString())
                        break;
                    case "datetranscribed":
                        fieldValues.add(task.dateFullyTranscribed?.format("dd-MMM-yyyy HH:mm:ss") ?: "")
                        break;
                    case "datevalidated":
                        fieldValues.add(task.dateFullyValidated?.format("dd-MMM-yyyy HH:mm:ss") ?: "")
                        break;
                    case "validationstatus":
                        fieldValues.add(taskValidationStatus(task))
                        break;
                    default:
                        if (fieldMap.containsKey(fieldName)) {
                            fieldValues.add(cleanseValue(fieldMap.get(fieldName)?.getAt(0)))
                        } else {
                            fieldValues.add("") // need to leave blank
                        }
                        break;
                }
            }
        }

        return fieldValues.toArray(new String[0]) // String array
    }

    private Map<String, UserDetails> getUserMapFromTaskList(List<Task> tasks) {
        def userIds = tasks.collectMany { [it.fullyTranscribedBy, it.fullyValidatedBy] }.unique()
        return userService.detailsForUserIds(userIds).collectEntries { [ (it.userId): it ]}
    }

    private def taskValidationStatus(Task task) {
        switch (task.isValid) {
            case true:
                return "Valid"
            case false:
                return "Invalid"
            default:
                return ""
        }
    }

}
