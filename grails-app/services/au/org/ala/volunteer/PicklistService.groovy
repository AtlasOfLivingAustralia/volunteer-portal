package au.org.ala.volunteer

import org.hibernate.FlushMode

class PicklistService {

    static transactional = true
    def sessionFactory
    def logService
    def propertyInstanceMap = org.codehaus.groovy.grails.plugins.DomainClassGrailsPlugin.PROPERTY_INSTANCE_MAP

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

    def replaceItems(long picklistId, String csvdata) {
        def picklist = Picklist.get(picklistId)
        // First delete the existing items...
        if (picklist) {
            logService.log "Deleting existing items..."
            int itemsDeleted = 0;
            PicklistItem.findAllByPicklist(picklist).each {
                it.delete();
                itemsDeleted++;
            }
            logService.log "${itemsDeleted} existing items deleted from picklist '${picklist.name}'"
        }

        def pattern = ~/^(['"])(.*)(\1)$/
        int rowsProcessed = 0;
        try {
            sessionFactory.currentSession.setFlushMode(FlushMode.MANUAL)
            csvdata.eachCsvLine { tokens ->
                def value = tokens[0]
                def m = pattern.matcher(value)
                if (m.find()) {
                    value = m.group(2);
                }
                def picklistItem = new PicklistItem(picklist: picklist, value: value)

                if (tokens.size() > 1) {
                    picklistItem.key = tokens[1] // optional second value as "key"
                }
                picklistItem.save()
                rowsProcessed++;
                if (rowsProcessed % 2000 == 0) {
                    // Doing this significantly speeds up imports...
                    sessionFactory.currentSession.flush()
                    sessionFactory.currentSession.clear()
                    propertyInstanceMap.get().clear()
                    logService.log "${rowsProcessed} picklist items imported (${picklist.name})"
                }
            }
        } finally {
            sessionFactory.currentSession.flush();
            sessionFactory.currentSession.setFlushMode(FlushMode.AUTO)
        }

    }
}
