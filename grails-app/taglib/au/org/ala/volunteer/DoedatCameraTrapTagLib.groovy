package au.org.ala.volunteer

class DoedatCameraTrapTagLib extends CameraTrapTagLib {

    static namespace = "dct"

    Map readImageInfo(allImageIds,warnings) {

        Map result = [:]
        allImageIds.each({ imageId ->
            result.put(imageId,
                    [
                            "squareThumbUrl": imageId,
                            "imageUrl": imageId
                    ])
        })

        return result;
    }
}
