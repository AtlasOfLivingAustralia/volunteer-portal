package au.org.ala.volunteer

class EmailService {

    def mailService

    def sendMail(String emailAddress, String subj, String message) {

        println "Sending email to $emailAddress - $subj"
        println mailService.mailConfig

        mailService.sendMail {
            to emailAddress
            from "noreply@volunteer.ala.org.au"
            subject subj
            body message
        }
    }
}
