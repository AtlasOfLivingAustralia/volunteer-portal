package au.org.ala.volunteer

import org.owasp.html.PolicyFactory
import org.owasp.html.examples.EbayPolicyExample

class SanitizerService {

    static transactional = false

    static final PolicyFactory policyFactory = EbayPolicyExample.POLICY_DEFINITION

    def sanitize(String html) {
        return html ? policyFactory.sanitize(html) : ''
    }
}
