package au.org.ala.volunteer

class EmailService {

    static transactional = false

    def mailService
    def logService

    def sendMail(String emailAddress, String subj, String message) {

        logService.log("Sending email to ${emailAddress} - ${subj}")

        mailService.sendMail {
            to emailAddress
            from "noreply@volunteer.ala.org.au"
            subject subj
            body message
        }
    }
}
