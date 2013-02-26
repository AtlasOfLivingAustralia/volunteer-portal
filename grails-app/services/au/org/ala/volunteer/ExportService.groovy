package au.org.ala.volunteer

import au.com.bytecode.opencsv.CSVWriter
import java.util.zip.ZipOutputStream
import java.util.zip.ZipEntry

class ExportService {

    static transactional = true

    def fieldService
    def grailsApplication

    // Simply dumps everything out flat. This is a problem for those templates that collect repeating groups (or multivalue fields)
    // such as journal templates, and the new specimen label templates, but this will do for older specimen label projects.
    def export_default = { Project project, taskList, taskMap, fieldNames, response ->
        def filename = "Project-" + project.id + "-DwC"
        response.setHeader("Content-Disposition", "attachment;filename=" + filename +".txt");
        response.setContentType("text/plain");
        OutputStream fout= response.getOutputStream();
        OutputStream bos = new BufferedOutputStream(fout);
        OutputStreamWriter outputwriter = new OutputStreamWriter(bos);

        CSVWriter writer = new CSVWriter(outputwriter);
        // write header line (field names)
        writer.writeNext(fieldNames.toArray(new String[0]))

        taskList.each { task ->
            String[] values = getFieldsForTask(task, fieldNames, taskMap)
            writer.writeNext(values)
        }

        writer.close()
    }

    def export_AerialObservations = { Project project, taskList, valueMap, List fieldNames, response ->
        zipExport(project, taskList, valueMap, fieldNames, response, [FieldCategory.dataset],[])
    }

    def export_ObservationDiary = { Project project, taskList, valueMap, List fieldNames, response ->
        zipExport(project, taskList, valueMap, fieldNames, response, [FieldCategory.dataset],[])
    }

    def export_ObservationDiaryWithMonth = export_ObservationDiary

    def export_FieldNoteBook = { Project project, taskList, valueMap, List fieldNames, response ->
        zipExport(project, taskList, valueMap, fieldNames, response, [FieldCategory.dataset], ['occurrenceRemarks'])
    }

    def export_SpecimenLabel = { Project project, taskList, valueMap, List fieldNames, response ->
        zipExport(project, taskList, valueMap, fieldNames, response, [FieldCategory.dataset], ['recordedBy'])
    }

    def export_GenericLabels = export_SpecimenLabel

    def export_SmithsonianPlants = export_SpecimenLabel

    def export_FieldNoteBookDoublePage = export_FieldNoteBook

    def export_Journal = export_FieldNoteBook

    private void zipExport(Project project, taskList, valueMap, List fieldNames, response, List<FieldCategory> datasetCategories, List<String> otherRepeatingFields) {
        def datasetCategoryFields = [:]
        if (datasetCategories) {
            datasetCategories.each { category ->
                // Work out which fields are a repeating group...
                def templateFields = TemplateField.findAllByTemplate(project.template)
                def dataSetFields = templateFields.findAll { it.category == category }
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

        taskList.each { task ->
            String[] values = getFieldsForTask(task, fieldNames, valueMap)
            writer.writeNext(values)
        }
        writer.flush();
        zipStream.closeEntry();

        // now for each repeating field category...
        if (datasetCategoryFields) {
            datasetCategoryFields.keySet().each { category ->
                // Dataset files...
                def dataSetFieldNames = datasetCategoryFields[category]
                zipStream.putNextEntry(new ZipEntry(category.toString() +".csv"))
                exportDataSet(taskList, valueMap, writer, dataSetFieldNames)
                writer.flush();
                zipStream.closeEntry();
            }
        }
        // Now for the other repeating fields...
        if (otherRepeatingFields) {
            otherRepeatingFields.each {
                zipStream.putNextEntry(new ZipEntry("${it}.csv"))
                exportDataSet(taskList, valueMap, writer, [it])
                writer.flush();
                zipStream.closeEntry();
            }
        }

        // Export multimedia as 'associatedMedia'. There may be more than one piece of multimedia per task
        // so we do it in a separate file...

        zipStream.putNextEntry(new ZipEntry("associatedMedia.csv"))
        exportMultimedia(taskList, writer);
        writer.flush();
        zipStream.closeEntry()

        // And finally the task comments, if any
        zipStream.putNextEntry(new ZipEntry("taskComments.csv"))
        exportTaskComments(taskList, writer);
        writer.flush();
        zipStream.closeEntry()

        zipStream.close();

    }

    def exportTaskComments(List<Task> taskList, CSVWriter writer) {
        String[] columnNames = ['taskID', 'externalIdentifier','userId', 'userDisplayName', 'date', 'comment']

        writer.writeNext(columnNames)
        taskList.each { Task task ->
            def c = TaskComment.createCriteria();
            def comments = c {
                eq("task", task)
                order('date', 'asc')
            }
            for (TaskComment comment : comments) {
                String[] outputValues = [task.id.toString(), task.externalIdentifier, comment.user.userId, comment.user.displayName, comment.date.format("yyyy-MM-dd HH:mm:ss"), cleanseValue(comment.comment)]
                writer.writeNext(outputValues)
            }
        }
    }

    def exportMultimedia(List<Task> taskList, CSVWriter writer) {
        String[] columnNames = ['taskID', 'externalIdentifier', 'recordIdx', 'associatedMedia', 'mimetype', 'licence']
        writer.writeNext(columnNames)
        taskList.each { Task task ->
            int recordIdx = 0
            task.multimedia.each { multimedia ->
                def url = "${grailsApplication.config.server.url}${multimedia.filePath}"
                String[] values = [task.id.toString(), task.externalIdentifier, recordIdx.toString(), url, multimedia.mimeType, multimedia.licence]
                writer.writeNext(values)
                recordIdx++
            }
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

    private String[] getFieldsForTask(Task task, List fields, Map taskMap) {
        List fieldValues = []
        def taskId = task.id

        if (taskMap.containsKey(taskId)) {
            Map fieldMap = taskMap.get(taskId)
            fields.eachWithIndex { fieldName, fieldIndex ->

                if (fieldIndex == 0) {
                    fieldValues.add(taskId.toString())
                }
                else if (fieldIndex == 1) {
                    fieldValues.add(task.fullyTranscribedBy)
                }
                else if (fieldIndex == 2) {
                    fieldValues.add(task.fullyValidatedBy)
                }
                else if (fieldIndex == 3) {
                    fieldValues.add(task.externalIdentifier)
                }
                else if (fieldIndex == 4) {
                    def sb = new StringBuilder()
                    if (task.fullyTranscribedBy) {
                        sb.append("Fully transcribed by ${task.fullyTranscribedBy}. ")
                    }
                    def date = new Date().format("dd-MMM-yyyy")
                    sb.append("Exported on ${date} from ALA Volunteer Portal (http://volunteer.ala.org.au)")
                    fieldValues.add((String) sb.toString())
                }
                else if (fieldMap.containsKey(fieldName)) {
                    fieldValues.add(cleanseValue(fieldMap.get(fieldName)?.getAt(0)))
                }
                else {
                    fieldValues.add("") // need to leave blank
                }
            }
        }

        return fieldValues.toArray(new String[0]) // String array
    }

}
