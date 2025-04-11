#!/usr/bin/env groovy
import java.text.*
@groovy.transform.SourceURI def sourceURI
def date = new Date()
def df = new SimpleDateFormat('yyyyMMddHHmmssSSSS')
def ts = df.format(date)
def name = args.length > 0 ? args[0].replace(" ", "-") : "RENAME_ME"
def file = new File(new File(sourceURI).parentFile,"src/main/resources/db/migration/V${ts}__${name}.sql")
if (file.createNewFile()) {
  file.withWriter { fw ->
    fw.write('/*\n')
    fw.write('    Author: Your name\n')
    fw.write('\n')
    fw.write('    Add as-idempotent-as-possible DDL statements here\n')
    fw.write('    See: http://www.jeremyjarrell.com/using-flyway-db-with-distributed-version-control/\n')
    fw.write('*/')
    fw.write('\n')
  }
  println "Created $file"
  return 0
} else {
  System.err.println("$file already exists!?!?")
  return 1
}
