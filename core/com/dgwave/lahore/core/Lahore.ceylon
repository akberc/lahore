import ceylon.net.http.server.endpoints { serveStaticFile }
import ceylon.net.http.server { Server, createServer, AsynchronousEndpoint, startsWith, Endpoint, isRoot, Request, Response}
import com.dgwave.lahore.core.console { console, consoleListener }
import ceylon.file { Path, parsePath, File, Directory, current, parseURI, Resource, defaultSystem }
import ceylon.io { newOpenFile }
import ceylon.io.buffer { ByteBuffer, newByteBuffer }
import ceylon.net.http { contentType, contentLength, get }
import ceylon.io.charset { utf8 }
import com.dgwave.lahore.api { watchdog, Context, Storage, Entity, Config }
import ceylon.collection { HashMap }
import com.dgwave.lahore.core.component { SqlStorage, fileStorage, SystemConfig, AssocConfig, plugins }

doc ("The Lahore instance")
by ("Akber Choudhry")

shared variable Integer lahoreDebugLevel =9;


object lahore {
	shared variable Boolean booted = false;
		
	Config bootConfig = SystemConfig();
	
	shared Path home {
		if (exists h = process.namedArgumentValue("lahore.home")) {
			return parseURI(h);
		} else {
			return parseURI(bootConfig.stringWithDefault("lahore.home", 
				current.childPath("lahore").uriString));
		} 
	}
    
	shared String version = `lahore`.declaration.packageContainer.container.version;
    
    shared String environment = bootConfig.stringWithDefault("lahore.environment", "DEV");
	
	if (exists p = parseInteger(bootConfig.stringWithDefault("lahore.debugLevel", "9"))) {
		lahoreDebugLevel = p;
    }
    
    shared object context satisfies Context {

        variable String configURI = bootConfig.stringWithDefault("lahore.configStore", 
			home.absolutePath.childPath("config").uriString); // default value
		configURI = configURI.replace("{lahore.home}", home.uriString); // replace placeholder
		// FIXME
		configURI = "lahore/config";
    	shared actual Storage<Config> configStorage = fileStorage(parsePath(configURI));
		
		// TODO based on actual URI scheme

        variable String dataURI = bootConfig.stringWithDefault("lahore.dataStore", 
			home.absolutePath.childPath("data").uriString); // default value
		configURI = configURI.replace("{lahore.home}", home.uriString); // replace placeholder
    	shared actual Storage<Entity> entityStorage = SqlStorage(parsePath(dataURI));
    	
    	shared actual Config config => bootConfig;
    	
    	shared actual Path staticResourcePath(String type, String name) { return home.childPath("static").childPath(name + "." + type);}
	}

    shared void boot() {
	
	    if (is Directory homeDir = home.resource) {
				watchdog(0, "Lahore", "Using home directory: ``homeDir``");
		} else {
			watchdog(0, "Lahore", "Lahore home directory ``home`` does not exist, please use -Dlahore.home='someDir' OR create a 'lahore' directory in the current directory");
			process.exit(1);
		}

		Manager().registerExtensions();
		booted = true;
	}
	
    shared HashMap<String, Server> servers= HashMap<String, Server>();
    shared HashMap<String, Site> sites = HashMap<String, Site>();    	  
}

shared Map<String, Server>lahoreServers => lahore.servers;
shared Map<String, Site>lahoreSites => lahore.sites;

shared Boolean lahoreBooted => lahore.booted;

doc ("Run the `Lahore` engine.")
shared void run() {
	watchdog(0, "Lahore", "VM version: " + process.vmVersion);
    watchdog(0, "Lahore", "Operating System: " + process.os + " - " + process.osVersion);
    watchdog(0, "Lahore", "VM Arguments: " + process.arguments.string);
    watchdog(0, "Lahore", "Lahore version: 0.1");

	watchdog(0, "Lahore", "Using Lahore boot directory: ``lahore.home.string``");
	lahore.boot();
	createServers();	 	 	
 } // end of run	   

shared void createServers() {
    Server adminServer = createServer {};
	adminServer.addListener(consoleListener);
	loadAdminSite(adminServer);
	if (exists site = lahore.sites.first) {
		lahore.servers.put(site.item.host + ":" + site.item.port.string + " (admin)", adminServer);
	
		if (lahore.environment == "DEV") {
			adminServer.start(site.item.port, site.item.host);
		} else {
			adminServer.startInBackground(site.item.port, site.item.host); // throw in background
		}
		loadOtherSites();
		//loadOtherPlugins();
	}   
}

void loadOtherSites() {   
	Resource configDir = lahore.context.configStorage.basePath.resource;
	if (is Directory configDir) {	
		for (d  in configDir.childDirectories("*.site")) {
			if (is File f = d.childResource("site.yaml")) {
				watchdog(5, "Lahore", "Loading site from `` f.name`` ");

			}
		}
	}
}

void loadAdminSite(Server adminServer) {
 	if (exists site = loadSite("admin", true)) {
		// add static endppoint
	 	if (!site.staticURI.string.startsWith("http")) {
		    adminServer.addEndpoint(AsynchronousEndpoint {
		        path = startsWith(site.context + ".site") or pluginStaticPath(site.enabledPlugins);
		        service => serveStaticFile(site.staticURI.parent.string);
		        acceptMethod = {get};
		    });
		    watchdog(0, "Lahore", "Serving static files for site ``site.context`` from ``site.staticURI.parent.string``.");
		} else { //TODO redirect on http URI
			watchdog(1, "Lahore", site.staticURI.system.string + defaultSystem.string);
		}
		// add console which should not depend on any module/site or engine
	    adminServer.addEndpoint(Endpoint {
	        path = startsWith(site.context + "/console");
	        service => console;
	    });

		// add all admin routes
	    adminServer.addEndpoint(Endpoint {
	        path = startsWith(site.context);
	        service => site.endService;
	    });
	    	    			    		
		//home page - move to main site
		adminServer.addEndpoint(Endpoint {
	        path = isRoot();
	        service => webPage(site.staticURI.string + "/index.html");
	    });
	    lahore.sites.put(site.host + ":" + site.port.string + "/" + "admin", site);

  	} else {
 		watchdog(0, "Lahore", "Admin site could not be loaded - will end now!");
 	}
}


Site? loadSite(String siteId, Boolean create) {
	watchdog(2, "Lahore", "Loading site `` siteId`` ");
	
	Config? siteConfig = lahore.context.configStorage.load(siteId + ".site/site.yaml");
	
	if (exists siteConfig) {
		return createSite(siteId, siteConfig);
	} else {
		if (create) {
			return createSite(siteId, AssocConfig()); // empty config
			// TODO write config
		} else {
			return null;
		}
	}
}

Site? createSite(String siteId, Config config) {
	if ("web" == config.stringWithDefault("type", "web")) {
		return WebSite(siteId, lahore.context.staticResourcePath("site", siteId), config);
	}
	else if ("rest" == config.stringWithDefault("type", "web")) {
		return RestSite(siteId, config);
	} else {
		watchdog(0, "Lahore", "Only `web` and `rest` type of sites supported");
		return null;
	}
}

void webPage(String pathToFile)(Request request, Response response) {
    Path filePath = parsePath(pathToFile);
    if (is File file = filePath.resource) {
        value openFile = newOpenFile(file);
        try {
            Integer available = file.size;
            
            response.addHeader(contentLength(available.string));
            response.addHeader(contentType { 
                                    contentType = "text/html"; 
                                    charset = utf8; 
                               });
            
            /* Simple file read and write to response. 
               As we have no parsing/content modification we should use
               channels to transfer bytes efficiently. */
            ByteBuffer buffer = newByteBuffer(available);
            openFile.read(buffer);
            response.writeBytes(buffer.bytes());
        } finally {
            openFile.close();
        }
    } else {
        response.responseStatus=404;
    } 
}

