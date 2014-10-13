import com.dgwave.lahore.api { ... }
import com.dgwave.lahore.system_theme { SystemThemeConfig }

shared class ConsoleSite() satisfies Site {

    shared actual {Resource*} resources = {

     };

    shared actual {PluginConfig*} pluginsConfig = {

    };

    shared actual ThemeConfig themeConfig = SystemThemeConfig(Assoc {

    });

    shared actual Region pageHome = Div ({
        Ul ({
            Li(a("/admin/console", "Console")),
            Li(a("/admin/help", "Help"))
        })
    });
}