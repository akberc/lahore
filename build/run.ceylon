import ceylon.build.task { Goal }
import ceylon.build.tasks.ceylon { compile }
import ceylon.build.engine { build }

void run() {
    
    value compileAll = Goal {
        name = "compile";
        compile {
            moduleName = "com.dgwave.lahore.api com.dgwave.lahore.core com.dgwave.lahore.system";
            sourceDirectories = {"api", "core", "system"};
        };
    };

    build {
        project = "Lahore Build";
        compileAll
    };
}