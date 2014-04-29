dataSource {
    pooled = true
    driverClassName = "org.postgresql.Driver"
    username = "root"
    password = "password"
    loggingSql = false
}
hibernate {
    cache.use_second_level_cache = true
    cache.use_query_cache = true
    cache.provider_class = 'net.sf.ehcache.hibernate.EhCacheProvider'
}
// environment specific settings
environments {
    development {
        dataSource {
            dbCreate = "update" // one of 'create', 'create-drop','update'
            username="postgres"
            password="password"
            url = "jdbc:postgresql://localhost/volunteers-prod"
            // url = "jdbc:postgresql://localhost/volunteers"
            logSql = false
        }
    }
    uat {
        dataSource {
            dbCreate = "update" // one of 'create', 'create-drop','update'
            username="postgres"
            password="password"
            url = "jdbc:postgresql://localhost/volunteers"
            logSql = false
        }
    }
    test {
        dataSource {
            dbCreate = "update"
            url = "jdbc:postgresql://localhost/volunteerstest"
            driverClassName = "org.postgresql.Driver"
            username = "postgres"
            password = "password"
        }
    }
    production {
        dataSource {
            dbCreate = "update"
            url = "jdbc:postgresql://ala-biocachedb1.vm.csiro.au/volunteers"
            testOnBorrow = true
            properties {
                maxActive = 10
                maxIdle = 5
                minIdle = 5
                initialSize = 5
                minEvictableIdleTimeMillis = 60000
                timeBetweenEvictionRunsMillis = 60000
                maxWait = 10000
                validationQuery = "select max(id) from task"
            }
        }
    }
}
