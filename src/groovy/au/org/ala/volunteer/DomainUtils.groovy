package au.org.ala.volunteer

class DomainUtils {
    /**
     * Check that o is an instanceOf aClass, using the gorm .instanceOf(aClass) method but
     * swallowing the methodnotfoundexception if o isn't a gorm object.
     *
     * @param o The Object to check
     * @param aClass The type to check
     * @return true if o is an instanceof aClass, false otherwise
     */
    static boolean instanceOf(o, Class<?> aClass) {
        if (o == null) return false // short circuit try block
        try {
            return o.instanceOf(aClass)
        } catch (MissingMethodException e) {
            return aClass.isInstance(o)
        }
    }
}
