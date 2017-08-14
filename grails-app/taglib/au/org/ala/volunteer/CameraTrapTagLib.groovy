package au.org.ala.volunteer

import grails.converters.JSON
import org.grails.web.converters.exceptions.ConverterException

import static grails.async.Promises.*

class CameraTrapTagLib {
    static namespace = "ct"

    static defaultEncodeAs = [taglib: 'html']
    static encodeAsForTags = [cameraTrapImageInfos: [taglib:'none']]
    static returnObjectForTags = ['cameraTrapImageInfos']

    def userService
    def imageServiceService

    def cameraTrapImageInfos = { attrs, body ->
        Project project = attrs.project
        Picklist picklist = attrs.picklist
        def userId = userService.currentUserId
        def warnings = []

        if (!picklist) return [error: message(code: "cameraTrapTagLib.no_valid_picklist")]

        def valueCounts
        def myLast
        if (project.id == null) {
            valueCounts = task { [] }
            myLast = task { [] }
        } else {
            valueCounts = Field.async.executeQuery("select f.value, count(f.id) from Field f JOIN f.task t WHERE t.project.id = :projectId GROUP BY f.value", [projectId: project.id])
            myLast = Field.async.executeQuery("select distinct f.value, max(t.dateFullyTranscribed) from Field f JOIN f.task t WHERE t.project.id = :projectId AND t.fullyTranscribedBy = :userId GROUP BY f.value ORDER BY max(t.dateFullyTranscribed) DESC", [projectId: project.id, userId: userId])
        }

        def items = PicklistItem.findAllByPicklistAndInstitutionCode(picklist, project?.picklistInstitutionCode)

        // fallback to default picklist if institution code given and no items found
        if (project?.picklistInstitutionCode && !items) items = PicklistItem.findAllByPicklistAndInstitutionCodeIsNull(picklist)

        if (!items) return [error: message(code: "transcribeTagLib.no_picklist_items_found", args: [picklist.uiLabel, project?.picklistInstitutionCode])]

        def valueCountMap = valueCounts.get().collectEntries { [(it[0]): it[1]] }

        def myLastList = myLast.get()
        def count = 0
        def myLastMap = myLastList.collectEntries { [(it[0]): count++] }

        def allImageIds = []
        def items2 = items.collectEntries {
            def results
            try {
                def doc = JSON.parse(it.key)

                if (doc.reference) {
                    def tags = doc.tags
                    def dayImageIds = doc.dayImages
                    def nightImageIds = doc.nightImages
                    def imageIds = (dayImageIds + nightImageIds).findAll { it?.trim() != null }.collect { it?.trim() }
                    def similarSpecies = doc.similarSpecies
                    def popularity = valueCountMap.get(it.value) ?: 0
                    def lastUsed = myLastList.size() - (myLastMap.get(it.value) ?: myLastList.size())
                    results = [ (it.value): [imageIds: imageIds, value: it.value, tags: tags.toList(), dayImages: dayImageIds.toList(), nightImageIds: nightImageIds.toList(), similarSpecies: similarSpecies.toList(), popularity: popularity, lastUsed: lastUsed ] ]
                    allImageIds += imageIds
                } else {
                    results = [:]
                }

            } catch (ConverterException e) {
                warnings.add(message(code: "cameraTrapTagLib.could_not_parse_entry_for", args: [it.value]))
                results = [:]
            }
            results
        }

        //def imageIds = items2*.key.flatten()
        def imageInfos
        try {
            imageInfos = imageServiceService.getImageInfoForIds(allImageIds)
        } catch (e) {
            log.error("Error calling image service for ${allImageIds}", e)
            return [error: message(code: "transcribeTagLib.error_contacting_image_service", args: [e.message])]
        }

        if (!imageInfos)
            return [error: message(code: "transcribeTagLib.could_not_find_images_for_keys", args: [imageIds.join(", ")])]
        else {
            //def missing = imageIds.collect { [i18nName: it, info:imageInfos[it]] }.findAll { it.info == null }.collect { it.i18nName }
            def missing = allImageIds.findAll { imageInfos[it] == null }
            if (missing) warnings.add(message(code: "transcribeTagLib.the_following_image_ids_cannot_be_found", args: [missing.join(', ')]))
        }

        return [items: items2, infos: imageInfos, warnings: warnings]
    }

    def imageInfosByPopularity = { attrs, body ->
        Project project = attrs.project
        List<Picklist> picklists = attrs.picklists
        List<TemplateField> templateFields = attrs.fields

        def warnings = []

        def valueCounts = Field.async.executeQuery("select value, count(id) from Field f JOIN Task t WHERE t.project = :project GROUP BY f.value", [project: project])

        if (!picklists && !fields) return [error: message(code: "cameraTrapTagLib.no_valid_picklist")]

        if (!picklists) {
            picklists = templateFields.collect { field ->
                def pl
                pl = Picklist.findByNameAndFieldTypeClassifier(field.fieldType.name(), field.fieldTypeClassifier)
                if (!pl) Picklist.findByName(field.fieldType.name())
                if (!pl) warnings.add("No valid picklist found for ${field.fieldType.name()}")

                def items = PicklistItem.findAllByPicklistAndInstitutionCode(pl, project?.picklistInstitutionCode)
                // fallback to default picklist if institution code given and no items found
                if (project?.picklistInstitutionCode && !items) items = PicklistItem.findAllByPicklistAndInstitutionCodeIsNull(pl)
                pl
            }.findAll { it }
        }

        if (!picklists) return [error: message(code: "cameraTrapTagLib.no_picklists_found_for", args: [templateFields.collect { "${it.fieldType.name()} (${it.fieldTypeClassifier})" }])]

        def items = picklists.collect { pl ->
            def items = PicklistItem.findAllByPicklistAndInstitutionCode(pl, project?.picklistInstitutionCode)
            // fallback to default picklist if institution code given and no items found
            if (project?.picklistInstitutionCode && !items) items = PicklistItem.findAllByPicklistAndInstitutionCodeIsNull(pl)
            if (!items) return [error: message(code: "transcribeTagLib.no_picklist_items_found", args: [pl.uiLabel, project?.picklistInstitutionCode])]
            items
        }.findAll { it }.flatten()

        def valueCountMap = valueCounts.get().collectEntries { [(it[0]): it[1]] }

        items.sort { valueCountMap.get(it.value) ?: 0 }

        def items2 = items.collectEntries {
            def key = it.key.split(',').toList().collect { it?.trim() }
            [ (key) : it.value ]
        }
        items2

        def imageIds = items2*.key.flatten()
        def imageInfos
        try {
            imageInfos = imageServiceService.getImageInfoForIds(imageIds)
        } catch (e) {
            log.error("Error calling image service for ${imageIds}", e)
            return [error: message(code: "transcribeTagLib.error_contacting_image_service", args: [e.message])]
        }

        if (!imageInfos)
            return [error: message(code: "transcribeTagLib.could_not_find_images_for_keys", args: [imageIds.join(", ")])]
        else {
            //def missing = imageIds.collect { [i18nName: it, info:imageInfos[it]] }.findAll { it.info == null }.collect { it.i18nName }
            def missing = imageIds.findAll { imageInfos[it] == null }
            if (missing) warnings.add(message(code: "transcribeTagLib.the_following_image_ids_cannot_be_found", args: [missing.join(', ')]))
        }

        [picklist: pl, items: items2, infos: imageInfos, warnings: warnings]
    }
}
