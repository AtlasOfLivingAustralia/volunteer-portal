package au.org.ala.volunteer.collectory;

import com.google.common.collect.Lists;
import com.google.gson.JsonElement;

import java.util.Date;
import java.util.List;

public class CollectoryProviderDto extends CollectoryDto {

    public String acronym; //

    public String pubDescription; // public description
    public String techDescription; // technical description
    public String focus; //
    public CollectoryAddressDto address;
    // Address postalAddress
    public Double latitude;     // decimal latitude
    public double longitude; // decimal longitude
    public String altitude; // may include units eg 700m
    public String state;
    public String websiteUrl;
    public String email;
    public String phone;

    public String notes;
    public List<JsonElement> networkMembership = Lists.newArrayList();
    public List<UrlLinkDto> attributions = Lists.newArrayList();


    public String taxonomyHints; // JSON object holding hints for taxonomic coverage
    public Date dateCreated;
    public Date lastUpdated;
    public String userLastModified;

    public ImageLinkDto imageRef;
    public ImageLinkDto logoRef;

}
