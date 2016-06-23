package au.org.ala.volunteer.sanitizer

import groovy.transform.CompileStatic
import groovy.transform.TypeChecked
import groovy.transform.stc.ClosureParams
import groovy.transform.stc.ThirdParam
import groovy.util.logging.Commons
import org.grails.datastore.mapping.core.Datastore
import org.grails.datastore.mapping.engine.event.AbstractPersistenceEvent
import org.grails.datastore.mapping.engine.event.AbstractPersistenceEventListener
import org.grails.datastore.mapping.engine.event.PreInsertEvent
import org.grails.datastore.mapping.engine.event.PreUpdateEvent
import org.springframework.context.ApplicationEvent

import java.lang.annotation.Annotation
import java.lang.reflect.Field

/**
 * A GORM event listener that will convert domain object fields annotated with a given annotation using
 * a provided closure.
 *
 * At this stage only non generic types are supported (eg String) trying to use it on anything fancier
 * will result in undefined behaviour.
 *
 * @param <T> The type of the field to be converted
 */
@CompileStatic
@TypeChecked
@Commons
class ValueConverterListener<T> extends AbstractPersistenceEventListener {

    final Class<? extends Annotation> annotationType
    final Class<T> converterType
    final Closure<T> converter

    /**
     * Creates a new ValueConverterListener that will convert fields annotated with the annotationType using the
     * converter.
     * @param datastore The GORM datastore to apply this to
     * @param annotationType The annotation used to mark fields for conversion
     * @param converterType Simple reification of the converter functions return type
     * @param converter The function that does the conversion
     */
    ValueConverterListener(Datastore datastore, Class<? extends Annotation> annotationType, Class<T> converterType, @ClosureParams(ThirdParam.FirstGenericType) Closure<T> converter) {
        super(datastore)
        this.annotationType = annotationType
        this.converter = converter.memoizeAtMost(100)
        this.converterType = converterType
        log.info("Value Converter instantiated for $annotationType annotated fields of type $converterType")
    }

    /**
     * Factory method to avoid redundant new ValueConverterListener<T>.
     * @see ValueConverterListener<T>#constructor(Datastore, Class<? extends Annotation>, Class<T>, Closure<T>)
     * @return a new ValueConverterListener
     */
    static <U> ValueConverterListener<U> of(Datastore datastore, Class<? extends Annotation> annotationType, Class<U> converterType, @ClosureParams(ThirdParam.FirstGenericType) Closure<U> converter) {
        return new ValueConverterListener<U>(datastore, annotationType, converterType, converter)
    }

    @Override
    protected void onPersistenceEvent(AbstractPersistenceEvent event) {
        switch (event) {
            case PreInsertEvent:
            case PreUpdateEvent:
                convertFields(event)
                break;
            default:
                log.debug("Got unsupported event: $event")
        }
    }

    void convertFields(AbstractPersistenceEvent event) {
        def entityAccess = event.entityAccess
        def obj = event.entityObject

        def fields = obj.class.declaredFields.findAll { it.getAnnotation(annotationType) }

        for (def field : fields) {
            ConvertResult result = convertField(obj, field)
            if (result.converted) {
                entityAccess?.setProperty(field.name, result.newVal)
                obj[field.name] = result.newVal
            }
        }
    }

    /**
     * Pseudo Either type
     */
    private static class ConvertResult {
        boolean converted = true;
        Object newVal = null;
        static ConvertResult success(Object obj) { new ConvertResult(newVal: obj) }
        static ConvertResult failed = new ConvertResult(converted: false)
    }

    private ConvertResult convertField(Object obj, Field field) {
        Class<?> type = field.getType()
        if (converterType == type) {
            T value = (T) obj[field.name]
            if (value != null) {
                T newValue = converter(value)
                if (value != newValue) {
                    log.info("Converted $value to $newValue for ${field.name} on $obj")
                }
                return ConvertResult.success(newValue)
            } else {
                // Don't convert null values.
                return ConvertResult.failed
            }
        } else {
            log.debug("${obj.class}.${field.name} is a $type, not a ${converterType}")
            return ConvertResult.failed
        }
    }

    @Override
    boolean supportsEventType(Class<? extends ApplicationEvent> eventType) {
        return eventType in [PreInsertEvent, PreUpdateEvent]
    }
}
