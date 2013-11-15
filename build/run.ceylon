import ceylon.build.task { Goal }
import ceylon.build.tasks.ceylon { compile, all }
import ceylon.build.engine { build }

void run() {
    
    value compileAll = Goal {
        name = "compile";
        compile {
            modules = {
            	"com.dgwave.lahore.api", "com.dgwave.lahore.core", "com.dgwave.lahore.server",
            	"com.dgwave.lahore.system", "com.dgwave.lahore.help", "com.dgwave.lahore.menu"
            };
            sourceDirectories = {"api", "core", "server", "system", "help", "menu"};
            verboseModes = all;
        }
    };

    build {
        project = "Lahore Build";
        compileAll
    };
}