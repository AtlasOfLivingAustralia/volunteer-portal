package au.org.ala.volunteer.collectory;

import retrofit.http.GET;
import retrofit.http.Path;

import java.util.List;

public interface CollectoryClient {

    @GET("/institution")
    public List<CollectoryDto> getInstitutions();

    @GET("/collection")
    public List<CollectoryDto> getCollections();


    @GET("/institution/{uid}")
    public CollectoryInstitutionDto getInstitution(@Path("uid") String uid);

    @GET("/collection/{uid}")
    public CollectoryCollectionDto getCollection(@Path("uid") String uid);

}
