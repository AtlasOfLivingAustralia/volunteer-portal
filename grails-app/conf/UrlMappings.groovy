class UrlMappings {

	static mappings = {

        "/"(controller: "/index")

        name institutionAdmin: "/admin/institutions/$action?/$id?"(controller: 'institutionAdmin')
        "/admin/label/$action?" (controller: 'label')
		"/admin/leaderboard/$action?" (controller: 'leaderBoardAdmin')
        name achievementDescription: "/admin/achievements/$action?/$id?" (controller: 'achievementDescription')

        "/$controller/$action?/$id?(.$format)?"{
			constraints {
				// apply constraints here
			}
		}

        "/ws/$action?/$id?(.$format)?"(controller: 'ajax')

		"500"(view:'/error')
	}
}
