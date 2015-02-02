class UrlMappings {

	static mappings = {

        "/admin/institutions/$action?/$id?"(controller: 'institutionAdmin') {
            constraints {

            }
        }

		"/admin/leaderboard/$action?" (controller: 'leaderBoardAdmin')

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
