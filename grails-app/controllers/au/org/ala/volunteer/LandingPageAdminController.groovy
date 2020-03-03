package au.org.ala.volunteer

import au.org.ala.web.AlaSecured
import grails.transaction.Transactional
import grails.converters.JSON
import static org.springframework.http.HttpStatus.CREATED
import static org.springframework.http.HttpStatus.NO_CONTENT

@AlaSecured("ROLE_VP_ADMIN")
class LandingPageAdminController {

    def fileUploadService
    def settingsService

    def index(Integer max) {
        params.max = Math.min(max ?: 10, 100)
        respond LandingPage.list(params), model: [landingPageCount: LandingPage.count()]
    }

    def create() {
       // def landingPage = chainModel?.landingPage ?: new LandingPage(params)
        def landingPageInstance = new LandingPage()
     //   redirect(action: "edit", params: ['mode': 'create'])
       // def landingPage = new LandingPage(params)
        landingPageInstance.label = new HashSet<Label>()
        landingPageInstance.numberOfContributors = 10
        ['landingPageInstance': landingPageInstance, projectTypes: ProjectType.listOrderByName()]
        //respond landingPage
    }

    def edit (LandingPage landingPageInstance) {
 /*       def landingPage = chainModel?.landingPage ?: null//params['landingPage']?:null
       *//* if (!landingPage) {
            landingPage = chainModel?.landingPage ?: null//params['landingPage']?:null
        }*//*
        final labelCats = Label.withCriteria { projections { distinct 'category' } }
        def mode = params['mode']
        if (mode != 'create' && mode != 'addTag') {
            def landingPageId = params['id']
            landingPage = LandingPage.findById(landingPageId)
        } else if (!landingPage) {
            landingPage = new LandingPage()
            landingPage.label = new HashSet<Label>()
            landingPage.numberOfContributors = 10
          //  ['landingPage': landingPage, 'mode': mode, projectTypes: ProjectType.listOrderByName(), labels: Label.listOrderByCategory(), 'labelCats': labelCats]
        }*/
        if (!landingPageInstance) {
            def landingPageId = params['id']
            landingPageInstance = LandingPage.findById(landingPageId)
        }
        ['landingPageInstance': landingPageInstance, projectTypes: ProjectType.listOrderByName()]
      //  final labelCats = Label.withCriteria { projections { distinct 'category' } }
//        ['landingPage': landingPage, projectTypes: ProjectType.listOrderByName(), 'labels': Label.listOrderByCategory(), 'labelCats': labelCats]
       // render view: 'edit', model: [landingPage: landingPage, 'mode': mode, projectTypes: ProjectType.listOrderByName(), 'labels': Label.listOrderByCategory(), 'labelCats': labelCats]
       // respond landingPage, params: [projectTypes: ProjectType.listOrderByName()]
    }

    def editImage(LandingPage landingPageInstance) {
       // ['landingPageInstance': landingPageInstance]
        respond landingPageInstance
        //respond model: ['landingPageInstance': landingPageInstance, projectTypes: ProjectType.listOrderByName(), 'labels': Label.listOrderByCategory(), 'labelCats': labelCats]
    }

    def editSelections(LandingPage landingPageInstance) {
        final labelCats = Label.withCriteria { projections { distinct 'category' } }
        ['landingPageInstance': landingPageInstance, 'labels': Label.listOrderByCategory(), 'labelCats': labelCats]
        //respond model: ['landingPageInstance': landingPageInstance, projectTypes: ProjectType.listOrderByName(), 'labels': Label.listOrderByCategory(), 'labelCats': labelCats]
    }

    def filterLabelCategory () {
        def list
        def category = params['category'] ?: null
        if (category != 'all') {
            list = Label.findAllByCategory(category)
        } else {
            list = Label.listOrderByValue()
        }
        render list*.toMap() as JSON
    }

    @Transactional
    def saveProjectLabels(LandingPage landingPageInstance) {

        if (landingPageInstance.hasErrors()) {
            chain action: "edit", model: ['landingPage': landingPageInstance], params: ['mode': 'create']
            return
            //   chain action: "edit", model: ['landingPage': landingPage], params: ['mode': 'create']
            //render view: 'edit', model: [landingPage: landingPage] //bean: landingPage.errors,
            //respond model: [landingPage: landingPage], view: 'edit'
            // return
        } else {

         /*   def labelIds = params['labelIds']
            List labelArr = new ArrayList<Label>();
            if (labelIds && labelIds != '[]'){
                ArrayList<String> labels = Arrays.asList(labelIds.split(","));
                labels.each{
                    if (it.isLong()) {
                        long labelId = it.toLong()
                        if (labelId) {
                            Label label = Label.findById(it)
                            labelArr.add(label)
                        }
                    }
                }
            } */

            def newLabel = Label.findById(params['tag'])
            if (!landingPageInstance.label) {
                landingPageInstance.label = new ArrayList<Label>()
                //List labelArr = new ArrayList<Label>();
            }

            landingPageInstance.label.add(newLabel)
            //    LandingPage.withTransaction {
            landingPageInstance.save flush: true
            //    }
            // chain action: "edit", model: ['landingPage': landingPageInstance, id: landingPageInstance.id]
            //    redirect(action: "edit", params: ['landingPage': landingPageInstance, 'mode': 'edit'])
            //    return
            // render view: 'edit', model: [landingPage: landingPageInstance, id: landingPageInstance.id]

            /* request.withFormat {
                 form multipartForm {
                     flash.message = message(code: 'default.created.message', args: [message(code: 'landingPageAdmin.label', default: 'LandingPage'), landingPage.id])
                     redirect action: "index"
                 }
                 //'*' { respond landingPage, [status: CREATED] }
             }*/
        }
        //respond landingPage, model: ['id': landingPageInstance.id]
        redirect(action: "editSelections", params: ['id': landingPageInstance.id])
    }

    def delete(LandingPage landingPage) {

        if (landingPage == null) {
            notFound()
            return
        }

        landingPage.delete flush: true

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.deleted.message', args: [message(code: 'LandingPageAdmin.label', default: 'Landing Page'), landingPage.id])
                redirect action: "index", method: "GET"
            }
            '*' { render status: NO_CONTENT }
        }
    }

    @Transactional
    def save(LandingPage landingPageInstance) {
     //   def frontPage = LandingPage.instance()

      /*  if (landingPage == null) {
            notFound()
            return
        }*/

        if (landingPageInstance.hasErrors()) {
            chain action: "create", model: ['landingPage': landingPageInstance], params: ['mode': 'create']
            return
          //   chain action: "edit", model: ['landingPage': landingPage], params: ['mode': 'create']
            //render view: 'edit', model: [landingPage: landingPage] //bean: landingPage.errors,
            //respond model: [landingPage: landingPage], view: 'edit'
           // return
        } else {

/*            def labelIds = params['labelIds']
            List labelArr = new ArrayList<Label>();
            if (labelIds && labelIds != '[]'){
                ArrayList<String> labels = Arrays.asList(labelIds.split(","));
                labels.each{
                    if (it.isLong()) {
                        long labelId = it.toLong()
                        if (labelId) {
                            Label label = Label.findById(it)
                            labelArr.add(label)
                        }
                    }
                }
            }
            landingPageInstance.label = labelArr*/
        //    LandingPage.withTransaction {
                landingPageInstance.save flush: true
        //    }
           // chain action: "edit", model: ['landingPage': landingPageInstance, id: landingPageInstance.id]
        //    redirect(action: "edit", params: ['landingPage': landingPageInstance, 'mode': 'edit'])
        //    return
           // render view: 'edit', model: [landingPage: landingPageInstance, id: landingPageInstance.id]

           /* request.withFormat {
                form multipartForm {
                    flash.message = message(code: 'default.created.message', args: [message(code: 'landingPageAdmin.label', default: 'LandingPage'), landingPage.id])
                    redirect action: "index"
                }
                //'*' { respond landingPage, [status: CREATED] }
            }*/
        }
        //respond landingPage, model: ['id': landingPageInstance.id]
        redirect(action: "edit", params: ['id': landingPageInstance.id])
    }

    @Transactional
    def deleteLabel () {
        def landingPageId = params['landingPageId']
        if (landingPageId.isLong()) {
            def landingPage = LandingPage.findById (landingPageId.toLong())
            def labels = landingPage.label
            def labelIdToRemove = params['selectedLabelId']
            if (labelIdToRemove && labelIdToRemove.isLong()) {
                landingPage.label = labels.grep {label ->
                    label.id != labelIdToRemove.toLong()
                }
                landingPage.save(flush: true)
                render status: NO_CONTENT
               // redirect(action: "edit", params: ['id': landingPage.id])
            }
        }
    }

    def addTag(LandingPage landingPage) {
        def labelId = params['labelId']
        Label label = Label.findById(labelId)
        //Set<Label> labels = new HashSet<Label>() {}
       // labels.add(label)
     //   landingPage.label.add(labels)
      //  chain action: "edit", model: ['landingPage': landingPage], params: ['mode': 'addTag']
       // respond landingPage
         render label.toMap() as JSON
    }

    @Transactional
    def uploadImage() {
        Long landingPageId = params['id'].toLong()
        def landingPage = LandingPage.findById (landingPageId)
        if (params.containsKey('clear-hero')) {
           // def frontPage = LandingPage.instance()
            landingPage.landingPageImage = null
            landingPage.save(flush: true)

        } else {
            def imageFile = request.getFile('heroImage')
            if (imageFile) {
                def heroImage = fileUploadService.uploadImage('landingPage', imageFile)

                // def frontPage = LandingPage.instance()

                landingPage.landingPageImage = heroImage.name
                landingPage.save(flush: true)
            }
        }
        redirect(action: "editImage", params: ['id': landingPage.id])
       // redirect(action: "edit", params: ['id': landingPage.id])
    }

    /*   def templateConfig(long id) {
           def template = Template.get(id)
           def viewParams2 = template.viewParams2 ?: [ categories: [], animals: [] ]
           [id: id, templateInstance: template, viewParams2: viewParams2]
       }

       @Transactional
       def saveTemplateConfig(long id) {
           def template = Template.get(id)
           template.viewParams2 = request.getJSON() as Map

           template.save()
           respond status: SC_NO_CONTENT
       }

       def uploadImage() {
           MultipartFile upload = request.getFile('animal') ?: request.getFile('entry')

           if (upload) {
               def file = fileUploadService.uploadImage('wildlifespotter', upload) { MultipartFile f, HashCode h ->
                   h.toString() + "." + fileUploadService.extension(f)
               }
               def hash = FilenameUtils.getBaseName(file.name)
               def ext = FilenameUtils.getExtension(file.name)
               render([ hash: hash, format: ext ] as JSON)
           } else {
               render([ error: "One of animal or entry must be provided" ] as JSON, status: SC_BAD_REQUEST)
           }

       }*/

}
