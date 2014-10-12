import ceylon.language.meta { modules }
import ceylon.language.meta.declaration { ClassDeclaration, Package }
import ceylon.logging {logger,Logger}
import com.dgwave.lahore.api { ... }
import com.dgwave.lahore.core.component { attachmentCache, BinaryResource }
import ceylon.io.buffer { newByteBuffer }

Logger log = logger(`module com.dgwave.lahore.core`);

shared class Engine(lahoreServers, sites) {
    {Server+} lahoreServers;
    String[] sites;

    for (site in sites) { // module already loaded
        value pluginName = site.split((Character ch) => ch == '/');

        if (exists cmName = pluginName.first,
            exists cmVersion = pluginName.skip(1).first,
            exists cm = modules.find(cmName, cmVersion),
            exists pluginType = cm.annotations<Type>().first?.pluginType,
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

                                    if (is Theme theme) {
                                        log.trace("Theme found ``theme.id``, now searching for attachments");
                                        for (tb in theme.attachments) {
                                            log.trace("Theme attachment found ``theme.id``, ``tb.string``");
                                            String key = siteContext.context + "/"
                                                    + String(tb.pathInModule.skipWhile((Character c) =>"/\\".contains(c)));

                                            String path =String(tb.pathInModule.skipWhile((Character c) =>"/\\".contains(c)));

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
                                                    BinaryResource bRes = BinaryResource(resource);
                                                    attachmentCache.put(key, [tb.contentType,
                                                        bRes.binaryContent() else newByteBuffer(0)]);
                                                }
                                            } else {
                                                log.warn("Resource ``tb.name`` could not be found in theme ``theme.id``");
                                            }
                                        }

                                        value pluginNames = [cm.name + "/" + cm.version].chain(
                                            [for (d in cm.dependencies) d.name + "/" + d.version]
                                        );
                                        log.trace("Site ``site`` uses modules: ``pluginNames``");

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