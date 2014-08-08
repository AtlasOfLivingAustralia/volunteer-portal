package au.org.ala.volunteer;

import au.org.ala.volunteer.collectory.CollectoryClient;
import au.org.ala.volunteer.collectory.CollectoryCollectionDto;
import au.org.ala.volunteer.collectory.CollectoryDto;
import au.org.ala.volunteer.collectory.CollectoryInstitutionDto;
import org.junit.Before;
import org.junit.Test;
import retrofit.RestAdapter;

import java.util.List;

public class CollectoryClientTest {

    CollectoryClient client;

    @Before
    public void setup() {
        RestAdapter ra = new RestAdapter.Builder()
                .setEndpoint("http://collections.ala.org.au/ws/")
                .build();

        client = ra.create(CollectoryClient.class);
    }

    @Test
    public void testGetAllInstitutions() {
        List<CollectoryDto> institutions = client.getInstitutions();

        for (CollectoryDto institution : institutions) {
            CollectoryInstitutionDto fullInstitution = client.getInstitution(institution.uid);
            System.out.println(fullInstitution);
        }
    }

    @Test
    public void testGetAllCollections() {
        List<CollectoryDto> collections = client.getCollections();
        for (CollectoryDto collection : collections) {
            System.out.println(collection.uid);
            CollectoryCollectionDto fullCollection = client.getCollection(collection.uid);
            System.out.println(fullCollection);
        }
    }

}
