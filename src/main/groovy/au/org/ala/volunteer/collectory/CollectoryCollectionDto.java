package au.org.ala.volunteer.collectory;

import com.google.common.collect.Lists;
import com.google.gson.JsonElement;

import java.util.ArrayList;
import java.util.List;

public class CollectoryCollectionDto extends CollectoryProviderDto {

    public List<String> collectionType = new ArrayList<String>();
    public List<String> keywords = new ArrayList<String>();
    public String active;
    public String numRecords;
    public String numRecordsDigitised;
    public String states;
    public String geographicDescription;
    public String startDate;
    public String endDate;
    public List<String> kingdomCoverage = new ArrayList<String>();
    public List<String> scientificNames = new ArrayList<String>();

    public List<JsonElement> subCollections = Lists.newArrayList();

    public JsonElement institution;




}
