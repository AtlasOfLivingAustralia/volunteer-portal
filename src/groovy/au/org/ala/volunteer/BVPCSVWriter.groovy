package au.org.ala.volunteer

class BVPCSVWriter {

	protected columns = [:]

	final writer

    protected String cachedQuote
    protected String cachedQuoteEscape
    protected String cachedQuoteReplace
    protected String cachedValueSeperator
    protected String cachedRowSeperator

	protected producers
	protected lastProducer

	protected headingsWritten = false

    boolean alwaysQuote = false
    boolean writeHeadings = true

	public BVPCSVWriter(Writer writer, Closure definition) {
		this.writer = writer

		columns = BVPCSVWriterColumnsBuilder.build(definition)

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

    def resetProducers() {
        producers = columns.values().toList()
        lastProducer = producers.last()
    }

	def write(row) {
		if (!this.@headingsWritten) {
			writeHeadings()
		} else {
            writer << this.@cachedRowSeperator
        }

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

	protected writeHeadings() {
        if (this.@writeHeadings) {
            columns.eachWithIndex { column, i ->
                writeValue(column.key)
                if (i != (columns.size() - 1)) {
                    writer << this.@cachedValueSeperator
                }
            }
            writer << this.@cachedRowSeperator
        }
		headingsWritten = true
	}

	protected writeValue(String value) {

        if (this.@alwaysQuote || value?.contains(this.@cachedValueSeperator)) {
            writer << this.@cachedQuote
        }

        if (this.@cachedQuote) {
            value = value.replace(this.@cachedQuote, this.@cachedQuoteReplace)
        }

		writer << value
        if (this.@alwaysQuote || value?.contains(this.@cachedValueSeperator)) {
            writer << this.cachedQuote
        }
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

class BVPCSVWriterColumnsBuilder {

	final columns = [:]

    BVPCSVWriterColumnsBuilder(Closure definition) {
		definition.delegate = this
		definition()
	}

	def methodMissing(String name, args) {
		if (args.size() == 1 && args[0] instanceof Closure) {
			columns[name] = args[0]
		} else {
			throw new IllegalArgumentException('Must have 1 closure argument')
		}
	}

	static build(Closure definition) {
		new BVPCSVWriterColumnsBuilder(definition).columns
	}
}

