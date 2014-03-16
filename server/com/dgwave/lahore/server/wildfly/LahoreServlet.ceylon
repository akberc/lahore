/*import javax.servlet.http { HttpServlet, HttpServletRequest, HttpServletResponse }
import java.io { PrintWriter }
import com.dgwave.lahore.api { Server, Site, Context, Assocable, Runtime }
import ceylon.file { Path, parsePath, Directory }

import ceylon.collection { LinkedList, HashMap }
import ceylon.logging { logger, Logger, Category, addLogWriter, info, Priority }
import org.jboss.modules { 
    Module { ceylonModuleLoader=callerModuleLoader},
    ModuleIdentifier { createModuleIdentifier=create},
    ModuleClassLoader
}
import com.dgwave.lahore.core { runWith }

Logger lahoreLog = logger(`module com.dgwave.lahore.api`);
SequenceBuilder<[String, String]> moduleNameAndVersions = SequenceBuilder<[String, String]>();

shared class LahoreServlet() extends HttpServlet() {
    
    addLogWriter {
        void log(Priority p, Category c, String m, Exception? e) {
            value print = p<=info 
            then process.writeLine 
            else process.writeError;
            print("[``system.milliseconds``] ``p.string`` ``m``");
            if (exists e) {
                printStackTrace(e);
            }
        }
    };
    
    variable String lahoreHome = process.propertyValue("jboss.server.base.dir") else ".";
    variable String lahoreConfigStore = process.propertyValue("jboss.server.config.dir") else "."
            + operatingSystem.fileSeparator + "lahore";
    variable String lahoreDataStore = process.propertyValue("jboss.server.data.dir") else "."
            + operatingSystem.fileSeparator + "lahore";
    
    doc ("The Lahore instance")
    object lahoreServer satisfies Server {
        
        shared actual variable Boolean booted = false;
        
        LinkedList<String> pluginList = LinkedList<String>();
        shared actual String[] pluginNames => pluginList.sequence; //FIXME
        
        shared LinkedList<Runtime> pluginRuntimes = LinkedList<Runtime>();
        shared actual void addPluginRuntime(Runtime pluginRuntime) => pluginRuntimes.add(pluginRuntime);
        
        shared actual Path home = parsePath(lahoreHome);
        
        shared actual String name = "Lahore Wildfly Server";
        shared actual String version = "0.1";
            
        shared actual Path config = parsePath(lahoreConfigStore);
        
        shared actual Path data = parsePath(lahoreDataStore);
        
        shared actual object defaultContext satisfies Context {
            shared actual Path staticResourcePath(String type, String name) { return home.childPath("static").childPath(name + "." + type);}
            
            shared actual Context passing(String string, Assocable arg)  {return this;}
            shared actual Assocable passed(String key)  {return "";} 
        }
        
        void loadModule(String modName, String modVersion) {
            ModuleIdentifier modIdentifier = createModuleIdentifier(modName, modVersion);
            Module mod = ceylonModuleLoader.loadModule(modIdentifier);
            ModuleClassLoader modClassLoader = mod.classLoader;
            modClassLoader.loadClass(modName+".module_");
        }
        
        shared void boot() {
            
            if (is Directory homeDir = home.resource) {
                lahoreLog.info("Using home directory: ``homeDir``");
            } else {
                lahoreLog.error("Lahore home directory ``home`` does not exist, please use -Dlahore.home='someDir' OR create a 'lahore' directory in the current directory");
                process.exit(1);
            }
            
            for(value moduleNameAndVersion in moduleNameAndVersions.sequence) {
                loadModule(moduleNameAndVersion[0], moduleNameAndVersion[1]);
                pluginList.add(moduleNameAndVersion[0] + "/" + moduleNameAndVersion[1]);
            }
            
            booted = true;
        }
        
        shared HashMap<String, Site> sites = HashMap<String, Site>();
        
        shared actual void addSite(Site site) {
            
            sites.put(site.host + ":" + site.port.string + "/" + "admin", site);
            
        }
        
        shared actual void removeSite(Site site) {
            // TODO
        }
    }
 
    
     shared actual void init() {
         lahoreHome = servletConfig.getInitParameter("lahore.home");
         String? preload = servletConfig.getInitParameter("preload");
         if (exists preload) {
             for (mv in preload.split(','.equals)) {
                 assert(exists i = mv.firstInclusion("/"));
                 String moduleName = mv[0..i-1];
                 String moduleVersion = mv[i+1...];
                 
                 moduleNameAndVersions.append([moduleName, moduleVersion]);
             }
             lahoreServer.boot();
         }
         runWith(lahoreServer);
     }
     
     shared actual void doGet(HttpServletRequest req, HttpServletResponse res) {
         
         Site? site = lahoreServer.sites.first?.item;

         res.contentType = "text/html";
         // Actual logic goes here.
         PrintWriter pout = res.writer;
         pout.println("<h1>" + "Hello" + req.string + "none" + "</h1>");
     }
}*/