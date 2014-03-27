import com.dgwave.lahore.api { ... }
import ceylon.collection { HashMap, LinkedList }
import ceylon.language.meta.declaration { ClassDeclaration, InterfaceDeclaration, FunctionDeclaration }
import ceylon.language.meta.model { Class, Method, Function }

class PluginInfoImpl (id, name, moduleName, moduleVersion, description,
    pluginClass, contributionInterface, 
    contributeList =[], dependsOnList=[], dependedByList=[], 
    resourcesList=[], servicesList = []) satisfies PluginInfo {
    
    shared actual String id;
    shared actual String name;
    shared actual String moduleName;
    shared actual String moduleVersion;
    shared actual String description;
    
    String[] contributeList;
    shared actual Boolean contributes(String contrib) => contributeList.contains(contrib);
    
    String[] dependsOnList;
    shared actual Boolean dependsOn (String pluginId) => dependsOnList.contains(pluginId);
    
    // these three are only referenced from the Impl
    shared String[] dependedByList;
    shared ClassDeclaration pluginClass;
    shared InterfaceDeclaration? contributionInterface;
    
    String[] servicesList;
    shared actual Boolean providesService (String serviceId) => servicesList.contains(serviceId);
    
    String[] resourcesList;
    shared actual Boolean providesResource (String resourceId) => resourcesList.contains(resourceId);
    
    shared PluginInfoImpl withDependsOn (String[] dependsOnList=[]) {
        return PluginInfoImpl(this.id, this.name, this.moduleName, this.moduleVersion, this.description, 
            this.pluginClass, this.contributionInterface, this.contributeList, dependsOnList, 
            this.dependedByList, this.servicesList, this.resourcesList);
    }
    
    shared PluginInfoImpl withDependedBy (String[] dependedByList=[]) {
        return PluginInfoImpl(this.id, this.name, this.moduleName, this.moduleVersion, this.description, 
            this.pluginClass, this.contributionInterface, this.contributeList, this.dependsOnList, 
            dependedByList, this.servicesList, this.resourcesList);	}
    }
    
    "Provides run-time implementations. PluginInfo can be for any plugin.
     Here the info represents the plugin itself, hence the duplication"
    class PluginRuntimeImpl (info, site) satisfies Runtime & PluginInfo {
        
        shared actual PluginInfoImpl info;
        SiteRuntime site;

        "Keyed by originating plugin and method name, with items being implementations. Populated externally"
        HashMap<String, Contribution> contributions = HashMap<String, Contribution> ();
        
        shared actual Boolean dependedBy(String pluginId) => info.dependedByList.contains(pluginId);
        
        shared actual String id => info.id;
        shared actual String name => info.name;
        shared actual String moduleName =>info.moduleName;
        shared actual String moduleVersion => info.moduleVersion;
        shared actual String description => info.description;
        
        shared actual Boolean contributes (String contributionId) => info.contributes(contributionId);
        shared actual Boolean dependsOn (String pluginId) => info.dependsOn(pluginId);
        shared actual Boolean providesService (String serviceId) => info.providesService(serviceId);
        shared actual Boolean providesResource (String resourceId) => info.providesResource(resourceId);
        
        shared void addContribution (String key, Contribution contribution) {
            this.contributions.put(key, contribution);
        }
        
        shared actual {Contributed*} allContributions(FunctionDeclaration contrib, Context c) {
            return { for (id in contributions.keys) if (exists cf = contributionFrom(id, contrib,c)) cf};
        }
        
        shared actual Contributed? contributionFrom(String pluginId, FunctionDeclaration contrib, Context c) {
            try {
                if (exists cb = contributions.get(pluginId)) {

                    value p = contrib.memberInvoke(cb, [], c);
                    if (is Fragment | Assoc p) {
                        return [pluginId, p];
                    }
                } 
            } catch (Exception e) {
                log.warn ("Contribution was not obtained from ``pluginId`` ", e);
            }
            return null;
        }
        
        shared actual {String*} contributors {
            return contributions.keys;
        }
        
        shared actual Boolean isContributedToBy(String otherPluginId) {
            return contributions.keys.contains(otherPluginId);
        }
        
        shared actual Boolean another(String pluginId) {
            if (exists pi = site.plugins?.info(pluginId)) {
                return true;
            } else {
                return false;
            }
        }
        
        shared actual PluginInfo? plugin(String pluginId) {
            return site.plugins?.info(pluginId);
        }
    }
    
    doc("The runtime representation of a plugin")
    class PluginImpl (scope, pluginInfo, site) satisfies Plugin {
        
        Scope scope;
        PluginInfoImpl pluginInfo;
        SiteRuntime site;
        
        shared LinkedList<WebRoute> routes = LinkedList<WebRoute>();
        
        shared PluginRuntimeImpl plugin = PluginRuntimeImpl(pluginInfo, site);
        
        shared Plugin? pluginInstance {    
            // instantiate class and interface from info and inject the run-time
            value instantiable = pluginInfo.pluginClass.apply<Plugin>();
            if (is Class<Anything, [Runtime]> instantiable) {
                value instance = instantiable(plugin);
                if (is Plugin instance) {
                    return instance;
                }
            }
            return null;
        }
        
        //top-level routes
        for ( a in pluginInfo.pluginClass.containingPackage
                .annotatedMembers<FunctionDeclaration, RouteAnnotation>()) {
            if (exists ra = a.annotations<RouteAnnotation>().first) {
                Function<Content?,[Context, Runtime]>method = 
                        a.apply<Content?, [Context, Runtime]>();
    
                WebRoute webRoute = WebRoute(pluginInfo.id, ra.routeName, a.annotations<Methods>(), 
                    ra.routePath, method, a.annotations<Permission>().first?.permission);
                log.debug("Adding top-level route: " + webRoute.string);
                routes.add(webRoute);
            }
        }
        
        /* routes within the plugin class
        for ( ca in pluginInfo.pluginClass
                .annotatedMemberDeclarations<FunctionDeclaration, RouteAnnotation>()) {
            if (exists ra = ca.annotations<RouteAnnotation>().first) {
                value method = type(pluginInstance).getMethod<Anything, Result, [Context]>(ca.name);
                if (exists method) {
                    WebRoute webRoute = WebRoute(pluginInfo.id, ra.routeName, ca.annotations<Methods>(), 
                    ra.routePath, method, ca.annotations<Permission>().first?.permission);
                    watchdog(1, "Plugins", "Adding plugin route: " + webRoute.string);
                    routes.add(webRoute);
                }
            }
        }
         */
        
        shared Content? produceRoute(Context c, WebRoute r) {
            if ( is Method<Anything,Content?,[Context]> producer = r.produce) {
                return producer(pluginInstance)(c); 
            }
            else if ( is Function<Content?,[Context, Runtime]> producer = r.produce) { 
                return producer(c, plugin);                    
            } else {
                return null;
            }
        }
        
        shared actual void start() {
            if (exists p = pluginInstance) {
                p.start();
            }
        }
        
        shared actual void stop() {
            if (exists p = pluginInstance) {
                p.stop();
            }		
        }
        
        shared actual void configure( Config config) {
            if (exists p = pluginInstance) {
                p.configure(config);
            }		
        }	
    }
    
class ContributionImpl(pluginId) satisfies Contribution {
    shared actual String pluginId;
    
}
