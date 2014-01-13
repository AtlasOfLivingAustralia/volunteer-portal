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
     * Special case handling for checkboxes
     *
     * Checkboxes in grails are handled differently to all other input types. Two input fields are created, one with the
     * name of the field you give it, and another hidden field with an underscore prefix. When you submit an unchecked checkbox
     * only the hidden field will be submited (unchecked checkboxes don't get submitted). When you submit a checked checkbox both the
     * normally named field and the underscore version will be submited (both will have empty values.
     *
     * To capture the checked state of a checkbox, then, means checking if a pair exists or not
     */
    static void cleanRecordValues(Map recordValues) {
        def idx = 0
        def hasMore = true

        while (hasMore) {
            Map fieldValuesForRecord = recordValues.get(idx.toString())
            def purgeList = []
            if (fieldValuesForRecord) {
                // cache the changes to avoid concurrent modification exceptions
                def changeMap = [:]
                fieldValuesForRecord.each { keyValue ->
                    String key = keyValue.key
                    if (key.startsWith("_")) {
                        // Remember this key so we can remove it later (we only want to store the non-underscored fields)
                        purgeList << key
                        // look for the matching presence of a non-underscore method
                        def checkBoxKey = key.substring(1, key.length());
                        if (fieldValuesForRecord.containsKey(checkBoxKey)) {
                            changeMap[checkBoxKey] = "true"
                        } else {
                            changeMap[checkBoxKey] = "false"
                        }
                    }
                }
                if (changeMap) {
                    changeMap.each { kvp ->
                        recordValues[idx.toString()][kvp.key] = kvp.value
                    }
                }

                // Go through the purge list and strip out any intermediate '_' prefixed fields (used by checkboxes)
                if (purgeList) {
                    purgeList.each {
                        fieldValuesForRecord.remove(it)
                    }
                }

                idx++
            } else {
                hasMore = false
            }
        }

   }

    /**
     * Replaces consecutive runs on spaces with a single space within a string
     *
     * @param argStr
     * @return
     */
    public static String collapseSpaces(String argStr) {
        if (argStr == null || argStr.length() == 0) {
            return argStr;
        }

        char last = argStr.charAt(0);
        StringBuilder argBuf = new StringBuilder();

        for (int cIdx = 0 ; cIdx < argStr.length(); cIdx++) {
            char ch = argStr.charAt(cIdx);
            if (ch != ' ' || last != ' ') {
                argBuf.append(ch);
                last = ch;
            }
        }

        return argBuf.toString();
    }

    /**
     * Returns the first floating point number is a string that starts with a numeric, but may possibly contain other non numeric characters
     * @param str
     * @return
     */
    public static String firstNumber(String str) {
        if (str == null || str.length() == 0) {
            return str
        }

        boolean seenDot = false;
        def sb = new StringBuilder()
        for (char ch : str) {
            if (Character.isDigit(ch) || (!seenDot && ch == '.')) {
                sb.append(ch)
                if (ch == '.') {
                    seenDot = true
                }
            } else {
                break;
            }

        }
        return sb.toString()
    }

    /**
     * Turns camel case into space separated words. e.g. 'titleCase' => 'Title Case'
     * i.e. Spaces are inserted before each change from lower case to upper case
     *
     * @param str
     * @return
     */
    public static String makeTitleFromCamelCase(String str) {
        if (!str) {
            return str
        }

        StringBuilder b = new StringBuilder(str.charAt(0).toUpperCase().toString())
        for (int i = 1; i < str.length(); ++i) {
            char ch = str.charAt(i);
            if (Character.isUpperCase(ch)) {
                // insert a word breaking space
                b << ' '
            }
            b << ch
        }

        return b.toString()
    }

}
