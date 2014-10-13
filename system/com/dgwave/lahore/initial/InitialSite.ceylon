import com.dgwave.lahore.api { ... }
import com.dgwave.lahore.system_theme { SystemThemeConfig }

shared class InitialSite() satisfies Site {

    shared actual {Resource*} resources = {

    };

    shared actual {PluginConfig*} pluginsConfig = {

    };

    shared actual ThemeConfig themeConfig = SystemThemeConfig(Assoc {

    });
}