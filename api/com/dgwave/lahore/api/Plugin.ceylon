import ceylon.language.meta.declaration { FunctionDeclaration }
import ceylon.language.meta.model { Method, Function }


"""Null will not be passed through to the caller, but will get an empty result or a false.
     Assoc is a generic representation of complex objects.  The framework provides some marshallers for Assoc's.
     Fragments can be Templated or Markup or a mixture.
      
     Entities are not directly rendered by the framework, but must pass through a Route handler 
     or pass through a theme-provided template to be 'fragment'-ized."""
shared alias Contributed => [String, Fragment | Assoc | Div];

"A simple route"
shared interface Route {
    
    shared formal String pluginId;
    
    shared formal String name;
    
    shared formal Methods[] methods;
    
    shared formal String path;
    
    shared formal Method<Anything, Content?, [Context]>
            | Function<Content?,[Context, PluginRuntime]> produce;
}

"Interface to be implemented by all plugins that
     accept contributions from other plugins"
shared interface Contribution {
    shared default String pluginId { return "";}
}

"Information about a plugin that core and other plugins may need to know
     but the subject plugin knows about itself at compile-time"
shared interface PluginInfo {
    shared formal String id;
    shared formal String name;
    shared formal String description;	
    shared formal String moduleName;
    shared formal String moduleVersion;
    
    "Only provides yes/no to a query and should not allow any deeper instrospection"
    shared formal Boolean contributes (String contributionId);
    shared formal Boolean providesResource (String resourceName);
    
    //TODO provide service by API interface
    shared formal Boolean providesService (String serviceName);	
    shared formal Boolean dependsOn (String pluginId);
    //TODO do we need hasRoute here, or in runtime, or leave it at the site level?
    
    shared default actual String string {
        return "PluginInfo: ``id``, ``name``, ``description`` from 
                Ceylon module ``moduleName``/``moduleVersion``.";
    }	
}

shared interface Plugin {

    shared default void start() {}
    
    shared default void stop() {}
    
    "Merged plugin configuration for the right context"
    shared default void configure(Config config) {}   
}

"How other plugins are interacting with this plugin 
     and which the subject plugin can only know about at run-time"
shared interface PluginRuntime {
    shared formal PluginInfo info;
    shared formal Boolean dependedBy (String pluginId);
    "The content portion of Contributed can also be null"
    shared formal Contributed? contributionFrom (String pluginId, FunctionDeclaration contrib, Context c);
    shared formal {Contributed*} allContributions (FunctionDeclaration contrib, Context c);
    shared formal {String*} contributors;
    shared formal Boolean isContributedToBy(String otherPluginId);
    
    shared formal Boolean another(String pluginId);
    shared formal PluginInfo? plugin(String pluginId);
}
