package au.org.ala.volunteer

import groovy.util.logging.Slf4j

/**
 * A simple collation class that allows for the collection of timings and calculation of average times.
 */
@Slf4j
class LapTime {
    private volatile List<Long> laptimes
    private String name
    private int timeFactor
    private int interval = 1000
    private volatile Long maxTime = 0L

    public static final int TIMEFACTOR_MILLISECONDS = 0
    public static final int TIMEFACTOR_SECONDS = 1

    LapTime(String initName) {
        //log.debug("LapTime | Initialising LapTime labelled '${initName}', with interval of [${interval}]")
        name = initName
        laptimes = new ArrayList<Long>()
        timeFactor = TIMEFACTOR_MILLISECONDS
    }

    LapTime(String initName, int initTimeFactor) {
        //log.debug("LapTime | Initialising LapTime labelled '${initName}', with interval of [${interval}]")
        name = initName
        laptimes = new ArrayList<Long>()
        if (initTimeFactor == TIMEFACTOR_MILLISECONDS || initTimeFactor == TIMEFACTOR_SECONDS) {
            timeFactor = initTimeFactor
        } else {
            timeFactor = TIMEFACTOR_MILLISECONDS
        }
    }

    def synchronized setInterval(int newInterval) {
        if (newInterval < 10) return
        interval = newInterval
        log.debug("LapTime | Updating interval to new value: [${interval}]")
    }

    def synchronized addTime(long time) {
        //log.debug("LapTime | ['${name}'] Adding time of ${time}")
        laptimes.add(Long.valueOf(time))
        if (Long.valueOf(time) > maxTime) maxTime = Long.valueOf(time)
//        if (laptimes.size() % interval == 0) log.debug(getTimes())
    }

    def synchronized resetTimes() {
        laptimes = new ArrayList<Long>()
    }

    def synchronized getTimes() {
        def avg
        def sum = 0L
//        def sum = laptimes.sum() as Long
        // threadsafe
        for (int i = 0; i < laptimes.size(); i++) {
            sum += laptimes[i]
        }
        avg = laptimes.size() > 0 ? ( sum.floatValue() / laptimes.size().floatValue()) : 0
        return "Laptimes['${name}']: [${laptimes.size()}] laps, [${sum}] total time, [${avg}] per lap, maxTime of [${maxTime}]"
    }
}
