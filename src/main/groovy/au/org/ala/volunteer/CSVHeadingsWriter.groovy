package au.org.ala.volunteer

import grails.plugins.csv.CSVWriter
import grails.plugins.csv.CSVWriterColumnsBuilder

/**
 * Writes CSV content to a given writer, using a definition DSL.
 *
 * Examples:
 *
 * def sw = new StringWriter()
 * def b = new CSVBuilder(sw) {
 *   col1 { it.val1 }
 *   col2 { it.val2 }
 * }
 * b << [val1: 'a', val2: 'b']
 * b << [val1: 'c', val2: 'd']
 *
 * assert b.writer.toString() == '''"col1","col2"
 * "a",b"
 * "c","d"'''
 *
 * This class is NOT threadsafe.
 *
 * This class is a copy of org.grails.plugins.csv.CSVWriter with the writeHeadings made public.
 *
 * @author Luke Daley
 *
 *
 */
class CSVHeadingsWriter {

    private columns = [:]

    final writer

    private cachedQuote
    private cachedQuoteEscape
    private cachedQuoteReplace
    private cachedValueSeperator
    private cachedRowSeperator

    private producers
    private lastProducer

    private headingsWritten = false

    CSVHeadingsWriter(Writer writer, Closure definition) {
        this.writer = writer

        columns = CSVWriterColumnsBuilder.build(definition)

        // do these once incase subclasses are reading from config etc.
        cachedQuote = this.quote
        cachedQuoteEscape = this.quoteEscape
        cachedQuoteReplace = this.quoteEscape + this.quote
        cachedValueSeperator = this.valueSeperator
        cachedRowSeperator = this.rowSeperator

        producers = columns.values().toList()
        lastProducer = producers.last()
    }

    def leftShift(row) {
        write(row)
        this
    }

    def write(row) {
        if (!headingsWritten) {
            writeHeadings()
        }

        writer << this.@cachedRowSeperator
        for (producer in this.@producers) {
            writeValue(producer(row).toString())
            if (!producer.is(this.@lastProducer)) {
                writer << this.@cachedValueSeperator
            }
        }

        writer
    }

    def writeAll(Collection rows) {
        for (row in rows) {
            write(row)
        }
        writer
    }

    def writeHeadings() {
        columns.eachWithIndex { column, i ->
            writeValue(column.key)
            if (i != (columns.size() - 1)) {
                writer << this.@cachedValueSeperator
            }
        }
        headingsWritten = true
    }

    protected writeValue(String value) {
        writer << this.@cachedQuote
        writer << value.replace(this.@cachedQuote, this.@cachedQuoteReplace)
        writer << this.@cachedQuote
    }

    protected getQuote() {
        '"'
    }

    protected getQuoteEscape() {
        '"'
    }

    protected getValueSeperator() {
        ","
    }

    protected getRowSeperator() {
        "\n"
    }
}
