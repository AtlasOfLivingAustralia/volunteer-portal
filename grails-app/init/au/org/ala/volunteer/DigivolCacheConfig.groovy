package au.org.ala.volunteer

config = {
    cache {
        name 'userDetailsCache'
        eternal false
        timeToLiveSeconds 1800
        timeToIdleSeconds 300
        maxElementsInMemory 10000 // TODO Derive from a property?
        memoryStoreEvictionPolicy 'LRU'
        overflowToDisk true
        diskPersistent false
        diskExpiryThreadIntervalSeconds 120
    }
    cache {
        name 'userDetailsByIdCache'
        eternal false
        timeToLiveSeconds 1800
        timeToIdleSeconds 300
        maxElementsInMemory 100
        memoryStoreEvictionPolicy 'LRU'
        overflowToDisk true
        diskPersistent false
        diskExpiryThreadIntervalSeconds 120
    }
    cache {
        name 'geoip'
        eternal false
        timeToLiveSeconds 86400
    }
    diskStore {
        temp true
    }
}