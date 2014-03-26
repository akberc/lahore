import ceylon.file { Path }
import ceylon.io.charset { Charset }

shared interface Storable {
    shared formal void load(Assoc assoc);
    shared formal Assoc save();
}

shared interface Config satisfies Storable {
    shared formal String? stringOnly(String key);
    shared formal String stringWithDefault (String key, String defValue);
    shared formal String[] stringsWithDefault (String key, String[] defValues = []);
}

shared abstract class AbstractConfig() satisfies Config {
    shared actual default void load(Assoc assoc) {} 
    
    shared actual default Assoc save() {
        return assoc();
    }
    
    shared actual default String stringWithDefault(String key, String defValue) {
        if (exists s = stringsWithDefault(key, [defValue]).first) {
            return s;
        } else {
            return defValue;
        }
    }
    
    shared actual default String? stringOnly(String key) {
        if (exists s = stringsWithDefault(key, []).first) {
            return s;
        } else {
            return null;
        }
    }					
}


"A server container that presents system services to Core"
shared interface Server {
    shared formal String name;
    shared formal String version;
    
    shared formal String host;
    shared formal Integer port;
    
    shared formal Path home;
    shared formal Path temp;
    shared formal Path data;
    
    shared formal void loadModule(String modName, String modVersion);
       
    shared formal Boolean booted;
}

"A site that has a context, configures plugins and a theme,
 and provides resources.
 Implementations should NOT have any parameters"
shared interface Site {
    
    "Theme"
    shared formal ThemeConfig themeConfig;
    
    "Final configuration for this site and plugin matrix"
    shared formal {PluginConfig*} pluginsConfig;
    
    "Exported Resources"
    shared formal {Resource *} resources;
    
    "Not a route to avoid circular references"
    shared default Region page404 => Div({Span("Page not Found")});
    shared default Region page403 => Div({Span("Not Authorized")});
    shared default Region page500 => Div({Span("Internal Error")});
}

shared interface Request {
    shared formal String path;
    shared formal HttpMethod method;
    shared formal Map<String, String> parameters;
    shared formal Map<String, String> headers;
    shared formal Session session;
}

shared interface Response {
    shared formal void withContentType([String, Charset] contentType);
    shared formal void withStatus(Integer status);
    shared formal void writeString(String write);
}

shared interface Session {
    
}