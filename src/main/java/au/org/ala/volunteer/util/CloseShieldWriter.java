package au.org.ala.volunteer.util;

import java.io.FilterWriter;
import java.io.IOException;
import java.io.Writer;

/**
 * A FilterWriter that prevents the underlying writer being closed.
 */
public class CloseShieldWriter extends FilterWriter {

    /**
     * Create a new filtered writer.
     *
     * @param out a Writer object to provide the underlying stream.
     * @throws NullPointerException if <code>out</code> is <code>null</code>
     */
    public CloseShieldWriter(Writer out) {
        super(out);
    }

    @Override
    public void close() throws IOException {
        // deliberately empty to prevent wrapped writer from closing the underlying stream
    }
}
