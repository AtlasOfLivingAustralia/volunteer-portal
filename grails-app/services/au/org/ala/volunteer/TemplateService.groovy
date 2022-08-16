package au.org.ala.volunteer

import com.google.common.base.Strings
import com.google.common.io.Resources
import grails.converters.JSON
import grails.gorm.transactions.Transactional
import grails.util.Environment
import groovy.sql.Sql

import javax.sql.DataSource
import java.util.regex.Pattern

class TemplateService {

    def userService
    DataSource dataSource

    @Transactional
    def cloneTemplate(Template template, String newName) {
        def newTemplate = new Template(name: newName, viewName: template.viewName, author: userService.currentUser.userId)

        newTemplate.viewParams = [:]
        template.viewParams.entrySet().each { entry ->
            newTemplate.viewParams[entry.key] = entry.value
        }

        newTemplate.viewParams2 = JSON.parse((template.viewParams2 as JSON).toString()) as Map

        newTemplate.save()
        // Now we need to copy over the template fields
        def fields = TemplateField.findAllByTemplate(template)
        Field.saveAll(fields.collect { f ->
            def newField = new TemplateField(f.properties)
            newField.template = newTemplate
            newField
        })

        return newTemplate
    }

    /**
     * Deletes a template from the database
     * @param template the template to delete
     */
    @Transactional
    def deleteTemplate(Template template) {
        // First got to delete all the template_fields...
        def fields = TemplateField.findAllByTemplate(template)
        if (fields) {
            fields.each { it.delete(flush: true) }
        }
        // Now can delete template proper
        template.delete(flush: true)
    }

    /**
     * Returns a list of the currently used views in the template table (used for search filtering).
     * @return
     */
    def getTemplateViews() {
        def query = Template.createCriteria()
        def views = query.listDistinct {
            projections {
                groupProperty("viewName")
            }
            order ('viewName', 'asc')
        }

        return views
    }

    def getAvailableTemplateViews() {
        def views = []
        def pattern

        if (Environment.isDevelopmentEnvironmentAvailable()) {
            log.debug("Checking for dev templates")
            findDevGsps 'grails-app/views/transcribe/templateViews', views
            // This is a pattern for windows... linux developer would have to modify?
            pattern = Pattern.compile("^grails-app\\\\views\\\\transcribe\\\\templateViews\\\\(.*Transcribe)[.]gsp\$")
        } else {
            log.debug("Checking for WAR deployed templates")
            findWarGsps '/WEB-INF/grails-app/views/transcribe/templateViews', views
            pattern = Pattern.compile("^transcribe/templateViews/(.*Transcribe)[.]gsp\$")
        }

        log.debug("Got views: ${views}")

        def results = views.collectMany { String viewName ->
            def m = pattern.matcher(viewName)
            m.matches() ? [m.group(1)] : []
        }.sort()

        log.debug("Views after collect/sort: {}", results)
        return results
    }

    /**
     * Determines whether the user can edit the provided template. If the user is an institution admin for the institution
     * owning the project (or a site admin), they can edit, else it is read only.
     * @param template
     * @param user
     * @return true if the user can edit the template.
     */
    def getTemplatePermissions(Template template) {
        // Site Admin can edit all templates.
        def templatePermissions = [template: template, canEdit: userService.isSiteAdmin(), projectCount: 0]

        if (!userService.isSiteAdmin()) {
            // List of Institutions user is Institution Admin for
            def institutionAdminList = userService.getAdminInstitutionList()*.id
            log.debug("template permissions: institution ID list: ${institutionAdminList}")
            def projectInstitutionList = template.projects*.institution?.id?.unique()
            log.debug("template permissions: project institution ID list: ${projectInstitutionList}")

            /*
            Institution Edit permission:
            * If the template is used by projects in a single institution and the user is assigned to that institution,
              then they can edit.
            * If the template is not assigned at all (not used), it can be edited by anyone.
            * Use by a different institution or multiple institutions, it cannot be edited.
            * Global cannot be edited by Institution Admin.
            */
            if (template.isGlobal) {
                templatePermissions.canEdit = false
            } else {
                if (projectInstitutionList.size() == 1) {
                    templatePermissions.canEdit = !institutionAdminList.intersect(projectInstitutionList).isEmpty()
                } else if (projectInstitutionList.size() == 0) {
                    templatePermissions.canEdit = true
                } else {
                    templatePermissions.canEdit = false
                }
            }
        }

        if (template.projects.size() > 0) {
            templatePermissions.projectCount = template.projects.size()
        }
        log.debug("Can edit: ${templatePermissions.canEdit}")
        return templatePermissions
    }

    /**
     * Returns a list of templates available for an project's institution. Includes templates previously used by the institution
     * and any global templates.
     * @param project the project in question
     * @param includeHidden when set to true, includes hidden templates, when set to false, hidden templates are ignored.
     * @param concise when set to true, reduces the amount of data returned (i.e. for AJAX purposes). A false value will
     * return full template domain objects.
     * @return the list of templates.
     */
    def getTemplatesForProject(Project project, boolean includeHidden = false, boolean concise = false) {
        return getTemplatesForInstitution(project.institution, project.template.id, includeHidden, concise)
    }

    /**
     * Returns a list of templates available for an institution. Includes templates previously used by the institution
     * and any global templates.
     * @param institution the institution
     * @param includeHidden when set to true, includes hidden templates, when set to false, hidden templates are ignored.
     * @param concise when set to true, reduces the amount of data returned (i.e. for AJAX purposes). A false value will
     * return full template domain objects.
     * @return a list of available templates
     */
    def getTemplatesForInstitution(Institution institution, boolean includeHidden = false, boolean concise = false) {
        return getTemplatesForInstitution(institution, 0L, includeHidden, concise)
    }

    /**
     * Returns a list of templates available for an institution. Includes templates previously used by the institution
     * and any global templates.
     * @param institution the institution
     * @param selectedTemplate the ID of the selected template (in case it's hidden and includeHidden is false)
     * @param includeHidden when set to true, includes hidden templates, when set to false, hidden templates are ignored.
     * @param concise when set to true, reduces the amount of data returned (i.e. for AJAX purposes). A false value will
     * return full template domain objects.
     * @return
     */
    def getTemplatesForInstitution(Institution institution, long selectedTemplate, boolean includeHidden = false, boolean concise = false) {
        def results = []
        def includeHiddenClause = (!includeHidden ? " and (template.is_hidden = false " +
                "OR template.id = ${selectedTemplate > 0L ? selectedTemplate : 0L}) " : "")

        def query = """\
            select distinct template.id, 
                template.name, 
                template.is_global, 
                template.is_hidden,
                count(project.id) as num_projects,
                CASE
                    WHEN ( is_global = true ) THEN
                        'c1'
                    WHEN ( is_hidden = true ) THEN
                        'c2'
                    ELSE
                        CASE
                            WHEN ( COUNT(project.id) > 0 ) THEN
                                    'c3'
                            ELSE
                                'c4'
                        END
                END AS category
            from template 
            left outer join project on (project.template_id = template.id)
            left outer join institution on (institution.id = project.institution_id)
            where (institution.id = :institutionId
                or template.is_global = true
                or project.template_id is null)
                ${includeHiddenClause}
            group by template.id, template.name, template.is_global, template.is_hidden
            order by category ASC, template.name ASC """.stripIndent()

        def sql = new Sql(dataSource)
        sql.eachRow(query, [institutionId: institution?.id]) { row ->
            Template template = Template.get(row.id as long)
            if (concise) {
                // Only put the id, name and flags into the map.
                results.add([template: template.getTemplateMap(), category: row.category])
            } else {
                results.add([template: template, category: row.category])
            }
        }

        sql.close()

        return results
    }

    /**
     * Returns a list of Templates. Can be filtered with the following filters: <br />
     * <li>institution: (int) returns templates belonging to the institution with an ID of this value.
     * <li>q: (string) returns templates where the attached project name includes this string in the name (case-insensitive)
     * <li>viewName: (string) returns templates using this view name.
     * @param params Hashmap containing parameters (see above). Other parameters include max, offset, sort and order.
     * @return the list of templates as per the filter query.
     */
    def getTemplatesWithFilter(Map params) {
        def results = []
        Institution institution

        def query = """\
            select distinct t.id as template_id, 
                t.name, 
                u.last_name || ', ' || u.first_name as author, 
                t.author as author_user_id, 
                t.view_name,
                t.is_global
            from template t 
            left outer join project p on (p.template_id = t.id)             
            left outer join institution i on (i.id = p.institution_id) 
            left join vp_user u on (u.user_id = t.author) """.stripIndent()

        def clause = []
        def parameters = [:]

        // Add the institution filter, if present
        if (!Strings.isNullOrEmpty(params.institution as String) && params.institution != 'all') {
            institution = Institution.get(Long.parseLong(params.institution?.toString()))
            clause.add(" (i.id = :institutionId or t.is_global = true) ")
            parameters.institutionId = institution.id
        }

        // Add the project search filter, if present
        if (!Strings.isNullOrEmpty(params.q as String)) {
            clause.add(" t.name ilike '%${params.q}%' ")
        }

        // Add the view name filter, if present
        if (!Strings.isNullOrEmpty(params.viewName as String)) {
            clause.add(" t.view_name = :viewName ")
            parameters.viewName = params.viewName
        }

        // Add status filter, if present
        if (!userService.isSiteAdmin()) {
            clause.add(" t.is_hidden = false ")
        }

        if (!Strings.isNullOrEmpty(params.status as String)) {
            switch(params.status) {
                case 'hidden':
                    clause.add(" t.is_hidden = true ")
                    break
                case 'global':
                    clause.add(" t.is_global = true ")
                    break
                case 'unassigned':
                    clause.add(" p.id is null ")
                    break
            }
        }

        // Add the clauses
        clause.eachWithIndex { line, idx ->
            if (idx == 0) query += " where "
            else query += " and "
            query += "${line}"
        }

        // Add the sort order
        if (!Strings.isNullOrEmpty(params.sort?.toString())) {
            String sort
            switch (params.sort) {
                case 'name': sort = "t.name"
                    break
                case 'viewName': sort = "t.view_name"
                    break
                case 'author': sort = "author"
                    break
                default: sort = "t.id"
                    break
            }

            // Sanitise the order parameter
            if (!Strings.isNullOrEmpty(params.order?.toString())) {
                if (params.order.toString().toLowerCase() != "asc" && params.order.toString().toLowerCase() != "desc") {
                    params.order = 'asc'
                }
            }

            query += " order by is_global desc, ${sort} ${params.order}"
        } else {
            query += " order by is_global desc, t.id asc"
        }
        log.debug("Template list query: ${query}")
        log.debug("Offset: ${params.offset as int}, max: ${params.max as int}")

        def sql = new Sql(dataSource)
        // Postgres driver is funny about empty lists/maps
        def processTemplate = { def row ->
            Template template = Template.get(row.template_id as long)
            if (template) results.add(template)
        }

        if (parameters) sql.eachRow(query, parameters, (params.offset as int) + 1, params.max as int, processTemplate)
        else sql.eachRow(query, (params.offset as int) + 1, params.max as int, processTemplate)


        def countQuery = "select count(*) as row_count_total from (" + query + ") as countQuery"
        def countRows = parameters ? sql.firstRow(countQuery, parameters) : sql.firstRow(countQuery)

        def returnMap = [templateList: results, totalCount: countRows.row_count_total]

        sql.close()
        return returnMap
    }

    private void findDevGsps(String current, List gsps) {
        for (file in new File(current).listFiles()) {
            if (file.path.endsWith('.gsp')) {
                gsps << file.path - 'grails-app/views/'
            } else {
                findDevGsps file.path, gsps
            }
        }
    }

    private void  findWarGsps(String current, List<String> gsps) {
        try {
            def properties = Resources.getResource('/gsp/views.properties').withReader('UTF-8') { r ->
                def p = new Properties()
                p.load(r)
                p
            }
            def keys = properties.keySet()
            log.debug("Got keys from views.properties {}", keys)
            keys.findAll { it.toString().startsWith(current) }.collect(gsps) { it - '/WEB-INF/grails-app/views/' }
        } catch (e) {
            log.error("Error loading views.properties!", e)
        }
    }


}
