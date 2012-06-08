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

class WebUtils {

    /**
     * Remove strange chars from form fields (appear with ° symbols, etc)
     */
    static void cleanRecordValues(Map recordValues) {
        def idx = 0
        def hasMore = true
        while (hasMore) {
            def fieldValuesForRecord = recordValues.get(idx.toString())
            if (fieldValuesForRecord) {
                fieldValuesForRecord.each { keyValue ->
                    // remove strange chars from form fields TODO: find out why they are appearing
                    // keyValue.value = keyValue.value.replace("Â","").replace("Ã","")

                    // David Baird 7th June 2012
                    // Got to the bottom of this...Apparently in the Servlet Spec, containers always assume form parameters are sent as ISO 8859-1 (the default encoding of HTTP)
                    // The string created by the container apparatus contains the right sequence of bytes, but has the wrong encoding.
                    // With ASCII form data the problem is undetectable because 8 bit characters are the same in both encodings,
                    // but when you have a utf-8 surrogate pair character (anything > 1 byte) the incorrect encoding becomes a problem
                    // The solution is to extract the original sequence of bytes and 'recast' them as utf-8

                    // see http://friend-of-misery.blogspot.com.au/2007/03/java-and-utf-8-encoding.html
                    // Also see http://blog.saddey.net/2010/02/06/grails-utf-8-form-input-garbled-when-running-within-tomcat/ which indicates
                    // there maybe something we can do configuration wise to get rid of this hack

                    keyValue.value = new String(keyValue.value.getBytes("8859_1"), "utf-8")
                }

                idx = idx + 1
            } else {
                hasMore = false
            }
        }
    }
}

