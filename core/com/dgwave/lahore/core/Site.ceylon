import com.dgwave.lahore.api { Context, Result, WebContext, Storage, Theme, Entity, Hook, Plugin, Config }
import ceylon.net.http.server { Request, Response, Matcher }
import ceylon.net.http { HttpMethod = Method }
import ceylon.file { Path, parsePath }
import ceylon.collection { HashMap }
import ceylon.language.model { Method }

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
	shared formal {WebRoute*} webRoutes;

	shared formal Path staticURI;

	shared formal Anything(Request, Response) endService;

	shared formal Matcher matcher;
}


class ParamMatcher(String context) extends Matcher(){

    matches(String path) => path.startsWith(context);
    relativePath(String requestPath) => requestPath[context.size...];
}

class PluginStaticPath({String*} ps) extends Matcher() {
    matches(String path) => ps.any((String e) => path.startsWith("/" + e + ".plugin"));
 	relativePath(String requestPath) => requestPath; // FIXME
}
"Rule using static paths in site-enabled plugins."
shared Matcher pluginStaticPath({String*} ps) => PluginStaticPath(ps);

shared class DefaultWebContext(Context fromContext,  theme, config) 
	extends HashMap<String, Object>() satisfies WebContext {

	shared actual Storage<Config> configStorage = fromContext.configStorage;
	shared actual Storage<Entity> entityStorage = fromContext.entityStorage;
	shared actual Theme theme;
	shared actual Config config;	
	
	shared actual Entity? entity {
		Object? o = get("entity");
		if (exists o) {
			if (is Entity o) {
				return o;
			}
		}
		return null;		
	}
	
	shared actual default Path staticResourcePath(String type, String name) {
		return parsePath("/" + name + "." + type);
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
			if (is Map<String, String> o) {
				return (HashMap<String, String>(o));
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
				(HashMap<String, String>(o)).put(key,item);
			}
		} else {
			HashMap<String, String> newMap = HashMap<String, String>();
			newMap.put(key,item);
			put(mapItem, newMap);
		}
	}
	
	// Hook Handlers
	shared actual Result hook(String pluginId, String hookName, [String] args) {
		
		Hook? hook = hookFor(pluginId);
		if (exists hook) {
			//if (is HookWrapper hook) {
		 // 		if (hookName == "help") {
			//		return hook.invokehelp(args[0], [""]);
			//	}
			//}
		} 
		return null;
	 }
}


doc("A simple Web route")
shared class WebRoute(pluginId, String routeName, [String+] routeMethods, String routePath, Method<Plugin,Result,[Context]> routeProducer, String? routerPermission = null) {
	
	shared String pluginId;

	shared String name = routeName;
	
	shared [String+] methods = routeMethods;
	
	shared String path = routePath;
	
	shared Method<Plugin,Result,[Context]> produce = routeProducer;
	
	shared actual String string = "Web Route: from ``pluginId`` with name ``routeName`` : ``methods`` on ``routePath``";
}