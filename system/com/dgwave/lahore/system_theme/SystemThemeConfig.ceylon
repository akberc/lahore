import com.dgwave.lahore.api { ThemeConfig, Assoc }
shared class SystemThemeConfig(Assoc assoc) extends ThemeConfig(`class SystemTheme`) {
    shared actual String[] stringsWithDefault(String key, String[] defValues) { 
        if (exists arr = assoc.getArray(key)) {
            return [for (a in arr) if (is String a) a];
        } else if (exists a = assoc.getString(key)) {
            return [a];
        }
        return [];
    }
}