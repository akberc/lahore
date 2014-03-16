import ceylon.collection { HashMap, LinkedList, HashSet }
import ceylon.language.meta { modules }
import ceylon.language.meta.declaration { ... }
import com.dgwave.lahore.api { ... }

import com.dgwave.lahore.core.component { AssocConfig }

class Plugins(String[] lahorePlugins) {
    
    doc("Plugin:identifier to plugin info")
    value pluginInfos = HashMap<String, PluginInfoImpl>();
    
    doc("Plugin:identifier to contextual plugin")
    value pluginFinals = HashMap<String, PluginImpl>();
    
    doc("Plugin:identifier to contribution map")
    HashMap<String, String[]> pluginContributions = HashMap<String, String[]>();
    
    HashMap<String, ClassDeclaration> themes = HashMap<String, ClassDeclaration>();
    
    doc("Exchange contribution implementations")
    void registerContributions() {
        for (impl in pluginFinals) {
            InterfaceDeclaration? myInterfaceDecl = pluginInfos.get(impl.key)?.contributionInterface;
            if (exists myInterfaceDecl) {
                String myInterfaceName = myInterfaceDecl.containingPackage.name + "." + myInterfaceDecl.name;
                for (contributor in pluginContributions) {
                    if (contributor.item.contains(myInterfaceName),
                        exists contributorPlugin = pluginFinals.get(contributor.key),
                        is PluginRuntimeImpl pri = impl.item.plugin,
                        is Contribution cppi = contributorPlugin.pluginInstance) {
                            pri.addContribution(contributor.key, cppi);

                    }
                }
            }
        }
    }
    
    
    "Register the official id, name, description as loaded"
    void register(Module cm, ClassDeclaration pluginClass, String[] contribImpls, InterfaceDeclaration? contribInterface) {
        
        String? pluginId = cm.annotations<Id>().first?.id;
        
        if (exists pluginId) {
            String? pluginName = cm.annotations<Name>().empty
                then  pluginId else cm.annotations<Name>().first?.name ;
            String? pluginDesc = cm.annotations<Description>().empty
                then pluginId else cm.annotations<Description>().first?.description;
            String? pluginConfigure = cm.annotations<Configure>().empty
                then pluginId else cm.annotations<Configure>().first?.configureLink;			
            
            if (pluginInfos.contains(pluginId)) {
                log.warn("A module with that id already registered. Plugin NOT registered: ``cm``");
            } else {
                log.info("Internal register Plugin : ``pluginId``");
                if (exists pluginName,
                    exists pluginDesc,
                    exists pluginConfigure) {
                        pluginInfos.put(pluginId, PluginInfoImpl {
                            moduleName = cm.name;
                            moduleVersion = cm.version;						  	
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
        } else {
            log.error("Plugin NOT registered, not found annotation 'id' on: ``pluginClass``");
            return;
        }
    }
    
    doc("Recursively parse dependencies")	
    HashSet<String> parseDependencies(String cmName, String cmVersion, String id, HashSet<String> oldList) {
        // start with ourselves, and then fan out
        variable HashSet<String> list = HashSet<String>{ elements = oldList;};
        
        Null|Module us = modules.find(cmName, cmVersion );
        
        if (exists us) { // verified
            if (!list.contains(id)) { // not already exists
                list.add(id); // only added if found
                for (dep in us.dependencies) {
                    if (exists depId = pluginInfos.find((String->PluginInfo inf) => 
                            dep.name == inf.item.moduleName && dep.version == inf.item.moduleVersion) ) {
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
    for (lp in lahorePlugins) {
        try {
            value pluginName = lp.split((Character ch) => ch == '/');
            
            if (exists cmName = pluginName.first,
                exists cmVersion = pluginName.skipping(1).first,
                exists cm = modules.find(cmName, cmVersion),
                exists pluginId = cm.annotations<Id>().first?.id ) {
                for (Package pk in cm.members) {
                    if (cm.name == pk.name) {
                        variable ClassDeclaration? pc = null;
                        value impls = LinkedList<String>();
                        for (ClassDeclaration cid in pk.members<ClassDeclaration>()) {
                            for (interf in cid.satisfiedTypes) {
                                String fullName = interf.declaration.containingPackage.name + "." + interf.declaration.name;
                                log.debug("Evaluating interface for plugin: ``fullName``");
                                if ("com.dgwave.lahore.api.Plugin".equals(fullName)) {
                                    log.debug("Loading - " + cm.name + pk.name + "." + cid.name);
                                    pc = cid;
                                }
                                if ("com.dgwave.lahore.api.Theme".equals(fullName)) {
                                    log.debug("Loading theme - " + cm.name + pk.name + "." + cid.name);
                                    themes.put("system", cid);
                                }
                                for (superInterf in interf.satisfiedTypes) {
                                    String superFullName = superInterf.declaration.containingPackage.name + "." + superInterf.declaration.name;							
                                    if ("com.dgwave.lahore.api.Contribution".equals (superFullName)) {
                                        impls.add(fullName);
                                    }
                                }							
                            }
                        }
                        variable InterfaceDeclaration? hc = null;
                        if (exists pluginClass = pc) {
                            for (InterfaceDeclaration iid in pk.members<InterfaceDeclaration>()) {
                                for (interf in iid.satisfiedTypes) {
                                    String fullName = interf.declaration.containingPackage.name + "." + interf.declaration.name;
                                    log.debug("Evaluating interface for hook ``fullName``");
                                    if ("com.dgwave.lahore.api.Contribution".equals(fullName)) {
                                        hc = iid;
                                    }
                                }
                            }
                            register(cm, pluginClass, impls.sequence, hc);
                        }
                    }
                }
            }
        } catch (Exception e){
            // nothing
            log.error("Error registering Plugin: ``lp`` : ", e);
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
    
    shared ClassDeclaration? themeClass (String themeId) {
        if (exists themeCls = themes.get(themeId)) {
            return themeCls;
        }
        return null;
    }  
}


object plugins {
    variable String[] pluginNames = [];
    if (exists ls = lahoreServer) {
            pluginNames= ls.pluginNames;
    }
    Plugins mh  = Plugins(pluginNames);
    
    shared {Assoc*} adminTasks(String pluginId) { 
        return mh.getAdminTasks(pluginId);
    }
    
    shared {WebRoute*} routesFor({String*} sitePlugins, Boolean all = false) { 
        return mh.routesFor(sitePlugins, all); 
    }
    
    shared PluginImpl? plugin(String pluginId) { 
        return mh.findPlugin(pluginId); 
    }
    
    shared PluginInfoImpl? info(String pluginId) {
        return mh.findPluginInfo(pluginId);    }
    
    shared ClassDeclaration? theme(String themeId) {
        return mh.themeClass(themeId);
    }
    
    shared String[] list => mh.list;
}

