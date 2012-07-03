package au.org.ala.volunteer

import java.util.regex.Pattern
import org.hibernate.FlushMode
import org.springframework.web.multipart.MultipartFile

class CollectionEventService {

    static transactional = true
    static Pattern normalisePattern = Pattern.compile('\\s|\\.|,|;|:|"|')
    def sessionFactory
    def propertyInstanceMap = org.codehaus.groovy.grails.plugins.DomainClassGrailsPlugin.PROPERTY_INSTANCE_MAP
    def logService

    List<CollectionEvent> findCollectionEvents(String institutionCode, List<String> collectors, String eventDate, String locality, int maxRows) {
        def c = CollectionEvent.createCriteria();
        c {
            and {
                if (institutionCode) {
                    eq('institutionCode', institutionCode)
                }
                like('eventDate', eventDate + "%")
                for (collector in collectors) {
                    if (collector) {
                        like('collectorNormalised', '%' + normaliseCollector(collector) + '%')
                    }
                }
                isNotNull('latitude')
                isNotNull('longitude')
                if (locality) {
                    or {
                        ilike('locality', '%' + locality + '%')
                        ilike('state', '%' + locality + '%')
                        ilike('country', '%' + locality + '%')
                        ilike('township', '%' + locality + '%')
                    }
                }
            }
            maxResults(maxRows)
        }
    }

    public String normaliseCollector(String collector) {
        return collector?.replaceAll(normalisePattern,'')?.toLowerCase()
    }

    public ImportResult importEvents(String institutionCode, MultipartFile file) {

        def result = new ImportResult(success: false, message: '');

        try {
            sessionFactory.currentSession.setFlushMode(FlushMode.MANUAL)
            if (file && !file.empty) {
                InputStream is = file.inputStream;
                def reasons = [:]

                def count = 0;
                def rowsProcessed = 0;

                def rowsDeleted = CollectionEvent.executeUpdate("delete CollectionEvent where institutionCode = '${institutionCode}'")
                logService.log "${rowsDeleted} rows deleted from CollectionEvent table"

                Map<String, Integer> col =[:]

                is.eachCsvLine { String[] tokens ->

                    if (!col) {
                        // First row contains column headers...
                        for (int i = 0; i < tokens.length; ++i) {
                            col[tokens[i]] = i;
                        }

                    } else {
                        def item = [:]
                        item.eventId = Long.parseLong(tokens[col.collevent_irn])
                        item.country = tokens[col.LocCountry]
                        item.state = tokens[col.LocProvinceStateTerritory]
                        item.township = tokens[col.LocTownship]
                        item.locality = tokens[col.LocPreciseLocation]
                        item.latitudeDMS = tokens[col.LatLatitude]
                        item.longitudeDMS = tokens[col.LatLongitude]
                        item.latitude = tokens[col.LatLatitudeDecimal] ? Double.parseDouble(tokens[col.LatLatitudeDecimal]) : null
                        item.longitude = tokens[col.LatLongitudeDecimal] ? Double.parseDouble(tokens[col.LatLongitudeDecimal]) : null
                        item.collector = tokens[col.NamBriefName]
                        item.date = tokens[col.ColDateVisitedFrom]
                        item.localityId = Long.parseLong(tokens[col.site_irn])

                        if (!item.date) {
                            reasons['No date'] = (reasons['No date'] ?: 0) + 1
                        } else if (!item.collector) {
                            reasons['No collector'] = (reasons['No collector'] ?: 0) + 1
                        } else {
                            String normalisedCollector = normaliseCollector(item.collector)

                            def event = new CollectionEvent(
                                    externalEventId: item.eventId,
                                    externalLocalityId: item.localityId,
                                    eventDate: item.date,
                                    collector: item.collector,
                                    latitude: item.latitude,
                                    longitude: item.longitude,
                                    locality: item.locality,
                                    township: item.township,
                                    state: item.state,
                                    country: item.country,
                                    latitudeDMS: item.latitudeDMS,
                                    longitudeDMS: item.longitudeDMS,
                                    collectorNormalised: normalisedCollector,
                                    institutionCode: institutionCode
                            )
                            event.save()
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
                result.message = "${count} collection events loaded. ${result.rowsSkipped} skipped (${reasons.toString()})"
                result.rowsProcessed = count;
            } else {
                result.message = "Invalid file, or file missing!"
            }
        } catch (Exception ex) {
            result.message = ex.message
            result.success = false;
        } finally {
            sessionFactory.currentSession.flush();
            sessionFactory.currentSession.setFlushMode(FlushMode.AUTO)
        }

        return result
    }

}

public class ImportResult {
    boolean success
    String message
    int rowsProcessed
    int rowsSkipped
}