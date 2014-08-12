package au.org.ala.volunteer

import au.org.ala.volunteer.collectory.CollectoryDto
import au.org.ala.volunteer.collectory.CollectoryProviderDto
import org.springframework.web.multipart.MultipartFile

class InstitutionService {

    def grailsApplication
    def collectoryClient
    def grailsLinkGenerator

    public uploadBannerImage(Institution institution, MultipartFile mpfile) {

        if (!institution || !mpfile) {
            return
        }

        try {
            def filePath = getBannerImagePath(institution.id)
            def file = new File(filePath);
            if (!file.getParentFile().exists()) {
                if (!file.getParentFile().mkdirs()) {
                    throw new RuntimeException("Failed to create institution directories: ${file.getParentFile().getAbsolutePath()}")
                }
            }

            mpfile.transferTo(file);

            return true
        } catch (Exception ex) {
            log.error("Failed to upload image file for institution", ex)
        }
    }

    public uploadLogoImage(Institution institution, MultipartFile mpfile) {

        if (!institution || !mpfile) {
            return
        }

        try {
            def filePath = getLogoImagePath(institution.id)
            def file = new File(filePath);
            file.getParentFile().mkdirs();
            mpfile.transferTo(file);
            return true
        } catch (Exception ex) {
            log.error("Failed to upload image file for institution", ex)
        }
    }

    public boolean hasBannerImage(Institution institution) {
        def f = new File(getBannerImagePath(institution?.id))
        return f.exists()
    }

    public boolean hasLogoImage(Institution institution) {
        def f = new File(getLogoImagePath(institution?.id))
        return f.exists()
    }

    public String getBannerImageUrl(Institution institution) {
        if (hasBannerImage(institution)) {
            return "${grailsApplication.config.server.url}/${grailsApplication.config.images.urlPrefix}institution/${institution.id}/banner-image.jpg"
        } else {
            return grailsLinkGenerator.resource([dir: '/images/banners', file: 'default-institution-banner.jpg'])
        }
    }

    public String getLogoImageUrl(Institution institution) {
        if (hasLogoImage(institution)) {
            return "${grailsApplication.config.server.url}/${grailsApplication.config.images.urlPrefix}institution/${institution.id}/logo-image.jpg"
        } else {
            return grailsLinkGenerator.resource([dir: '/images/banners', file: 'default-institution-logo.jpg'])
        }
    }

    private String getBannerImagePath(long institutionId) {
        return "${grailsApplication.config.images.home}/institution/${institutionId}/banner-image.jpg"
    }

    private String getLogoImagePath(long institutionId) {
        return "${grailsApplication.config.images.home}/institution/${institutionId}/logo-image.jpg"
    }


    public CollectoryProviderDto getCollectoryObjectFromUid(String uid) {

        CollectoryProviderDto provider = null
        if (uid?.toLowerCase()?.startsWith("in")) {
            provider = collectoryClient.getInstitution("$uid")
        } else if (uid?.toLowerCase()?.startsWith("co")) {
            provider = collectoryClient.getCollection("$uid")
        }

        return provider
    }

    public List<CollectoryDto> getCombinedInsitutionsAndCollections() {
        def results = collectoryClient.getInstitutions()
        def collections = collectoryClient.getCollections()
        // Merge the two lists
        results.addAll(collections)
        results.sort { it.name }

        return results
    }


    Institution findByIdOrName(Long id, String name) {
        Institution retVal
        if (id)  {
            retVal = Institution.get(id)
        } else {
            try {
               retVal = Institution.findByName(name)
            } catch (Exception e) {
                log.error("Exception", e)
                throw e
            }
        }
        return retVal
    }
}
