package au.org.ala.volunteer

import com.drew.imaging.ImageMetadataReader
import com.drew.imaging.ImageProcessingException
import com.drew.metadata.exif.ExifIFD0Directory
import com.drew.metadata.Directory
import com.drew.metadata.Metadata
import com.drew.metadata.Tag
import com.drew.metadata.exif.ExifSubIFDDirectory
import groovy.util.logging.Slf4j
import org.apache.commons.io.FilenameUtils
import org.imgscalr.Scalr

import javax.imageio.ImageIO
import java.awt.*
import java.awt.image.BufferedImage
import java.text.DecimalFormat

import static java.lang.Math.round

@Slf4j
public class ImageUtils {


    static {
        ImageIO.useCache = false
    }

    public static Rectangle getThumbBounds(int srcWidth, int srcHeight, int targetWidth, int targetHeight) {
        while (srcHeight > targetHeight || srcWidth > targetWidth) {
            if (srcHeight > targetHeight) {
                double ratio = (double) (targetHeight) / (double) srcHeight;
                srcHeight = targetHeight;
                srcWidth = (int) ((double) srcWidth * ratio);
            }

            if (srcWidth > targetWidth) {
                double ratio = (double) (targetWidth) / (double) srcWidth;
                srcWidth = targetWidth;
                srcHeight = (int) ((double) srcHeight * ratio);
            }
        }

        return new Rectangle(0, 0, srcWidth, srcHeight);
    }

    public static getScaledHeight(int sourceWidth, int sourceHeight, int destWidth) {
        double ratio = (double) (destWidth) / (double) sourceWidth;
        return (int) (sourceHeight * ratio);
    }

    public static BufferedImage bytesToImage(Image imageInstance, byte[] bytes) {
        ByteArrayInputStream bais = null
        try {

            if (imageInstance.mimeType?.equalsIgnoreCase('application/pdf')) {
                return createImageFromPDFBytes(bytes)
            } else {
                bais = new ByteArrayInputStream(bytes)
                return ImageIO.read(new BufferedInputStream(bais))
            }
        } finally {
            if (bais) {
                bais.close()
            }
        }
    }

    static int IMAGE_BUF_INIT_SIZE = 2 * 1024 * 1024

    public static byte[] imageToBytes(BufferedImage image) {
        try {
            ByteArrayOutputStream baos = new ByteArrayOutputStream(IMAGE_BUF_INIT_SIZE)
            ImageIO.write(image, "JPG", baos)
            return baos.toByteArray()
        } finally {
        }
    }

    public static BufferedImage scaleWidth(BufferedImage src, int destWidth) {
        return Scalr.resize(src, Scalr.Method.SPEED, destWidth, Scalr.OP_ANTIALIAS, Scalr.OP_BRIGHTER);
    }

    public static BufferedImage scale(BufferedImage src, int destWidth, int destHeight) {
        return Scalr.resize(src, Scalr.Method.ULTRA_QUALITY, Scalr.Mode.FIT_EXACT, destWidth, destHeight, Scalr.OP_ANTIALIAS, Scalr.OP_BRIGHTER);
    }

    public static BufferedImage rotateImage(BufferedImage image, int degrees) {

        Scalr.Rotation rotation = null;
        switch (degrees) {
            case 90:
                rotation = Scalr.Rotation.CW_90
                break;
            case 180:
                rotation = Scalr.Rotation.CW_180;
                break;
            case 270:
                rotation = Scalr.Rotation.CW_270;
                break;
        }

        if (rotation) {
            return Scalr.rotate(image, rotation, null)
        }

//        AffineTransform tx = new AffineTransform();
//        tx.translate(image.getHeight() / 2, image.getWidth() / 2);
//        tx.rotate(Math.toRadians(degrees));
//        tx.translate(-image.getWidth() / 2, -image.getHeight() / 2);
//        AffineTransformOp op = new AffineTransformOp(tx, AffineTransformOp.TYPE_BILINEAR);
//        BufferedImage dest = new BufferedImage(image.getHeight(), image.getWidth(), image.getType());
//        op.filter(image, dest);
//        return dest
    }

    public static String formatFileSize(double filesize) {
        def labels = [ ' bytes', 'KB', 'MB', 'GB' ]
        def label = labels.find { ( filesize < 1024 ) ? true : { filesize /= 1024 ; false }() } ?: 'TB'
        return "${new DecimalFormat( '0.#' ).format( filesize )} $label"
    }

    static BufferedImage centreCropAndScale(BufferedImage src, int targetWidth, int targetHeight) {
        def cropped = centreCrop(src, ((double)targetWidth) / ((double)targetHeight))
        def scaled = Scalr.resize(cropped, targetWidth, targetHeight)
        if  (!cropped.is(src)) {
            cropped.flush()
        }
        return scaled
    }

    static BufferedImage centreCrop(BufferedImage src, double targetRatio) {
        double width = (double)src.getWidth()
        double height = (double)src.getHeight()
        double aspectHeight = width / targetRatio
        double aspectWidth = height * targetRatio

        if (aspectHeight < height) {
            return Scalr.crop(src, 0, (int)round((height - aspectHeight) / 2.0), src.width, (int)round(aspectHeight))
        } else if (aspectWidth < width) {
            return Scalr.crop(src, (int)round((width - aspectWidth) / 2.0), 0, (int)round(aspectWidth), src.height)
        } else {
            return src
        }
    }

    static String contentType(String format) {
        switch(format) {
            case 'jpg': return 'image/jpeg'
            case 'png': return 'image/png'
            case 'gif': return 'image/gif'
        }
        return 'application/octet-stream'
    }

    /**
     * Extracts EXIF data from the supplied image file and returns a Map with key: tag name and value: tag value.
     */
    static Map getExifMetadata(File file) {
        Map exif = [:]

        Metadata metadata = ImageMetadataReader.readMetadata(file)

        for (Directory directory : metadata.getDirectories()) {
            for (Tag tag : directory.getTags()) {
                String description = tag.getDescription()
                if (description == null)
                    description = directory.getString(tag.getTagType()) + " (unable to formulate description)"
                exif.put("[" + directory.getName() + "] " + tag.getTagName(),description)
            }
        }

        return exif
    }

    static Date getDateTaken(File file) {
        Metadata metadata = ImageMetadataReader.readMetadata(file)
        ExifSubIFDDirectory directory = metadata.getFirstDirectoryOfType(ExifSubIFDDirectory.class)

        (directory ? directory.getDate(ExifSubIFDDirectory.TAG_DATETIME_ORIGINAL) : null)
    }

    /**
     * Reads the exif data from the supplied file, and if it's available, checks the image orientation.
     * If necessary, a processed version of the image will be created and written to the supplied file.
     *
     * @param original the file to check and rotate if necessary
     * @param rotated a placeholder for the output, must not exist already.
     * @return true if processing was performed.
     */
    static boolean reorientImage(File original, File output) {
        int orientation = getOrientation(original)

        ArrayList<Scalr.Rotation> transforms = new ArrayList<Scalr.Rotation>()
        switch (orientation) {

            case 1:
                break // Image is already oriented correctly
            case 2:
                transforms << Scalr.Rotation.FLIP_HORZ
                break
            case 3:
                transforms << Scalr.Rotation.CW_180
                break
            case 4:
                transforms << Scalr.Rotation.FLIP_VERT
                break
            case 5:
                transforms << Scalr.Rotation.CW_90
                transforms << Scalr.Rotation.FLIP_HORZ
                break
            case 6:
                transforms << Scalr.Rotation.CW_90
                break
            case 7:
                transforms << Scalr.Rotation.CW_90
                transforms << Scalr.Rotation.FLIP_VERT
                break
            case 8:
                transforms << Scalr.Rotation.CW_270
                break
        }

        boolean processed = false

        if (transforms) {
            BufferedImage result = ImageIO.read(original)

            transforms.each { transform ->
                result = Scalr.rotate(result, transform, null)
            }
            processed = ImageIO.write(result, FilenameUtils.getExtension(original.name), output)
        }
        processed
    }

    /**
     * Returns the orientation tag from the image EXIF data, if available.  If no EXIF data exists,
     * this method returns 0.
     * @param file the image file to check.
     * @return the value of the EXIF orientation tag, or 0 if no EXIF data was found.
     */
    private static int getOrientation(File file) {
        int orientation = 0

        try {
            Metadata metadata = ImageMetadataReader.readMetadata(file)
            Directory dir = metadata.getFirstDirectoryOfType(ExifIFD0Directory.class)

            if (dir && dir.containsTag(ExifIFD0Directory.TAG_ORIENTATION)) {
                orientation = dir.getInt(ExifIFD0Directory.TAG_ORIENTATION)
            }
        }
        catch (ImageProcessingException e) {
            log.info("Unsupported file type encountered when attempting to read image metadata: ${file.name}")
        }

        return orientation
    }
}
