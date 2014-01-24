package au.org.ala.volunteer


import java.awt.Image
import java.awt.Rectangle
import java.awt.geom.AffineTransform
import java.awt.image.AffineTransformOp
import java.awt.image.BufferedImage
import java.text.DecimalFormat
import javax.imageio.ImageIO
import org.imgscalr.Scalr

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
        return Scalr.resize(src, Scalr.Method.SPEED, destWidth, destHeight, Scalr.OP_ANTIALIAS, Scalr.OP_BRIGHTER);
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

}
