package au.org.ala.volunteer.freegeoip;

import retrofit2.Call;
import retrofit2.http.GET;
import retrofit2.http.Path;

public interface FreeGeoipClient {

    @GET("/json/{ip}")
    Call<FreeGeoipResponse> getIpGeolocation(@Path("ip") String ip);

}
