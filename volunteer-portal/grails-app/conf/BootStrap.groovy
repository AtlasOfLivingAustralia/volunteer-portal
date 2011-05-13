import au.org.ala.volunteer.FieldType
import au.org.ala.volunteer.FieldCategory
import au.org.ala.volunteer.Picklist
import au.org.ala.volunteer.PicklistItem
import au.org.ala.volunteer.Template
import au.org.ala.volunteer.TemplateField
import au.org.ala.volunteer.DarwinCoreField
import org.codehaus.groovy.grails.commons.ApplicationHolder

class BootStrap {

    javax.sql.DataSource dataSource

    def init = { servletContext ->

      //add a utility method for creating a map from a arraylist
      java.util.ArrayList.metaClass.toMap = { ->
        def myMap = [:]
        delegate.each { keyCount ->
          myMap.put keyCount[0], keyCount[1]
        }
        myMap
      }

      //DDL - add cascading, currently not working from generated DDL from grails
      def sql = new groovy.sql.Sql(dataSource)
      sql.execute("""
          alter table multimedia drop constraint FK4B39F64BCBAB13A;
          alter table picklist_item drop constraint FKE7584B1388EA2EFA;
          alter table project drop constraint FKED904B19AD0C811A;
          alter table task drop constraint FK363585D7B4217A;
          alter table viewed_task drop constraint FK2B205EE0CBAB13A;
          alter table task add constraint FK363585D7B4217A
              foreign key (project_id) references project ON DELETE CASCADE;
          alter table multimedia add constraint FK4B39F64BCBAB13A
              foreign key (task_id) references task ON DELETE CASCADE;
          alter table picklist_item add constraint FKE7584B1388EA2EFA
              foreign key (picklist_id) references picklist ON DELETE CASCADE;
          alter table viewed_task add constraint FK2B205EE0CBAB13A
              foreign key (task_id) references task ON DELETE CASCADE;
        """)
        
        // add some picklist values if not already loaded
        println("creating picklists...")
        def items = ["country", "stateProvince", "typeStatus", "institutionCode", "recordedBy", "coordinatePrecision"]
        items.each {
            println("checking picklist: " + it)
            if (!Picklist.findByName(it)) {
                println("creating new picklist " + it)
                Picklist picklist = new Picklist(name:it).save(flush:true, failOnError: true)
                def text = ApplicationHolder.application.parentContext.getResource("classpath:resources/"+it+".csv").inputStream.text
                text.eachLine {
                    def picklistItem = new PicklistItem()
                    picklistItem.picklist = picklist
                    picklistItem.value = it
                    picklistItem.save(flush:true, failOnError: true)
                }
            }
        }
        // Create default template if not in DB
        Template template = Template.findByName('default')
        if (!template) {
            println "creating new Template: default"
            template = new Template(name:'default', viewName:'Default', author:'webmaster@ala.org.au', 
                created:new Date(), fieldOrder:'').save(flush:true, failOnError: true)
        }
        
        // populate default set of TemplateFields
        def fields = ApplicationHolder.application.parentContext.getResource("classpath:resources/defaultFields.csv").inputStream.text
        fields.eachLine { line ->
            String[] fs = line.split(',')
            DarwinCoreField dwcf = DarwinCoreField.valueOf(fs[0])
            if (!TemplateField.findByFieldType(dwcf)) {
                println "creating new FieldType: " + fs + " size="+fs.size()
                TemplateField tf = new TemplateField(
                        fieldType: dwcf,
                        label: fs[1],
                        defaultValue: fs[2],
                        category: FieldCategory.valueOf(fs[3]),
                        type: FieldType.valueOf(fs[4]),
                        mandatory: ((fs[5] == '1') ? true : false),
                        multiValue: ((fs[6] == '1') ? true : false),
                        helpText: fs[7],
                        validationRule: fs[8],
                        template: template
                ).save(flush:true, failOnError: true)
            } else {
                println "Field already exists: " + fs[0]
            }
        }

        //add templates
//      sql.execute("""
//          TRUNCATE TEMPLATE CASCADE;
//          INSERT INTO template (id, name, view_name) VALUES (1, 'Specimen Transcription', 'specimenTranscribe');
//        """)
    }
    def destroy = {
    }
}
