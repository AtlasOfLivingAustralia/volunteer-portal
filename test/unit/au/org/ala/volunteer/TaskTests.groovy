package au.org.ala.volunteer

import grails.test.*

class TaskTests extends GrailsUnitTestCase {
    protected void setUp() {
        super.setUp()
    }

    protected void tearDown() {
        super.tearDown()
    }

    void testSomething() {
       def p = new Project()
      p.name = "Test Project"
      println("has errors: " + p.hasErrors())
      p.save(flush:true)

      Task t = new Task()
      t.project = p
      t.save(flush:true)
    }
}
