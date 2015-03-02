package au.org.ala.volunteer

import groovy.transform.ToString
import org.codehaus.groovy.control.CompilationFailedException

class AchievementDescription {

    String name
    String description
    String badge

    boolean enabled = false

    // Discriminate with this instead of polymorphism
    AchievementType type = AchievementType.ELASTIC_SEARCH_QUERY
    
    // full json?
    // template string with task.id, task.???, task.fields.???, user.id, user.???
    // eg
    /*
{
    "filtered" : {
        "filter" : {
            "range" : {
                "dateFullyValidated" : {
                    "gt" : now-2M
                }
            }
        }
    }
}
     */
    String searchQuery
    Integer count

    String aggregationQuery
    AggregationType aggregationType = AggregationType.CODE


    // Should return boolean?
    // Provide access to current user, updated task, Task / Field / ??? Repos?
    String code
    
    static hasMany = [awards: AchievementAward]

    Long version
    
    Date dateCreated
    Date lastUpdated
    
    static constraints = {
        description maxSize: 1000
        code nullable: true, minSize: 0, maxSize: 10000, widget: 'textArea', validator: { val, obj, errors ->
            if (obj.type != AchievementType.GROOVY_SCRIPT
                    && (obj.aggregationType != AggregationType.CODE) || obj.type != AchievementType.ELASTIC_SEARCH_AGGREGATION_QUERY)
                return true

            if (!val || obj.count == null) return false
            try {
                new GroovyShell().parse(val)
                return true
            } catch (CompilationFailedException e) {
                log.error("Compilation failed for groovy code:\n\n$val\n", e)
                return false
            }
        }
        searchQuery nullable: true, minSize: 0, maxSize: 10000, widget: 'textArea', validator: { val, obj, errors ->
            if (obj.type != AchievementType.ELASTIC_SEARCH_QUERY) return true
            if (!val) return false
        }
        count nullable: true, validator: { val, obj, errors ->
            if (obj.type != AchievementType.ELASTIC_SEARCH_QUERY) return true
            if (val == null || val < 0) return false
        }
        aggregationQuery nullable: true, minSize: 0, maxSize: 10000, widget: 'textArea', validator: { val, obj, errors ->
            if (obj.type != AchievementType.ELASTIC_SEARCH_AGGREGATION_QUERY) return true
            if (!val) return false
        }
        aggregationType nullable: true, validator: { val, obj, errors ->
            if (obj.type != AchievementType.ELASTIC_SEARCH_AGGREGATION_QUERY) return true
            if (val == null) return false
        }
    }

    public String toString() {
        "AchievementDescription (id: $id, name: ${name})"
    }
}
