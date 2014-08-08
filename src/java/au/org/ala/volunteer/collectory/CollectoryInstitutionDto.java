package au.org.ala.volunteer.collectory;

import com.google.common.collect.Lists;
import com.google.gson.JsonElement;

import java.net.URL;
import java.util.Date;
import java.util.List;

/**
 * DTO representing institutions from the ALA collectory
 */
public class CollectoryInstitutionDto extends CollectoryProviderDto {

    public URL alaPublicUrl;
    public String institutionType;


    public List<CollectoryLinkDto> hubMembership = Lists.newArrayList();

    public List<CollectoryLinkDto> collections = Lists.newArrayList();
    public List<CollectoryLinkDto> parentInstitutions = Lists.newArrayList();
    public List<CollectoryLinkDto> childInstitutions = Lists.newArrayList();
    public List<CollectoryLinkDto> linkedRecordProviders = Lists.newArrayList();

}
