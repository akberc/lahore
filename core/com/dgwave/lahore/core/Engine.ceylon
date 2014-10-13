import ceylon.language.meta { modules }
import ceylon.language.meta.declaration { ClassDeclaration, Package, Module }
import ceylon.logging {logger,Logger}
import com.dgwave.lahore.api { ... }
import com.dgwave.lahore.core.component { ... }
import ceylon.io.charset {
    utf8
}
import ceylon.io.buffer {
    ByteBuffer
}

Logger log = logger(`module com.dgwave.lahore.core`);

shared class Engine(lahoreServers, sites) {
    {Server+} lahoreServers;
    String[] sites;

    void cacheAttachments(Theme theme, String context, ThemeConfig themeConfig) {
        for (tb in theme.attachments) {
            log.trace("Theme attachment found ``theme.id``, ``tb.string``");
            String key = context + "/"
                    + String(tb.pathInModule.skipWhile((Character c) =>"/\\".contains(c)));

            String path =String(tb.pathInModule.skipWhile((Character c) =>"/\\".contains(c)));

            Resource? resource = themeConfig.themeClass.containingModule
                    .resourceByPath(path);

            cacheResource(key, tb, resource);
        }
    }

    void loadSite(ClassDeclaration cid, String context, Module cm) {
        value originalSite = cid.instantiate([]);
        if (is Site originalSite) {
            ThemeConfig themeConfig = originalSite.themeConfig;

            value theme = themeConfig.themeClass.instantiate([], context, themeConfig);

            if (is Theme theme) {
                log.trace("Theme found ``theme.id``, now searching for attachments");
                cacheAttachments(theme, context == "/" then "" else context, themeConfig);

                value pluginNames = [cm.name + "/" + cm.version].chain(
                    [for (d in cm.dependencies) d.name + "/" + d.version]
                );
                log.trace("Site ``site`` uses modules: ``pluginNames``");

                value runtimeSite = SiteRuntime(originalSite, context, theme);

                value plugins = Plugins(pluginNames, runtimeSite);

                runtimeSite.plugins = plugins;

                siteRegistry.put(context, runtimeSite);
                log.debug("Added to Site Registry : ``cid.qualifiedName``" );
            }
        }
    }

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
                                loadSite(cid, siteContext.context, cm);
                            }
                        }
                    }
                }
            }
        }
    }

    shared void siteService(Request req, Response resp) {
        Boolean isAttachment(Request req) =>
                req.path.endsWith(".css") || req.path.endsWith(".js") ||
                req.path.endsWith(".ico") || req.path.endsWith(".jpg") ||
                req.path.endsWith(".png");

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

        String[] tokens = req.path.split('/'.equals).sequence();
        String context = "/``(tokens[1] else "/")``";
        if (exists s = siteRegistry.get(context)) {
            s.siteService(req, resp);
        } else { //unknown context
            siteRegistry.get("/")?.siteService(req, resp);
        }
    }
}