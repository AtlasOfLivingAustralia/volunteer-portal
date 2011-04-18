package au.org.ala.volunteer

import grails.test.*

class TaskServiceTests extends GroovyTestCase {

    def taskService

    protected void setUp() {
        super.setUp()
    }

    protected void tearDown() {
        super.tearDown()
    }

    void testCSVLoad() {
      def project = new Project(name:"Test Project For TaskLoad Test")
      project.save(flush:true)
      taskLoadService.loadCSV(project.id.toInteger(), "AM1,http://bie.ala.org.au/repo/1013/128/1284064/raw.jpg")
    }

    void testProjectCounts(){
      def project1 = new Project(name:"Test Project1 For Project Counts")
      project1.save(flush:true)
      def project2 = new Project(name:"Test Project2 For Project Counts")
      project2.save(flush:true)

      //add some tasks
      new Task(project1).save(flush:true)
      new Task(project1).save(flush:true)
      new Task(project2).save(flush:true)

      Map counts = taskService.getProjectTaskCounts()

      assert counts.get(project1) == 2
    }
}
