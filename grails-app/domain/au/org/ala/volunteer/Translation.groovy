package au.org.ala.volunteer

class Translation implements Serializable {

    public static Locale DEFAULT_LOCALE = Locale.US;

    Translation() {}
    Translation(String defaultTranslation) {
        this[DEFAULT_LOCALE.toString()] = defaultTranslation;
    }
    Translation(String locale, String translation) {
        this[locale] = translation;
    }

    String en_US;
    String nl_BE;
    String de_DE;
    String fr_FR;

    static constraints = {
        en_US nullable: true, type: 'text'
        nl_BE nullable: true, type: 'text'
        de_DE nullable: true, type: 'text'
        fr_FR nullable: true, type: 'text'
    }

    String toString() {
        return WebUtils.safeGet(this,WebUtils.getCurrentLocaleAsString())?:WebUtils.safeGet(this,DEFAULT_LOCALE.toString());
    }
}
