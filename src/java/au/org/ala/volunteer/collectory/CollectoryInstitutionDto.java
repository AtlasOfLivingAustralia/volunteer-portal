package au.org.ala.volunteer.collectory;

import com.google.common.collect.Lists;
import com.google.gson.JsonElement;

import java.net.URL;
import java.util.Date;
import java.util.List;

/**
 * DTO representing institutions from the ALA collectory
 */
public class CollectoryInstitutionDto {

    // present on both collection and individual versions

    public String name;
    public String uid;
    public URL uri;

    // only on individual dtos

    public CollectoryAddressDto address;

    public String acronym;
    public String guid;

    public String phone;
    public String email;

    public String pubDescription;
    public String techDescription;
    public String focus;
    public Double latitude;
    public Double longitude;

    public String state;
    public URL websiteUrl;
    public URL alaPublicUrl;

    public ImageLinkDto imageRef;
    public ImageLinkDto logoRef;

    public List<JsonElement> networkMembership = Lists.newArrayList(); // heterogenous list

    public List<CollectoryLinkDto> hubMembership = Lists.newArrayList();
    public List<UrlLinkDto> attributions = Lists.newArrayList();

    public Date dateCreated;
    public Date lastUpdated;
    public String userLastModified;
    public String institutionType; // enum

    public List<CollectoryLinkDto> collections = Lists.newArrayList();
    public List<CollectoryLinkDto> parentInstitutions = Lists.newArrayList();
    public List<CollectoryLinkDto> childInstitutions = Lists.newArrayList();
    public List<CollectoryLinkDto> linkedRecordProviders = Lists.newArrayList();

}
