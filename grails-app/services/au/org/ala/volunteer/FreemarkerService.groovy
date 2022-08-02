package au.org.ala.volunteer

import freemarker.cache.StringTemplateLoader
import freemarker.template.Configuration
import freemarker.template.Template
import freemarker.template.TemplateExceptionHandler

class FreemarkerService {

    Configuration cfg
    StringTemplateLoader loader

    FreemarkerService() {
        loader = new StringTemplateLoader()
        cfg = new Configuration(Configuration.VERSION_2_3_22)
        cfg.setDefaultEncoding('UTF-8')
        cfg.setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER)
        cfg.setTemplateLoader(loader)
    }

    Template getTemplate(String templateText) {
        def key = Integer.toString(templateText.hashCode())
        def t = loader.findTemplateSource(key)
        if (!t) loader.putTemplate(key, templateText)
        cfg.getTemplate(key)
    }

    String runTemplate(String templateText, Map<String, Object> args) {
        def sw = new StringWriter()
        getTemplate(templateText).process(args, sw)
        sw.toString()
    }
}
