import com.dgwave.lahore.api { ... }
import com.dgwave.lahore.system_theme { SystemThemeConfig }

shared class ConsoleSite() satisfies Site {
     
    shared actual {Resource*} resources = {
         
     };
    
    shared actual {PluginConfig*} pluginsConfig = {
        
    };
    
    shared actual ThemeConfig themeConfig = SystemThemeConfig(Assoc {
        
    });  
}