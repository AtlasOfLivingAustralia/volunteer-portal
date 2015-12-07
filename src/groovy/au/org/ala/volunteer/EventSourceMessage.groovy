package au.org.ala.volunteer

import com.google.gson.Gson
import com.google.gson.GsonBuilder
import groovy.transform.ToString

@ToString
class EventSourceMessage implements Writable {

    private static final Gson gson = new GsonBuilder().create()

    String id = null
    String event = null
    String comment = null
    Object data = null


    @Override
    Writer writeTo(Writer out) throws IOException {
        if ((!id && !event && !comment && !data)) {
            return out
        }

        if (comment) out.write(": $comment\n")
        if (id) out.write("id: $id\n")
        if (event) out.write("event: $event\n")
        if (data != null) {
            switch (data) {
                case String:
                    def strData = ((String)data).replace('\n', '\ndata: ')
                    out.write("data: $strData\n")
                    break;
                default:
                    out.write('data: ')
                    gson.toJson(data, out)
                    out.write('\n')
            }
        }
        out.write('\n')
        return out
    }
}
