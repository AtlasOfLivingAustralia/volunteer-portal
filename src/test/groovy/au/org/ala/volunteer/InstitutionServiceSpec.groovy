package au.org.ala.volunteer

import grails.testing.services.ServiceUnitTest
import spock.lang.Specification

class InstitutionServiceSpec extends Specification implements ServiceUnitTest<InstitutionService> {

    def cleanup() {
        GroovySystem.metaClassRegistry.removeMetaClass(Task)
        GroovySystem.metaClassRegistry.removeMetaClass(Field)
    }

    def "countTranscribedTasksForInstitution uses a single aggregate query"() {
        given:
        def institution = new Institution(id: 42L, name: 'Test Institution')
        String query = null
        Map params = null
        Task.metaClass.static.executeQuery = { String q, Map p ->
            query = q
            params = p
            [9]
        }

        when:
        def count = service.countTranscribedTasksForInstitution(institution)

        then:
        count == 9
        query == 'select count(*) from Task where isFullyTranscribed = true and project.institution = :institution'
        params == [institution: institution]
    }

    def "countSpeciesTranscribedForInstitution filters by project institution association"() {
        given:
        def institution = new Institution(id: 42L, name: 'Test Institution')
        String query = null
        Map params = null
        Field.metaClass.static.executeQuery = { String q, Map p ->
            query = q
            params = p
            [1]
        }

        when:
        def count = service.countSpeciesTranscribedForInstitution(institution)

        then:
        count == 1
        query.replaceAll(/\s+/, ' ').trim() == 'select count(distinct f.value) from Field f join f.task t join t.project p where f.name = :fieldName and p.institution = :institution'
        params == [fieldName: 'scientificName', institution: institution]
    }
}


