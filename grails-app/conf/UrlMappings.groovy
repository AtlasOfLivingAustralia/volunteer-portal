import au.org.ala.volunteer.Institution

class UrlMappings {

	static mappings = {

        "/admin/institutions/$action?/$id?"(controller: 'institution') {
            constraints {

            }
        }

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
