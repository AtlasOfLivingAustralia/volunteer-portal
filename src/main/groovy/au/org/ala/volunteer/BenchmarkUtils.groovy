package au.org.ala.volunteer

import com.google.common.base.Stopwatch
import groovy.util.logging.Slf4j
import org.slf4j.Logger

@Slf4j(category = "Benchmarks")
class BenchmarkUtils {

    static <R> Closure<R> benchmarker(Logger logger) {
        return benchmarker(logger, Stopwatch.createUnstarted())
    }

    static <R> Closure<R> benchmarker(Logger logger, Stopwatch sw) {
        return benchmarkClosure.curry(logger, sw)
    }

    static <R> Closure<R> benchmarker(Stopwatch sw) {
        return benchmarkClosure.curry(log, sw)
    }

    static <R> R benchmark(String name, Closure<R> c) {
        return benchmark(log, name, c)
    }

    static <R> R benchmark(Stopwatch sw, String name, Closure<R> c) {
        benchmark(log, sw, name, c)
    }

    static <R> R benchmark(Logger logger, String name, Closure<R> c) {
        def sw = Stopwatch.createUnstarted()
        benchmark(logger, sw, name, c)
    }

    static <R> R benchmark(Logger logger, Stopwatch sw, String name, Closure<R> c) {
        benchmarkClosure(logger, sw, name, c)
    }

    static Closure benchmarkClosure = { Logger logger, Stopwatch sw, String name, Closure c ->
        sw.reset().start()
        def result = c()
        logger.debug('{}: {}', name, sw)
        return result
    }
}
