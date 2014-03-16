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
    shared formal Path home;
    shared formal Path config;
    shared formal Path data;
    shared formal Boolean booted;
    shared formal Context defaultContext;
    shared formal String[] pluginNames;
    shared formal void addPluginRuntime (Runtime pluginRuntime);
    shared formal void addSite (Site site);
    shared formal void removeSite (Site site);
}

doc("A full top-level Dispatcher that handles all methods")
shared interface Site {
    
    shared formal String host;
    shared formal Integer port;
    shared formal String context;
    
    doc("Site name")
    shared formal String site;
    
    doc("Final configuration for this site and plugin matrix")
    shared formal Config config;
    
    shared formal {String*} enabledPlugins; //direclty enabled and dependent plugins
    
    shared formal {HttpMethod*} acceptMethods;
    
    shared default {String*} contentTypes => {};
    
    shared default {String*} accepts => {};
    
    doc("We still need the routes and these may define methods")
    shared formal {Route *} routes;
    
    shared formal Path staticURI;
    
    shared formal void siteService(Request request, Response response);
    
    shared formal Matcher matcher;
}

shared abstract class Matcher() {
    shared formal Boolean matches(String path);
}

shared interface Request {
    shared formal String path;
    shared formal HttpMethod method;
    shared formal Map<String, String> parameters;
    shared formal Map<String, String> headers;
}

shared interface Response {
    shared formal [String, Charset] contentType;
    shared formal void withStatus(Integer status);
    shared formal void writeString(String write);
}