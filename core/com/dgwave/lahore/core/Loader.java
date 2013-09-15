package com.dgwave.lahore.core;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.jboss.modules.Module;
import org.jboss.modules.ModuleIdentifier;

import com.redhat.ceylon.common.config.CeylonConfig;
import com.redhat.ceylon.compiler.java.runtime.metamodel.Metamodel;
import com.redhat.ceylon.cmr.api.ArtifactContext;
import com.redhat.ceylon.cmr.api.ArtifactResult;
import com.redhat.ceylon.cmr.api.RepositoryManager;
import com.redhat.ceylon.cmr.ceylon.CeylonUtils;

public class Loader {

    public void registerExtensions() {

        try {
            
            List<String> toLoad = new ArrayList<String>();
            toLoad.addAll(Arrays.asList(CeylonConfig.get().getOptionValues("lahore.plugins.preload")));
            String [] toLoadNames = toLoad.toArray(new String[] {});

            RepositoryManager rm = CeylonUtils.repoManager().buildManager(); 
            
            for (String ex : toLoadNames) {
                String[] nv = ex.split("/");
                ArtifactContext context = new ArtifactContext(nv[0], nv[1], ArtifactContext.CAR, ArtifactContext.JAR);
                ArtifactResult result = rm.getArtifactResult(context);
                
                if (result == null) {
                    throw new Exception("Plugin: " + ex + " could not be found in configured repositories");
                } else {
                    Module onePlugin = Module.getCallerModuleLoader().loadModule(ModuleIdentifier.create(nv[0], nv[1]));
                    System.out.println("Loader: Plugin loaded is: " + onePlugin.toString());                
                    Metamodel.loadModule(nv[0], nv[1], result, onePlugin.getClassLoader());
                }
            }
            
        } catch (Exception e) {
            System.err.println("Loader: Error loading plugin ': " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
}
