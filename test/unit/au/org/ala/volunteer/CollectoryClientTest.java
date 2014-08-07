package au.org.ala.volunteer;

import au.org.ala.volunteer.collectory.CollectoryClient;
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
    public void testGetAll() {
        List<CollectoryInstitutionDto> institutions = client.getInstitutions();

        for (CollectoryInstitutionDto institution : institutions) {
            CollectoryInstitutionDto fullInstitution = client.getInstitution(institution.uid);
        }
    }
}
