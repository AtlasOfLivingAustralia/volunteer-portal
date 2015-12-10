package au.org.ala.volunteer;

import com.google.common.base.Strings;

import javax.servlet.AsyncContext;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.concurrent.TimeUnit;

public class EventSourceServlet extends HttpServlet {

    private EventSourceService eventSourceService;
    private UserService userService;

    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);

        System.out.println("EventSource Servlet init");

        eventSourceService = (EventSourceService) ApplicationContextHolder.getBean("eventSourceService");
        userService = (UserService) ApplicationContextHolder.getBean("userService");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        final String userId = Strings.nullToEmpty(userService.getCurrentUserId());
        resp.setContentType("text/event-stream");
        resp.setCharacterEncoding("UTF-8");

        final AsyncContext ac = req.startAsync();
        ac.setTimeout(0); // no timeout for an event stream.

        resp.flushBuffer();

        eventSourceService.addAsyncContext(ac, userId);
    }
}
