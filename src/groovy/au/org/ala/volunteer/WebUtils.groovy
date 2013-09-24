/*
 *  Copyright (C) 2011 Atlas of Living Australia
 *  All Rights Reserved.
 *
 *  The contents of this file are subject to the Mozilla Public
 *  License Version 1.1 (the "License"); you may not use this file
 *  except in compliance with the License. You may obtain a copy of
 *  the License at http://www.mozilla.org/MPL/
 *
 *  Software distributed under the License is distributed on an "AS
 *  IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 *  implied. See the License for the specific language governing
 *  rights and limitations under the License.
 */

package au.org.ala.volunteer

import java.util.regex.Pattern

class WebUtils {

    public static DECIMAL_DEGREE_PATTERN = Pattern.compile("^\\d+[.]\\d+\$")
    public static DEGREE_DECIMAL_MINUTES_PATTERN = Pattern.compile("^(\\d+)[°](\\d+)[.](\\d+)\$")
    public static DEGREE_PATTERN = Pattern.compile("^(\\d+)[°]\$")
    public static DEGREE_MINUTES_PATTERN = Pattern.compile("^(\\d+)[°](\\d+)[']\$")
    public static DEGREE_MINUTES_SECONDS_PATTERN = Pattern.compile("^(\\d+)[°](\\d+)['](\\d+)[\"]\$")

    public static YEAR_PATTERN = Pattern.compile("^(\\d{2,4})\$")
    public static YEAR_MONTH_PATTERN = Pattern.compile("^(\\d{2,4})-(\\d{1,2})\$")
    public static YEAR_MONTH_DAY_PATTERN = Pattern.compile("^(\\d{2,4})-(\\d{1,2})-(\\d{1,2})\$")


    /**
     * Remove strange chars from form fields (appear with ° symbols, etc)
     */
    static void cleanRecordValues(Map recordValues) {
// Update 5/4/2013 David Baird
// The inclusion of the webxml plugin appears to have fixed the encoding filter order problem, with the side effect of the following code
// breaking the now correct encoding. So it has been commented out.

//        def idx = 0
//        def hasMore = true
//        while (hasMore) {
//            def fieldValuesForRecord = recordValues.get(idx.toString())
//            if (fieldValuesForRecord) {
//                fieldValuesForRecord.each { keyValue ->
//                    // remove strange chars from form fields TODO: find out why they are appearing
//                    // keyValue.value = keyValue.value.replace("Â","").replace("Ã","")
//
//                    // David Baird 7th June 2012
//                    // Got to the bottom of this...Apparently in the Servlet Spec, containers always assume form parameters are sent as ISO 8859-1 (the default encoding of HTTP)
//                    // The string created by the container apparatus contains the right sequence of bytes, but has the wrong encoding.
//                    // With ASCII form data the problem is undetectable because 8 bit characters are the same in both encodings,
//                    // but when you have a utf-8 surrogate pair character (anything > 1 byte) the incorrect encoding becomes a problem
//                    // The solution is to extract the original sequence of bytes and 'recast' them as utf-8
//
//                    // see http://friend-of-misery.blogspot.com.au/2007/03/java-and-utf-8-encoding.html
//                    // Also see http://blog.saddey.net/2010/02/06/grails-utf-8-form-input-garbled-when-running-within-tomcat/ which indicates
//                    // there maybe something we can do configuration wise to get rid of this hack
//
//                    if (keyValue?.value instanceof String) {
//                        keyValue.value = new String(keyValue.value.getBytes("8859_1"), "utf-8")
//                    } // Todo: could be an array in the case where the same fieldname is included more than once in the submission!
//                }
//                idx++
//            } else {
//                hasMore = false
//            }
//        }
    }

    public static LatLongValues parseLatLong(String val) {
        if (val) {
            def matcher = DECIMAL_DEGREE_PATTERN.matcher(val)
            if (matcher.matches()) {
                return new LatLongValues(decimalDegrees: val)
            }

            matcher = DEGREE_DECIMAL_MINUTES_PATTERN.matcher(val)
            if (matcher.matches()) {
                return new LatLongValues(degrees: matcher.group(1), minutes: matcher.group(2))
            }

            matcher = DEGREE_PATTERN.matcher(val)
            if (matcher.matches()) {
                return new LatLongValues(degrees: matcher.group(1))
            }

            matcher = DEGREE_MINUTES_PATTERN.matcher(val)
            if (matcher.matches()) {
                return new LatLongValues(degrees: matcher.group(1), minutes: matcher.group(2))
            }

            matcher = DEGREE_MINUTES_SECONDS_PATTERN.matcher(val)
            if (matcher.matches()) {
                return new LatLongValues(degrees: matcher.group(1), minutes: matcher.group(2), seconds: matcher.group(3))
            }
        }

        return new LatLongValues(decimalDegrees: val)
    }

    public static DateRange parseDateRange(String val) {
        if (val) {
            if (val.contains('/')) {
                def bits = val.split('/')
                def startDate = parseDate(bits[0])
                def endDate = parseDate(bits[1])
                return new DateRange(startDate: startDate, endDate: endDate)
            } else {
                return new DateRange(startDate: parseDate(val))
            }
        }
        return new DateRange(startDate: parseDate(val))
    }

    public static DateComponents parseDate(String val) {
        if (val) {
            def matcher = YEAR_MONTH_DAY_PATTERN.matcher(val)
            if (matcher.matches()) {
                return new DateComponents(year: matcher.group(1), month: matcher.group(2), day: matcher.group(3))
            }
            matcher = YEAR_MONTH_PATTERN.matcher(val)
            if (matcher.matches()) {
                return new DateComponents(year: matcher.group(1), month: matcher.group(2))
            }
            matcher = YEAR_PATTERN.matcher(val)
            if (matcher.matches()) {
                return new DateComponents(year: matcher.group(1))
            }
        }

        return new DateComponents(year: val)
    }

}

public class LatLongValues {
    String degrees
    String minutes
    String seconds
    String decimalDegrees
}

public class DateRange {
    DateComponents startDate
    DateComponents endDate
}

public class DateComponents {
    String day
    String month
    String year
}

