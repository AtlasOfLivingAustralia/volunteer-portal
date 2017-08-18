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
        en_US maxSize: 2000, nullable: true
        nl_BE maxSize: 2000, nullable: true
        de_DE maxSize: 2000, nullable: true
        fr_FR maxSize: 2000, nullable: true
    }

    String toString() {
        return WebUtils.safeGet(this,WebUtils.getCurrentLocaleAsString())?:WebUtils.safeGet(this,DEFAULT_LOCALE.toString());
    }
}
