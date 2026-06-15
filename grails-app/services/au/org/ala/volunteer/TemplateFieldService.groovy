package au.org.ala.volunteer

import grails.gorm.transactions.Transactional
import org.apache.commons.io.ByteOrderMark
import org.apache.commons.io.input.BOMInputStream
import org.springframework.web.multipart.MultipartFile

import javax.servlet.ServletOutputStream
import java.nio.charset.StandardCharsets

@Transactional(readOnly = true)
class TemplateFieldService {

    def exportService

    @Transactional
    def importFieldsFromCSV(Template template, MultipartFile file) {

        if (!template || !file) {
            return
        }

        // Delete any existing fields for this template
        def existingFields = TemplateField.findAllByTemplate(template)
        if (existingFields) {
            existingFields.each { field ->
                field.delete()
            }
        }

        //InputStream is = file.inputStream
        InputStream is = BOMInputStream.builder()
                .setInputStream(file.inputStream)
                .setByteOrderMarks(ByteOrderMark.UTF_8)
                .get()
        is.eachCsvLine { String[] tokens ->

            def field = new TemplateField(template: template)
            field.fieldType = tokens[0] as DarwinCoreField
            field.label = tokens[1]
            field.defaultValue = tokens[2]
            field.category = tokens[3] as FieldCategory
            field.type = tokens[4] as FieldType
            field.mandatory = tokens[5] as Boolean
            field.multiValue = tokens[6] as Boolean
            field.helpText = tokens[7]
            field.validationRule = tokens[8]
            field.displayOrder = tokens[9] ? Integer.parseInt(tokens[9]) : null
            field.layoutClass = tokens[10]
            field.save()
        }

    }

    def exportFieldToCSV(Template templateInstance, response) {
        if (!templateInstance) {
            return
        }
        def fileName = exportService.cleanFilename("${templateInstance.name}_fields")
        if (!fileName) fileName = "digivol_template_fields.csv"
        response.setHeader("Content-Disposition", "attachment;filename=${fileName}.csv")
        response.setContentType('text/csv;charset=utf-8')

        def osw = new OutputStreamWriter(response.outputStream as ServletOutputStream, StandardCharsets.UTF_8)
        def writer = new BVPCSVWriter(osw,{
            'fieldType' { it.fieldType?.toString() }
            'label' { it.label ?: '' }
            'defaultValue' { it.defaultValue ?: '' }
            'category' { it.category ?: '' }
            'type' { it.type?.toString() }
            'mandatory' { it.mandatory ? "1" : "0" }
            'multiValue' { it.multiValue ? "1" : "0" }
            'helpText' { it.helpText ?: '' }
            'validationRule' { it.validationRule ?: '' }
            'displayOrder' { it.displayOrder ?: ''}
            'layoutClass' { it.layoutClass ?: ''}
        })

        writer.writeHeadings = false

        def fields = TemplateField.findAllByTemplate(templateInstance)?.sort { it.displayOrder }
        for (def field : fields) {
            writer << field
        }
        osw.flush()
        osw.close()
    }
}
