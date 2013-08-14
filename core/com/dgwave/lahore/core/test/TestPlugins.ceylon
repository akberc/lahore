import ceylon.test { ... }
import com.dgwave.lahore.api { ... }
import com.dgwave.lahore.core { PluginRuntimeImpl, PluginInfoImpl }

by ("Akber Choudhry")
doc ("Run tests for static global methods for Lahore")

void testPlugins(){
	Runtime runtime = PluginRuntimeImpl(PluginInfoImpl("test", "Test", 
		"", "", "", "", `TestPlugin`,
			`TestContribution`), empty, empty);
	Plugin test = TestPlugin(runtime);
	//assertNotNull(plugins.findPlugin("test"));
	//assertEquals(2, plugins.adminRoutes().size);
	//assertEquals(0, plugins.mainRoutes().size);
}

id("test")
name("Test")
description("Test Module")
shared class TestPlugin(plugin) satisfies Plugin & TestContribution {
	shared actual Runtime plugin;

	methods(httpGET)
	route("test_one", "admin/help")
	permission("access administration pages")
	shared Result testProducer(Context c) {return assoc("test"->"successful");}
	
// implementing API
	shared actual {String*} testInsert {return {"something"};}
}


shared interface TestContribution satisfies Contribution {

	shared default {String*} testInsert {return {};}
	
}

