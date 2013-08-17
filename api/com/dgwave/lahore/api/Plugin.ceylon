import ceylon.language.model.declaration { FunctionDeclaration }
import ceylon.language.model { Annotated }
doc(" Any plugin invocation, direct or hooked, should result in one of these.
     Null will not be passed through to the caller, but will get an empty result or a false.
     Assoc is a generic representation of complex objects.  The framework provides some marshallers for Assoc's.
     Fragments can be Templated or Markup or a mixture.  
     Entities are not directly rendered by the framework, but must pass through a Route handler 
     or pass through a theme-provided template to be 'fragment'-ized.")
shared alias Result => Null | Assoc | {Fragment+} | {Entity+};

shared alias Contributed => [String, Result];

shared alias Route => FunctionDeclaration & Result(Context);

shared interface Fragment {
	shared formal String element;
	shared formal String render();
}

doc("Interface to be implemented by all plugins that
     accept contributions from other plugins")
shared interface Contribution {
	shared default String pluginId { return "";}

}

doc("Information about a plugin that core and other plugins may need to know
     but the subject plugin knows about itself at compile-time")
shared interface PluginInfo {
	shared formal String id;
	shared formal String name;
	shared formal String description;	
	shared formal String moduleName;
	shared formal String moduleVersion;
	shared formal String configurationLink;
	shared formal {Task*} configurationTasks;
	
	"Only provides yes/no to a query and should not allow any deeper instrospection"
	shared formal Boolean contributes (String contributionId);
	shared formal Boolean providesResource (String resourceName);
	shared formal Boolean providesService (String serviceName);	
	shared formal Boolean dependsOn (String pluginId);
	//TODO do we need hasRoute here, or in runtime, or leave it at the site level?
		
	shared default actual String string {
		return "PluginInfo: ``id``, ``name``, ``description`` 
		        from Ceylon module ``moduleName``/``moduleVersion``.";
	}	
}

doc("How other plugins are interacting with this plugin 
     and which the subject plugin can only know about at run-time")
shared interface PluginRuntime {
	shared formal Boolean dependedBy (String pluginId);
	"The [[Result]] portion of Contributed can also be null"
	shared formal Contributed? contributionFrom (String pluginId, FunctionDeclaration contrib, Context c);
	shared formal {Contributed*} allContributions (FunctionDeclaration contrib, Context c);
	shared formal {String*} contributors;
	shared formal Boolean isContributedToBy(String otherPluginId);
	
	shared formal Boolean another(String pluginId);
	shared formal PluginInfo? plugin(String pluginId);
}

shared alias Runtime => PluginInfo & PluginRuntime;

doc("Interface to be implemented by all Lahore plugins")
shared interface Plugin satisfies Annotated {
	
	shared formal Runtime plugin;
	
	doc("Stop but not uninstall. Will be called before the framework has stopped the plugin") 
	shared default void stop() {}
	
	doc("Resume from existing settings. Will be called after the framework has started the plugin") 
	shared default void start() {}
	
	doc("Merged plugin configuration for the right context")
	shared default void configure(Config config) {}
}

"A controller is like a plugin extension
 and an implementation can be invoked with the Runtime object as a parameter,
 for example [[ctl1 = ControllerOne(Runtime plugin)]]"
 
shared interface Controller {
	shared formal Runtime plugin;
}

shared interface Resource satisfies Annotated {
	shared formal String id;
}

shared interface Service satisfies Annotated {
	shared formal String id;
}

shared interface Task satisfies Service{
    shared formal String message;
    shared formal variable Boolean done;
}