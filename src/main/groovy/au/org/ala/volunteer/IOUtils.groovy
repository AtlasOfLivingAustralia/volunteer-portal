package au.org.ala.volunteer

class IOUtils {

    protected static final int MAX_DIR_NAME_LENGTH = 200
    protected static final int MAX_FILE_NAME_LENGTH = 128

    /**
     * Converts any string into a string that is safe to use as a file name. The
     * result will only include ascii characters and numbers, and the "-","_",
     * characters.
     *
     * @param name
     * @return safe name of the directory
     */
    static String toFileSystemDirectorySafeName(String name) {
        return toFileSystemSafeName(name, MAX_DIR_NAME_LENGTH);
    }

    static String toFileSystemSafeName(String name) {
        return toFileSystemSafeName(name, MAX_FILE_NAME_LENGTH);
    }

    /**
     * Converts any string into a string that is safe to use as a file name. The
     * result will only include ascii characters and numbers, and the "-","_",
     * characters.
     *
     * @param name
     * @param maxFileLength
     * @return file system safe name
     */
    static String toFileSystemSafeName(String name, int maxFileLength) {
        def result = name.replaceAll("[^a-zA-Z0-9-_]", "_")
        if (result.length() > maxFileLength) {
            result = result.substring(result.length() - maxFileLength, result.length())
        }
        return result;
    }
}
