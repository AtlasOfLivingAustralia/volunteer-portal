package au.org.ala.volunteer

import au.com.bytecode.opencsv.CSVWriter
import java.util.zip.ZipOutputStream
import java.util.zip.ZipEntry

class ExportService {

    static transactional = true

    def fieldService

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

    def export_FieldNoteBook = { Project project, taskList, valueMap, List fieldNames, response ->

        // Work out which fields are a repeating group...
        def templateFields = TemplateField.findAllByTemplate(project.template)
        def dataSetFields = templateFields.findAll {
            it.category == FieldCategory.dataset
        }
        def dataSetFieldNames = dataSetFields.collect { it.fieldType.toString() }
        // These fields are in a repeating group, and will be exported in a seperated (normalized) file, so remove
        // them from the list of columns to go in the main file...
        fieldNames.removeAll { dataSetFieldNames.contains(it) }

        fieldNames.remove("occurrenceRemarks")  // this gets handled specially for journal tasks...

        def filename = "Project-" + project.featuredLabel.replaceAll(" ","") + "-DwC"
        response.setHeader("Content-Disposition", "attachment;filename=" + filename +".zip");
        response.setContentType("application/zip, application/octet-stream");

        def zipStream = new ZipOutputStream(response.getOutputStream())
        OutputStream bos = new BufferedOutputStream(zipStream);
        OutputStreamWriter outputwriter = new OutputStreamWriter(bos);

        CSVWriter writer = new CSVWriter(outputwriter);

        zipStream.putNextEntry(new ZipEntry("tasks.csv"));
        // write header line (field names)
        writer.writeNext(fieldNames.toArray(new String[0]))

        taskList.each { task ->
            String[] values = getFieldsForTask(task, fieldNames, valueMap)
            writer.writeNext(values)
        }
        writer.flush();
        zipStream.closeEntry();

        // Dataset files...
        zipStream.putNextEntry(new ZipEntry(dataSetFieldNames.join("_") +".csv"))
        exportDataSet(taskList, valueMap, writer,dataSetFieldNames)
        writer.flush();
        zipStream.closeEntry();

        // Occurrence remarks (transcription)
        zipStream.putNextEntry(new ZipEntry("occurrenceRemarks.csv"))
        exportDataSet(taskList, valueMap, writer, ['occurrenceRemarks'])
        writer.flush();
        zipStream.closeEntry();

        zipStream.close();
    }

    def export_FieldNoteBookDoublePage = export_FieldNoteBook

    def export_Journal = export_FieldNoteBook

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
