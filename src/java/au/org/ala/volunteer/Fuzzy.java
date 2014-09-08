package au.org.ala.volunteer;

import com.google.common.base.Objects;

/**
 * Fuzzy match utils
 */
public class Fuzzy {

    /**
     * Calculate edit distance between two strings using the levenshtein algorithm.
     * @param s The first string to compare
     * @param t The second string to compare
     * @return The number of adds, updates or deletes required to change s into t
     */
    public static int levenshteinDistance(String s, String t)
    {
        // degenerate cases
        if (Objects.equal(s,t)) return 0;
        if (s.length() == 0) return t.length();
        if (t.length() == 0) return s.length();

        // create two work vectors of integer distances
        int[] v0 = new int[t.length() + 1];
        int[] v1 = new int[t.length() + 1];

        // initialize v0 (the previous row of distances)
        // this row is A[0][i]: edit distance for an empty s
        // the distance is just the number of characters to delete from t
        for (int i = 0; i < v0.length; i++)
            v0[i] = i;

        for (int i = 0; i < s.length(); i++)
        {
            // calculate v1 (current row distances) from the previous row v0

            // first element of v1 is A[i+1][0]
            //   edit distance is delete (i+1) chars from s to match empty t
            v1[0] = i + 1;

            // use formula to fill in the rest of the row
            for (int j = 0; j < t.length(); j++)
            {
                int cost = (s.charAt(i) == t.charAt(j)) ? 0 : 1;
                v1[j + 1] = min(v1[j] + 1, v0[j + 1] + 1, v0[j] + cost);
            }

            // copy v1 (current row) to v0 (previous row) for next iteration
            System.arraycopy(v1, 0, v0, 0, v0.length);
            //for (int j = 0; j < v0.length; j++)
            //    v0[j] = v1[j];
        }

        return v1[t.length()];
    }

    /**
     * Calculate ratio of the levensthein distance to the length of the longest string.  This gives a ratio from
     * 1.0 to 0.0 of how close one string is to the other. 1.0 indicates the strings are exactly the same, 0.0 indicates
     * everything needs to change to transform one string to another.
     *
     * @param s The first string to compare
     * @param t The second string to compare
     * @return A ratio of the calculated distance to max edit distance.
     */
    public static double ldRatio(String s, String t) {
        int ld = levenshteinDistance(s,t);
        int max = Math.max(s.length(), t.length());
        return (double)(max - ld) / (double)max;
    }

    public static int min(int... args) {
        int min = Integer.MAX_VALUE;
        for (int arg : args) {
            if (arg < min) {
                min = arg;
            }
        }
        return min;
    }

}
