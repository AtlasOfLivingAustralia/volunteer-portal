package au.org.ala.volunteer

import java.io.PrintWriter;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

import javax.servlet.http.HttpServletResponse;

class DummyResponseCreator {
    static HttpServletResponse createInstance(final PrintWriter writer) {
        def characterEncoding = "UTF-8"
        def contentType
        def locale
        def bufferSize = 0
        
        return Proxy.newProxyInstance(
                    HttpServletResponse.class.getClassLoader(),
                    [HttpServletResponse.class] as Class[],
                    new InvocationHandler()
        {
            public Object invoke(Object proxy, Method method, Object[] args) {
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

                    case "getCharacterEncoding":
                        return characterEncoding
                    case "setCharacterEncoding":
                        characterEncoding = args[0]
						return

                    case "getLocale":
                        return locale
                    case "setLocale":
                        locale = args[0]
						return

                    case "getBufferSize":
                        return bufferSize
                    case "setBufferSize":
                        bufferSize = args[0]
						return
                }
                return null;
            }
        });
    }
}
