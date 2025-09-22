package au.org.ala.volunteer

class ImageService {

    def grailsApplication

    public static final TYPES = [
            '.jpg','.jpeg', '.png', '.gif', '.bmp', '.webp',
            '.tiff', '.tif',
            '.svg',
            '.jp2', '.j2k', '.jpf', '.jpx', '.jpm', '.mj2',
            '.jxr', '.hdp', '.wdp',
            '.apng',
            '.mng',
            '.xbm',
            '.ico'
    ]

    /**
     * Find an image file with one of the known extensions.
     * @param prefix the directory prefix (e.g. projectId/taskId)
     * @param name the base name of the file (without extension)
     * @return the file if found, null if not found
     */
    File findImageWithSupportedExtension(String prefix, String name) {
        def imagesHome = grailsApplication.config.getProperty('images.home') as String
        log.debug("Searching for image with prefix: $prefix, name: $name in $imagesHome")
        File home = new File(imagesHome, prefix)
        log.debug("Looking for image in $home with name $name")
        for (String ext : TYPES) {
            log.debug("Checking for image with extension: $ext")
            def f = new File(home, name + ext)
            log.debug("Checking for file: $f")
            if (f.exists()) {
                log.debug("Found image: $f")
                return f
            }
        }
        log.debug("No image found with prefix: $prefix, name: $name")
        return null
    }

    /**
     * Check if an image exists.
     * @param parent the parent directory (e.g. projectId/taskId)
     * @param name the base name of the file (without extension)
     * @param format the file extension (without leading dot)
     * @return true if the image exists, false if not
     */
    def imageExists(String parent, String name, String format) {
        log.debug("Checking for image with parent: $parent, name: $name")
        def imagePath = buildImagePath(parent, name, format)
        imagePath.exists()
    }

    /**
     * Get the image file.
     * @param parent the parent directory (e.g. projectId/taskId)
     * @param name the base name of the file (without extension)
     * @param format the file extension (without leading dot)
     * @return the image file
     */
    def getImageFile(String parent, String name, String format) {
        log.debug("Getting image with parent: $parent, name: $name")
        buildImagePath(parent, name, format)
    }

    /**
     * Build the image path.
     * @param parent the parent directory (e.g. projectId/taskId)
     * @param name the base name of the file (without extension)
     * @param format the file extension (without leading dot)
     * @return the image file
     */
    private File buildImagePath(String parent, String name, String format) {
        log.debug("Building image path with parent: $parent, name: $name, format: $format")
        def imagesHome = grailsApplication.config.getProperty('images.home') as String
        def encodedParent = IOUtils.toFileSystemDirectorySafeName(parent)
        def encodedName = IOUtils.toFileSystemSafeName(name) + ".$format"
        log.debug("Looking for image in $imagesHome${File.separator}$encodedParent, file: $encodedName")
        new File("$imagesHome${File.separator}$encodedParent", encodedName)
    }
}
