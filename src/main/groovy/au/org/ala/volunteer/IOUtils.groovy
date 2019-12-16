package au.org.ala.volunteer

import com.google.common.hash.HashFunction
import com.google.common.hash.Hashing
import com.google.common.hash.HashingOutputStream

class IOUtils {

    protected static final int MAX_DIR_NAME_LENGTH = 200
    protected static final int MAX_FILE_NAME_LENGTH = 128
    public static final int DEFAULT_BUFFER_SIZE = 1024 * 4

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

    /**
     * Combine the list files into the single file parameter and produce and md5 hash of the
     * resulting single file whilst doing it.
     *
     * @param file The destination file
     * @param files The list of source files, in order
     * @return The MD5 hash of the destination file
     */
    static String combineFilesAndMd5(File file, List<File> files) {
        def hos = new HashingOutputStream(Hashing.md5(), file.newOutputStream())
        hos.withStream {
            files.each {
                it.withInputStream { fis ->
                    org.apache.commons.io.IOUtils.copyLarge(fis, hos)
                }
            }
            hos.flush()
        }
        return hos.hash().toString()
    }
}
