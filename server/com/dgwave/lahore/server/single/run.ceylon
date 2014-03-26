import ceylon.logging { ... }
import com.dgwave.lahore.api { Config }
import com.dgwave.lahore.core { Engine }

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
            print("[``system.milliseconds``] ``p.string`` ``m``");
            if (exists e) {
                printStackTrace(e);
            }
        }
    };
      
    log.info("VM version: " + runtime.version);
    log.info("Operating System: " + operatingSystem.name + " - " + operatingSystem.version);
    log.info("VM Arguments: " + process.arguments.string);
    log.info("Lahore version: 0.1");
    
    log.info("Using Lahore boot directory: ``lahoreServer.home.string``");
    lahoreServer.boot();
    Engine engine = Engine({lahoreServer}, lahoreServer.siteList.sequence);
    lahoreServer.runWith(engine);	 	
} 