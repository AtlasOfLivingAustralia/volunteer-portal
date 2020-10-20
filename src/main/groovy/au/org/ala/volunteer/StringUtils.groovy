package au.org.ala.volunteer

class StringUtils {

    /**
     * Checks if a string variable is empty, i.e. null OR no length string.
     * @param var the string to check.
     * @return true if empty, false if not.
     */
    public static boolean isEmpty(String var) {
        if (var == null) return true
        if (var.equalsIgnoreCase("")) return true
        return false
    }
}
