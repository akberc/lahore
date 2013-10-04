import ceylon.net.http.server.endpoints { serveStaticFile }
import ceylon.net.http.server { Server, createServer, AsynchronousEndpoint, startsWith, Endpoint, isRoot, Request, Response}
import com.dgwave.lahore.server.console { console, consoleListener }
import ceylon.file { Path, parsePath, File, Directory, current, parseURI, defaultSystem }
import ceylon.io { newOpenFile }
import ceylon.io.buffer { ByteBuffer, newByteBuffer }
import ceylon.net.http { contentType, contentLength, get }
import ceylon.io.charset { utf8 }
import com.dgwave.lahore.api { watchdog, Context, Storage, Entity, Config, Assocable, Site, LahoreServer = Server, Logger }
import ceylon.collection { HashMap, LinkedList }
import java.util { JavaList = List, JavaIterator = Iterator }
import java.lang { JavaString = String }
import com.dgwave.lahore.core.component { SqlStorage, fileStorage }
import com.dgwave.lahore.core { pluginStaticPath, runWith }


shared variable Integer lahoreDebugLevel =9;

doc ("The Lahore instance")
object lahoreServer satisfies LahoreServer {

    shared actual variable Boolean booted = false;
    
    LinkedList<String> pluginList = LinkedList<String>();
    shared actual String[] plugins = pluginList.sequence; //FIXME

    Config bootConfig = SystemConfig();
    
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
    
    if (exists p = parseInteger(bootConfig.stringWithDefault("lahore.debugLevel", "9"))) {
        lahoreDebugLevel = p;
    }
    
    shared actual object defaultContext satisfies Context {
        
        variable String configURI = bootConfig.stringWithDefault("lahore.configStore", 
        home.absolutePath.childPath("config").uriString); // default value
        configURI = configURI.replace("{lahore.home}", home.uriString); // replace placeholder
        // FIXME
        configURI = "lahore/config";
        shared actual Storage<Config> configStorage = fileStorage(parsePath(configURI));
        
        // TODO based on actual URI scheme
        
        variable String dataURI = bootConfig.stringWithDefault("lahore.dataStore", 
        home.absolutePath.childPath("data").uriString); // default value
        dataURI = dataURI.replace("{lahore.home}", home.uriString); // replace placeholder
        // FIXME
        dataURI = "lahore/data";
        shared actual Storage<Entity> entityStorage = SqlStorage(parsePath(dataURI));
        
        shared actual Path staticResourcePath(String type, String name) { return home.childPath("static").childPath(name + "." + type);}
        
        shared actual Context passing(String string, Assocable arg)  {return this;}
        shared actual Assocable passed(String key)  {return "";} 
    }
    
    shared void boot() {
        
        if (is Directory homeDir = home.resource) {
            watchdog(0, "Lahore", "Using home directory: ``homeDir``");
        } else {
            watchdog(0, "Lahore", "Lahore home directory ``home`` does not exist, please use -Dlahore.home='someDir' OR create a 'lahore' directory in the current directory");
            process.exit(1);
        }
        
        JavaList<JavaString> loaded = Loader().registerExtensions();
        JavaIterator<JavaString> iter = loaded.iterator();
        while (iter.hasNext()) {
            pluginList.add(iter.next().string);
        }

        booted = true;
    }
    
    shared HashMap<String, Server> servers= HashMap<String, Server>();
    shared HashMap<String, Site> sites = HashMap<String, Site>();

    shared actual void addSite(Site site) {
        if (exists adminServer = servers.first?.item) {
            adminServer.addEndpoint(Endpoint {
                path = startsWith(site.context);
                service => site.endService;
            });
            sites.put(site.host + ":" + site.port.string + "/" + "admin", site);

            //home page - move to main site
            adminServer.addEndpoint(Endpoint {
                path = isRoot();
                service => webPage(site.staticURI.string + "/index.html");
            });
            
            
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
        }
    }
    
    shared actual void removeSite(Site site) {
    }

    shared actual Logger logger(String component) => LahoreLogger(component);
    
}

shared Map<String, Server> lahoreServers => lahoreServer.servers;
shared Map<String, Site> lahoreSites => lahoreServer.sites;
shared List<String> lahorePlugins => lahoreServer.plugins;

shared Boolean lahoreBooted => lahoreServer.booted;

shared void createServers() {
    Server adminServer = createServer {};
    adminServer.addListener(consoleListener);
    lahoreServer.servers.put("localhost" + ":" + "8080" + " (admin)", adminServer); //FIXME
    
    // pass control to core
    runWith(lahoreServer);

    if (exists site = lahoreServer.sites.first) {
        if (lahoreServer.environment == "DEV") {
            adminServer.start(site.item.port, site.item.host);
        } else {
            adminServer.startInBackground(site.item.port, site.item.host); // throw in background
        }
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

