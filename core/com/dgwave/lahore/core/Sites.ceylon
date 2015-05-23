import com.dgwave.lahore.api { ... }
import ceylon.collection { HashMap }
import ceylon.language.meta.model { Method, Function }
import ceylon.language.meta { modules }
import com.dgwave.lahore.core.component { cacheResource }
import ceylon.language.meta.declaration {

	FunctionDeclaration
}

class WebContext(request) extends HashMap<String, Assocable>() satisfies Context {

    shared actual Request request;

    shared actual Context passing(String key, Assocable arg) { // TODO scope
        put(key, arg);
        return this;
    }

    shared actual Assocable? passed(String key) {
        return get(key);
    }
}

class WebRoute (pluginId, name, methods, String routePath, produce, String? routerPermission = null)  satisfies Route {
    shared actual String pluginId;
    shared actual String name;
    shared actual Methods[] methods;
    shared actual String path = routePath;
    shared [Entry<Integer,String>*] pathParams = {
            for (i->token in String(routePath.skip(1)).split('/'.equals).indexed)
                if (token.startsWith("{") && token.endsWith("}"))
                    i->token
    }.sequence();
    shared actual Method<Anything,Content?,[Context]>
            |Function<Content?,[Context, PluginRuntime]> produce;
    shared actual String string =
            "Web Route: from ``pluginId`` with name ``name`` : ``methods`` on ``routePath``";
}

class SiteRuntime(site, context, theme) satisfies Dispatcher {
    Site site;
    String context;
    Theme theme;
    shared late Plugins plugins;

    {WebRoute*} routes {
        return plugins.routesFor(empty, true);
    }

    "Web request/response service"
    shared void siteService (Request req, Response resp) {

        // create a new context
        Context dc = WebContext(req);

        WebRoute? rt  = findApplicableRoute(req.method.string, req.path.spanFrom(1), dc);
        value keyMap = HashMap<String, String>();

        if (exists r = rt,
            exists plugin = plugins.plugin(r.pluginId),
            exists content = plugin.produceRoute(dc, r)) {

            switch(content)
            case (is Paged) {
                for (tb in content.top.chain(content.bottom)) {
                    if (is Attached tb) {
                        String relative = String(tb.pathInModule.skipWhile((Character c) =>"/\\".contains(c)));
                        String key = "``context``/" + plugin.plugin.id + "/" + relative;

                        Resource? resource = modules.find(
                            plugin.plugin.info.moduleName, plugin.plugin.info.moduleVersion)
                                ?.resourceByPath(relative);

                        cacheResource(key, tb, resource);
                        keyMap.put(tb.name, key);
                    }
                }
                resp.withContentType(textHtml);
                resp.writeString(theme.assemble(keyMap, content));
            }
            case (is Status) {
                resp.withStatus(content.code);
                resp.writeString(content.message);
            } else {
                resp.withContentType(applicationJson);
                resp.writeString(content.string);
            }
        } else {
            if (req.path.equals(context) || req.path.equals(context + "/")) {
                resp.withContentType(textHtml);
                resp.writeString(theme.assemble(keyMap, Paged(site.pageHome, {})));
            } else {
                resp.withStatus(404);
                resp.writeString(site.page404.render());
            }
        }
    }

    "Internal method to find an applicable route given a path"
    WebRoute? findApplicableRoute(String method, String path, Context dc) {
        log.debug("Looking for route: " + method + " " + path);
        for (r in routes) {
            log.debug("Evaluating route : " + r.string);
            [String*] inSegments = path.split('/'.equals).sequence();
            log.debug("Incoming path segments: " + inSegments.string);

            String oneOf(Integer index, String original) {
                for (pp in r.pathParams) {
                    if (pp.key == index) {
                        dc.passing(pp.item, original);
                        return pp.item;
                    }
                } else {
                    return original;
                }
            }

            String modifiedPath = "/".join {
                for (i->inSeg in inSegments.indexed)
                     oneOf(i, inSeg)
            };
            log.debug("Modified path is " + modifiedPath);

            if (r.methods.any((Methods ms) => ms.method.string == method) && r.path.equals(modifiedPath)) {
                return r;
            }
        } else {
            return null;
        }
    }
    
    shared actual Content produceRoute(
        FunctionDeclaration functionDeclaration, {<String->String>*} pass) {
        return Paged(Div {}, {}, {} );
    }
    
}

HashMap<String, SiteRuntime>siteRegistry = HashMap<String, SiteRuntime>();