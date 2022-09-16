package au.org.ala.volunteer

import au.com.bytecode.opencsv.CSVReader
import grails.plugins.csv.CSVReaderUtils
import grails.gorm.transactions.Transactional
//import org.grails.plugins.domain.DomainClassGrailsPlugin
import org.hibernate.FlushMode

@Transactional
class PicklistService {

    def sessionFactory
    def settingsService

    /**
     * Loads a CSV of external identifiers and external URLs
     * into the tables, loading the task and multimedia tables.
     *
     * @param projectId
     * @param text
     * @return
     */
    def load(String name, String text) {
        def picklist = new Picklist(name: name)
        picklist.save(flush: true)
        text.eachCsvLine { tokens ->
            //only one line in this case
            def picklistItem = new PicklistItem()
            picklistItem.picklist = picklist
            picklistItem.value = tokens[0]
            if (tokens.size() > 1) {
                picklistItem.key = tokens[1] // optional second value as "key"
            }
            picklistItem.save(flush: true)
        }
    }

    def replaceItems(long picklistId, CSVReader csvdata, String institutionCode) {
        def picklist = Picklist.get(picklistId)

        // First delete the existing items...
        if (picklist) {
            log.info "Deleting existing items..."
            int itemsDeleted = 0
            PicklistItem.findAllByPicklistAndInstitutionCode(picklist, institutionCode ?: null).each {
                it.delete()
                itemsDeleted++
            }
            log.info "${itemsDeleted} existing items deleted from picklist '${picklist.name}' and institutionCode '${institutionCode}'"
        }

        def pattern = ~/^(['"])(.*)(\1)$/
        int rowsProcessed = 0
        try {
            sessionFactory.currentSession.setFlushMode(FlushMode.MANUAL)
            csvdata.eachLine { tokens ->
                def value = tokens[0]
                def m = pattern.matcher(value)
                if (m.find()) {
                    value = m.group(2)
                }
                def picklistItem = new PicklistItem(picklist: picklist, value: value, institutionCode: institutionCode ?: null, index: rowsProcessed)

                if (tokens.size() > 1) {
                    picklistItem.key = tokens[1] // optional second value as "key"
                }
                picklistItem.save()
                rowsProcessed++
                if (rowsProcessed % 2000 == 0) {
                    // Doing this significantly speeds up imports...
                    sessionFactory.currentSession.flush()
                    sessionFactory.currentSession.clear()
                    log.info "${rowsProcessed} picklist items imported (${picklist.name})"
                }
            }
        } catch (e) {
            log.error(e)
            throw e
        } finally {
            sessionFactory.currentSession.flush()
            sessionFactory.currentSession.setFlushMode(FlushMode.AUTO)
        }
    }

    def getInstitutionCodes() {
        def c = PicklistItem.createCriteria()
        def results = c.list {
            isNotNull("institutionCode")
            projections {
                distinct("institutionCode")
            }
            order("institutionCode", "asc")
        }
        List<String> codes = settingsService.getSetting(SettingDefinition.PicklistCollectionCodes) as List<String>
        boolean changed = false
        results.each {
            if (!codes.contains(it)) {
                codes.add(it as String)
                changed = true
            }
        }

        if (changed) {
            settingsService.setSetting(SettingDefinition.PicklistCollectionCodes.key, codes.sort())
        }

        return codes
    }

    boolean addCollectionCode(String code) {
        List<String> codes = settingsService.getSetting(SettingDefinition.PicklistCollectionCodes) as List<String>

        if (codes && code) {
            if (!codes.contains(code)) {
                codes.add(code)
                settingsService.setSetting(SettingDefinition.PicklistCollectionCodes.key, codes.sort())
                return true
            }
        }

        return false
    }

    boolean removeCollectionCode(String code) {
        List<String> codes = settingsService.getSetting(SettingDefinition.PicklistCollectionCodes) as List<String>

        if (codes && code) {
            if (codes.contains(code)) {
                codes.remove(code)
                settingsService.setSetting(SettingDefinition.PicklistCollectionCodes.key, codes)
                return true
            }
        }

        return false
    }
    
    List getPicklistItemsForProject(DarwinCoreField picklistField, Project project) {
        def results = []

        if (picklistField && project) {
            def pl = Picklist.findByName(picklistField.toString())
            if (pl) {
                if (project.picklistInstitutionCode) {
                    results = PicklistItem.findAllByPicklistAndInstitutionCode(pl, project.picklistInstitutionCode)
                } else {
                    results = PicklistItem.findAllByPicklistAndInstitutionCode(pl, null)
                }
            }
        }

        return results
    }
}
