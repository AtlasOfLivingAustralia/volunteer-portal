package au.org.ala.volunteer

import org.springframework.web.context.request.RequestAttributes
import org.springframework.web.context.request.RequestContextHolder

class GormEventDebouncer {

    static def debounceField(long id) {
        getFieldSet()?.add(id)
    }

    static def debounceTask(long id) {
        def ts = getTaskSet()
        if (ts != null) {
            // we have an active request
            ts.add(id)
        } else {
            // otherwise drop it on the task queue
            FullTextIndexService.scheduleTaskIndex(id)
        }

    }

    static def debounceDeleteTask(long id) {
        def ts = getDeletedTaskSet()
        if (ts != null) {
            // we have an active request
            ts.add(id)
        } else {
            // otherwise drop it on the task queue
            FullTextIndexService.scheduleTaskDeleteIndex(id)
        }
    }
    
    static Set<Long> getFieldSet() { getRequestSet("updatedFields") }
    static Set<Long> getTaskSet() { getRequestSet("updatedTasks") }
    static Set<Long> getDeletedTaskSet() { getRequestSet("deletedTasks") }

    static Set<Long> getRequestSet(String name) {
        try {
            def cr = RequestContextHolder.currentRequestAttributes()
            if (!cr) return null
            
            def updateSet = cr.getAttribute(name, RequestAttributes.SCOPE_REQUEST)
            if (updateSet == null || !(updateSet instanceof Set)) {
                updateSet = new HashSet<Long>();
                cr.setAttribute(name, updateSet, RequestAttributes.SCOPE_REQUEST)
            }
            return (Set<Long>)updateSet
        } catch (Exception e) {
            // no request context, return nothing
            return null
        }

    }
    
}
