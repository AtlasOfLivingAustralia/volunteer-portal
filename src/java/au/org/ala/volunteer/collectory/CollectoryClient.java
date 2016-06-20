package au.org.ala.volunteer.collectory;

import retrofit2.Call;
import retrofit2.http.GET;
import retrofit2.http.Path;

import java.util.List;

public interface CollectoryClient {

    @GET("/institution")
    Call<List<CollectoryDto>> getInstitutions();

    @GET("/collection")
    Call<List<CollectoryDto>> getCollections();


    @GET("/institution/{uid}")
    Call<CollectoryInstitutionDto> getInstitution(@Path("uid") String uid);

    @GET("/collection/{uid}")
    Call<CollectoryCollectionDto> getCollection(@Path("uid") String uid);

}
