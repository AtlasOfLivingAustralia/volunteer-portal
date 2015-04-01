package au.org.ala.volunteer

import org.apache.log4j.Logger
import org.springframework.web.context.request.RequestAttributes
import org.springframework.web.context.request.RequestContextHolder

class GormEventDebouncer {

    private static final Logger log = Logger.getLogger(GormEventDebouncer.class)

    static def debounceProject(long id) {
//        def ps = getProjectSet()
//        if (ps != null) {
//            ps.add(id)
//        } else {
            DomainUpdateService.scheduleProjectUpdate(id)
//        }
    }

    static def debounceTask(long id) {
        def ts = getTaskSet()
        if (ts != null) {
            // we have an active request
            ts.add(id)
        } else {
            // otherwise drop it on the task queue
            DomainUpdateService.scheduleTaskUpdate(id)
        }

    }

    static def debounceDeleteTask(long id) {
        def ts = getDeletedTaskSet()
        if (ts != null) {
            // we have an active request
            ts.add(id)
        } else {
            // otherwise drop it on the task queue
            DomainUpdateService.scheduleTaskDeleteIndex(id)
        }
    }
    
    static Set<Long> getTaskSet() { getRequestSet("updatedTasks") }
    //static Set<Long> getProjectSet() { getRequestSet("updatedProjects") }
    static Set<Long> getDeletedTaskSet() { getRequestSet("deletedTasks") }

    static Set<Long> getRequestSet(String name) {
        try {
            def cr = RequestContextHolder.getRequestAttributes()
            if (!cr) return null
            
            def updateSet = cr.getAttribute(name, RequestAttributes.SCOPE_REQUEST)
            if (updateSet == null || !(updateSet instanceof Set)) {
                updateSet = new HashSet<Long>();
                cr.setAttribute(name, updateSet, RequestAttributes.SCOPE_REQUEST)
            }
            return (Set<Long>)updateSet
        } catch (Exception e) {
            log.error("Exception while getting request set", e)
            return null
        }

    }
    
}
