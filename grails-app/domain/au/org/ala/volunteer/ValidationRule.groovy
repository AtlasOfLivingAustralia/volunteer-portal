package au.org.ala.volunteer

class ValidationRule {

    String name
    String description
    String message
    String regularExpression
    Boolean testEmptyValues
    ValidationType validationType = ValidationType.Warning

    static constraints = {
        name nullable: false, unique: true
        description nullable: true
        message nullable: true
        regularExpression nullable: true
        testEmptyValues nullable: true
        validationType nullable: true
    }

}
