import ceylon.net.http.server { ... }
import ceylon.file { Path, parsePath, Directory, current, parseURI }
import ceylon.io { SocketAddress }
import com.dgwave.lahore.api { LahoreServer = Server }
import ceylon.collection { LinkedList }
import org.jboss.modules { 
	Module { ceylonModuleLoader=callerModuleLoader},
	ModuleIdentifier { createModuleIdentifier=create},
	ModuleClassLoader
}
import java.lang { System {javaProperty = getProperty}}
import com.dgwave.lahore.core { Engine }

doc ("The Lahore instance")
object lahoreServer satisfies LahoreServer {
    shared actual String host = "localhost";
    shared actual Integer port = 8080;
    
    shared actual variable Boolean booted = false;
    
    shared actual Path home {
        if (exists h = process.namedArgumentValue("lahore.home")) {
            return parseURI(h);
        } else {
            return parseURI(bootConfig.stringWithDefault("lahore.home", 
                current.childPath("lahore").uriString));
        } 
    }
    
    shared actual String name = "Lahore Standalone Server";
    shared actual String version = `lahoreServer`.declaration.containingModule.version;
    
    shared String environment = bootConfig.stringWithDefault("lahore.environment", "DEV");
    
    String? tempPath = javaProperty("java.io.tmpdir");
    shared actual Path temp { 
        if (exists tempPath) {
            return parsePath(tempPath).childPath("lahore").childPath("temp");
        } else {
            return home.childPath("temp");
        }
    }
    
    shared actual Path data = home.childPath("data");
    
    shared actual void loadModule(String modName, String modVersion) {
  	    ModuleIdentifier modIdentifier = createModuleIdentifier(modName, modVersion);
  	    Module mod = ceylonModuleLoader.loadModule(modIdentifier);
  	    ModuleClassLoader modClassLoader = mod.classLoader;
  	    modClassLoader.loadClass(modName+".module_");
    }
  
    shared LinkedList<String> siteList = LinkedList<String>();
  
    shared void boot() {
        
        if (is Directory homeDir = home.resource) {
            log.info("Using home directory: ``homeDir``");
        } else {
            log.error("Lahore home directory ``home`` does not exist, please use -Dlahore.home='someDir' OR create a 'lahore' directory in the current directory");
            process.exit(1);
        }
        
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
