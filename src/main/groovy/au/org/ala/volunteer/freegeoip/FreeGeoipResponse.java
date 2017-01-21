package au.org.ala.volunteer.freegeoip;

/**
 "ip": "152.83.193.195",
 "country_code": "AU",
 "country_name": "Australia",
 "region_code": "ACT",
 "region_name": "Australian Capital Territory",
 "city": "Canberra",
 "zip_code": "2601",
 "time_zone": "Australia/Sydney",
 "latitude": -35.2778,
 "longitude": 149.1183,
 "metro_code": 0
 */
public class FreeGeoipResponse {
    public String ip;
    public String countryCode;
    public String countryName;
    public String regionCode;
    public String regionName;
    public String city;
    public String zipCode;
    public String timeZone;
    public Double latitude;
    public Double longitude;
    public Integer metroCode;
}
