package au.org.ala.volunteer

class SettingsService {

    def getSetting(String key, String defaultValue = null) {
        return get(key, defaultValue)
    }

    def getSetting(String key, int defaultValue) {
        return get(key, defaultValue)
    }

    def getSetting(String key, double defaultValue) {
        return get(key, defaultValue)
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

    private <T> T get(String key, T defaultValue = null) {
        def setting = Setting.findByKey(key)
        if (setting) {
            return setting as T
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
