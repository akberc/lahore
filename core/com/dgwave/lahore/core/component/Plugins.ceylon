import ceylon.collection { HashMap, LinkedList, HashSet }
import ceylon.language.model { type, Method, modules }
import ceylon.language.model.declaration { ... }
import com.dgwave.lahore.api { ... }
import com.dgwave.lahore.core { WebRoute, PluginInfoImpl, PluginImpl, ContributionImpl}

class Plugins() {

	doc("Plugin:identifier to plugin info")
	value pluginInfos = HashMap<String, PluginInfoImpl>();

	doc("Plugin:identifier to contextual plugin")
	value pluginFinals = HashMap<String, PluginImpl>();
		
	doc("Plugin:identifier to Route object map")
	value pluginRoutes = HashMap<String, WebRoute>();

	doc("Plugin:identifier to Resource map")
	value pluginResources = HashMap<String, Resource>();

	doc("Plugin:identifier to Resource map")
	value pluginServices = HashMap<String, Service>();

	doc("Plugin:identifier to Contribution interface map")
	HashMap<String, Contribution> pluginContributions = HashMap<String, Contribution>();

	doc("Check annoations and register route")
	void registerRoutes() {
	  for (inf in pluginInfos) {
		for ( a in inf.item.pluginClass.annotatedMemberDeclarations<FunctionDeclaration, RouteAnnotation>()) {
			if (exists ra = a.annotations<RouteAnnotation>().first) {
				Method<Plugin,Result,[Context]> method = a.memberApply<Plugin, Result, [Context]>(`Context`);
				WebRoute webRoute = WebRoute(inf.key, ra.routeName, a.annotations<Methods>(), 
						ra.routePath, method, a.annotations<Permission>().first?.permission);
				watchdog(1, "Plugins", "Adding route: " + webRoute.string);
				pluginRoutes.put(inf.key + ":" + webRoute.path, webRoute);
				print ("Plugin Routes: " + pluginRoutes.string);
			}
		}
	  }
	}

	deprecated("FIX this and use it in register")
	String|Boolean satisfiesInterface(String name, OpenParameterisedType<InterfaceDeclaration>[] ifcs, String caller) {
		variable String|Boolean ret = false;
		for (i in ifcs) {
			value fullName = i.declaration.packageContainer.name + "." + i.declaration.name;
			if (name == fullName) {
				return caller;
			} else {
				ret = satisfiesInterface(name, i.interfaces, fullName);
			}
		}
		return ret;
	}
	
	deprecated("FIX this and use it in register")
	void registerContributions(String id, Plugin plugin) {
	  // we are only checking for interfaces, as the plugin class can satisfy hooks as well
	  for (t in type(plugin).declaration.packageContainer.members<InterfaceDeclaration>()) {
		value searched = satisfiesInterface("com.dgwave.lahore.api.Contribution", t.interfaceDeclarations, t.packageContainer.name + "." + t.name); 
		if (!is Boolean searched) {
			pluginContributions.put(id, ContributionImpl(searched));
		} else {
			watchdog(1, "Plugins", "No hook API found for plugin ``id``");
		}
	  }
		watchdog(1, "Plugins", "Hook List: " + pluginContributions.string); 
	}


	doc("We need the official id, name, desc as loaded")
	void register(String cmName, String cmVersion, ClassDeclaration pluginClass, String[] hookImpls, InterfaceDeclaration? hookInterface) {
		
		String? pluginId = pluginClass.annotations<Id>().first?.id;
	
		if (exists pluginId) {
			String? pluginName = pluginClass.annotations<Name>().empty
				then  pluginId else pluginClass.annotations<Name>().first?.name ;
			String? pluginDesc = pluginClass.annotations<Description>().empty
				then pluginId else pluginClass.annotations<Description>().first?.description;
			String? pluginConfigure = pluginClass.annotations<Configure>().empty
				then pluginId else pluginClass.annotations<Configure>().first?.configureLink;			
				
			if (pluginInfos.contains(pluginId)) {
				watchdog(0, "Lahore", "A module with that id already registered. Plugin NOT registered: ``pluginClass``");
			} else {
				watchdog(1, "Plugins", "Internal register Plugin : ``pluginId``");
				if (exists pluginName) { // should always exit
					if (exists pluginDesc) {
						if (exists pluginConfigure) {
						  pluginInfos.put(pluginId, PluginInfoImpl(
							pluginId, pluginName, pluginDesc, pluginConfigure,
							cmName, cmVersion,
							pluginClass, hookInterface, hookImpls));
						}
					}
				}
			}

		} else {
			watchdog(0, "Lahore", "Plugin NOT registered, not found annotation 'id' on: ``pluginClass``");
			return;
		}
	}

	doc("Recursively parse dependencies")	
	HashSet<String> parseDependencies(String cmName, String cmVersion, String id, HashSet<String> oldList) {
		// start with ourselves, and then fan out
		variable HashSet<String> list = HashSet<String>(oldList);
	
		Null|Module us = modules.find(cmName, cmVersion );
	
		if (exists us) { // verified
			if (!list.contains(id)) { // not already exists
				list.add(id); // only added if found
				for (dep in us.dependencies) {
					if (exists depId = pluginInfos.find((String->PluginInfo inf) => 
						dep.name == inf.item.moduleName && dep.version == inf.item.moduleVersion) )
					{
						list.addAll(parseDependencies(dep.name, dep.version, 
						depId.key, list));
					}
				}
			}
		} 
	
		return list;
    }
    
	doc("Re-calculate dependencies after all plugins are registered.
	     These are the declared dependencies in the Ceylon modules,
	     not the 'hook' dependencies.  Presence of hook interface will ensure that")
	void reCalculateDependencies() {
		for (info in pluginInfos) {
			PluginInfoImpl s = info.item;
			String[] deps = parseDependencies(s.moduleName, s.moduleVersion, s.id, HashSet<String>()).sequence;
			pluginInfos.put(info.key, s.withDependsOn(deps));
		}

		
		for (info in pluginInfos) {
			value depBy = pluginInfos.collect<String>((String->PluginInfo inf) => 
				inf.item.dependsOn(info.key) then inf.key else "~NO~")
				.filter((String e) => e != "~NO~").sequence;
			PluginInfoImpl r = info.item;
			pluginInfos.put(info.key, r.withDependedBy(depBy));
		}		
	}
			
	// OK, now register all the modules once
	for (cm in modules.list) {
		try {
		  if (!cm.name.startsWith("ceylon") && !cm.name.startsWith("oracle") && !cm.name.startsWith("java") && !cm.name.startsWith("javax")) {
			for (Package pk in cm.members) {
				if (cm.name == pk.name  && cm.name != "com.dgwave.lahore.core") { //FIXME - kludge for null on Java classes
				//  if (exists marker = pk.getClassOrInterface("module_")) {
					variable ClassDeclaration? pc = null;
					variable value impls = LinkedList<String>();
					for (ClassDeclaration cid in pk.annotatedMembers<ClassDeclaration, Id>()) {
						for (interf in cid.interfaceDeclarations) {
							String fullName = interf.declaration.packageContainer.name + "." + interf.declaration.name;
							watchdog(8, "Plugins", "Evaluating interface for plugin: ``fullName``");
							if ("com.dgwave.lahore.api.Plugin".equals(fullName)) {
								watchdog(0, "Lahore", "Loading - " + cm.name + pk.name + "." + cid.name);
								pc = cid;
							}
							for (superInterf in interf.declaration.interfaceDeclarations) {
							String superFullName = superInterf.declaration.packageContainer.name + "." + superInterf.declaration.name;							
								if ("com.dgwave.lahore.api.Hook".equals (superFullName)) {
									impls.add(fullName);
								}
							}							
						}
					}
					variable InterfaceDeclaration? hc = null;
					if (exists pluginClass = pc) {
						for (InterfaceDeclaration iid in pk.members<InterfaceDeclaration>()) {
							for (interf in iid.interfaceDeclarations) {
								String fullName = interf.declaration.packageContainer.name + "." + interf.declaration.name;
								watchdog(8, "Plugins", "Evaluating interface for hook ``fullName``");
								if ("com.dgwave.lahore.api.Hook".equals(fullName)) {
									hc = iid;
								}
							}
						}
						register(cm.name, cm.version, pluginClass,impls.sequence, hc);
					}
				 // }
				}
			}
		  }
		} catch (Exception e){
			// nothing
			watchdog(0, "Lahore", "Error registering Plugin: " + cm.name + " : " + e.message);
			e.printStackTrace();
		}
	}		

	registerRoutes();
	reCalculateDependencies();
	
	for (inf in pluginInfos) {
		pluginFinals.put(inf.key, PluginImpl(pluginScope, inf.item, AssocConfig(), 
			pluginRoutes.values.filter((WebRoute route) => route.pluginId == inf.key).sequence,
			pluginContributions.values.filter((Contribution cont) => cont.pluginId == inf.key).sequence,
			pluginResources.values.filter((Resource res) => res.pluginId == inf.key).sequence,
			pluginServices.values.filter((Service service) => service.pluginId == inf.key).sequence
			));
	}


	shared {WebRoute*} getMainRoutes() {
		return pluginRoutes.values.filter((WebRoute route) => !route.path.startsWith("admin"));
	}

	shared {WebRoute*} getAdminRoutes() {
		return pluginRoutes.values.filter((WebRoute route) => route.path.startsWith("admin"));
	}
	
	shared PluginImpl? findPlugin(String pluginId) { 
		return pluginFinals.get(pluginId); 
	}

	shared PluginInfoImpl? findPluginInfo(String pluginId) { 
		return pluginInfos.get(pluginId); 
	}
	
	Plugin? removePlugin(String pluginId) {
		pluginRoutes.remove(pluginId);
		pluginContributions.remove(pluginId);
		pluginInfos.remove(pluginId);
		return pluginFinals.remove(pluginId); 
	}
		
	doc("Stop but not uninstall") 
	shared void stopPlugin(String pluginId) {
		Plugin? plugin = removePlugin(pluginId);
		if (exists plugin) {
			plugin.stop();
		}
		reCalculateDependencies();
	}
	
	doc("Erase existing configuration and start with a new config") 
	shared void reConfigure(String pluginId, Assoc? config = null ) {
		stopPlugin(pluginId);
		//service("lahore.config").erase(pluginId);
		if (exists config) {
			//service("lahore.config").put(pluginId, config);
		} else {
			//service("lahore.config").put(pluginId, lahorePluginList.get(pluginId).defaultConfig);
		}
		//startPlugin(pluginId);
	}
	shared Array getImplementations(String hook) { return nothing; }
	shared Assoc invoke(String name, String hook, Array args) { return nothing; }
	shared Array getAdminTasks(String name, String string) { return nothing; }
	shared Boolean implementsHook(String mod, String hook) {
		return false; 
	}	
}


shared object plugins {
	Plugins mh = Plugins();
	
	shared {WebRoute*} mainRoutes() {
		return mh.getMainRoutes();
	}
	
	shared {WebRoute*} adminRoutes() {
		return mh.getAdminRoutes();	}
	
	shared {Assoc*} adminTasks(String pluginId) { 
		return {}; 
	}
	
	shared {WebRoute*} routesFor({String*} sitePlugins) { 
		return nothing; 
	}
	
	shared PluginImpl? plugin(String pluginId) { 
		return mh.findPlugin(pluginId); 
	}
	
	shared PluginInfoImpl? info (String pluginId) {
		return mh.findPluginInfo(pluginId);	}
}

