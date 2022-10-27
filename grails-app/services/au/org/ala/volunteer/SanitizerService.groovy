package au.org.ala.volunteer

import au.org.ala.volunteer.sanitizer.HtmlSanitizerPolicy
import org.owasp.html.HtmlPolicyBuilder
import org.owasp.html.PolicyFactory
import org.owasp.html.examples.EbayPolicyExample

import java.util.regex.Pattern

class SanitizerService {

    //static final PolicyFactory policyFactory = EbayPolicyExample.POLICY_DEFINITION
    static final PolicyFactory policyFactory = HtmlSanitizerPolicy.POLICY_DEFINITION

    def sanitize(String html) {
        return html ? policyFactory.sanitize(html) : ''
    }
}
