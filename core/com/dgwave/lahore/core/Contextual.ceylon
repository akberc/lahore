import com.dgwave.lahore.api { Hooked, Hook, Result, Scope, Resource, Service, Config, Plugin, Context }
import ceylon.collection { HashMap }
import ceylon.language.model.declaration { ClassDeclaration, InterfaceDeclaration }
import ceylon.language.model { Class, Method }

doc("Provides the hooking mechanism within a context")
shared abstract class ContextualHooked() satisfies Hooked {
	
	HashMap<String, Hook> implMap = HashMap<String, Hook>();

	shared void addHookImplementation(String implementingPlugin, Hook pluginHook) {	
		implMap.put(implementingPlugin, pluginHook);
	}

	shared actual default Result? hook(String pluginName, String hookName, [String] args) {return null;}
	
	shared actual default {Result*} hookAll(String hookName, [String] args) {
		return {};	
	}
	
	shared actual {String*} hookImplementations {
		return implMap.keys.sequence;
	}
	
	shared actual Boolean hookIsImplementedBy (String pluginName) {
		return implMap.keys.contains(pluginName);
	}

	shared actual default Hook? hookFor(String pluginName) {
		return implMap.get(pluginName);
	}
	
}

shared class PluginInfo(id, name, description, configureLink, 
	moduleName, moduleVersion, pluginClass, hookInterface, implements,
	dependsOn=[], dependedOnBy = [], provides = []) {
	shared String id;
	shared String name;
	shared String moduleName;
	shared String moduleVersion;
	shared String description;
	shared String configureLink;
	shared ClassDeclaration pluginClass;
	shared InterfaceDeclaration? hookInterface;
	shared String[] implements;
	shared String[] provides;
	shared String[] dependsOn;
	shared String[] dependedOnBy;
	shared actual String string {
		return "PluginInfo: ``id``, ``name``, ``description`` from Ceylon module ``moduleName``/``moduleVersion``. 
		        Depends on ``dependsOn`` and is depended on by ``dependedOnBy`` 
		        Implements hooks for ``implements`` and provides ``provides``";
	}
}
	
doc("The runtime representation of a plugin")
shared class ContextualPlugin(scope, pluginInfo, config, 
		routes = [], hooks= [], resources = [], services =[] ) 
	satisfies Plugin {

	
	shared Scope scope;
	shared PluginInfo pluginInfo;
	shared Config config;
	
	shared WebRoute[] routes;
	shared ContextualHooked[] hooks;
	shared Resource[] resources;
	shared Service[] services;
	
	Class<Anything,Nothing> appliedPlugin() { return pluginInfo.pluginClass.apply(); }
	value instance = appliedPlugin(); 
//	Method<Plugin, Result, [Context]>? m = instance.getMethod<Plugin, Result, [Context]>("helpMain");
//	if (exists m) {
		// Result r = m(instance., Context);
//	}

	shared actual void start() {
		
	}
	
	shared actual void stop() {
		
	}
}