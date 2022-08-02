package au.org.ala.volunteer

import com.google.common.hash.HashCode
import com.google.common.hash.Hashing
import com.google.common.hash.HashingInputStream
import org.apache.commons.io.FilenameUtils
import org.springframework.web.multipart.MultipartFile

class FileUploadService {

    def grailsApplication

    List<Map> uploadImages(String directory, Map<String, List<MultipartFile>> fileMap) {

        if (!directory) throw new IllegalArgumentException('directory can not be empty')
        def imagesHome = grailsApplication.config.images.home
        if (!imagesHome) throw new IllegalStateException('images.home not set')
        def imagesDir = new File(imagesHome, directory)
        if (!imagesDir.exists() && !imagesDir.mkdirs()) throw new IOException("Couldn't create $imagesHome/$directory")

        fileMap.collectMany { k, v ->
            v.collect { mpf ->
                try {
                    [k: k, of: mpf.originalFilename, file: uploadFile(imagesDir, mpf), error: null]
                } catch(e) {
                    log.error("Image upload failed: ${e.message}", e)
                    [k: k, of: mpf.originalFilename, file: null, error: e]
                }
            }
        }
    }

    File uploadImage(String directory, MultipartFile mpf) {
        if (!directory) throw new IllegalArgumentException('directory can not be empty')
        def imagesHome = grailsApplication.config.images.home
        if (!imagesHome) throw new IllegalStateException('images.home not set')
        def imagesDir = new File(imagesHome, directory)
        if (!imagesDir.exists() && !imagesDir.mkdirs()) throw new IOException("Couldn't create $imagesHome/$directory")

        uploadFile(imagesDir, mpf)
    }

    File uploadImage(String directory, MultipartFile mpf, Closure<String> renameFile) {
        if (!directory) throw new IllegalArgumentException('directory can not be empty')
        def imagesHome = grailsApplication.config.images.home as String
        if (!imagesHome) throw new IllegalStateException('images.home not set')
        def imagesDir = new File(imagesHome, directory)
        if (!imagesDir.exists() && !imagesDir.mkdirs()) throw new IOException("Couldn't create $imagesHome/$directory")

        uploadFile(imagesDir, mpf, renameFile)
    }

    File uploadFile(File directory, MultipartFile file) {
        uploadFile(directory, file) { MultipartFile f, HashCode hash ->
            f.originalFilename
        }
    }

    File uploadFile(File directory, MultipartFile file, Closure<String> renameFile) {
        File f = new File(directory, UUID.randomUUID().toString())
        try {
            def hashStream = new HashingInputStream(Hashing.sha256(), file.inputStream)
            hashStream.with {
                f.withOutputStream { os ->
                    os << hashStream
                }
            }
            def filename = renameFile(file, hashStream.hash())
            def result = new File(directory, filename)
            f.renameTo(result)
            log.info("Uploaded ${file.originalFilename} to $f and renamed to $result")
            return result
        } finally {
            // remove temp UUID file.
            if (f.exists()) {
                f.delete()
            }
        }
    }

    def extension(MultipartFile mpf) {
        def fromContentType = extension(mpf.contentType, '')
        if (fromContentType) {
            return fromContentType
        }
        return FilenameUtils.getExtension(mpf.originalFilename) ?: 'jpg'
    }

    def extension(String contentType, String defaultForNoMatch = 'bin') {
        def extension
        switch (contentType) {
            case 'image/jpeg':
                extension = 'jpg'
                break
            case 'image/png':
                extension = 'png'
                break
            case 'image/gif':
                extension = 'gif'
                break
            case 'image/webp':
                extension = 'webp'
                break
            case 'image/svg+xml':
                extension = 'svg'
                break
            default:
                extension = defaultForNoMatch
        }
        return extension
    }
}
