package au.org.ala.volunteer

import grails.test.*

class ProjectControllerTests extends ControllerUnitTestCase {
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
    }
}
