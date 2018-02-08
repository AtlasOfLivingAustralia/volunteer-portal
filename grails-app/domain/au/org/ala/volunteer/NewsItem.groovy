package au.org.ala.volunteer

import au.org.ala.volunteer.sanitizer.SanitizedHtml

class NewsItem implements Serializable {

    Institution institution
    Project project

    Translation i18nTitle
    Translation i18nShortDescription
    @SanitizedHtml
    Translation i18nBody


    Date created
    String createdBy

    static constraints = {
        //body nullable: true, maxSize: 4000, widget:'textarea'
        //shortDescription nullable: true
        project nullable: true
        institution nullable: true, validator: { val, obj -> val == null && obj.project == null ? "projectOrInstitutionRequired" : null }
    }

    public String toString() {
        return i18nTitle
    }
}
