import ceylon.test { ... }
import com.dgwave.lahore.api { ... }
import com.dgwave.lahore.core.component { plugins }

by ("Akber Choudhry")
doc ("Run tests for static global methods for Lahore")

void testPlugins(){
	Plugin test = TestPlugin();
	assertNotNull(plugins.findPlugin("test"));
	assertEquals(2, plugins.adminRoutes().size);
	assertEquals(0, plugins.mainRoutes().size);
}

id("test")
name("Test")
description("Test Module")
shared class TestPlugin() satisfies Plugin & TestHook {

	route("test_one", "GET", "admin/help", "access administration pages")
	shared Result testProducer(Context c) {return assoc("test"->"successful");}
	
// implementing API
	shared actual {String*} testInsert {return {"something"};}
}


shared interface TestHook satisfies Hook{

	shared default {String*} testInsert {return {};}
	
}

