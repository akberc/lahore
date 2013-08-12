import com.dgwave.lahore.core { ... }
import ceylon.test { ... }
import com.dgwave.lahore.api { Context, Storage, Config, Entity }
import com.dgwave.lahore.core.component { FileStorage, SqlStorage, SystemConfig }
import ceylon.file { parsePath, Path, Resource, Directory }

by ("Akber Choudhry")
doc ("Run tests for the Lahore kernel")

void testDispatcher(){

}

object testContext satisfies Context {

	Resource testRes = parsePath("build/test").resource;
	shared actual Storage<Config> configStorage {
		if (is Directory testRes) {
			 return FileStorage(testRes);
		} else {
			fail("Test file storage could not be created");
			throw Exception("Test file storage could not be created");
		}
	}
	shared actual String? contextParam(String name) {return null;}			
	shared actual Entity? entity {return null;}			
	shared actual Storage<Entity> entityStorage = SqlStorage(parsePath(""));
	shared actual Config config = SystemConfig();
	shared actual String? pathParam(String placeHolder) {return null;}	
	shared actual String? queryParam(String name) {return null;}	
	shared actual Path staticResourcePath(String type, String name) {return parsePath(type + "." + name);}
}