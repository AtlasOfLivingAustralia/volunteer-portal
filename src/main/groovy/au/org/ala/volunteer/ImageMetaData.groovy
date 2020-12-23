package au.org.ala.volunteer

class ImageMetaData implements Serializable {
    int height
    int width
    String url

    String toString() {
        return "ImageMetaData: [height: ${height}, width: ${width}, url: ${url}]"
    }
}
