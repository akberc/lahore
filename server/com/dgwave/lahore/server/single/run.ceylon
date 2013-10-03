import com.dgwave.lahore.api { watchdog }

"Run the `Lahore` standalone server."
shared void run() {
    watchdog(0, "Lahore", "VM version: " + process.vmVersion);
    watchdog(0, "Lahore", "Operating System: " + process.os + " - " + process.osVersion);
    watchdog(0, "Lahore", "VM Arguments: " + process.arguments.string);
    watchdog(0, "Lahore", "Lahore version: 0.1");
    
    watchdog(0, "Lahore", "Using Lahore boot directory: ``lahoreServer.home.string``");
    lahoreServer.boot();
    createServers();	 	 	
} 