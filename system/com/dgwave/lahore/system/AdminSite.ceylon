import com.dgwave.lahore.api { ... }

shared class AdminSite() satisfies Site {
     
    shared actual {Resource*} resources = {
         
     };
    
    shared actual {PluginConfig*} pluginsConfig = {
        
    };
    
    shared actual ThemeConfig themeConfig = SystemThemeConfig(Assoc {
        
    });  
}