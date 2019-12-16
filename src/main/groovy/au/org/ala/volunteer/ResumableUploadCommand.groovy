package au.org.ala.volunteer

import com.google.common.hash.Hashing
import com.google.common.hash.HashingInputStream
import com.google.common.io.Files
import grails.validation.Validateable
import groovy.transform.ToString
import groovy.util.logging.Slf4j

@ToString
@Slf4j
class ResumableUploadCommand implements Validateable {

    def stagingService

    long projectId

    int resumableChunkNumber
    int resumableChunkSize
    int resumableCurrentChunkSize
    long resumableTotalSize
    int resumableTotalChunks
    // These are Sets because the resumable.js code sends both query string and form body params of the same name
    // and if left as String then the values are concatenated (whereas the ints above are not)
    Set<String> resumableType
    Set<String> resumableIdentifier
    Set<String> resumableFilename
    Set<String> resumableRelativePath

    Set<String> checksum
    Set<String> completeChecksum

    static constraints = {
        resumableChunkSize min: 0
        resumableCurrentChunkSize min: 0
        resumableTotalSize min: 0l
        resumableChunkNumber min: 1
        resumableTotalChunks min: 1
        resumableIdentifier minSize: 1, maxSize: 1
        resumableFilename minSize: 1, maxSize: 1
        resumableRelativePath minSize: 1, maxSize: 1
        checksum minSize: 1, maxSize: 1
        completeChecksum minSize: 1, maxSize: 1
    }


    private String _path
    String getPath() {
        if (!_path) {
            _path = stagingService.createStagedPath(projectId, filename)
        }
        return _path
    }

    File getUploadChunkPath() {
        new File(chunkDir, "$identifier-upload$resumableChunkNumber")
    }

    private String _chunkDirPath
    String getChunkDirPath() {
        if (!_chunkDirPath) {
            _chunkDirPath = stagingService.createUploadChunksPath(projectId, filename)
        }
        return _chunkDirPath
    }

    File getChunkDir() {
        def result = new File(chunkDirPath)
        result.mkdirs()
        return result
    }

    File getCompleteChunkFile() {
        new File(chunkDir, chunkFilenameForItem(resumableChunkNumber))
    }

    String getIdentifier() {
        stringParam(resumableIdentifier)
    }

    String getFilename() {
        stringParam(resumableFilename)
    }

    String getType() {
        stringParam(resumableType)
    }

    String getRelativePath() {
        stringParam(resumableRelativePath)
    }

    private static String stringParam(Collection<String> params) {
        params.isEmpty() ? null : params.first()
    }

    String chunkFilenameForItem(int item) {
        "$identifier-chunk$item"
    }

    /**
     * Test if a resumable chunk is complete.
     * First check if the final chunk already exists and if so, check the checksum matches
     * If the final chunk is missing, check whether the whole file is already uploaded and
     * is of the same length and MD5
     *
     * @return True if this chunk already exists on the server
     */
    boolean isChunkComplete() {

        def c = completeChunkFile
        def f = new File(path)
        if (c.exists()) {
            def calculatedChecksum = Files.hash(c, Hashing.md5()).toString()
            def checksum = stringParam(checksum)
            log.debug("checksums calculated: {}, received: {}", calculatedChecksum, checksum)

            def result = calculatedChecksum == checksum
            if (result) {
                checkCompleteFile()
            }

            return result
        } else if (f.exists())  {
            if (f.length() != resumableTotalSize) return false

            def calculatedChecksum = Files.hash(f, Hashing.md5()).toString()
            def checksum = stringParam(completeChecksum)
            log.debug("checksums calculated: {}, received: {}", calculatedChecksum, checksum)

            return calculatedChecksum == checksum
        }

        return false
    }

    /**
     * Upload this chunk from the inputstream and check the MD5 hash
     *
     * @param inputStream The inputstream containing this chunk
     * @return Whether the MD5 hash of the input stream matches this MD5 hash
     */
    boolean uploadAndCheckChunk(InputStream inputStream) {
        File chunkFile = uploadChunkPath

        def stream = new HashingInputStream(Hashing.md5(), inputStream)
        stream.withStream {
            chunkFile.withOutputStream { out ->
                def bytes = org.apache.commons.io.IOUtils.copyLarge(stream, out)
                log.debug("bytes copied {}, expecting {}", bytes, resumableCurrentChunkSize)
            }
        }
        def calculatedChecksum = stream.hash().toString()
        def checksum = stringParam(checksum)
        log.debug("checksums calculated: {}, received: {}", calculatedChecksum, checksum)

        def result = calculatedChecksum == checksum
        if (result) {
            Files.move(chunkFile, completeChunkFile)
            checkCompleteFile()
        }

        return result
    }

    /**
     * Check whether the whole file this chunk belongs to is complete and, if so,
     * complete it
     */
    def checkCompleteFile() {

        def srcs = (1..resumableTotalChunks).collect { i -> new File(chunkDir, chunkFilenameForItem(i)) }
        def complete = srcs.every { it.exists() }

        if (complete) {
            def dest = File.createTempFile(filename, null)

            def calculatedCompleteChecksum = IOUtils.combineFilesAndMd5(dest, srcs)
            def completeChecksum = stringParam(completeChecksum)
            log.debug("checking calculatedCompleteChecksum {} against completeChecksum {}", calculatedCompleteChecksum, completeChecksum)
            if (calculatedCompleteChecksum != completeChecksum) {
                log.error("Checksums don't match calculatedCompleteChecksum {} against completeChecksum {}", calculatedCompleteChecksum, completeChecksum)
            }
            def finalDest = new File(path)
            if (finalDest.exists()) finalDest.delete()
            Files.move(dest, finalDest)
            srcs.each { it.delete() }

            log.debug("Successfully uploaded {} for project {}", filename, projectId)
        }
    }
}