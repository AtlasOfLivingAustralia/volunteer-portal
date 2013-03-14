package au.org.ala.volunteer

import java.lang.reflect.InvocationHandler
import java.lang.reflect.Method
import java.lang.reflect.Proxy

import javax.servlet.http.HttpServletResponse

class DummyResponseCreator {
    static HttpServletResponse createInstance(final PrintWriter writer) {
        return Proxy.newProxyInstance( HttpServletResponse.class.getClassLoader(), [HttpServletResponse.class] as Class[], new DummyResponseInvocationHandler(writer)) as HttpServletResponse;
    }
}

class DummyResponseInvocationHandler implements InvocationHandler {

    def characterEncoding = "UTF-8"
    def contentType
    def locale
    def bufferSize = 0
    PrintWriter writer

    public DummyResponseInvocationHandler(final PrintWriter writer) {
        this.writer = writer
    }

    Object invoke(Object o, Method method, Object[] args) throws Throwable {
        switch (method.name) {
            case "containsHeader":
            case "isCommitted":
                return false

            case "encodeURL":
            case "encodeRedirectURL":
            case "encodeUrl":
                return args[0]

            case "getStatus":
                return 0

            case "getHeader":
            case "getHeaders":
            case "getHeaderNames":
                return null

            case "getOutputStream":
                throw new UnsupportedOperationException("You cannot use the OutputStream in non-request rendering operations. Use getWriter() instead")

            case "getWriter":
                return writer
            case "getContentType":
                return contentType
            case "setContentType":
                contentType = args[0]
                break
            case "getCharacterEncoding":
                return characterEncoding
            case "setCharacterEncoding":
                characterEncoding = args[0]
                break
            case "getLocale":
                return locale
            case "setLocale":
                locale = args[0]
                break
            case "getBufferSize":
                return bufferSize
            case "setBufferSize":
                bufferSize = args[0]
                break
        }
        return null
    }
}