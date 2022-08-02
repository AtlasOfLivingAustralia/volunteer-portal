package au.org.ala.volunteer

import grails.gorm.transactions.Transactional
import org.springframework.web.multipart.MultipartFile
import org.hibernate.FlushMode
import org.hibernate.Criteria
import groovy.sql.Sql

import javax.sql.DataSource

@Transactional
class LocalityService {

    def sessionFactory
    DataSource dataSource

    private List<String> _allStates = null;

    public List<String> getCollectionCodes() {
        def c = Locality.createCriteria();

        def results = c {
            isNotNull("institutionCode")
            projections {
                distinct("institutionCode")
            }
        }

        return results
    }

    public ImportResult importLocalities(String institutionCode, MultipartFile file) {

        def result = new ImportResult(success: false, message: '');

        try {
            sessionFactory.currentSession.setFlushMode(FlushMode.MANUAL)
            if (file && !file.empty) {
                InputStream is = file.inputStream;
                def reasons = [:]

                def count = 0;
                def rowsProcessed = 0;

                def rowsDeleted = Locality.executeUpdate("delete Locality where institutionCode = '${institutionCode}'")
                log.info "${rowsDeleted} rows deleted from Locality table"

                Map<String, Integer> col =[:]

                is.eachCsvLine { String[] tokens ->

                    if (!col) {
                        // First row contains column headers...
                        for (int i = 0; i < tokens.length; ++i) {
                            col[tokens[i]] = i;
                        }

                    } else {
                        def item = [:]
                        def localityId = tokens[col.site_irn]
                        if (localityId) {
                            item.localityId = Long.parseLong(localityId)
                            item.country = tokens[col.LocCountry]
                            item.state = tokens[col.LocProvinceStateTerritory]
                            item.township = tokens[col.LocTownship]
                            item.locality = tokens[col.LocPreciseLocation]
                            item.latitudeDMS = tokens[col.LatLatitude]
                            item.longitudeDMS = tokens[col.LatLongitude]
                            item.latitude = tokens[col.LatLatitudeDecimal] ? Double.parseDouble(tokens[col.LatLatitudeDecimal]) : null
                            item.longitude = tokens[col.LatLongitudeDecimal] ? Double.parseDouble(tokens[col.LatLongitudeDecimal]) : null
                        }

                        if (!item || !item.localityId) {
                            reasons['No LocalityID'] = (reasons['No LocalityID'] ?: 0) + 1
                        } else if (!item.latitude || !item.longitude) {
                            reasons['No Position'] = (reasons['No Position'] ?: 0) + 1
                        } else {
                            def locality = new Locality(
                                    externalLocalityId: item.localityId,
                                    latitude: item.latitude,
                                    longitude: item.longitude,
                                    locality: item.locality,
                                    township: item.township,
                                    state: item.state,
                                    country: item.country,
                                    latitudeDMS: item.latitudeDMS,
                                    longitudeDMS: item.longitudeDMS,
                                    institutionCode: institutionCode
                            )
                            locality.save()
                            count++
                        }
                    }
                    rowsProcessed++;
                    if (rowsProcessed % 2000 == 0) {
                        // Doing this significantly speeds up imports...
                        sessionFactory.currentSession.flush()
                        sessionFactory.currentSession.clear()
                        log.info "${rowsProcessed} rows processed, ${count} rows imported..."
                    }

                }

                result.rowsSkipped = reasons.collect({ it.value })?.sum() ?: 0
                result.message = "${count} localities loaded. ${result.rowsSkipped} skipped (${reasons.toString()})"
                result.rowsProcessed = count;
            } else {
                result.message = "Invalid file, or file missing!"
            }
        } catch (Exception ex) {
            // ex.printStackTrace();
            log.error("Import Localities failed: ${ex.message}", ex)
            result.message = ex.message
            result.success = false;
        } finally {
            sessionFactory.currentSession.flush();
            sessionFactory.currentSession.setFlushMode(FlushMode.AUTO)
        }

        return result
    }

    private Closure wholeTerm = {String query, String institution, int maxRows, boolean wildcard ->
        // First try and find an exact match...
        def c = Locality.createCriteria();
        def wildcardChar = (wildcard ? "%" : "")

        def results = c {
            and {
                eq('institutionCode', institution)
                or {
                    ilike('locality', "${wildcardChar}${query}${wildcardChar}")
                    ilike('township', "${wildcardChar}${query}${wildcardChar}")
                }
                notEqual('latitude', (double) 0)
                notEqual('longitude', (double) 0)
                isNotNull('latitude')
                isNotNull('longitude')
            }
            maxResults(maxRows)
        }

        return results;
    }

    private Closure splitTerms = { String query, String institution, int maxRows, boolean wildcard ->
        // try and break it down and make the search more liberal
        def c = Locality.createCriteria();
        def wildcardChar = (wildcard ? "%" : "")
        String[] bits = query.split(" ");

        def results = c {
            and {
                eq('institutionCode', institution)
                and {
                    notEqual('latitude', (double) 0)
                    notEqual('longitude', (double) 0)
                    isNotNull('latitude')
                    isNotNull('longitude')
                    for (String bit : bits) {
                        or {
                            ilike('locality', "${wildcardChar}${bit}${wildcardChar}")
                            ilike('state', "${wildcardChar}${bit}${wildcardChar}")
                            ilike('country', "${wildcardChar}${bit}${wildcardChar}")
                            ilike('township', "${wildcardChar}${bit}${wildcardChar}")
                        }
                    }
                }
            }
            maxResults(maxRows)
        }
        return results;
    }

    private synchronized String findState(String query) {
        if (_allStates == null) {
            _allStates = new ArrayList<String>()
            def sql = new Sql(dataSource: dataSource)
            sql.eachRow("SELECT DISTINCT(LOWER(State)) from locality") { row ->
                def state = row[0] as String
                if (state) {
                    log.info("Adding state to cache: ${state}")
                    _allStates.add(state)
                }
            }
            sql.close()
        }

        for (String state : _allStates) {
            if (query.contains(state)) {
                return state
            }
        }
    }

    private Closure stateMatchWhole = { String query, String institution, int maxRows, boolean wildcard ->
        query = query.toLowerCase()
        String state = findState(query)

        if (state == null) {
            return null;
        }

        // need to strip out the state from the query...
        query = query.replaceAll(state, "").trim()
        log.info("Found state: ${state}, modified query is now ${query}")

        def wildcardChar = (wildcard ? "%" : "")
        def c  = Locality.createCriteria();

        def results = c {
            and {
                eq('institutionCode', institution)
                and {
                    or {
                        ilike('locality', "${wildcardChar}${query}${wildcardChar}")
                        ilike('country', "${wildcardChar}${query}${wildcardChar}")
                        ilike('township', "${wildcardChar}${query}${wildcardChar}")
                    }
                    ilike('state', "${state}")
                    notEqual('latitude', (double) 0)
                    notEqual('longitude', (double) 0)
                    isNotNull('latitude')
                    isNotNull('longitude')
                }
            }
            maxResults(maxRows)
        }
        return results;
    }

    private Closure stateMatchSplit = { String query, String institution, int maxRows, boolean wildcard ->
        query = query.toLowerCase()
        String state = findState(query)

        if (state == null) {
            return null;
        }

        // need to strip out the state from the query...
        query = query.replaceAll(state, "").trim()
        log.info("Found state: ${state}, modified query is now ${query}")

        def wildcardChar = (wildcard ? "%" : "")
        def c  = Locality.createCriteria();
        String[] bits = query.split(" ");

        def results = c {
            and {
                eq('institutionCode', institution)
                and {
                    for (String bit : bits) {
                        or {
                            ilike('locality', "${wildcardChar}${bit}${wildcardChar}")
                            ilike('country', "${wildcardChar}${bit}${wildcardChar}")
                            ilike('township', "${wildcardChar}${bit}${wildcardChar}")
                        }
                    }
                    ilike('state', "${state}")
                    notEqual('latitude', (double) 0)
                    notEqual('longitude', (double) 0)
                    isNotNull('latitude')
                    isNotNull('longitude')
                }
            }
            maxResults(maxRows)
        }
        return results;
    }


    Object findLocalities(String query, String institution, int maxRows) {

        query = query?.trim();
        List<Closure> criteriaFunctions = [wholeTerm, stateMatchWhole, stateMatchSplit, splitTerms ]

        List<Locality> results = null;
        for (boolean wildcard in [false, true]) {
            for (Closure searchFunction : criteriaFunctions) {
                results = searchFunction(query, institution, maxRows, wildcard)
                if (results?.size() > 0) {
                    return results;
                }
            }
        }

        return results;
    }

}

