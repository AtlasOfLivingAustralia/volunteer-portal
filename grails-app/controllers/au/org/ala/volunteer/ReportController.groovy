package au.org.ala.volunteer

import java.time.LocalDate
import java.time.format.DateTimeFormatter

class ReportController {

    static final String DATE_FORMAT = "dd/MM/yyyy"
    def index() {
        redirect(action: 'userReport', params: params)
    }

    def userReport() {
        def userLabelCategory = LabelCategory.findByName('user')
        def userLabelList = Label.findAllByCategory(userLabelCategory)
        LocalDate startDate = LocalDate.now().minusDays(7)
        final DateTimeFormatter dtf = DateTimeFormatter.ofPattern(DATE_FORMAT, Locale.ENGLISH);
        String startDateStr = startDate.format(dtf);
        String endDateStr = LocalDate.now().format(DateTimeFormatter.ofPattern(DATE_FORMAT, Locale.ENGLISH))

        [userLabelList: userLabelList, defaultStartDate: startDateStr, defaultEndDate: endDateStr]
    }
}
