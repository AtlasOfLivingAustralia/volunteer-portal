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
      picklistItem.save(flush:true)
    }
  }
}
