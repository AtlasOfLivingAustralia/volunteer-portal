package au.org.ala.volunteer

class PicklistService {

    static transactional = true

    def serviceMethod() {
    }

    /**
   * Loads a CSV of external identifiers and external URLs
   * into the tables, loading the task and multimedia tables.
   *
   * @param projectId
   * @param text
   * @return
   */
  def load(String name, String text) {
    def picklist = new Picklist(name:name)
    picklist.save(flush:true)
    text.eachCsvLine { tokens ->
      //only one line in this case
      def picklistItem = new PicklistItem()
      picklistItem.picklist = picklist
      picklistItem.value = tokens[0]
      if (tokens.size() > 1) {
          picklistItem.key = tokens[1] // optional second value as "key"
      }
      picklistItem.save(flush:true)
    }
  }
    
  def replaceItems(long picklistId, String csvdata) {
      def picklist = Picklist.get(picklistId)
      // First delete the existing items...
      if (picklist) {
          PicklistItem.findAllByPicklist(picklist).each {
              it.delete();
          }
      }

      def pattern = ~/(['"])(.*)(\1)/
      
      csvdata.eachCsvLine { tokens ->
        //only one line in this case
        def picklistItem = new PicklistItem()
        picklistItem.picklist = picklist
        def value = tokens[0]
        def m = pattern.matcher(value)
        if (m.find()) {
            value = m.group(2);
        }
        picklistItem.value = value
        if (tokens.size() > 1) {
            picklistItem.key = tokens[1] // optional second value as "key"
        }
        picklistItem.save(flush:true)
      }

    }
}
