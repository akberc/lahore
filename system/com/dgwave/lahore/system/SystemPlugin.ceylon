import com.dgwave.lahore.api { ... }
import ceylon.logging { logger, Logger }

shared class SystemPlugin(plugin) satisfies Plugin {
    shared Runtime plugin;

}

Logger log = logger(`module com.dgwave.lahore.system`);
