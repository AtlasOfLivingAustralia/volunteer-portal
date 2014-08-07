package au.org.ala.volunteer.collectory;

import retrofit.http.GET;
import retrofit.http.Path;

import java.util.List;

public interface CollectoryClient {

    @GET("/institution")
    public List<CollectoryInstitutionDto> getInstitutions();

    @GET("/institution/{uid}")
    public CollectoryInstitutionDto getInstitution(@Path("uid") String uid);

}
