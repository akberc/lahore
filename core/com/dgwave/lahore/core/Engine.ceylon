import com.dgwave.lahore.api { ... }
import ceylon.logging { logger, Logger }
import ceylon.language.meta { modules }
import ceylon.language.meta.declaration { ClassDeclaration, Package }

Logger log = logger(`module com.dgwave.lahore.core`);


shared class Engine(lahoreServers, sites) {
    {Server+} lahoreServers;
    String[] sites;
    
    for (site in sites) { // module already loaded
        value pluginName = site.split((Character ch) => ch == '/');
        
        if (exists cmName = pluginName.first,
            exists cmVersion = pluginName.skipping(1).first,
            exists cm = modules.find(cmName, cmVersion),
            exists pluginId = cm.annotations<Id>().first?.id,
            exists siteContext = cm.annotations<SiteContext>().first) {
            for (Package pk in cm.members) {
                if (cm.name == pk.name) {
                    for (ClassDeclaration cid in pk.members<ClassDeclaration>()) {
                        for (interf in cid.satisfiedTypes) {
                            String fullName = interf.declaration.containingPackage.name + "." + interf.declaration.name;
                            log.debug("Evaluating interface for site: ``fullName``");
                            if ("com.dgwave.lahore.api.Site".equals(fullName)) {
                                log.debug("Loading Site: ``cid.qualifiedName``" );
                                value originalSite = cid.instantiate([]);
                                if (is Site originalSite) {
                                    ThemeConfig themeConfig = originalSite.themeConfig;

                                    value theme = themeConfig.themeClass.instantiate([], themeConfig);
                                    // value model = 
                                    // themeConfig.themeClass.classApply<Theme<ThemeConfig>,[ThemeConfig]>();
                                    // value theme = classModel.apply(themeConfig);                 
                                    if (is Theme theme) {
                                        value pluginNames = [cm.name + "/" + cm.version].chain(
                                            [for (d in cm.dependencies) d.name + "/" + d.version]
                                        );
// TODO remove after Ceylon language bug #315 is fixed
                                        for (d in cm.dependencies) {
                                            lahoreServers.first.loadModule(d.name, d.version);
                                        }
                                        value runtimeSite = SiteRuntime(originalSite, siteContext.context, 
                                            theme);
                                                                               
                                        value plugins = Plugins(pluginNames, runtimeSite);
                                                                               
                                        runtimeSite.plugins = plugins;
                                    
                                        siteRegistry.put(cid.qualifiedName, runtimeSite);
                                        log.debug("Added to Site Registry : ``cid.qualifiedName``" );
                                    }
                                }
                            }                                 
                        }
                    }
                }
            }
        }
    }

    shared void siteService(Request req, Response resp) {
        if (exists site = siteRegistry.first?.item) {
            site.siteService(req, resp);
        }
    }
}