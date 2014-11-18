package au.org.ala.volunteer

import grails.converters.JSON
import grails.transaction.NotTransactional
import groovy.json.JsonSlurper
import org.codehaus.groovy.grails.web.servlet.mvc.GrailsParameterMap
import org.elasticsearch.action.delete.DeleteResponse
import org.elasticsearch.action.index.IndexResponse
import org.elasticsearch.action.search.SearchRequestBuilder
import org.elasticsearch.action.search.SearchResponse
import org.elasticsearch.action.search.SearchType
import org.elasticsearch.client.Client
import org.elasticsearch.common.settings.ImmutableSettings
import org.elasticsearch.index.query.FilterBuilder
import org.elasticsearch.search.sort.SortOrder

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
        logService.log("ElasticSearch service starting...")
        ImmutableSettings.Builder settings = ImmutableSettings.settingsBuilder();
        settings.put("path.home", grailsApplication.config.elasticsearch.location);
        node = nodeBuilder().local(true).settings(settings).node();
        client = node.client();
        client.admin().cluster().prepareHealth().setWaitForYellowStatus().execute().actionGet();
        logService.log("ElasticSearch service initialisation complete.")
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
            println ex
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

    def indexTask(Task task) {
        def ct = new CodeTimer("Index task ${task.id}")

        def data = [
            id: task.id,
            projectid: task.project.id,
            externalIdentifier: task.externalIdentifier,
            externalUrl: task.externalUrl,
            fullyTranscribedBy: task.fullyTranscribedBy,
            dateFullyTranscribed: task.dateFullyTranscribed,
            fullyValidatedBy: task.fullyValidatedBy,
            dateFullyValidated:task.dateFullyValidated,
            isValid: task.isValid,
            created: task.created,
            lastViewed: new Date(task.lastViewed),
            lastViewedBy: task.lastViewedBy,
            fields: [],
            project:[
                projectType: task.project.projectType.toString(),
                institution: task.project.institution ? task.project.institution.name : task.project.featuredOwner,
                name: task.project.featuredLabel
            ]
        ]

        def c = Field.createCriteria()
        def fields = c.list {
            eq("task", task)
            eq("superceded", false)
            and {
                isNotNull("value")
                notEqual("value", "")
            }
        }

        fields.each {
            data.fields << [fieldid: it.id, name: it.name, index: it.recordIdx, value: it.value, transcribedByUserId: it.transcribedByUserId, validatedByUserId: it.validatedByUserId, updated: it.updated, created: it.created]
        }

        def json = (data as JSON).toString()

        IndexResponse response = client.prepareIndex(INDEX_NAME, TASK_TYPE, task.id.toString()).setSource(json).execute().actionGet();
        ct.stop(true)
    }

    def deleteTask(Task task) {
        if (task) {
            DeleteResponse response = client.prepareDelete(INDEX_NAME, TASK_TYPE, task.id.toString()).execute().actionGet();
        }
    }

    public QueryResults<Task> simpleTaskSearch(String query, GrailsParameterMap params) {
        def qmap = [query: [filtered: [query:[query_string: [query: query?.toLowerCase()]]]]]
        return search(qmap, params)
    }

    public QueryResults<Task> search(Map query, GrailsParameterMap params) {
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

        return executeSearch(b, params)
    }

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


    private QueryResults<Task> executeFilterSearch(FilterBuilder filterBuilder, GrailsParameterMap params) {
        def searchRequestBuilder = client.prepareSearch(INDEX_NAME).setSearchType(SearchType.QUERY_THEN_FETCH)
        searchRequestBuilder.setPostFilter(filterBuilder)
        return executeSearch(searchRequestBuilder, params)
    }

    private static QueryResults<Task> executeSearch(SearchRequestBuilder searchRequestBuilder, GrailsParameterMap params) {

        if (params?.offset) {
            searchRequestBuilder.setFrom(params.int("offset"))
        }

        if (params?.max) {
            searchRequestBuilder.setSize(params.int("max"))
        }

        if (params?.sort) {
            def order = params?.order == "asc" ? SortOrder.ASC : SortOrder.DESC
            searchRequestBuilder.addSort(params.sort as String, order)
        }

        def ct = new CodeTimer("Index search")
        SearchResponse searchResponse = searchRequestBuilder.execute().actionGet();
        ct.stop(true)

        ct = new CodeTimer("Object retrieval (${searchResponse.hits.hits.length} of ${searchResponse.hits.totalHits} hits)")
        def taskList = []
        if (searchResponse.hits) {
            searchResponse.hits.each { hit ->
                taskList << Task.get(hit.id.toLong())
            }
        }
        ct.stop(true)

        return new QueryResults<Task>(list: taskList, totalCount: searchResponse?.hits?.totalHits ?: 0)
    }

    def ping() {
        logService.log("ElasticSearch Service is ${node ? '' : 'NOT' } alive.")
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