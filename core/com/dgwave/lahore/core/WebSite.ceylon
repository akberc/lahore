import com.dgwave.lahore.api { ... }
import com.dgwave.lahore.core.component {Page}
import ceylon.language.meta.model { Method, Function }
import ceylon.file { Path, parseURI }
import ceylon.net.http { HttpMethod=Method, get, post, contentType }
import ceylon.net.http.server { Matcher, Request, Response }
import ceylon.io.charset { utf8 }

class WebRoute (pluginId, name, methods, String routePath, produce, 
String? routerPermission = null)  satisfies Route {
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
    Path siteStaticDir = server.defaultContext.staticResourcePath("site", siteId);
    shared actual Path staticURI = parseURI(siteConfig.stringWithDefault("static", 
    siteStaticDir.uriString));
    shared actual Config config = siteConfig;
    shared actual {String*} enabledPlugins = config.stringsWithDefault("enabledPlugins", {});
    shared actual {HttpMethod*} acceptMethods = {get, post};
    shared actual default {WebRoute*} routes = 
            context == "/admin" then 
    plugins.routesFor(enabledPlugins, true)
            .filter((WebRoute wr) => wr.path.startsWith("/admin") || wr.path.startsWith("admin")) 
    else plugins.routesFor(enabledPlugins);
    shared actual Matcher matcher = ParamMatcher(context);
    
    String? page404 = config.stringOnly("pages.404");
    String? page403 = config.stringOnly("pages.403");
    String? pageFront = config.stringOnly("pages.front");
    
    
    doc("Web request/response service")
    shared actual Anything(Request, Response) endService =>externalService;
    void externalService (Request req, Response resp) {
        // create a new context
        DefaultWebContext dc = DefaultWebContext(server.defaultContext, systemTheme, config); 
        dc.put("path",req.path);
        dc.put("method", req.method.string);
        dc.put("headers", req.headers);
        dc.put("parameters", req.parameters);
        dc.put("request", req); //Kludge for now TODO
        
        resp.addHeader(contentType { 
            contentType = "text/html"; 
            charset = utf8; });	
            
            String? method = dc.contextParam("method");
            WebRoute? r;
            if (exists method) {
                r = findApplicableRoute(method, req.path.spanFrom(1), dc);
            } else {
                resp.responseStatus = 500;
                resp.writeString(context + "Internal Server Error");
                return;
            }
            
            if (exists r) {	
                PluginImpl? plugin = plugins.plugin(r.pluginId);
                if (exists plugin) {						
                    Page? p = plugin.produceRoute(dc, r);
                    if (exists p) {
                        resp.writeString(p.render());
                    } else {
                        resp.responseStatus = 500;
                        resp.writeString(context + "Internal Server Error");
                    }
                } else {
                    resp.responseStatus = 500;
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
                    resp.responseStatus = 404;
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
            watchdog(6, "WebSite", "Looking for route: " + method + " " + path);
            for (r in routes) {
                watchdog(7, "WebSite", "Evaluating route : " + r.string);
                
                {String*} pathSegments = r.path.split((Character ch) => ch == '/');
                {Entry<Integer, String>*} tokens = getPathTokens(pathSegments);
                
                if (!tokens.empty) {
                    value token = tokens.first;
                    if (exists token) {
                        watchdog(8, "WebSite", "Found path token in template: " + token.item + " at position " + token.key.string); // TODO loop
                        variable String keyPath = ""; variable String keyVal = "";
                        {String*} inSegments = path.split((Character ch) => ch == '/');
                        watchdog(8, "WebSite", "Incoming path segments: " + inSegments.string);
                        variable Integer j = 0;
                        for(seg in inSegments) {
                            if (j == token.key) {
                                keyVal = seg;
                                watchdog(8, "WebSite", "Found value matching token in path: " + keyVal);
                                break;
                            }
                            keyPath = keyPath + seg + "/";
                            j++;
                        }
                        watchdog(8, "WebSite", "Modified path is " + keyPath);
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
    
object systemTheme satisfies Theme {
    shared actual String id = "system";
    shared actual {Region*} regions = {};
    shared actual {Script*} scripts = {};
    shared actual {Style*} styles = {};
    shared actual {Template<Markup>*} templates = {};
}

class ParamMatcher(String context) extends Matcher(){
    
    matches(String path) => path.startsWith(context);
    relativePath(String requestPath) => requestPath[context.size...];
}
