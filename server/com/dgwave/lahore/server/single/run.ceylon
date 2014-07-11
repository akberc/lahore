import ceylon.logging { ... }
import com.dgwave.lahore.api { Config }
import com.dgwave.lahore.core { Engine }
import ceylon.time { now }

"Logger for this module"
Logger log = logger(`module com.dgwave.lahore.server.single`);

"Reads configuration from Ceylon project config file"
Config bootConfig = SystemConfig();

"Run the `Lahore` standalone server."
shared void run() {

    "Determine defaultPriority threshold from config"
	String configuredPriority = bootConfig.stringWithDefault("lahore.logPriority", "INFO");
	for (priority in { fatal, error, warn, info, debug, trace }) {
		if (priority.string.equals(configuredPriority)) {
			defaultPriority = priority;
			break; 
		}
	}
    
    /* Add a console writer for the entire JVM */
    addLogWriter {
        void log(Priority p, Category c, String m, Exception? e) {
            if (p <= info) {
                process.writeLine ("[``now()``] ``p.string`` ``c.name``  ``m``");
            } else {
                process.writeError ("[``now()``] ``p.string`` ``c.name``  ``m``");
                process.writeError(operatingSystem.newline); // TODO bug in Ceylon or JVM
            }
            
            if (exists e) {
                printStackTrace(e);
            }
        }
    };
      
    log.info("VM version: " + runtime.version);
    log.info("Operating System: " + operatingSystem.name + " - " + operatingSystem.version);
    log.info("VM Arguments: " + process.arguments.string);
    log.info("Lahore version: 0.2");
    
    lahoreServer.boot();
    Engine engine = Engine({lahoreServer}, lahoreServer.siteList.sequence());
    lahoreServer.runWith(engine);	 	
} 