package au.org.ala.volunteer

import org.springframework.web.multipart.MultipartFile
import org.hibernate.FlushMode

class LocalityService {

    static transactional = true
    def sessionFactory
    def propertyInstanceMap = org.codehaus.groovy.grails.plugins.DomainClassGrailsPlugin.PROPERTY_INSTANCE_MAP
    def logService

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
                logService.log "${rowsDeleted} rows deleted from Locality table"

                Map<String, Integer> col =[:]

                is.eachCsvLine { String[] tokens ->

                    if (!col) {
                        // First row contains column headers...
                        for (int i = 0; i < tokens.length; ++i) {
                            col[tokens[i]] = i;
                        }

                    } else {
                        def item = [:]
                        item.localityId = Long.parseLong(tokens[col.site_irn])
                        item.country = tokens[col.LocCountry]
                        item.state = tokens[col.LocProvinceStateTerritory]
                        item.township = tokens[col.LocTownship]
                        item.locality = tokens[col.LocPreciseLocation]
                        item.latitudeDMS = tokens[col.LatLatitude]
                        item.longitudeDMS = tokens[col.LatLongitude]
                        item.latitude = tokens[col.LatLatitudeDecimal] ? Double.parseDouble(tokens[col.LatLatitudeDecimal]) : null
                        item.longitude = tokens[col.LatLongitudeDecimal] ? Double.parseDouble(tokens[col.LatLongitudeDecimal]) : null

                        if (!item.latitude || !item.longitude) {
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
                        propertyInstanceMap.get().clear()
                        logService.log "${rowsProcessed} rows processed, ${count} rows imported..."
                    }

                }

                result.rowsSkipped = reasons.collect({ it.value }).sum()
                result.message = "${count} localities loaded. ${result.rowsSkipped} skipped (${reasons.toString()})"
                result.rowsProcessed = count;
            } else {
                result.message = "Invalid file, or file missing!"
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            result.message = ex.message
            result.success = false;
        } finally {
            sessionFactory.currentSession.flush();
            sessionFactory.currentSession.setFlushMode(FlushMode.AUTO)
        }

        return result
    }

    Object findLocalities(String query, String institution, int maxRows) {

        def c = Locality.createCriteria();

        String[] bits = query.split(" ");

        def results = c {
            and {
                eq('institutionCode', institution)
                and {
                    for (String bit : bits) {
                        or {
                            ilike('locality', "%${bit}%")
                            ilike('state', "%${bit}%")
                            ilike('country', "%${bit}%")
                            ilike('township', "%${bit}%")
                        }
                    }
                }
            }
            maxResults(maxRows)
        }

        return results
    }
}
