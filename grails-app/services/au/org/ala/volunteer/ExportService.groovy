package au.org.ala.volunteer

import au.com.bytecode.opencsv.CSVWriter
import au.org.ala.web.UserDetails
import com.google.common.base.Stopwatch
import grails.gorm.transactions.Transactional

import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicInteger
import java.util.regex.Pattern
import java.util.zip.ZipOutputStream
import java.util.zip.ZipEntry
import org.springframework.context.i18n.LocaleContextHolder
import groovyx.gpars.GParsPool

import static java.util.concurrent.TimeUnit.MILLISECONDS

@Transactional
class ExportService {

    def grailsApplication
    def grailsLinkGenerator
    def taskService
    def multimediaService
    def messageSource
    def userService
    def fieldService

    final int THREAD_POOL = 5
    final long EMPTY_TRANSCRIPTIONID = -1L

    private String getUserDisplayName(String userId, Map<String, UserDetails> usersMap = [:]) {
        if (!userId) {
            return ''
        }
        return usersMap[userId]?.displayName ?: userService.propertyForUserId(userId, 'displayName')
    }

    private String getTaskField(Project project, Task task, Transcription transcription, String fieldName, Map<String, UserDetails> usersMap = [:]) {
        def sw = Stopwatch.createStarted()

        def result = ""
        switch (fieldName.toLowerCase()) {
            case "taskid":
                result = task.id
                break;
            case "taskurl":
                result = grailsLinkGenerator.link(absolute: true, controller: 'validate', action: 'task', id: task.id)
                break
            case "transcriberid":
                result = getUserDisplayName(transcription?transcription.fullyTranscribedBy:task.fullyValidatedBy, usersMap)
                break;
            case "validatorid":
                result = getUserDisplayName(task.fullyValidatedBy, usersMap)
                break;
            case "externalidentifier":
                result = task.externalIdentifier
                break;
            case "exportcomment":
                def sb = new StringBuilder()
                if ((task.fullyValidatedBy) && (!transcription || (project.getRequiredNumberOfTranscriptions() == 1))) {
                    sb.append("Validated by ${getUserDisplayName(task.fullyValidatedBy, usersMap)}. ")
                } else if (transcription?.fullyTranscribedBy ) {
                    sb.append("Fully transcribed by ${getUserDisplayName(transcription.fullyTranscribedBy, usersMap)}. ")
                }
                def date = new Date().format("dd-MMM-yyyy")
                def appName = messageSource.getMessage("default.application.name", null, "DigiVol", LocaleContextHolder.locale)
                sb.append("Exported on ${date} from ${appName} (https://volunteer.ala.org.au)")
                result = sb.toString()
                break;
            case "datetranscribed":
                result = transcription?.dateFullyTranscribed?.format("dd-MMM-yyyy HH:mm:ss") ?: ""
                break;
            case "datevalidated":
                result = task.dateFullyValidated?.format("dd-MMM-yyyy HH:mm:ss") ?: ""
                break;
            case "validationstatus":
                result = taskValidationStatus(task)
        }
        def elapsed = sw.elapsed(MILLISECONDS)
        if (elapsed > 50) log.debug("Got {} value in {}ms", fieldName, elapsed)
        return result
    }

    def export_zipFile = { Project project, taskList, fieldNames, fieldList, response ->
        def sw = Stopwatch.createStarted()
        def databaseFieldNames = fieldService.getMaxRecordIndexByFieldForProject(project)
        log.debug("Got databaseFieldNames in {}ms", sw.elapsed(MILLISECONDS))
        sw.reset().start()

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
        log.debug("Generated repeating fields in {}ms", sw.elapsed(MILLISECONDS))
        sw.reset().start()

        zipExport(project, taskList, fieldNames, fieldList, response, ["dataset"], repeatingFields)
    }

    private Map<Transcription, Map> getTranscriptionsToExport(Project project, Task task, Map valuesMap) {

        Map results = [:]
        if (project.requiredNumberOfTranscriptions > 1) {
            if (valuesMap) {
                results = valuesMap
            } else {
                // return empty map to allow the export of task fields even though there are no transcription fields
                // this behaviour is consistent with the single transcription task
                results = [(EMPTY_TRANSCRIPTIONID): [:]]
            }
        }
        else {
            results << getTranscribedAndUploadedFields(task, valuesMap)
        }

        return results
    }

    private Map getTranscribedAndUploadedFields(Task task, Map taskValuesMap) {
        Transcription onlyTranscription = task.transcriptions?.size() > 0 ? task.transcriptions?.first() : null
        taskValuesMap = taskValuesMap ?: [:]
        if (onlyTranscription) {
            // Merge uploaded and EXIF field data into a single set of values.
            Map transcribedValues = taskValuesMap[(long)onlyTranscription.id] ?: [:]
            Map uploadedValues = taskValuesMap[EMPTY_TRANSCRIPTIONID] ?: [:]

            return [(onlyTranscription.id): uploadedValues + transcribedValues]
        } else {
            Map uploadedValues = taskValuesMap[EMPTY_TRANSCRIPTIONID] ?: [:]
            return [(EMPTY_TRANSCRIPTIONID): uploadedValues]
        }
    }

    def export_default = { Project project, taskList, fieldNames, fieldList, response ->
        def sw = Stopwatch.createStarted()
        def taskMap = fieldListToMultiMap(fieldList)
        log.debug("Got taskMap in {}ms", sw.elapsed(MILLISECONDS))
        sw.reset().start()
        def databaseFieldNames = fieldService.getMaxRecordIndexByFieldForProject(project)
        log.debug("Got databaseFieldNames in {}ms", sw.elapsed(MILLISECONDS))
        sw.reset().start()

        def fieldIndexMap = databaseFieldNames.collectEntries { [ it[0], it[1] ] }
        log.debug("Got fieldIndexMap in {}ms", sw.elapsed(MILLISECONDS))
        sw.reset().start()

        List<String> columnNames = []

        if (project.template.viewParams.exportGroupByIndex=="true") {
            fieldNames.each {
                if (!(fieldIndexMap.containsKey(it) && fieldIndexMap[it])) columnNames << it
            }
            def maxIdx = fieldIndexMap.values().max()
            for (int i = 0 ; i <= maxIdx; ++i) {
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
        log.debug("Got columnNames in {}ms", sw.elapsed(MILLISECONDS))
        sw.reset().start()

        def usersMap = taskService.getUserMapFromTaskList(taskList)
        log.debug("Generated users map in {}ms", sw.elapsed(MILLISECONDS))
        sw.reset().start()

        def filename = "Project-" + project.id + "-DwC"
        response.setHeader("Content-Disposition", "attachment;filename=" + filename +".csv");
        response.setContentType("text/plain");
        OutputStream fout = response.getOutputStream();
        OutputStream bos = new BufferedOutputStream(fout);
        OutputStreamWriter outputwriter = new OutputStreamWriter(bos);

        CSVWriter writer = new CSVWriter(outputwriter);
        // write header line (field names)
        writer.writeNext(columnNames as String[])
        log.debug("Wrote column names in {}ms", sw.elapsed(MILLISECONDS))
        sw.reset().start()

        def columnIndexRegex = Pattern.compile("^(\\w+)_(\\d+)\$")

        int threadPoolSize = grailsApplication.config.exportCSVThreadPoolSize ?: THREAD_POOL
        GParsPool.withPool threadPoolSize, {
            final AtomicInteger numberOfTasks = new AtomicInteger(0)
            taskList.eachParallel { Task task ->
                def sw2 = Stopwatch.createUnstarted()
                def sw3 = Stopwatch.createUnstarted()
                Map toExport = getTranscriptionsToExport(project, task, taskMap[task.id])
                toExport.each { transcriptionId, fieldMap ->

                    Transcription transcription = task.transcriptions.find { it.id == transcriptionId }
                    sw2.reset().start()
                    def values = []

                    columnNames.each { columnName ->
                        sw3.reset().start()
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
                            value = getTaskField(project, task, transcription, fieldName, usersMap)
                        }
                        values << value
                        def elapsed = sw3.elapsed(MILLISECONDS)
                        if (elapsed > 50) log.debug("Got column {} value {} in {}ms", fieldName, value, elapsed)
                    }
                    def elapsed = sw2.elapsed(MILLISECONDS)
                    if (elapsed > 50) log.debug("Got column values in {}ms", elapsed)
                    writer.writeNext(values as String[])
                    //valuesList.add(values as String[])
                }
                numberOfTasks.addAndGet(1)
                //writer.writeAll(valuesList)
            }
            log.info ("Wrote {} tasks", numberOfTasks.toString())
        }

        log.debug("Wrote all tasks in {}ms", sw.elapsed(MILLISECONDS))
        sw.reset().start()

        writer.close()
    }

    private void zipExport(Project project, taskList, List fieldNames, fieldList, response, List<FieldCategory> datasetCategories, List<String> otherRepeatingFields) {
        def valueMap = fieldListToMultiMap(fieldList)
        def sw = Stopwatch.createStarted()
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
                if (dataSetFieldNames?.size() > 0) {
                    datasetCategoryFields[category] = dataSetFieldNames
                }
            }
        }
        log.debug("Generated dataset category fields in {}ms", sw.elapsed(MILLISECONDS))
        sw.reset().start()

        if (otherRepeatingFields) {
            otherRepeatingFields.each {
                fieldNames.remove(it)  // this will get export in its own file
            }
        }
        log.debug("Modified other repeating fields in {}ms", sw.elapsed(MILLISECONDS))
        sw.reset().start()

        def usersMap = taskService.getUserMapFromTaskList(taskList)
        log.debug("Generated users map in {}ms", sw.elapsed(MILLISECONDS))
        sw.reset().start()

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

        int threadPoolSize = grailsApplication.config.exportCSVThreadPoolSize ?: THREAD_POOL
        GParsPool.withPool threadPoolSize, {
            final AtomicInteger numberOfTasks = new AtomicInteger(0)
            taskList.eachParallel { task ->
                Map toExport = getTranscriptionsToExport(project, task, valueMap[task.id])
                toExport.each { transcriptionId, transcriptionValueMap ->
                    Transcription transcription = task.transcriptions.find { it.id == transcriptionId }
                    def combinedFieldsMap = new LinkedHashMap(valueMap[task.id]?: [:])
                    if (transcriptionValueMap && transcriptionValueMap.size() > 0) {
                        if (combinedFieldsMap[transcriptionId]) {
                            combinedFieldsMap[transcriptionId].putAll(transcriptionValueMap)
                        } else {
                            combinedFieldsMap[transcriptionId] = transcriptionValueMap
                        }
                    }
                    String[] values = getFieldsForTask(project, task, transcription, fieldNames, combinedFieldsMap, usersMap)
                    if (values.length > 0) {
                        writer.writeNext(values)
                    }
                }
                numberOfTasks.addAndGet(1)
            }
            log.info ("Wrote {} tasks", numberOfTasks.toString())
        }
        writer.flush();
        zipStream.closeEntry();
        log.debug("Wrote tasks.csv in {}ms", sw.elapsed(MILLISECONDS))
        sw.reset().start()

        // now for each repeating field category...
        if (datasetCategoryFields) {
            datasetCategoryFields.keySet().each { category ->
                // Dataset files...
                def dataSetFieldNames = datasetCategoryFields[category]
                zipStream.putNextEntry(new ZipEntry(category.toString() +".csv"))
                exportDataSet(project, taskList, valueMap, writer, dataSetFieldNames)
                writer.flush();
                zipStream.closeEntry();
                log.debug("Wrote {}.csv in {}ms", category, sw.elapsed(MILLISECONDS))
                sw.reset().start()
            }
        }
        // Now for the other repeating fields...
        if (otherRepeatingFields) {
            otherRepeatingFields.each {
                zipStream.putNextEntry(new ZipEntry("${it}.csv"))
                exportDataSet(project, taskList, valueMap, writer, [it])
                writer.flush();
                zipStream.closeEntry();
                log.debug("Wrote {}.csv in {}ms", it, sw.elapsed(MILLISECONDS))
                sw.reset().start()
            }
        }

        // Export multimedia as 'associatedMedia'. There may be more than one piece of multimedia per task
        // so we do it in a separate file...

        zipStream.putNextEntry(new ZipEntry("associatedMedia.csv"))
        exportMultimedia(taskList, writer);
        writer.flush();
        zipStream.closeEntry()
        log.debug("Wrote associatedMedia.csv in {}ms", sw.elapsed(MILLISECONDS))
        sw.reset().start()

        zipStream.close();

    }

    def exportMultimedia(List<Task> taskList, CSVWriter writer) {
        String[] columnNames = ['taskID', 'externalIdentifier', 'recordIdx', 'associatedMedia', 'mimetype', 'licence']
        writer.writeNext(columnNames)
        if (taskList && taskList.size() > 0) {
            def c = Multimedia.createCriteria()
            def mms = c.scroll {
                inList('task', taskList)
                order('task', 'asc')
            }
            def recordIdx = 0
            def lastTaskId = null
            while (mms.next()) {
                def multimedia = mms.get()[0]
                def url = multimediaService.getImageUrl(multimedia)
                def taskId = multimedia.task.id
                String[] values = [multimedia.task.id.toString(), multimedia.task.externalIdentifier, recordIdx.toString(), url, multimedia.mimeType, multimedia.licence]
                writer.writeNext(values)
                recordIdx = taskId == lastTaskId ? recordIdx + 1 : 0
            }
        }
    }

    private void exportDataSet(Project project, List<Task> taskList, Map valueMap, CSVWriter writer, List dataSetFieldNames) {

        def columnNames = ['taskID', 'externalIdentifier','recordIdx'] + dataSetFieldNames;

        writer.writeNext(columnNames.toArray(new String[0]))
        taskList.each { Task task ->
            Map valuesByTranscription = valueMap[task.id]

            Map toExport = getTranscriptionsToExport(project, task, valuesByTranscription)
            toExport.each { transcriptionId, values ->

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

    }

    private String cleanseValue(Object value) {
        if (value == null) {
            return null;
        }
        return value.toString().replaceAll("\r\n|\n\r|\n|\r", '\\\\n')
    }

    private String[] getFieldsForTask(Project project, Task task, Transcription transcription, List fields, Map taskMap, Map<String, UserDetails> usersMap = [:]) {
        List fieldValues = []
        def taskId = task.id

        def transcriptionId = transcription?.id ?: EMPTY_TRANSCRIPTIONID

        Map fieldMap = taskMap[transcriptionId]
        def sw = Stopwatch.createUnstarted()
        fields.eachWithIndex { String fieldName, fieldIndex ->
            sw.reset().start()
            switch (fieldName.toLowerCase()) {
                case "taskid":
                    fieldValues.add(taskId.toString())
                    break;
                case "transcriberid":
                    fieldValues.add(getUserDisplayName(transcription ? transcription.fullyTranscribedBy : task.fullyValidatedBy, usersMap))
                    break;
                case "validatorid":
                    fieldValues.add(getUserDisplayName(task.fullyValidatedBy, usersMap))
                    break;
                case "externalidentifier":
                    fieldValues.add(task.externalIdentifier)
                    break;
                case "exportcomment":
                    def sb = new StringBuilder()
                    if ((task.fullyValidatedBy) && (!transcription || (project.getRequiredNumberOfTranscriptions() == 1))) {
                        sb.append("Validated by ${getUserDisplayName(task.fullyValidatedBy, usersMap)}. ")
                    } else if (transcription?.fullyTranscribedBy ) {
                        sb.append("Fully transcribed by ${getUserDisplayName(transcription.fullyTranscribedBy, usersMap)}. ")
                    }
                    def date = new Date().format("dd-MMM-yyyy")
                    def appName = messageSource.getMessage("default.application.name", null, "DigiVol", LocaleContextHolder.locale)
                    sb.append("Exported on ${date} from ${appName} (https://volunteer.ala.org.au)")
                    fieldValues.add((String) sb.toString())
                    break;
                case "datetranscribed":
                    fieldValues.add(transcription?.dateFullyTranscribed?.format("dd-MMM-yyyy HH:mm:ss") ?: "")
                    break;
                case "datevalidated":
                    fieldValues.add(task.dateFullyValidated?.format("dd-MMM-yyyy HH:mm:ss") ?: "")
                    break;
                case "validationstatus":
                    fieldValues.add(taskValidationStatus(task))
                    break;
                default:
                    if (fieldMap?.containsKey(fieldName)) {
                        fieldValues.add(cleanseValue(fieldMap.find{it.key == fieldName}?.value?.getAt(0)))
                    } else {
                        fieldValues.add("") // need to leave blank
                    }
                    break;
            }
            def elapsed = sw.elapsed(MILLISECONDS)
            if (elapsed > 50) log.debug("Got {} value in {}ms", fieldName, elapsed)
        }

        return fieldValues.toArray(new String[0]) // String array
    }

    private def taskValidationStatus(Task task) {
        // Updated to update the definition of validation status
        switch (task.isValid) {
            case true:
                return "Validated"
            case false:
                return "In progress"
            default:
                return ""
        }
    }

    /**
     * Utility to convert list of Fields to a Map of Maps with task.id as key
     *
     * @param fieldList
     * @return
     */
    private Map fieldListToMultiMap(List fieldList) {
        Map taskMap = [:]

        fieldList.each {
          //  if (it.value) {
                Map transcriptionMap = null
                Map fieldMap = null

                if (taskMap.containsKey(it.task.id)) {
                    transcriptionMap = taskMap.get(it.task.id)
                } else {
                    transcriptionMap = [:]
                    taskMap[it.task.id] = transcriptionMap
                }

                def transcriptionId = it.transcription?.id ?: EMPTY_TRANSCRIPTIONID // Fields loaded during staging and validatior supplied fields don't have a transcription
                if (transcriptionMap.containsKey(transcriptionId)) {
                    fieldMap = transcriptionMap[transcriptionId]
                }
                else {
                    fieldMap = [:]
                    transcriptionMap[transcriptionId] = fieldMap
                }

                Map valueMap = null;
                if (fieldMap.containsKey(it.name)) {
                    valueMap = fieldMap[it.name]
                } else {
                    valueMap = [:]
                    fieldMap[it.name] = valueMap
                }

                valueMap[it.recordIdx] = it.value
           // }
        }

        return taskMap
    }
}
