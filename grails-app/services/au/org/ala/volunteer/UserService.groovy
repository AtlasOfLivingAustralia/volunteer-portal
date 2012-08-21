package au.org.ala.volunteer

import org.codehaus.groovy.grails.commons.ConfigurationHolder
import javax.sql.DataSource
import groovy.sql.Sql

class UserService {

    def ROLE_ADMIN = "ROLE_VP_ADMIN"
    def ROLE_VALIDATOR = "ROLE_VP_VALIDATOR"

    def authService
    def logService

    DataSource dataSource
    def config = ConfigurationHolder.config

    static transactional = true

   /**
    * Update a user stats
    * @param userId
    * @return
    */
    def updateUserTranscribedCount(String userId){
      def transcribedCount = Task.countByFullyTranscribedBy(userId)
      User.executeUpdate("""update User u set u.transcribedCount = :transcribedCount where u.userId = :userId """,
        [transcribedCount:transcribedCount, userId:userId])
    }

   /**
    * Update a user stats
    * @param userId
    * @return
    */
    def updateUserValidatedCount(String userId){
      def validatedCount = Task.countByFullyTranscribedByAndFullyValidatedByIsNotNull(userId)
      User.executeUpdate("""update User u set u.validatedCount = :validatedCount where u.userId = :userId """,
        [validatedCount:validatedCount, userId:userId])
    }

   /**
    * Register the current user in the system.
    */
    def registerCurrentUser = {
      def userId = authService.username()
      def displayName = authService.displayName()
      logService.log("Checking user is registered: " + userId+", " + displayName )
      if(userId){
        if(User.findByUserId(userId)==null){
          User user = new User()
          user.userId = userId
          user.created = new Date()
          user.displayName = displayName
          user.save(flush:true)
        }
      }
    }

    def getUserCounts = {

        User.executeQuery("""
            select u.displayName, count(t)
            from Task t, User u
            where t.fullyTranscribedBy = u.userId
            and t.fullyTranscribedBy is not null
            group by u.displayName
            order by count(t) desc
        """)

    }

    def getUserScore(User user) {
        def t = new CodeTimer("Calculating score")
        def transcribedCount = getTranscribedCount(user)
        def tasksTheyHaveValidatedCount = getValidatedCount(user)
        def theirTasksValidated = getOwnTasksValidatedCount(user)
        def score = transcribedCount /* + theirTasksValidated */ + tasksTheyHaveValidatedCount
        logService.log "Calculated score for ${user.userId}: ${transcribedCount} (Transcribed) + ${theirTasksValidated} (number of THEIR tasks validated) + ${tasksTheyHaveValidatedCount} (tasks they have validated) = ${score}"
        t.stop(true)

        return score
    }

    def getOwnTasksValidatedCount(User user, Project project = null) {
        def c = Task.createCriteria()
        return c {
            projections {
                count('id')
            }
            and {
                eq("fullyTranscribedBy", user.userId)
                isNotNull("fullyValidatedBy")
                if (project) {
                    eq("project", project)
                }
            }
        }[0]
    }

    def getTranscribedCount(User user, Project project = null) {
        def vc = Task.createCriteria();
        return vc {
            projections {
                count('id')
            }
            and {
                eq('fullyTranscribedBy', user.getUserId())
                if (project) {
                    eq("project", project)
                }
            }
        }[0]
    }

    long getValidatedCount(User user, Project project = null) {
        def vc = Task.createCriteria();
        return vc {
            projections {
                count('id')
            }
            and {
                eq('fullyValidatedBy', user.getUserId())
                if (project) {
                    eq("project", project)
                }
            }
        }[0]
    }

//    Map filteredUserList(Map params) {
//        String query = '%'
//        if (params.q) {
//            query = "%" + (params.q?:"") + "%"
//        }
//
//        query= query.toLowerCase()
//
//        def count = User.executeQuery("""select count(u) from User u
//                                         where lower(u.displayName) like :query""",
//                                        [query: query], [:])[0]
//
//
//        def users = User.executeQuery("""select u from User u
//                                         where lower(u.displayName) like :query order by $params.sort $params.order""",
//                                        [query: query], params)
//        return [count: count, list: users.toList()]
//    }

    /**
     * returns true if the current user can validate tasks from the specified project
     * @param project
     * @return
     */
    public boolean isValidator(Project project) {
        def userId = authService.username()

        // If there the user has been granted the ALA-AUTH roles then these override everything
        if (authService.userInRole(ROLE_ADMIN) || authService.userInRole(ROLE_VALIDATOR)) {
            return true
        }

        // Otherwise check the intra app roles...

        // If project is null, return true if the user can validate in any project
        // If project is not null, return true only if they are validator for that project, or if they have a null project in their validator role (meaning 'all projects')

        def user = User.findByUserId(userId)
        if (user) {
            def validatorRole = Role.findByNameIlike("validator")
            def role = user.userRoles.find { it.role.id == validatorRole.id && (it.project == null || project == null || it.project.id == project?.id) }
            if (role) {
                // a role exists for the current user and the specified project (or the user has a role with a null project
                // indicating that they can validate tasks from any project
                return true;
            }
        }

        return false;

    }

    def getValidatedCounts(Collection<String> usernames) {
        def c = Task.createCriteria();
        def counts = c {
            projections {
                groupProperty("fullyValidatedBy")
                count("fullyValidatedBy")
            }
            if (usernames) {
                'in'("fullyValidatedBy", usernames)
            }
        }

        def results = [:]

        counts.each {
            results[it[0]] = it[1]
        }

        logService.log("Validate Counts: ${results}")

        return results
    }

    public Map getUserList(params) {
        // Because we have to calculate the number of tasks that a user has validated
        // we have to use SQL to do a join...

        def limit = params.int("limit") ?: 10;
        def offset = params.int("offset") ?: 0;
        def sort = params.sort ?: "displayName"
        def order = params.order ?:  (sort == 'displayName' ? "asc" : "desc")
        String query = '%'
        if (params.q) {
            query = "%" + (params.q?:"") + "%"
        }

        query = query.toLowerCase()

        def count = User.executeQuery("select count(u) from User u where lower(u.displayName) like :query", [query: query], [:])[0]

        def select = """
            select id, user_id as userId, display_name as displayName, transcribed_count as transcribedCount, created, coalesce(v.c, 0) as validatedCount from vp_user
            left outer join (select fully_validated_by, count(fully_validated_by) as c from Task group by fully_validated_by) as v on user_id = v.fully_validated_by
            where lower(display_name) like '${query}'
            order by ${sort} ${order}
            LIMIT ${limit}
            OFFSET ${offset}
        """.toString()

        def results = new ArrayList<UserListDTO>()

        def sql = new Sql(dataSource: dataSource)
        sql.eachRow(select, { row ->
            def user = new UserListDTO(id: row.id, userId: row.userId, displayName: row.displayName, transcribedCount: row.transcribedCount, created: row.created, validatedCount: row.validatedCount)
            results.add(user)
        })

        return [count: count, list: results]
    }
}

class UserListDTO {
    long id
    String userId
    String displayName
    int transcribedCount
    Date created
    int validatedCount
}
