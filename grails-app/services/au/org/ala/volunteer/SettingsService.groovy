package au.org.ala.volunteer

import grails.converters.JSON
import grails.gorm.transactions.Transactional

@Transactional(readOnly = true)
class SettingsService {

    def <T> T getSetting(SettingDefinition<T> setting) {
        return getSetting(setting.key, setting.defaultValue as T) as T
    }

    def getSetting(String key, String defaultValue = null) {
        return get(key, defaultValue)
    }

    List<String> getSetting(String key, List<String> defaultValue) {
        String str = get(key, defaultValue as JSON)
        return JSON.parse(str) as List<String>
    }

    @Transactional(readOnly = false)
    def setSetting(String key, List<String> items) {
        String str = items as JSON
        set(key, str)
    }

    def getSetting(String key, int defaultValue) {
        return get(key, defaultValue)?.toInteger()
    }

    def getSetting(String key, double defaultValue) {
        return get(key, defaultValue)?.toDouble()
    }

    def getSetting(String key, boolean defaultValue) {
        return get(key, defaultValue)?.toBoolean()
    }

    @Transactional(readOnly = false)
    def setSetting(String key, String value) {
        set(key, value)
    }

    @Transactional(readOnly = false)
    def setSetting(String key, int value) {
        set(key, value)
    }

    @Transactional(readOnly = false)
    def setSetting(String key, double value) {
        set(key, value)
    }

    @Transactional(readOnly = false)
    def setSetting(String key, boolean value) {
        set(key, value)
    }

    private <T> T get(String key, T defaultValue = null) {
        def setting = Setting.findByKey(key)
        if (setting) {
            if (Boolean.class.isAssignableFrom(defaultValue.class)) {
                return (T) Boolean.parseBoolean(setting.value)
            }
            return setting.value as T
        }
        return defaultValue
    }

    private <T> void set(String key, T value) {
        def setting = Setting.findByKey(key)
        if (setting) {
            if (value) {
                setting.value = value.toString()
            } else {
                setting.value = null
            }
            if (!setting.save(failOnError: true)) {
                log.error("Coudln't save setting $setting because ${setting.errors}")
            }
        } else {
            setting = new Setting(key: key, value: value)
            setting.save()
            if (setting.hasErrors()) {
                log.error("Couldn't save setting $setting because ${setting.errors}")
            }
        }
    }

}
