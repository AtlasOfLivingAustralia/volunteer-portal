package au.org.ala.volunteer

class UrlMappings {

    static mappings = {

        "/"(controller: "index", action: 'index')

        "/es"(controller: 'eventSource', action: 'index')
        "/image/$prefix/$width/$height/$name.$format"(controller: 'image', action: 'size')

        name institutionAdmin: "/admin/institutions/$action?/$id?"(controller: 'institutionAdmin')
        "/institution/apply?"(controller: 'institutionAdmin', action: 'apply')
        "/institution/applyConfirm?"(controller: 'institutionAdmin', action: 'applyConfirm')
        "/admin/label/$action?" (controller: 'label')
        "/admin/leaderboard/$action?" (controller: 'leaderBoardAdmin')
        name achievementDescription: "/admin/achievements/$action?/$id?" (controller: 'achievementDescription')
        name landingPageAdmin: "/admin/landingPage/$action?/$id?" (controller: 'landingPageAdmin')

        "/ws/$action?/$id?(.$format)?"(controller: 'ajax')

        "500"(controller: 'error', action: 'index')
        "404"(view:'/notFound')

        name landingPage: "/$shortUrl"(controller: 'project', action: 'customLandingPage')

        "/$controller/$action?/$id?(.$format)?"{
            constraints {
                // apply constraints here
            }
        }

    }
}