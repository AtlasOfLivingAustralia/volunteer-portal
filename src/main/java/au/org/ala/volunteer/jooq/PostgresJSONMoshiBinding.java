package au.org.ala.volunteer.jooq;

import com.squareup.moshi.JsonAdapter;
import com.squareup.moshi.JsonReader;
import com.squareup.moshi.JsonWriter;
import com.squareup.moshi.Moshi;
import groovy.lang.GString;
import org.jooq.Binding;
import org.jooq.BindingGetResultSetContext;
import org.jooq.BindingGetSQLInputContext;
import org.jooq.BindingGetStatementContext;
import org.jooq.BindingRegisterContext;
import org.jooq.BindingSQLContext;
import org.jooq.BindingSetSQLOutputContext;
import org.jooq.BindingSetStatementContext;
import org.jooq.Converter;
import org.jooq.conf.ParamType;
import org.jooq.impl.DSL;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.annotation.Nullable;
import java.io.IOException;
import java.sql.SQLException;
import java.sql.SQLFeatureNotSupportedException;
import java.sql.Types;
import java.util.Objects;

public class PostgresJSONMoshiBinding implements Binding<Object, Object> {

    static final Logger log = LoggerFactory.getLogger(PostgresJSONMoshiBinding.class);
    static final Moshi moshi = new Moshi.Builder().add(GString.class, new JsonAdapter<Object>() {
        @Nullable
        @Override
        public Object fromJson(JsonReader reader) throws IOException {
            return reader.nextString();
//            return null;
        }

        @Override
        public void toJson(JsonWriter writer, @Nullable Object value) throws IOException {
            if (value == null) writer.nullValue();
            else writer.value(value.toString());
        }
    }).build();

    // The converter does all the work
    @Override
    public Converter<Object, Object> converter() {

        return new Converter<Object, Object>() {
            @Override
            public Object from(Object t) {
                JsonAdapter<Object> adapter = moshi.adapter(Object.class);
                try {
                    return t == null ? null : adapter.fromJson("" + t.toString());
                } catch (IOException e) {
                    log.error("Unable to adapt JSON from {}", t, e);
                    throw new org.jooq.exception.IOException("Unable to adapt JSON from " + t, e);
                }
            }

            @Override
            public Object to(Object u) {
                JsonAdapter<Object> adapter = moshi.adapter(Object.class);
                return u == null ? null : adapter.toJson(u);
            }

            @Override
            public Class<Object> fromType() {
                return Object.class;
            }

            @Override
            public Class<Object> toType() {
                return Object.class;
            }
        };
    }

    // Rending a bind variable for the binding context's value and casting it to the json type
    @Override
    public void sql(BindingSQLContext<Object> ctx) throws SQLException {
        // Depending on how you generate your SQL, you may need to explicitly distinguish
        // between jOOQ generating bind variables or inlined literals.
        if (ctx.render().paramType() == ParamType.INLINED)
            ctx.render().visit(DSL.inline(ctx.convert(converter()).value())).sql("::json");
        else
            ctx.render().sql("?::json");
    }

    // Registering VARCHAR types for JDBC CallableStatement OUT parameters
    @Override
    public void register(BindingRegisterContext<Object> ctx) throws SQLException {
        ctx.statement().registerOutParameter(ctx.index(), Types.VARCHAR);
    }

    // Converting the JsonElement to a String value and setting that on a JDBC PreparedStatement
    @Override
    public void set(BindingSetStatementContext<Object> ctx) throws SQLException {
        ctx.statement().setString(ctx.index(), Objects.toString(ctx.convert(converter()).value(), null));
    }

    // Getting a String value from a JDBC ResultSet and converting that to a JsonElement
    @Override
    public void get(BindingGetResultSetContext<Object> ctx) throws SQLException {
        ctx.convert(converter()).value(ctx.resultSet().getString(ctx.index()));
    }

    // Getting a String value from a JDBC CallableStatement and converting that to a JsonElement
    @Override
    public void get(BindingGetStatementContext<Object> ctx) throws SQLException {
        ctx.convert(converter()).value(ctx.statement().getString(ctx.index()));
    }

    // Setting a value on a JDBC SQLOutput (useful for Oracle OBJECT types)
    @Override
    public void set(BindingSetSQLOutputContext<Object> ctx) throws SQLException {
        throw new SQLFeatureNotSupportedException();
    }

    // Getting a value from a JDBC SQLInput (useful for Oracle OBJECT types)
    @Override
    public void get(BindingGetSQLInputContext<Object> ctx) throws SQLException {
        throw new SQLFeatureNotSupportedException();
    }
}