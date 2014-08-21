package au.org.ala.volunteer

/**
 * TaskCounts represents a collection of tasks, and the numbers of those tasks that are transcribed and/or validated.
 *
 * TaskCounts, therefore can be used to represent the task counts for a particular {@link Project}, or for a collection of projects, like those attached to {@link Institution}s
 */
class TaskCounts {

    long taskCount
    long countTranscribed
    long countValidated

    public int getPercentTranscribed() {
        return calcPercent(countTranscribed, taskCount)
    }

    public int getPercentValidated() {
        return calcPercent(countValidated, taskCount)
    }

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
