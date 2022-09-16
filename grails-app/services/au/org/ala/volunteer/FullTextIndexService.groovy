package au.org.ala.volunteer

import grails.async.Promises
import grails.converters.JSON
import grails.gorm.transactions.NotTransactional
import grails.gorm.transactions.Transactional
import groovy.json.JsonSlurper
import groovy.util.logging.Slf4j
import org.apache.commons.lang.NotImplementedException
import org.elasticsearch.index.query.FilterBuilders
import org.elasticsearch.index.query.QueryBuilders
import org.elasticsearch.search.sort.SortBuilders
import org.grails.orm.hibernate.HibernateSession
import org.grails.web.json.JSONObject
import org.elasticsearch.action.delete.DeleteResponse
import org.elasticsearch.action.index.IndexResponse
import org.elasticsearch.action.search.SearchRequestBuilder
import org.elasticsearch.action.search.SearchResponse
import org.elasticsearch.action.search.SearchType
import org.elasticsearch.client.Client
import org.elasticsearch.client.Requests
import org.elasticsearch.common.settings.ImmutableSettings
import org.elasticsearch.common.xcontent.ToXContent
import org.elasticsearch.common.xcontent.XContentBuilder
import org.elasticsearch.common.xcontent.XContentFactory
import org.elasticsearch.index.query.FilterBuilder
import org.elasticsearch.node.Node
import org.elasticsearch.search.sort.SortOrder
import org.hibernate.Criteria
import org.hibernate.FetchMode

import javax.annotation.PostConstruct
import javax.annotation.PreDestroy

import static au.org.ala.volunteer.BenchmarkUtils.benchmark
import static org.elasticsearch.node.NodeBuilder.nodeBuilder

@Slf4j
@Transactional(readOnly = true)
class FullTextIndexService {

    public static final String INDEX_NAME = "digivol"
    public static final String TASK_TYPE = "task"

    def grailsApplication

    private Node node
    private Client client

    @NotTransactional
    @PostConstruct
    def initialize() {
        log.info("ElasticSearch service starting...")
        ImmutableSettings.Builder settings = ImmutableSettings.settingsBuilder();
        settings.put("path.home", grailsApplication.config.elasticsearch.location);
        node = nodeBuilder().local(true).settings(settings).node();
        client = node.client();
        client.admin().cluster().prepareHealth().setWaitForYellowStatus().execute().actionGet();
        log.info("ElasticSearch service initialisation complete.")
    }

    @NotTransactional
    @PreDestroy
    def destroy() {
        if (node) {
            node.close();
        }
    }

    @NotTransactional
    def reinitialiseIndex() {
        try {
            benchmark(log, "Index deletion") {
                node.client().admin().indices().prepareDelete(INDEX_NAME).execute().get()
            }
        } catch (Exception ex) {
            log.warn("Failed to delete index - maybe because it didn't exist?", ex)
            // failed to delete index - maybe because it didn't exist?
        }
        addMappings()
    }

    def indexTask(Task task) {

        //def ct = new CodeTimer("Indexing task ${task.id}")

        LinkedHashMap<String, Serializable> data = esObjectFromTask(task)

        return indexEsObject(data)
        //ct.stop(true)
    }

    private LinkedHashMap<String, Serializable> esObjectFromTask(Task task) {
//        User validator = task.fullyValidatedBy ? User.findByUserId(task.fullyValidatedBy) : null
//        User transcriber = task.fullyTranscribedBy ? User.findByUserId(task.fullyTranscribedBy) : null
        def data = [
                id                  : task.id,
                projectid           : task.project.id,
                externalIdentifier  : task.externalIdentifier,
                externalUrl         : task.externalUrl,
                isFullyTranscribed  : task.isFullyTranscribed,
                fullyValidatedBy    : task.fullyValidatedBy,
                dateFullyValidated  : task.dateFullyValidated,
                timeToTranscribe    : task.timeToTranscribe,
                timeToValidate      : task.timeToValidate,
                isValid             : task.isValid,
                created             : task.created,
                lastViewed          : task.lastViewed ? new Date(task.lastViewed) : null,
                lastViewedBy        : task.lastViewedBy,
                version             : task.version,
                fields              : [],
                project             : [
                        projectType            : task.project.projectType.toString(),
                        institution            : task.project.institution ? task.project?.institution?.name : task.project.featuredOwner,
                        institutionCollectoryId: task.project.institution?.collectoryUid,
                        harvestableByAla       : task.project.harvestableByAla,
                        name                   : task.project.featuredLabel,
                        templateName           : task.project.template?.name,
                        templateViewName       : task.project.template?.viewName,
                        labels                 : task.project.labels?.collect {
                            [category: it.category, value: it.value]
                        } ?: []
                ],
                transcriptions       : []
        ]

        if (task.project.mapInitLatitude && task.project.mapInitLongitude) {
            data.project.put('mapRef', [lat: task.project.mapInitLatitude, lon: task.project.mapInitLongitude])
        }

        def c = Field.createCriteria()
        def fields = c {
            eq("task", task)
            eq("superceded", false)
        }

        fields.each { field ->
            if (field.value) {
                data.fields << [fieldid: field.id, name: field.name, recordIdx: field.recordIdx, value: field.value, transcribedByUserId: field.transcribedByUserId, validatedByUserId: field.validatedByUserId, updated: field.updated, created: field.created]
            }
        }

        def transcriptions = Transcription.findAllByTask(task)

        transcriptions.each { transcription ->
            if (transcription.fullyTranscribedBy) {
                data.transcriptions << [transcriptionid: transcription.id, fullyTranscribedBy: transcription.fullyTranscribedBy, dateFullyTranscribed: transcription.dateFullyTranscribed,
                                       fullyValidatedBy: transcription.fullyValidatedBy, dateFullyValidated: transcription.dateFullyValidated]
            }
        }

        return data
    }

    private IndexResponse indexEsObject(LinkedHashMap<String, Serializable> data) {
        def json = (data as JSON).toString()
        def indexBuilder = client.prepareIndex(INDEX_NAME, TASK_TYPE, data.id.toString()).setSource(json)
        if (data.version) indexBuilder.setVersion(data.version)
        IndexResponse response = indexBuilder.execute().actionGet();
        return response
    }

    @NotTransactional
    List<DeleteResponse> deleteTasks(Collection<Long> taskIds) {
        taskIds.collect {
            def dr = deleteTask(it)
            if (dr.found)
                log.debug("${dr.id} deleted from index")
            else
                log.warn("${dr.id} not found in index while attempting to delete")
            dr
        }
    }

    @NotTransactional
    DeleteResponse deleteTask(Long taskId) {
        client.prepareDelete(INDEX_NAME, TASK_TYPE, taskId.toString()).execute().actionGet();
    }

    QueryResults<Task> simpleTaskSearch(String query, Integer offset = null, Integer max = null, String sortBy = null, SortOrder sortOrder = null) {
        def qmap = [query: [filtered: [query:[query_string: [query: query?.toLowerCase()]]]]]
        return search(qmap, offset, max, sortBy, sortOrder)
    }

    /**
     * Retrieves all Tasks from the same project that have the same value for a particular field.
     * Optionally a field can be supplied to specify sort order.
     * This is used to find all Tasks that have the same sequenceGroupId for the purposes of presenting a
     * sequence of related camera trap images.
     * @param project the Project to get tasks from.
     * @param fieldName the field to search on.
     * @param fieldValue the value of the field to search on.
     * @param sortFieldName the field to sort by.
     */
    QueryResults<Task> findProjectTasksByFieldValue(Project project, String fieldName, String fieldValue, String sortFieldName = null) {
        def query = QueryBuilders.constantScoreQuery(FilterBuilders.andFilter(
                FilterBuilders.termFilter("projectid", project.id),
                FilterBuilders.nestedFilter("fields", FilterBuilders.andFilter(
                        FilterBuilders.termFilter("fields.name", fieldName),
                        FilterBuilders.termFilter("fields.value", fieldValue)

                ))
        ))

        def searchRequest = client.prepareSearch(INDEX_NAME).setSearchType(SearchType.QUERY_THEN_FETCH).setQuery(query)
        if (sortFieldName) {
            def sort = SortBuilders.fieldSort("fields.value").setNestedFilter(FilterBuilders.termFilter("fields.name", sortFieldName))
            searchRequest.addSort(sort)
        }
        executeSearch(searchRequest, null, null, null, null)

    }

    QueryResults<Task> search(Map query, Integer offset, Integer max, String sortBy, SortOrder sortOrder) {
        Map qmap = null
        Map fmap = null
        if (query.query) {
            qmap = query.query
        } else {
            if (query.filter) {
                fmap = query.filter
            } else {
                qmap = query
            }
        }

        def b = client.prepareSearch(INDEX_NAME).setSearchType(SearchType.QUERY_THEN_FETCH)
        if (qmap) {
            b.setQuery(qmap)
        }

        if (fmap) {
            b.setPostFilter(fmap)
        }

        return executeSearch(b, offset, max, sortBy, sortOrder)
    }

    public <V> V rawSearch(String json, SearchType searchType, Closure<V> resultClosure) {
        rawSearch(json, searchType, null, null, null, null, null, resultClosure)
    }


    public <V> V rawSearch(String json, SearchType searchType, String aggregation, Closure<V> resultClosure) {
        rawSearch(json, searchType, aggregation, null, null, null, null, resultClosure)
    }

    public <V> V rawSearch(String json, SearchType searchType, Integer max, Closure<V> resultClosure) {
        rawSearch(json, searchType, null, null, max, null, null, resultClosure)
    }

    public <V> V rawSearch(String json, SearchType searchType, String aggregation, Integer offset, Integer max, String sortBy, SortOrder sortOrder, Closure<V> resultClosure) {
        
        def queryMap = jsonStringToJSONObject(json)

        def b = client.prepareSearch(INDEX_NAME).setSearchType(searchType)
        
        Requests.searchRequest(INDEX_NAME).source(json)
        b.setQuery(queryMap)
        if (aggregation) {
            def aggMap = jsonStringToJSONObject(aggregation)
            b.setAggregations(aggMap)
        }
        
        return executeGenericSearch(b, offset, max, sortBy, sortOrder, resultClosure)
    }

    private JSONObject jsonStringToJSONObject(String json) {
        def map = JSON.parse(json)

        if (map instanceof JSONObject) {
            return map
        }
        throw new IllegalArgumentException("json must be a JSON object")
    }
    
    Closure<String> elasticSearchToJsonString = { ToXContent toXContent ->
        XContentBuilder builder = XContentFactory.jsonBuilder()
        builder.startObject().humanReadable(true)
        toXContent.toXContent(builder, ToXContent.EMPTY_PARAMS);
        builder.endObject().flush().string()
    }
    
    Closure<Boolean> searchResponseHitsGreaterThanOrEqual(long count) {
        { SearchResponse searchResponse -> searchResponse.hits.totalHits() >= count }
    }

    Closure<Boolean> aggregationHitsGreaterThanOrEqual(long count, AggregationType type) {
        def closure;
        switch (type) {
            case AggregationType.ALL_MATCH:
                throw new NotImplementedException("aggregationHitsGreaterThanOrEqual(count,type) can't be applied to type ${type}")
                //closure = { SearchResponse searchResponse -> true }
                break
            case AggregationType.ANY_MATCH:
                throw new NotImplementedException("aggregationHitsGreaterThanOrEqual(count,type) can't be applied to type ${type}")
                //closure = { SearchResponse searchResponse -> true }
                break
            default:
                throw new RuntimeException("aggregationHitsGreaterThanOrEqual(count,type) can't be applied to type ${type}")
        }
        return closure
    }

    static Closure<Long> hitsCount = {
        SearchResponse searchResponse -> searchResponse.hits.totalHits
    }
    
    static Closure<SearchResponse> rawResponse = { it }

    def addMappings() {

        def mappingJson = '''
{
  "mappings": {
    "task": {
      "dynamic_templates": [
      ],
      "_all": {
        "enabled": true,
        "store": "yes"
      },
      "properties": {
        "id" : {"type" : "long"},
        "projectId" : {"type" : "long"},
        "externalIdentifier" : {"type" : "string", "index": "not_analyzed" },
        "externalUrl" : {"type" : "string", "index": "not_analyzed"},
        "isFullyTranscribed": {"type":"boolean"},
        "fullyValidatedBy" : {"type" : "string", "index": "not_analyzed"},
        "dateFullyValidated" : {"type" : "date"},
        "isValid" : {"type" : "boolean"},
        "timeToTranscribe" : {"type":"integer"},
        "timeToValidate" : {"type":"integer"},
        "created" : {"type" : "date"},
        "lastViewed" : {"type" : "date"},
        "lastViewedBy" : {"type" : "string", "index": "not_analyzed"},
        "fields" : {
          "type" : "nested",
          "include_in_parent": true,
          "properties": {
            "fieldid" : {"type": "long" },
            "name"  : { "type": "string", "index": "not_analyzed" },
            "recordIdx" : {"type": "integer" },
            "value"  : {
              "type": "string",
              "index": "not_analyzed",
              "fields": {
                "analyzed": {
                  "type": "string",
                  "index": "analyzed",
                  "analyzer": "snowball"
                }
              }
            },
            "transcribedByUserId": {"type": "string", "index": "not_analyzed" },
            "validatedByUserId": {"type": "string", "index": "not_analyzed" },
            "updated" : {"type" : "date"},
            "created" : {"type" : "date"}
          }
        },
        "project" : {
          "type" : "object",
          "properties" : {
            "name" : {
              "type": "string",
              "index": "not_analyzed",
              "fields": {
                "analyzed": {
                  "type": "string",
                  "index": "analyzed",
                  "analyzer": "snowball"
                }
              }
            },
            "projectType" : { "type" : "string", "index": "not_analyzed" },
            "institution" : {
              "type": "string",
              "index": "not_analyzed",
              "fields": {
                "analyzed": {
                  "type": "string",
                  "index": "analyzed"
                }
              }
            },
            "institutionCollectoryId": { "type" : "string", "index": "not_analyzed" },
            "harvestableByAla": { "type" : "boolean" },
            "mapRef": { "type": "geo_point", "lat_lon": true },
            "templateName" : { "type" : "string", "index": "not_analyzed"},
            "templateViewName" : { "type" : "string", "index": "not_analyzed"},
            "labels" : {
              "type" : "nested",
              "include_in_parent": true,
              "properties": {
                "category" : { "type": "string", "index": "not_analyzed" },
                "value"  : { "type": "string", "index": "not_analyzed" }
              }
            }
          }
        },
        "transcriptions" : {
          "type" : "nested",
          "include_in_parent": true,
          "properties": {
            "transcriptionid" : {"type": "long" },
            "fullyTranscribedBy": {"type": "string", "index": "not_analyzed" },
            "dateFullyTranscribed" : {"type" : "date"},
            "fullyValidatedBy": {"type": "string", "index": "not_analyzed" },
            "dateFullyValidated" : {"type" : "date"}
          }
        }
      }
    }
  }
}
        '''

        def parsedJson = new JsonSlurper().parseText(mappingJson)
        def mappingsDoc = (parsedJson as JSON).toString()
        client.admin().indices().prepareCreate(INDEX_NAME).setSource(mappingsDoc).execute().actionGet()

        client.admin().cluster().prepareHealth().setWaitForYellowStatus().execute().actionGet()
    }

    def flush () {
        client.admin().indices().prepareFlush().execute().actionGet();
    }

    private QueryResults<Task> executeFilterSearch(FilterBuilder filterBuilder, Integer offset, Integer max, String sortBy, SortOrder sortOrder) {
        def searchRequestBuilder = client.prepareSearch(INDEX_NAME).setSearchType(SearchType.QUERY_THEN_FETCH)
        searchRequestBuilder.setPostFilter(filterBuilder)
        return executeSearch(searchRequestBuilder, offset, max, sortBy, sortOrder)
    }

    private static <V> V executeGenericSearch(SearchRequestBuilder searchRequestBuilder, Integer offset = null, Integer max = null, String sortBy = null, SortOrder sortOrder = null, Closure<V> closure) {
        if (offset) {
            searchRequestBuilder.setFrom(offset)
        }

        if (max) {
            searchRequestBuilder.setSize(max)
        }

        if (sortBy) {
            def order = sortOrder == SortOrder.ASC ? SortOrder.ASC : SortOrder.DESC
            searchRequestBuilder.addSort(sortBy, order)
        }

        // TODO Create a Yammer metrics meter
        //def ct = new CodeTimer("Index search")
        SearchResponse searchResponse = searchRequestBuilder.execute().actionGet();
        //ct.stop(true)

        closure(searchResponse)
    }

    private static QueryResults<Task> executeSearch(SearchRequestBuilder searchRequestBuilder, Integer offset, Integer max, String sortBy, SortOrder sortOrder) {

        executeGenericSearch(searchRequestBuilder, offset, max, sortBy, sortOrder) { SearchResponse searchResponse ->
            List<Task> taskList = benchmark("Object retrieval (${searchResponse?.hits?.hits?.length} of ${searchResponse?.hits?.totalHits} hits)") {
                List ids = searchResponse.hits*.id*.toLong()
                ids ? Task.findAllByIdInList(ids) : []
            }

            return new QueryResults<Task>(list: taskList, totalCount: searchResponse?.hits?.totalHits ?: 0)
        }
    }

    @NotTransactional
    def ping() {
        log.info("ElasticSearch Service is${node ? ' ' : ' NOT ' }alive.")
    }

    @Transactional(readOnly = true)
    def indexTasks(Set<Long> ids, Closure cb = null) {
        if (ids) {

            final numBuckets = (int)(ids.size() / Runtime.runtime.availableProcessors()) + 1

            def promises = ids.toList()
                .collate(numBuckets)
                .findAll { !it.empty }
                .collect { bucket ->
                    Task.async.task {
                        withStatelessSession { HibernateSession session ->
                            //session.setSessionProperty('defaultReadOnly', true)
                            withCriteria {
                                'in'('id', bucket)
                                fetchMode 'project', FetchMode.JOIN
                                fetchMode 'project.labels', FetchMode.JOIN
                                fetchMode 'project.institution', FetchMode.JOIN
                                resultTransformer Criteria.DISTINCT_ROOT_ENTITY
                            }.collect { task ->
                                IndexResponse r = null
                                try {
                                    r = indexTask(task)
                                    if (cb) cb.call(task.id)
                                } catch (e) {
                                    log.error("exception trying to index task $task.id", e)
                                }
                                r
                            }
                        }
                    }
                }
            Promises.waitAll(promises).flatten()
        } else { [] }
    }

}

/**
 * For when you need to return both a page worth of results and the total count of record (for pagination purposes)
 *
 * @param < T > Usually a domain class. The type of objects being returned in the list
 */
public class QueryResults <T> {

    public List<T> list = []
    public int totalCount = 0
}