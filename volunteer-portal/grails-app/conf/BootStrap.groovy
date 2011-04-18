class BootStrap {

    def init = { servletContext ->

      //add a utility method for creating a map from a arraylist
      java.util.ArrayList.metaClass.toMap = { ->
        def myMap = [:]
        delegate.each { keyCount ->
          myMap.put keyCount[0], keyCount[1]
        }
        myMap
      }
    }
    def destroy = {
    }
}
