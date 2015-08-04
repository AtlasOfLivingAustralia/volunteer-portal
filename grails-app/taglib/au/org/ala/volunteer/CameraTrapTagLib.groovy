package au.org.ala.volunteer

import grails.converters.JSON
import org.codehaus.groovy.grails.web.converters.exceptions.ConverterException

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

        if (!picklist) return [error: "No valid picklist or field provided"]

        def valueCounts
        def myLast
        if (project.id == null) {
            valueCounts = task { [] }
            myLast = task { [] }
        } else {
            valueCounts = Field.async.executeQuery("select f.value, count(f.id) from Field f JOIN f.task t WHERE t.project.id = :projectId GROUP BY f.value", [projectId: project.id])
            myLast = Field.async.executeQuery("select distinct f.value, t.dateFullyTranscribed from Field f JOIN f.task t WHERE t.project.id = :projectId AND t.fullyTranscribedBy = :userId ORDER BY t.dateFullyTranscribed DESC", [projectId: project.id, userId: userId])
        }

        def items = PicklistItem.findAllByPicklistAndInstitutionCode(picklist, project?.picklistInstitutionCode)

        // fallback to default picklist if institution code given and no items found
        if (project?.picklistInstitutionCode && !items) items = PicklistItem.findAllByPicklistAndInstitutionCodeIsNull(picklist)

        if (!items) return [error: "No picklist items found for picklist ${pl.uiLabel} and picklist institution code ${project?.picklistInstitutionCode}"]

        def valueCountMap = valueCounts.get().collectEntries { [(it[0]): it[1]] }
        def count = 0
        def myLastMap = myLast.get().collectEntries { [it: count++] }

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
                    def lastUsed = myLastMap.size() - (myLastMap.get(it.value) ?: myLastMap.size())
                    results = [ (it.value): [imageIds: imageIds, value: it.value, tags: tags.toList(), dayImages: dayImageIds.toList(), nightImageIds: nightImageIds.toList(), similarSpecies: similarSpecies.toList(), popularity: popularity, lastUsed: lastUsed ] ]
                    allImageIds += imageIds
                } else {
                    results = [:]
                }

            } catch (ConverterException e) {
                warnings.add("Couldn't parse entry for ${it.value}")
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
            return [error: "Error contacting image service: ${e.message}"]
        }

        if (!imageInfos)
            return [error: "Could not retrieve image infos for keys ${allImageIds.join(", ")}"]
        else {
            //def missing = imageIds.collect { [name: it, info:imageInfos[it]] }.findAll { it.info == null }.collect { it.name }
            def missing = allImageIds.findAll { imageInfos[it] == null }
            if (missing) warnings.add("The following image ids can not be found: ${missing.join(', ')}")
        }

        return [items: items2, infos: imageInfos, warnings: warnings]
    }

    def imageInfosByPopularity = { attrs, body ->
        Project project = attrs.project
        List<Picklist> picklists = attrs.picklists
        List<TemplateField> templateFields = attrs.fields

        def warnings = []

        def valueCounts = Field.async.executeQuery("select value, count(id) from Field f JOIN Task t WHERE t.project = :project GROUP BY f.value", [project: project])

        if (!picklists && !fields) return [error: "No valid picklists or fields provided"]

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

        if (!picklists) return [error: "No picklists found for ${templateFields.collect { "${it.fieldType.name()} (${it.fieldTypeClassifier})" } }"]

        def items = picklists.collect { pl ->
            def items = PicklistItem.findAllByPicklistAndInstitutionCode(pl, project?.picklistInstitutionCode)
            // fallback to default picklist if institution code given and no items found
            if (project?.picklistInstitutionCode && !items) items = PicklistItem.findAllByPicklistAndInstitutionCodeIsNull(pl)
            if (!items) return [error: "No picklist items found for picklist ${pl.uiLabel} and picklist institution code ${project?.picklistInstitutionCode}"]
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
            return [error: "Error contacting image service: ${e.message}"]
        }

        if (!imageInfos)
            return [error: "Could not retrieve image infos for keys ${imageIds.join(", ")}"]
        else {
            //def missing = imageIds.collect { [name: it, info:imageInfos[it]] }.findAll { it.info == null }.collect { it.name }
            def missing = imageIds.findAll { imageInfos[it] == null }
            if (missing) warnings.add("The following image ids can not be found: ${missing.join(', ')}")
        }

        [picklist: pl, items: items2, infos: imageInfos, warnings: warnings]
    }
}
