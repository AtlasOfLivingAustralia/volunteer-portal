package au.org.ala.volunteer

class ErrorController {

    def index() {
        Exception cause = request?.exception?.cause
        response.status = 500

        def content = [status    : response.status,
                       title     : 'Error Encountered',
                       requestUri: request?.getAttribute('javax.servlet.forward.request_uri')
        ]

        render(view: "/error", model: [exception: cause, content: content])
    }
}
