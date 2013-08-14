import com.dgwave.lahore.api { Scope, Resource, Service, Config, Plugin, PluginRuntime, PluginInfo, Contribution, Runtime, Contributed, Context, Task }
import ceylon.collection { HashMap }
import ceylon.language.model.declaration { ClassDeclaration, InterfaceDeclaration, FunctionDeclaration }
import com.dgwave.lahore.core.component { plugins }

shared class PluginInfoImpl (id, name, moduleName, moduleVersion, description,
		configurationLink, pluginClass, contributionInterface, 
		contributeList =[], dependsOnList=[], dependedByList=[], 
		resourcesList=[], servicesList = []) satisfies PluginInfo {
	shared actual String id;
	shared actual String name;
	shared actual String moduleName;
	shared actual String moduleVersion;
	shared actual String description;
	shared actual String configurationLink;
	shared actual {Task*} configurationTasks = {};	

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
		return PluginInfoImpl(this.id, this.name, this.description, this.configurationLink,
					this.moduleName, this.moduleVersion, this.pluginClass, this.contributionInterface, this.contributeList, dependsOnList, 
					this.dependedByList, this.servicesList, this.resourcesList);
	}
	
	shared PluginInfoImpl withDependedBy (String[] dependedByList=[]) {
		return PluginInfoImpl(this.id, this.name, this.description, this.configurationLink,
					this.moduleName, this.moduleVersion, this.pluginClass, this.contributionInterface, this.contributeList, this.dependsOnList, 
					dependedByList, this.servicesList, this.resourcesList);	}
	}

doc("Provides run-time implementations. PluginInfo can be for any plugin.
     Here the info represents the plugin itself, hence the duplication")
shared class PluginRuntimeImpl (info, dependedByList, contributions) 
		satisfies PluginInfo & PluginRuntime {
	
	PluginInfo info;
	Contribution[] contributions;
	String[] dependedByList;
	shared actual Boolean dependedBy(String pluginId) => dependedByList.contains(pluginId);

	shared actual String id => info.id;
	shared actual String name => info.name;
	shared actual String moduleName =>info.moduleName;
	shared actual String moduleVersion => info.moduleVersion;
	shared actual String description => info.description;
	shared actual String configurationLink => info.configurationLink;
	shared actual {Task*} configurationTasks => info.configurationTasks;
	
	shared actual Boolean contributes (String contributionId) => info.contributes(contributionId);
	shared actual Boolean dependsOn (String pluginId) => info.dependsOn(pluginId);
	shared actual Boolean providesService (String serviceId) => info.providesService(serviceId);
	shared actual Boolean providesResource (String resourceId) => info.providesResource(resourceId);
	
	
	"Keyed by originating plugin and method name, with items being implementations"
	value contribMap = HashMap<String, Contribution>();

	shared actual {Contributed*} allContributions(FunctionDeclaration contrib, Context c) {
		return {};
	}
	
	shared actual Contributed? contributionFrom(String pluginId, 
		FunctionDeclaration contrib, Context c) {
		return null;
	}
	
	shared actual {String*} contributors {
		return contribMap.keys;
	}
	
	shared actual Boolean isContributedToBy(String otherPluginId) {
		return contribMap.contains(otherPluginId);
	}

	shared actual Boolean another(String pluginId) {
		if (exists pi = plugins.info(pluginId)) {
			return true;
		} else {
			return false;
		}
	}

	shared actual PluginInfo? plugin(String pluginId) {
		return plugins.info(pluginId);
	}
	
}
	
doc("The runtime representation of a plugin")
shared class PluginImpl (scope, pluginInfo, config, 
	routes, contributions, resources, services) satisfies Plugin {
	
	shared Scope scope;
	shared PluginInfoImpl pluginInfo;
	shared Config config;
	
	shared WebRoute[] routes;
	shared Contribution[] contributions;
	shared Resource[] resources;
	shared Service[] services;
			
	shared actual Runtime plugin = PluginRuntimeImpl(pluginInfo,
		pluginInfo.dependedByList, contributions);  // pass on for actual invocation

	// instantiate class and interface from info and inject the run-time
	value instantiable = pluginInfo.pluginClass.apply(`Runtime`);
	Plugin instance = instantiable(plugin);	

	shared actual void start() {
		
	}
	
	shared actual void stop() {
		
	}

	shared actual void configure( Config config) {
		
	}	
}

shared class ContributionImpl(pluginId) satisfies Contribution {
	shared actual String pluginId;
	
}