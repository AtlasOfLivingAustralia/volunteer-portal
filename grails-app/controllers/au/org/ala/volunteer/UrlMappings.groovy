package au.org.ala.volunteer

class UrlMappings {

    static mappings = {

        "/"(controller: "index", action: 'index')

        "/wildlife-spotter"(controller: 'project', action: 'wildlifespotter')
        "/es"(controller: 'eventSource', action: 'index')
        "/image/$prefix/$width/$height/$name.$format"(controller: 'image', action: 'size')

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

//class UrlMappings {
//
//    static mappings = {
//        "/$controller/$action?/$id?(.$format)?"{
//            constraints {
//                // apply constraints here
//            }
//        }
//
//        "/"(view:"/index")
//        "500"(view:'/error')
//        "404"(view:'/notFound')
//    }
//}
