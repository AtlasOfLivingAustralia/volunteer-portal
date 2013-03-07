package au.org.ala.volunteer

class SettingsService {

    def <T> T getSetting(SettingDefinition<T> setting) {
        return getSetting(setting.key, setting.defaultValue as T) as T
    }

    def getSetting(String key, String defaultValue = null) {
        return get(key, defaultValue)
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

    def setSetting(String key, String value) {
        set(key, value)
    }

    def setSetting(String key, int value) {
        set(key, value)
    }

    def setSetting(String key, double value) {
        set(key, value)
    }

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
        } else {
            setting = new Setting(key: key, value: value)
            setting.save()
        }
    }

}
