import ceylon.collection { HashMap, LinkedList, HashSet }
import ceylon.language.model { modules }
import ceylon.language.model.declaration { ... }
import com.dgwave.lahore.api { ... }
import com.dgwave.lahore.core { WebRoute, PluginInfoImpl, PluginImpl, PluginRuntimeImpl}

class Plugins() {
    
    doc("Plugin:identifier to plugin info")
    value pluginInfos = HashMap<String, PluginInfoImpl>();
    
    doc("Plugin:identifier to contextual plugin")
    value pluginFinals = HashMap<String, PluginImpl>();
    
    doc("Plugin:identifier to contribution map")
    HashMap<String, String[]> pluginContributions = HashMap<String, String[]>();
    
    deprecated("FIX this and use it in register")
    String|Boolean satisfiesInterface(String name, OpenInterfaceType[] ifcs, String caller) {
        variable String|Boolean ret = false;
        for (i in ifcs) {
            value fullName = i.declaration.containingPackage.name + "." + i.declaration.name;
            if (name == fullName) {
                return caller;
            } else {
                // TODO fix : ret = satisfiesInterface(name, i.memberDeclarations<Kind>m, fullName);
            }
        }
        return ret;
    }
    
    doc("Exchange contribution implementations")
    void registerContributions() {
        for (impl in pluginFinals) {
            InterfaceDeclaration? myInterfaceDecl = pluginInfos.get(impl.key)?.contributionInterface;
            if (exists myInterfaceDecl) {
                String myInterfaceName = myInterfaceDecl.containingPackage.name + "." + myInterfaceDecl.name;
                for (contributor in pluginContributions) {
                    if (contributor.item.contains(myInterfaceName)) {
                        if (exists contributorPlugin = pluginFinals.get(contributor.key)) {
                            if (is PluginRuntimeImpl pri = impl.item.plugin) {
                                if (is Contribution cppi = contributorPlugin.pluginInstance) {
                                    pri.addContribution(contributor.key, cppi);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    doc("We need the official id, name, desc as loaded")
    void register(String cmName, String cmVersion, ClassDeclaration pluginClass, String[] contribImpls, InterfaceDeclaration? contribInterface) {
        
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
                            pluginInfos.put(pluginId, PluginInfoImpl {
                                moduleName = cmName;
                                moduleVersion = cmVersion;						  	
                                id = pluginId;
                                name = pluginName; 
                                description = pluginDesc; 
                                configurationLink = pluginConfigure;
                                pluginClass = pluginClass; 
                                contributionInterface = contribInterface; 
                                contributeList = contribImpls;
                            });
                            pluginContributions.put(pluginId, contribImpls);
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
    
    "Re-calculate dependencies after all plugins are registered.
     These are the declared dependencies in the Ceylon modules,
     not the 'hook' dependencies.  Presence of hook interface will ensure that"
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
            if (!cm.name.startsWith("ceylon") && !cm.name.startsWith("oracle") 
                    && !cm.name.startsWith("java") && !cm.name.startsWith("javax") ) {
                for (Package pk in cm.members) {
                    if (cm.name == pk.name  && cm.name != "com.dgwave.lahore.core") { //FIXME - kludge for null on Java classes
                        //  if (exists marker = pk.getClassOrInterface("module_")) {
                        variable ClassDeclaration? pc = null;
                        variable value impls = LinkedList<String>();
                        for (ClassDeclaration cid in pk.annotatedMembers<ClassDeclaration, Id>()) {
                            for (interf in cid.memberDeclarations<InterfaceDeclaration>()) {
                                String fullName = interf.containingPackage.name + "." + interf.name;
                                watchdog(8, "Plugins", "Evaluating interface for plugin: ``fullName``");
                                if ("com.dgwave.lahore.api.Plugin".equals(fullName)) {
                                    watchdog(0, "Lahore", "Loading - " + cm.name + pk.name + "." + cid.name);
                                    pc = cid;
                                }
                                for (superInterf in interf.memberDeclarations<InterfaceDeclaration>()) {
                                    String superFullName = superInterf.containingPackage.name + "." + superInterf.name;							
                                    if ("com.dgwave.lahore.api.Contribution".equals (superFullName)) {
                                        impls.add(fullName);
                                    }
                                }							
                            }
                        }
                        variable InterfaceDeclaration? hc = null;
                        if (exists pluginClass = pc) {
                            for (InterfaceDeclaration iid in pk.members<InterfaceDeclaration>()) {
                                for (interf in iid.memberDeclarations<InterfaceDeclaration>()) {
                                    String fullName = interf.containingPackage.name + "." + interf.name;
                                    watchdog(8, "Plugins", "Evaluating interface for hook ``fullName``");
                                    if ("com.dgwave.lahore.api.Contribution".equals(fullName)) {
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
    
    reCalculateDependencies();
    
    for (inf in pluginInfos) {
        pluginFinals.put(inf.key, PluginImpl(pluginScope, inf.item, AssocConfig())); 
    }
    
    registerContributions();
    
    shared PluginImpl? findPlugin(String pluginId) { 
        return pluginFinals.get(pluginId); 
    }
    
    shared PluginInfoImpl? findPluginInfo(String pluginId) { 
        return pluginInfos.get(pluginId); 
    }
    
    Plugin? removePlugin(String pluginId) {
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
    
    shared String[] list = pluginInfos.keys.sequence;
    
    shared {WebRoute*} routesFor({String*} sitePlugins, Boolean all) { 
        
        {String*} lookFor = all then pluginFinals.keys else 
        pluginFinals.keys.filter((String k) => sitePlugins.contains(k));
        
        return { 
            for (lf in lookFor) 
            if (exists pf = pluginFinals.get(lf)) 
            for (r in pf.routes.sequence) r
        };
    }
    
    shared {Assoc*} getAdminTasks(String pluginId) { 
        return {}; 
    }
    
}


shared object plugins {
    Plugins mh = Plugins();
    
    shared {Assoc*} adminTasks(String pluginId) { 
        return mh.getAdminTasks(pluginId);
    }
    
    shared {WebRoute*} routesFor({String*} sitePlugins, Boolean all = false) { 
        return mh.routesFor(sitePlugins, all); 
    }
    
    shared PluginImpl? plugin(String pluginId) { 
        return mh.findPlugin(pluginId); 
    }
    
    shared PluginInfoImpl? info (String pluginId) {
        return mh.findPluginInfo(pluginId);    }
    
    shared String[] list => mh.list;
}

