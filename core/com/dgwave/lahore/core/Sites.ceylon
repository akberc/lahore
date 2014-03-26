import com.dgwave.lahore.api { ... }
import ceylon.collection { HashMap }
import ceylon.language.meta.model { Method, Function }

class DefaultWebContext() extends HashMap<String, Object>() satisfies Context {	
    
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

class WebRoute (pluginId, name, methods, String routePath, produce, String? routerPermission = null)  satisfies Route {
    shared actual String pluginId;
    shared actual String name;
    shared actual Methods[] methods;
    shared actual String path = routePath;
    shared actual Method<Anything,Result,[Context]>
            |Function<Result,[Context, Runtime]> produce;
    shared actual String string = 
            "Web Route: from ``pluginId`` with name ``name`` : ``methods`` on ``routePath``";
}

class SiteRuntime(site, context, theme) {
    shared Site site;
    String context;
    Theme theme;
    shared variable Plugins? plugins = null;
    {WebRoute*} routes = plugins?.routesFor(empty, true) else {};
    
    "Web request/response service"
    shared void siteService (Request req, Response resp) {
           
        // create a new context
        DefaultWebContext dc = DefaultWebContext(); 
        dc.put("path",req.path);
        dc.put("method", req.method.string);
        dc.put("headers", req.headers);
        dc.put("parameters", req.parameters);
        dc.put("request", req); //Kludge for now TODO
        
        String? method = dc.contextParam("method");
        
        WebRoute? rt {
            if (exists method) {
                return findApplicableRoute(method, req.path.spanFrom(1), dc);
            } else {
                resp.withStatus(500);
                resp.writeString(site.page500.render());
                return null;
            }
        }
        
        if (exists r = rt) {	
            PluginImpl? plugin = plugins?.plugin(r.pluginId);
            if (exists plugin) {						
                Result p = plugin.produceRoute(dc, r);
                if (exists p, is Assoc | Fragment p) {
                    resp.writeString(theme.assemble(theme.renderer.render({p})));
                } else {
                    resp.withStatus(500);
                    resp.writeString(site.page500.render());
                }
            } else {
                resp.withStatus(500);
                resp.writeString(site.page500.render());				
            }
        } else {
            if (req.path.equals(context) || req.path.equals(context + "/")) {
                resp.writeString(context + "Front Page");
            } else {
                resp.withStatus(500);
                resp.writeString(site.page404.render());
            }
        }
    }
    
    doc("Internal method to find an applicable route given a path")		
    WebRoute? findApplicableRoute(String method, String path, DefaultWebContext dc) {
        log.debug("Looking for route: " + method + " " + path);
        for (r in routes) {
            log.debug("Evaluating route : " + r.string);
            
            {String*} pathSegments = r.path.split((Character ch) => ch == '/');
            {Entry<Integer, String>*} tokens = getPathTokens(pathSegments);
            
            if (!tokens.empty) {
                value token = tokens.first;
                if (exists token) {
                    log.debug("Found path token in template: " + token.item + " at position " + token.key.string); // TODO loop
                    variable String keyPath = ""; variable String keyVal = "";
                    {String*} inSegments = path.split((Character ch) => ch == '/');
                    log.debug("Incoming path segments: " + inSegments.string);
                    variable Integer j = 0;
                    for(seg in inSegments) {
                        if (j == token.key) {
                            keyVal = seg;
                            log.debug("Found value matching token in path: " + keyVal);
                            break;
                        }
                        keyPath = keyPath + seg + "/";
                        j++;
                    }
                    log.debug("Modified path is " + keyPath);
                    if (keyVal!= "" && keyPath.endsWith("/") && r.path.startsWith(keyPath)) {
                        dc.putIntoMap("pathParam", token.item, keyVal);
                        return r;
                    }
                }
            }
            
            if (r.methods.any((Methods ms) => ms.method.string == method) && r.path.equals(path)) {
                return r;
            }
        }
        return null;
    }		

    {Entry<Integer, String>*} getPathTokens({String*} tokens) {
        {Entry<Integer, String>*} ret = {};
        variable Integer i=0;
        for (t in tokens) {
            if (t.startsWith("{") && t.endsWith("}")){
                return {i -> t}; // TODO make multiple
            }
            i++;
        }
        return ret;
    }
}

abstract class Matcher() {
    shared formal Boolean matches(String path);
}

class ParamMatcher(String context) extends Matcher(){
    
    matches(String path) => path.startsWith(context);
    
}

HashMap<String, SiteRuntime>siteRegistry = HashMap<String, SiteRuntime>();