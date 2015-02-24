package au.org.ala.volunteer

import grails.converters.JSON
import grails.transaction.NotTransactional
import groovy.json.JsonSlurper
import org.codehaus.groovy.grails.web.json.JSONObject
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
import org.elasticsearch.search.sort.SortOrder
import org.grails.plugins.metrics.groovy.Timed

import javax.annotation.PostConstruct
import javax.annotation.PreDestroy
import java.util.concurrent.ConcurrentLinkedQueue

import static org.elasticsearch.node.NodeBuilder.nodeBuilder
import org.elasticsearch.node.Node


class FullTextIndexService {

    public static final String INDEX_NAME = "digivol"
    public static final String TASK_TYPE = "task"

    private static Queue<IndexTaskTask> _backgroundQueue = new ConcurrentLinkedQueue<IndexTaskTask>()

    def logService
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

    @PreDestroy
    def destroy() {
        if (node) {
            node.close();
        }
    }

    public reinitialiseIndex() {
        try {
            def ct = new CodeTimer("Index deletion")
            node.client().admin().indices().prepareDelete(INDEX_NAME).execute().get()
            ct.stop(true)

        } catch (Exception ex) {
            log.warn("Failed to delete index - maybe because it didn't exist?", ex)
            // failed to delete index - maybe because it didn't exist?
        }
        addMappings()
    }

    def scheduleTaskIndex(Task task) {
        def job = new IndexTaskTask(taskId: task.id)
        _backgroundQueue.add(job)
    }

    def scheduleTaskIndex(long taskId) {
        def job = new IndexTaskTask(taskId: taskId)
        _backgroundQueue.add(job)
    }

    def getIndexerQueueLength() {
        return _backgroundQueue.size()
    }

    def processIndexTaskQueue(int maxTasks = 10000) {
        int taskCount = 0
        IndexTaskTask jobDescriptor = null

        while (taskCount < maxTasks && (jobDescriptor = _backgroundQueue.poll()) != null) {
            if (jobDescriptor) {
                Task t = Task.get(jobDescriptor.taskId)
                if (t) {
                    indexTask(t)
                }
                taskCount++
            }
        }

    }

    @Timed
    def indexTask(Task task) {

        //def ct = new CodeTimer("Indexing task ${task.id}")

        def data = [
            id: task.id,
            projectid: task.project.id,
            externalIdentifier: task.externalIdentifier,
            externalUrl: task.externalUrl,
            fullyTranscribedBy: task.fullyTranscribedBy,
            dateFullyTranscribed: task.dateFullyTranscribed,
            fullyValidatedBy: task.fullyValidatedBy,
            dateFullyValidated: task.dateFullyValidated,
            isValid: task.isValid,
            created: task.created,
            lastViewed: task.lastViewed ? new Date(task.lastViewed) : null,
            lastViewedBy: task.lastViewedBy,
            fields: [],
            project:[
                projectType: task.project.projectType.toString(),
                institution: task.project.institution ? task.project.institution.name : task.project.featuredOwner,
                name: task.project.featuredLabel
            ]
        ]

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

        def json = (data as JSON).toString()
        def indexBuilder = client.prepareIndex(INDEX_NAME, TASK_TYPE, task.id.toString()).setSource(json)
        if (task.version) indexBuilder.setVersion(task.version)
        IndexResponse response = indexBuilder.execute().actionGet();

        //ct.stop(true)
    }

    List<DeleteResponse> deleteTasks(Collection<Long> taskIds) {
        taskIds.collect {
            def dr = deleteTask(it)
            if (dr.found)
                log.info("${dr.id} deleted from index")
            else
                log.warn("${dr.id} not found in index")
        }
    }
    
    DeleteResponse deleteTask(Long taskId) {
        client.prepareDelete(INDEX_NAME, TASK_TYPE, taskId.toString()).execute().actionGet();
    }

    public QueryResults<Task> simpleTaskSearch(String query, Integer offset = null, Integer max = null, String sortBy = null, SortOrder sortOrder = null) {
        def qmap = [query: [filtered: [query:[query_string: [query: query?.toLowerCase()]]]]]
        return search(qmap, offset, max, sortBy, sortOrder)
    }

    public QueryResults<Task> search(Map query, Integer offset, Integer max, String sortBy, SortOrder sortOrder) {
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
    
    public <V> V rawSearch(String json, SearchType searchType, String aggregation = null, Integer offset = null, Integer max = null, String sortBy = null, SortOrder sortOrder = null, Closure<V> resultClosure) {
        
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
    
    Closure<Boolean> searchResponseHitsGreaterThan(long count) {
        { SearchResponse searchResponse -> searchResponse.hits.totalHits() > count } 
    }

    Closure<Boolean> aggregationHitsGreaterThan(long count, AggregationType type) {
        def closure;
        switch (type) {
            case AggregationType.ALL_MATCH:
                closure = { SearchResponse searchResponse -> true }
                break
            case AggregationType.ANY_MATCH:
                closure = { SearchResponse searchResponse -> true }
                break
            default:
                throw new RuntimeException("aggregationHitsGreaterThan(count,type) can't be applied to type ${type}")
        }
        return closure
    }
    
    Closure<SearchResponse> identity = { it }

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

        def ct = new CodeTimer("Index search")
        SearchResponse searchResponse = searchRequestBuilder.execute().actionGet();
        ct.stop(true)
        
        closure(searchResponse)
    }

    private static QueryResults<Task> executeSearch(SearchRequestBuilder searchRequestBuilder, Integer offset, Integer max, String sortBy, SortOrder sortOrder) {

        executeGenericSearch(searchRequestBuilder, offset, max, sortBy, sortOrder) { SearchResponse searchResponse ->
            def ct = new CodeTimer("Object retrieval (${searchResponse.hits.hits.length} of ${searchResponse.hits.totalHits} hits)")
            def taskList = []
            if (searchResponse.hits) {
                searchResponse.hits.each { hit ->
                    taskList << Task.get(hit.id.toLong())
                }
            }
            ct.stop(true)
            return new QueryResults<Task>(list: taskList, totalCount: searchResponse?.hits?.totalHits ?: 0)
        }
    }

    def ping() {
        log.info("ElasticSearch Service is${node ? ' ' : ' NOT ' }alive.")
    }

    @Timed
    def indexTasks(Set<Long> ids) {
        Task.findByIdInList(ids.toList()).each { indexTask(it) }
        //achievementService.calculateAchievements(userService.currentUser)
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

public class IndexTaskTask {

    public long taskId

}