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
            loggingSql = false
        }
    }
    uat {
        dataSource {
            dbCreate = "update" // one of 'create', 'create-drop','update'
            username="postgres"
            password="password"
            url = "jdbc:postgresql://localhost/volunteers"
            loggingSql = false
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
        }
    }
}
