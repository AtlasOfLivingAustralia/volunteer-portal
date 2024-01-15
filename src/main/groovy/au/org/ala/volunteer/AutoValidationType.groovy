package au.org.ala.volunteer

/**
 * AutoValidationType is a set of allowed options when system validating wildlife spotter expeditions.
 */
enum AutoValidationType {
    speciesOnly("Validate on Species only"),
    speciesWithCount("Validate on Species and count")

    def label

    AutoValidationType(String label) {
        this.label = label
    }

    /**
     * Returns the default validation type.
     * @return the default validation type.
     */
    static AutoValidationType getDefault() {
        speciesWithCount
    }

    /**
     * Translates an enum object from the string value. Returns the correlating validation type.
     * @param validationType the validation type in string form.
     * @return the validation type or default if not known.
     */
    static AutoValidationType fromString(String validationType) {
        if (validationType) {
            validationType as AutoValidationType
        } else {
            getDefault()
        }
    }
}