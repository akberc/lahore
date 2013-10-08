import ceylon.build.task { Goal }
import ceylon.build.tasks.ceylon { compile }
import ceylon.build.engine { build }

void run() {
    
    value compileAll = Goal {
        name = "compile";
        compile {
            compilationUnits = {
            	"com.dgwave.lahore.api", "com.dgwave.lahore.core", "com.dgwave.lahore.server",
            	"com.dgwave.lahore.system", "com.dgwave.lahore.help", "com.dgwave.lahore.menu"
            };
            sourceDirectories = {"api", "core", "server", "system", "help", "menu"};
        };
    };

    build {
        project = "Lahore Build";
        compileAll
    };
}