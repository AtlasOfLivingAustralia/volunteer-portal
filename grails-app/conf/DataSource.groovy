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
            //url = "jdbc:postgresql://localhost/volunteers-prod"
            url = "jdbc:postgresql://localhost/volunteers"
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
                maxActive = 50
                maxIdle = 25
                minIdle = 5
                initialSize = 10
                minEvictableIdleTimeMillis = 60000
                timeBetweenEvictionRunsMillis = 5000
                maxWait = 10000
                maxAge = 10 * 60000
                validationQuery = "SELECT 1"
                validationQueryTimeout = 3
                validationInterval = 15000
                testOnBorrow = true
                testWhileIdle = true
                testOnReturn = false
                ignoreExceptionOnPreLoad = true
                // http://tomcat.apache.org/tomcat-7.0-doc/jdbc-pool.html#JDBC_interceptors
                jdbcInterceptors = "ConnectionState;StatementCache(max=200)"
                defaultTransactionIsolation = java.sql.Connection.TRANSACTION_READ_COMMITTED // safe default
                // controls for leaked connections
                abandonWhenPercentageFull = 100 // settings are active only when pool is full
                removeAbandonedTimeout = 120
                removeAbandoned = true
                // use JMX console to change this setting at runtime
                logAbandoned = false // causes stacktrace recording overhead, use only for debugging
            }
        }
    }
}
