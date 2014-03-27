import com.dgwave.lahore.api { ... }
import ceylon.logging { logger, Logger }
import ceylon.language.meta { modules }
import ceylon.language.meta.declaration { ClassDeclaration, Package }
import ceylon.file { FileRes=Resource, File, parseURI }
import ceylon.io { newOpenFile }
import ceylon.io.buffer { ByteBuffer, newByteBuffer }

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

                                    value theme = themeConfig.themeClass.instantiate([], siteContext.context, themeConfig);
                                    // value model = 
                                    // themeConfig.themeClass.classApply<Theme<ThemeConfig>,[ThemeConfig]>();
                                    // value theme = classModel.apply(themeConfig);                 
                                    if (is Theme theme) {
                                        
                                        for (tb in theme.attachments) {
                                            String key = siteContext.context + "/"  
                                                    + String(tb.pathInModule.skippingWhile((Character c) =>"/\\".contains(c)));
                                            
                                            String path = themeConfig.themeClass.containingModule.name.replace(".", "/") + "/" 
                                                + String(tb.pathInModule.skippingWhile((Character c) =>"/\\".contains(c)));
                                            
                                            Resource? resource = themeConfig.themeClass.containingModule
                                                    .resourceByPath(path);
                                            
                                            if (exists resource) {
                                                value contentType = tb.contentType;
                                                switch (contentType)
                                                case (textCss, applicationJavascript, applicationJson) {
                                                    String? stuff = resource.textContent();
                                                    if (exists stuff) {
                                                        attachmentCache.put(key, [tb.contentType, stuff]);
                                                    }
                                                }
                                                case (imageIcon, imageJpg, imagePng) {
                                                    FileRes fRes = parseURI(resource.uri).resource;
                                                    if (is File fRes) {
                                                        value openFile = newOpenFile(fRes);
                                                        variable Integer available = openFile.size;
                                                        ByteBuffer byteBuffer = newByteBuffer(available);
                                                        openFile.read(byteBuffer);
                                                        byteBuffer.flip();
                                                        attachmentCache.put(key, [tb.contentType, byteBuffer]);
                                                    } else {
                                                        log.warn("Binary resource file ``fRes.path`` could no be loaded");   
                                                    }
                                                }
                                            } else {
                                                log.warn("Resource ``tb.name`` could not be found in theme ``theme.id``");
                                            }
                                        }
                                        
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