import com.dgwave.lahore.api { ... }
import ceylon.collection { HashMap }
import com.dgwave.lahore.core.component { AssocConfig, fileStorage }

class DefaultWebContext(Context fromContext, theme, config) 
        extends HashMap<String, Object>() satisfies WebContext {
    
    shared actual Theme theme;
    shared Config config;	
    
    shared actual Entity? entity {
        Object? o = get("entity");
        if (exists o) {
            if (is Entity o) {
                return o;
            }
        }
        return null;		
    }
    
    shared actual default String staticResourcePath(String type, String name) {
        return "/" + name + "." + type;
    }
    
    shared actual String? contextParam(String key) {
        Object? o = get(key);
        if (exists o) {
            if (is String o) {
                return o;
            }
        }
        return null;
    }
    
    HashMap<String, String> getAsMap(String key) {
        HashMap<String, String> newMap = HashMap<String, String>();
        Object? o = get(key);
        if (exists o) {
            if (is HashMap<String, String> o) {
                return o;
            }
        } else {
            put(key, HashMap<String, String>());
            return getAsMap(key); // recursive
        }
        return newMap;// no use
    }
    
    shared actual String pathParam(String key) {
        String? val = getAsMap("pathParam").get(key);
        if (exists val) {
            return val;
        } else {
            return "";
        }
    }
    
    shared actual String? queryParam(String key) {
        String? val = getAsMap("queryParam").get(key);
        if (exists val) {
            return val;
        } else {
            return "";
        }
    }
    
    shared void putIntoMap(String mapItem, String key, String item) {
        Object? o = get(mapItem);
        if (exists o) {
            if (is HashMap<String, String> o) {
                o.put(key,item);
            }
        } else {
            HashMap<String, String> newMap = HashMap<String, String>();
            newMap.put(key,item);
            put(mapItem, newMap);
        }
    }
    
    shared actual Context passing(String key, Assocable arg) { // TODO scope
        put(key, arg);
        return this;
    }
    
    shared actual Assocable passed(String key) {
        if (is Assocable assocable = get(key)) {
            return assocable;
        }
        return "";
    }	
}

void loadOtherSites(Server server) {
    /* FIXME get from system plugin   
    Resource configDir = server.defaultContext.configStorage.basePath.resource;
    if (is Directory configDir) {	
        for (d  in configDir.childDirectories("*.site")) {
            if (is File f = d.childResource("site.yaml")) {
                watchdog(5, "Lahore", "Loading site from `` f.name`` ");
                
            }
        }
    }
     */
}

void loadAdminSite(Server adminServer) {
    if (exists site = loadSite("admin", adminServer, true)) {
        adminServer.addSite(site);
    } else {
        log.error("Admin site could not be loaded - will end now!");
    }
}

Site? loadSite(String siteId, Server server, Boolean create) {
    log.debug("Loading site `` siteId`` ");
    value configStorage = fileStorage(server.config.childPath(siteId + ".site"));
    Config? siteConfig = configStorage.load("site.yaml");

    if (exists siteConfig) {
        return createSite(siteId, siteConfig, server);
    } else {
        if (create) {
            return createSite(siteId, AssocConfig(), server); // empty config
            // TODO write config
        } else {
            return null;
        }
    }
}

Site? createSite(String siteId, Config config, Server server) {

    return WebSite(siteId, config, server);

}