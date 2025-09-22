package au.org.ala.volunteer

import grails.testing.services.ServiceUnitTest
import spock.lang.Specification

class ImageServiceSpec extends Specification implements ServiceUnitTest<ImageService>{

    def imagesHome

    def setup() {
        imagesHome = "/mock/images"
        grailsApplication.config.images.home = imagesHome
    }

    def cleanup() {
    }

    void "findImageWithSupportedExtension should return file when image with supported extension exists"() {
        given:
        GroovySpy(File, global: true, useObjenesis: true)
        def prefix = "wildlifespotter"
        def name = "image1"

        def imagePath = "${imagesHome}/${prefix}"
        def fileNamePng = "${name}.png"
        def mockImage = Mock(File)
        mockImage.exists() >> true

        // Cover all possible constructor usages
        new File(imagePath, fileNamePng) >> mockImage
        new File(new File(imagePath), fileNamePng) >> mockImage
        new File("${imagePath}/${fileNamePng}") >> mockImage

        when:
        def result = service.findImageWithSupportedExtension(prefix, name)

        then:
        result == mockImage
    }

    void "findImageWithSupportedExtension should handle null prefix and return null"() {
        given:
        GroovySpy(File, global: true, useObjenesis: true)
        def prefix = null
        def name = "image1"

        def imagePath = "${imagesHome}"
        def fileNamePng = "${name}.png"
        def mockImage = Mock(File)
        mockImage.exists() >> false
        new File(_, _) >> mockImage

        when:
        def result = service.findImageWithSupportedExtension(prefix, name)

        then:
        result == null
    }

    void "findImageWithSupportedExtension should handle null name and return null"() {
        given:
        GroovySpy(File, global: true, useObjenesis: true)
        def prefix = "wildlifespotter"
        def name = null

        def mockImage = Mock(File)
        mockImage.exists() >> false
        new File(_, _) >> mockImage

        when:
        def result = service.findImageWithSupportedExtension(prefix, name)

        then:
        result == null
    }
}
