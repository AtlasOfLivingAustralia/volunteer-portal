package au.org.ala.volunteer

class FrontPageController {

    def index = {

        redirect(action: "edit", params: params)
    }

    def edit = {
        ['frontPage':FrontPage.instance()]
    }

    def save = {
        def frontPage = FrontPage.instance();

        frontPage.projectOfTheDay = Project.get(Long.parseLong(params['projectOfTheDay']))

        frontPage.useGlobalNewsItem = params['useGlobalNewsItem'] == "on"

        frontPage.newsTitle = params["newsTitle"]
        frontPage.newsBody = params["newsBody"]
        frontPage.newsCreated = params["newsCreated"]

        frontPage.systemMessage = params["systemMessage"]

        frontPage.showAchievements = params['showAchievements'] == 'on'
        frontPage.enableTaskComments = params['enableTaskComments'] == 'on'
        frontPage.enableForum = params['enableForum'] == 'on'

        frontPage.save();

        flash.message = "${message(code: 'default.updated.message', args: [message(code: 'frontPage.label', default: 'Front Page'), ''])}"
        redirect(action: "edit", params: params)
    }
}
