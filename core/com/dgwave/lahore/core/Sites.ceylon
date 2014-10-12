import com.dgwave.lahore.api { ... }
import ceylon.collection { HashMap }
import ceylon.file { FileRes = Resource, parseURI, File }
import ceylon.language.meta.model { Method, Function }
import ceylon.io.charset { utf8 }
import ceylon.language.meta { modules }
import ceylon.io.buffer { ByteBuffer, newByteBuffer }
import ceylon.io { newOpenFile }
import com.dgwave.lahore.core.component { attachmentCache,
    cacheResource }
import java.lang {
    ByteArray
}

class DefaultWebContext() extends HashMap<String, Object>() satisfies Context {

    shared actual Document? data {
        Object? o = get("entity");
        if (exists o) {
            if (is Document o) {
                return o;
            }
        }
        return null;
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
    shared actual Method<Anything,Content?,[Context]>
            |Function<Content?,[Context, PluginRuntime]> produce;
    shared actual String string =
            "Web Route: from ``pluginId`` with name ``name`` : ``methods`` on ``routePath``";
}

class SiteRuntime(site, context, theme) {
    shared Site site;
    String context;
    Theme theme;
    shared late Plugins plugins;

    {WebRoute*} routes {
        return plugins.routesFor(empty, true);
    }

    "Web request/response service"
    shared void siteService (Request req, Response resp) {

        Boolean isAttachment(Request req) =>
                req.path.endsWith("css") ||
                req.path.endsWith("js") ||
                req.path.endsWith("ico");

        if (isAttachment(req)) {
            value got = attachmentCache.get(req.path);
            if (exists got) {
                log.debug("Cache hit for ``req.path``");
                resp.withContentType([got[0].string, utf8]);
                resp.addHeader("Cache-Control", "max-age=3600");
                value item = got[1];
                switch(item)
                case (is String) {
                    resp.writeString(item);
                }
                case (is ByteBuffer) {
                    resp.writeByteBuffer(item);
                }
                return;
            }
        }

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

        if (exists r = rt,
            exists plugin = plugins.plugin(r.pluginId),
            exists content = plugin.produceRoute(dc, r)) {

            switch(content)
            case (is Paged) {
                value keyMap = HashMap<String, String>();
                for (tb in content.top.chain(content.bottom)) {
                    if (is Attached tb) {

                        String key = "``context``/" + plugin.plugin.id + "/"
                            + String(tb.pathInModule.skipWhile((Character c) =>"/\\".contains(c)));

                        String path = String(tb.pathInModule.skipWhile((Character c) =>"/\\".contains(c)));

                        Resource? resource = modules.find(plugin.plugin.info.moduleName, plugin.plugin.info.moduleVersion)
                            ?.resourceByPath(path);

                        cacheResource(key, tb, resource);
                        keyMap.put(tb.name, key);
                    }
                }
                resp.withContentType(["text/html", utf8]);
                resp.writeString(theme.assemble(keyMap, content));

            } else {
                resp.withContentType([applicationJson.string, utf8]);
                resp.writeString(content.string);
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

    "Internal method to find an applicable route given a path"
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