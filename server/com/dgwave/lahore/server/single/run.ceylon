import ceylon.logging { ... }
import com.dgwave.lahore.api { Config }
import com.dgwave.lahore.core { Engine }
import ceylon.time { now }

Logger log = logger(`module com.dgwave.lahore.server.single`);

Config bootConfig = SystemConfig();

"Run the `Lahore` standalone server."
shared void run() {

	String configuredPriority = bootConfig.stringWithDefault("lahore.logPriority", "INFO");
	for (priority in { fatal, error, warn, info, debug, trace }) {
		if (priority.string.equals(configuredPriority)) {
			defaultPriority = priority;
			break; 
		}
	}
		
    addLogWriter {
        void log(Priority p, Category c, String m, Exception? e) {
            value print = p<=info 
            then process.writeLine 
            else process.writeError;
            print("[``now()``] ``p.string`` ``c.name``  ``m``");
            if (exists e) {
                printStackTrace(e);
            }
        }
    };
      
    log.info("VM version: " + runtime.version);
    log.info("Operating System: " + operatingSystem.name + " - " + operatingSystem.version);
    log.info("VM Arguments: " + process.arguments.string);
    log.info("Lahore version: 0.1");
    
    lahoreServer.boot();
    Engine engine = Engine({lahoreServer}, lahoreServer.siteList.sequence);
    lahoreServer.runWith(engine);	 	
} 