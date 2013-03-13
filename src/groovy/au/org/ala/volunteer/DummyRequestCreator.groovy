package au.org.ala.volunteer

import java.lang.reflect.InvocationHandler
import java.lang.reflect.Method
import java.lang.reflect.Proxy;
import java.util.concurrent.ConcurrentHashMap

import javax.servlet.http.HttpServletRequest
import javax.servlet.http.Cookie

import org.apache.commons.collections.iterators.IteratorEnumeration

class DummyRequestCreator { //implements HttpServletRequest {

    static HttpServletRequest createInstance(String requestURI) {
        def params = new ConcurrentHashMap()
        def attributes = new ConcurrentHashMap()
		
        String contentType
        String characterEncoding = "UTF-8"

        return Proxy.newProxyInstance(
                    HttpServletRequest.class.getClassLoader(),
                    [HttpServletRequest.class] as Class[],
                    new InvocationHandler()
        {
            public Object invoke(Object proxy, Method method, Object[] args) {
                switch (method.name) {
                    case "getAuthType":
                    case "getHeader":
                    case "getRemoteUser":
                    case "getUserPrincipal":
                    case "getRequestedSessionId":
                    case "getServletContext":
                        return null
                        
                    case "getCookies":
                        return new Cookie[0]
                        
                    case "getDateHeader":
                        return -1L
                        
                    case "getHeaders":
                    case "getHeaderNames":
                        return new IteratorEnumeration([].iterator())
                        
                    case "getIntHeader":
                        return -1
                        
                    case "getMethod":
                        return "GET"
                        
                    case "getPathInfo":
                    case "getPathTranslated":
                    case "getQueryString":
                        return ""

                    case "getContextPath":
                    case "getServletPath":
                        return "/"

                    case "isUserInRole":
                    case "isRequestedSessionIdFromCookie":
                    case "isRequestedSessionIdFromURL":
                    case "isRequestedSessionIdFromUrl":
                    case "authenticate":
                    case "isSecure":
                    case "isAsyncStarted":
                    case "isAsyncSupported":
                        return false

                    case "isRequestedSessionIdValid":
                        return true
                    
					case "getRequestURI":
						return requestURI
					
                    case "getRequestURL":
                        return new StringBuffer(requestURI)

                    case "getRealPath":
                        return requestURI
                        
                    case "getAttribute":
                        return attributes[args[0]]

                    case "getAttributeNames":
                        return attributes.keys()

                    case "setAttribute":
                        attributes[args[0]] = args[1]
						return

                    case "removeAttribute":
                        attributes.remove(args[0])
						return
                        
                    case "getContentLength":
                        return 0

                    case "getParameter":
                        return params[args[0]]

                    case "getParameterNames":
                        return params.keys()

                    case "getParameterValues":
                        return new String[0]

                    case "getParameterMap":
                        return params

                    case "getProtocol":
                    case "getScheme":
                    case "getInputStream":
                    case "getSession":
                    case "getServerName":
                    case "getServerPort":
                    case "getReader":
                    case "getRemoteAddr":
                    case "getRemoteHost":
                    case "getRequestDispatcher":
                    case "getRemotePort":
                        throw new UnsupportedOperationException(
                            "You cannot read the " +
                                method.name.replaceAll( /([A-Z])/, / $1/ ).toLowerCase().substring(4) +
                            " in non-request rendering operations")

                    case "getLocale":
                        return Locale.getDefault()

                    case "getLocales":
                        return new IteratorEnumeration(Locale.getAvailableLocales().iterator())

                    case "getLocalName":
                        return "localhost"

                    case "getLocalAddr":
                        return "127.0.0.1"

                    case "getLocalPort":
                        return 80

                    case "getContentType":
                        return contentType
                    case "setContentType":
                        contentType = args[0]
						return

                    case "getCharacterEncoding":
                        return characterEncoding
                    case "setCharacterEncoding":
                        characterEncoding = args[0]
						return
                }
                return null;
            }
        });
    }
}
