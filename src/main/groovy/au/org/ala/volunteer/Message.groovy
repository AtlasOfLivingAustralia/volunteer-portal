package au.org.ala.volunteer

import groovy.transform.ToString

interface Message {
    @ToString
    class EventSourceMessage implements Message {

        String to = null

        String id = null
        String event = null
        String comment = null
        Object data = null
    }

    enum ShutdownMessage implements Message {
        INSTANCE
    }
}