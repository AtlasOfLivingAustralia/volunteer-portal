package au.org.ala.volunteer

import org.apache.commons.pool2.BaseKeyedPooledObjectFactory
import org.apache.commons.pool2.PooledObject
import org.apache.commons.pool2.impl.DefaultPooledObject

class GroovyScriptPooledObjectFactory extends BaseKeyedPooledObjectFactory<String, Script> {

    def shell

    GroovyScriptPooledObjectFactory() {
        shell = new GroovyShell()
    }

    @Override
    Script create(String code) throws Exception {
        shell.parse(code)
    }

    @Override
    PooledObject<Script> wrap(Script script) {
        new DefaultPooledObject<Script>(script)
    }
}
