import com.dgwave.lahore.api { ... }

import ceylon.language.meta.model { Method, Function }
import ceylon.file { Path, parseURI, parsePath }
import ceylon.language.meta.declaration { ClassDeclaration }

class WebRoute (pluginId, name, methods, String routePath, produce, String? routerPermission = null)  satisfies Route {
    shared actual String pluginId;
    shared actual String name;
    shared actual Methods[] methods;
    shared actual String path = routePath;
    shared actual Method<Anything,Result,[Context]>
        |Function<Result,[Context, PluginInfo&PluginRuntime]> produce;
    shared actual String string = 
            "Web Route: from ``pluginId`` with name ``name`` : ``methods`` on ``routePath``";
}

class WebSite(String siteId, Config siteConfig, Server server) satisfies Site {	
    shared actual String site = siteId;
    shared actual String host = siteConfig.stringWithDefault("host", "localhost");
    shared actual Integer port  { 
        if (exists p = parseInteger(siteConfig.stringWithDefault("port","8080"))) { 
            return p;
        } else {
            return 8080;
        }
    }
    shared actual String context = siteConfig.stringWithDefault("context", "/" + siteId);
    Path siteStaticDir = parsePath(server.defaultContext.staticResourcePath("site", siteId));
    shared actual Path staticURI = parseURI(siteConfig.stringWithDefault("static", siteStaticDir.uriString));
    shared actual Config config = siteConfig;
    shared actual {String*} enabledPlugins = config.stringsWithDefault("enabledPlugins", ["system", "help", "menu"]);
    shared actual {HttpMethod*} acceptMethods = {httpGET, httpPOST};
    shared actual default {WebRoute*} routes = context == "/admin" 
        then plugins.routesFor(enabledPlugins, true)
                .filter((WebRoute wr) => wr.path.startsWith("/admin") || wr.path.startsWith("admin")) 
        else plugins.routesFor(enabledPlugins);
    shared actual Matcher matcher = ParamMatcher(context);
    
    String? page404 = config.stringOnly("pages.404");
    String? page403 = config.stringOnly("pages.403");
    String? pageFront = config.stringOnly("pages.front");
    
    value theme {
        ClassDeclaration? themeCls = plugins.theme("system");
        if (exists themeCls) {
            value siteTheme = themeCls.instantiate([], this);
            if (is Theme siteTheme) {
                return siteTheme;
            }
        }
        return NullTheme(this);
    }
    
    doc("Web request/response service")
    shared actual void siteService (Request req, Response resp) {

		
        // create a new context
        DefaultWebContext dc = DefaultWebContext(server.defaultContext, theme, config); 
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
                resp.writeString(context + "Internal Server Error");
                return null;
            }
        }
            
        if (exists r = rt) {	
            PluginImpl? plugin = plugins.plugin(r.pluginId);
            if (exists plugin) {						
                Result p = plugin.produceRoute(dc, r);
                if (exists p, is Assoc | Fragment p) {
                    resp.writeString(theme.assemble(theme.renderer.render({p})));
                } else {
                    resp.withStatus(500);
                    resp.writeString(context + "Internal Server Error");
                }
            } else {
                resp.withStatus(500);
                resp.writeString(context + "Internal Server Error");				
            }
        } else {
            if (req.path.equals(context) || req.path.equals(context + "/")) {
                if (exists page = pageFront) {
                    resp.writeString(page);
                } else {
                    resp.writeString(context + "Front Page");
                }
            } else {
                resp.withStatus(500);
                if (exists page = page404) {
                    resp.writeString(page);
                } else {
                    resp.writeString("Page not Found");
                }
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
    

class ParamMatcher(String context) extends Matcher(){
    
    matches(String path) => path.startsWith(context);

}
