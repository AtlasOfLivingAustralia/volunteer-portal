package au.org.ala.volunteer.collectory;

import org.springframework.beans.factory.FactoryBean;
import retrofit2.Retrofit;

public class CollectoryClientFactoryBean implements FactoryBean<CollectoryClient> {

    private String endpoint;

    @Override
    public CollectoryClient getObject() throws Exception {
        return new Retrofit.Builder().baseUrl(endpoint).build().create(CollectoryClient.class);
    }

    @Override
    public Class<CollectoryClient> getObjectType() {
        return CollectoryClient.class;
    }

    @Override
    public boolean isSingleton() {
        return true;
    }

    public String getEndpoint() {
        return endpoint;
    }

    public void setEndpoint(String endpoint) {
        this.endpoint = endpoint;
    }
}
