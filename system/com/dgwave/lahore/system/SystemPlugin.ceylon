import com.dgwave.lahore.api { ... }

id("system")
name("System")
description("Handles general site configuration for administrators.")
shared class SystemPlugin(plugin) satisfies Plugin {
	shared actual Runtime plugin;
	
}

