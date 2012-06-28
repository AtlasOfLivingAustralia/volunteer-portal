package au.org.ala.volunteer

import javax.servlet.http.HttpSessionListener
import javax.servlet.http.HttpSessionEvent
import java.text.SimpleDateFormat

/**
 * Created with IntelliJ IDEA.
 * User: baird
 * Date: 22/06/12
 * Time: 3:50 PM
 * To change this template use File | Settings | File Templates.
 */
class BVPSessionListener implements HttpSessionListener {

    void sessionCreated(HttpSessionEvent e) {
        def sdf = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss")
        def dateStr = sdf.format(new Date())
        println("[${dateStr}] Session created: ${e.session.id}")
    }

    void sessionDestroyed(HttpSessionEvent e) {
        def sdf = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss")
        def dateStr = sdf.format(new Date())

        println("[${dateStr}] Session destroyed: ${e.session.id}, last accessed: ${new Date(e.session.lastAccessedTime)}")
    }

}
