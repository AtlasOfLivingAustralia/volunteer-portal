class UrlMappings {

	static mappings = {

        "/admin/institutions/$action?/$id?"(controller: 'institutionAdmin') {
            constraints {

            }
        }

        "/admin/label/$action?" (controller: 'label')
		"/admin/leaderboard/$action?" (controller: 'leaderBoardAdmin')
        "/admin/achievements/$action?/$id?" (controller: 'achievementDescription')

        "/$controller/$action?/$id?"{
			constraints {
				// apply constraints here
			}
		}

        "/ws/$action?/$id?"(controller: 'ajax')

		"/"(controller: "/index")
		"500"(view:'/error')
	}
}
