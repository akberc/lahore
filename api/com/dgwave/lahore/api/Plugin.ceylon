doc(" Any plugin invocation, direct or hooked, should result in one of these.
     Null will not be passed through to the caller, but will get an empty result or a false.
     Assoc is a generic representation of complex objects.  The framework provides some marshallers for Assoc's.
     Fragments can be Templated or Markup or a mixture.  
     Entities are not directly rendered by the framework, but must pass through a Route handler 
     or pass through a theme-provided template to be 'fragment'-ized.")
shared alias Result => Null |Assoc | {Fragment+} | {Entity+};
shared alias Route => Result(Context);

shared interface Fragment {
	shared formal String element;
	shared formal String render();
}

doc("Interface to be extended by all plugin APIs")
shared interface Hook {
	shared default Hook defaultHook { return noHook;} //default implementation
}

doc("Interface to be extended by all plugins exposing an API")
shared interface Hooked {
	
	doc ("Should only ever have to invoke our own hooks")
	shared default Result? hook(String pluginName, String hookName, [String] args) {return null;}
	
	shared default {Result*} hookAll(String hookName, [String] args) {return {};	}

	shared default {String*} hookImplementations {return {};}
	
	shared default Boolean hookIsImplementedBy (String pluginName) {return false;}
	
	shared default Hook? hookFor(String pluginName) {return null;}
}


doc("Interface to be implemented by all Lahore plugins")
shared interface Plugin {
	
	doc("Stop but not uninstall. Will be called before the framework has stopped the plugin") 
	shared default void stop() {}
	
	doc("Resume from existing settings. Will be called after the framework has started the plugin") 
	shared default void start() {}
}


shared interface Resource {

}

shared interface Service {

}

