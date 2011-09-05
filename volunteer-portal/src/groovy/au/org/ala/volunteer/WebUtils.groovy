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
                    keyValue.value = keyValue.value.replace("Â","").replace("Ã","")
                }

                idx = idx + 1
            } else {
                hasMore = false
            }
        }
    }
}

