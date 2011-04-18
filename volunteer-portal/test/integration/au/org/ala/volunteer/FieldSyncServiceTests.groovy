package au.org.ala.volunteer

import grails.test.*

class FieldSyncServiceTests extends GroovyTestCase {

    def fieldSyncService

    void testFieldSync() {
      def project = new Project(name:"Test Project for Field Sync")
      project.save(flush:true)
      def task = new Task(project:project)
      task.save(flush:true)
      def recordValues = ["0.latitude":"4", "0":["latitude":"4", "scientificName":"4", "longitude":"4", "locality":"4"], "0.scientificName":"4", "0.longitude":"4", "0.locality":"4"]
      fieldSyncService.syncFields(task, recordValues, "dave")
    }
}
