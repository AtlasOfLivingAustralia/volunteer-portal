package au.org.ala.volunteer

class CameraTrapTagLib {
    static namespace = "ct"

    static defaultEncodeAs = [taglib: 'html']
    //static encodeAsForTags = [tagName: [taglib:'html'], otherTagName: [taglib:'none']]
    static returnObjectForTags = ['imageInfosByPopularity']

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
