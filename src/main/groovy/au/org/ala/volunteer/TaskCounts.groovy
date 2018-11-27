package au.org.ala.volunteer

/**
 * TaskCounts represents a collection of tasks, and the numbers of those tasks that are transcribed and/or validated.
 *
 * TaskCounts, therefore can be used to represent the task counts for a particular {@link Project}, or for a collection of projects, like those attached to {@link Institution}s
 */
class TaskCounts {

    long taskCount
    long requiredTranscriptionCount
    long transcribedCount
    long validatedCount

    /**
     * Calculated property. Depends on taskCount and transcribedCount being set
     * @return The percent transcribed
     */
    public int getPercentTranscribed() {
        return calcPercent(transcribedCount, requiredTranscriptionCount)
    }

    /**
     * Calculated property. Depends on taskCount and validatedCount being set
     * @return the percent validated
     */
    public int getPercentValidated() {
        return calcPercent(validatedCount, taskCount)
    }

    /**
     * Calculates a percentage, but ensures that 100% is not erroneously returned due to rounding
     * @param count
     * @param total
     * @return The percentage
     */
    private static double calcPercent(double count, double total) {
        if (total == 0) {
            return 0
        }

        def percent = ((count / total) * 100)
        if (percent > 99 && count != total) {
            // Avoid reporting 100% unless the count actually equals the task total
            percent = 99;
        }
        return percent
    }

}
