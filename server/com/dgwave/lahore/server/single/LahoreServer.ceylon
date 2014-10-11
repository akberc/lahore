import ceylon.collection {
    LinkedList
}
import ceylon.io {
    SocketAddress
}
import ceylon.net.http.server {
    ...
}

import com.dgwave.lahore.api {
    LahoreServer=Server
}
import com.dgwave.lahore.core {
    Engine
}

import org.jboss.modules {
    Module {
        ceylonModuleLoader=callerModuleLoader
    },
    ModuleIdentifier {
        createModuleIdentifier=create
    },
    ModuleClassLoader
}

doc ("The Lahore instance")
object lahoreServer satisfies LahoreServer {
    shared actual String host = "localhost";
    shared actual Integer port = 8080;
    
    shared actual variable Boolean booted = false;
    
    shared actual String name = "Lahore Standalone Server";
    shared actual String version = `lahoreServer`.declaration.containingModule.version;
    
    shared String environment = bootConfig.stringWithDefault("lahore.environment", "DEV");
    
    shared actual void loadModule(String modName, String modVersion) {
  	    ModuleIdentifier modIdentifier = createModuleIdentifier(modName, modVersion);
  	    Module mod = ceylonModuleLoader.loadModule(modIdentifier);
  	    ModuleClassLoader modClassLoader = mod.classLoader;
  	    modClassLoader.loadClass(modName+".$module_");
    }
  
    shared LinkedList<String> siteList = LinkedList<String>();
  
    shared void boot() {
      
        String[] sites = bootConfig.stringsWithDefault("lahore.site");

        for (s in sites) {
            assert(exists i = s.firstInclusion("/"));
        	String moduleName = s[0..i-1];
        	String moduleVersion = s[i+1...];
        	loadModule(moduleName, moduleVersion);
        	siteList.add(s);
    	}

        booted = true;
    }
    
    shared Server singleServer = newServer {};
    
    shared void runWith(Engine engine) {
        singleServer.addEndpoint(Endpoint {
            path = startsWith("/");
            service => SiteService(engine).siteService;
        });
        value addr = SocketAddress(host, port);
            if (lahoreServer.environment == "DEV") {
                singleServer.start(addr);
            } else {
                singleServer.startInBackground(addr); // throw in background
            }
        }    
    }
