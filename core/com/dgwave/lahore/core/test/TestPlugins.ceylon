import ceylon.test { ... }
import com.dgwave.lahore.api { ... }
import com.dgwave.lahore.core { PluginRuntimeImpl, PluginInfoImpl, PluginImpl, Loader }
import com.dgwave.lahore.core.component { AssocConfig }

by ("Akber Choudhry")
doc ("Run tests for plugins")

void testPlugins() {
	
	value contrib = `TestContribution.testInsert`.declaration;
	String contribName = contrib.packageContainer.name +
		"." + contrib.name;
	
	value res = `TestTemplate`.declaration;
	variable String resName = res.packageContainer.name;
	ResourceAnnotation[] ra = res.annotations<ResourceAnnotation>();
	if (exists r = ra.first) {
		resName = resName + "." +r.name + "." + r.type.string;
	} else {
		fail ("Resource annotation not found");
	}

	value serv = `TestService`.declaration;
	variable String servName = serv.packageContainer.name;
	ServiceAnnotation[] sa = serv.annotations<ServiceAnnotation>();
	if (exists s = sa.first) {
		servName = servName + "." + s.name + "." + s.type.string;
	} else {
		fail ("Service annotation not found");
	}
	
	PluginInfoImpl info = PluginInfoImpl("test", "Test", 
		"com.dgwave.lahore.test", "0.x", "Test Description", "/admin/test/configure",
		 `TestPlugin`, `TestContribution`, [contribName], ["one", "two"], ["four", "five"],
		 [resName], [servName]);
	
	Runtime runtime = PluginRuntimeImpl(info);
	
	Plugin test = TestPlugin(runtime);
	
	// test self API
	assertNotNull(test);
	assertEquals("test", test.plugin.id);
	assertEquals("Test", test.plugin.name);
	assertEquals("com.dgwave.lahore.test", test.plugin.moduleName);
	assertEquals("0.x", test.plugin.moduleVersion);
	assertEquals("Test Description", test.plugin.description);
	assertEquals("/admin/test/configure", test.plugin.configurationLink);
	//TODO re-factor tasks and test here
	assertTrue(test.plugin.contributes("com.dgwave.lahore.core.test.testInsert"));
	assertFalse(test.plugin.contributes("com.dgwave.lahore.core.test.testSomething"));
	assertTrue(test.plugin.dependsOn("one"));
	assertFalse(test.plugin.dependsOn("three"));
	assertTrue(test.plugin.dependedBy("five"));
	assertFalse(test.plugin.dependedBy("six"));
	assertTrue(test.plugin.providesResource("com.dgwave.lahore.core.test.test.TEMPLATE"));
	assertFalse(test.plugin.providesResource("com.dgwave.lahore.core.test.test.THEME"));
	assertTrue(test.plugin.providesService("com.dgwave.lahore.core.test.test.TASK"));
	assertFalse(test.plugin.providesResource("com.dgwave.lahore.core.test.test.ENTITY"));	
		
	//TODO externalize instantation to outside Plugins into components and use to populate
	//FIXME take out this kludge once typechecker is accessible via runtime
	Loader().registerExtensions();
	PluginImpl impl = PluginImpl(pluginScope, info, AssocConfig());
	assertEquals("plugin", impl.scope.string);
	assertNotNull(impl.plugin); // impl should have created its own runtime
	
	// TODO test runtime API
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

resource(rTEMPLATE, "test")
shared class TestTemplate() satisfies Template<Markup> {

	shared actual {Markup*} apply({<String->Markup>*} fragments) {
		return {};
	}
	
	shared actual {<String->Markup>*} fragments {
		return {};
	}
}

service(sTASK, "test")
shared class TestService() satisfies Task {
	
	shared actual String id = "test";

	shared actual variable Boolean done = true;
	
	shared actual String message = "test message";
}