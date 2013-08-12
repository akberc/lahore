package com.dgwave.lahore.core;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.jboss.modules.Module;
import org.jboss.modules.ModuleIdentifier;

import com.redhat.ceylon.common.config.CeylonConfig;
import com.redhat.ceylon.compiler.java.runtime.metamodel.Metamodel;
import com.redhat.ceylon.cmr.api.ArtifactResult;
import com.redhat.ceylon.cmr.api.ArtifactResultType;
import com.redhat.ceylon.cmr.api.ImportType;
import com.redhat.ceylon.cmr.api.RepositoryException;
import com.redhat.ceylon.cmr.api.VisibilityType;


public class Manager {

	void registerExtensions() {
		ModuleIdentifier modId = ModuleIdentifier.create("com.dgwave.lahore.ext", "0.1");
		try {
			Module onePlugin = Module.getCallerModuleLoader().loadModule(modId);
			System.out.println("Manager: Plugin loaded is: " + onePlugin.toString());
			ArtifactResult ar = makeExtensionArtifact(System.getProperty("user.home") +"/.ceylon/repo", modId.getName(), modId.getSlot(), CeylonConfig.get().getOptionValues("modules.preload"));
			Metamodel.loadModule(modId.getName(), modId.getSlot(), ar, onePlugin.getClassLoader());
			
            for (String ex : CeylonConfig.get().getOptionValues("modules.preload")) {
				String[] nv = ex.split("/");
				onePlugin = Module.getCallerModuleLoader().loadModule(ModuleIdentifier.create(nv[0], nv[1]));
				System.out.println("Manager: Plugin loaded is: " + onePlugin.toString());				
				Metamodel.loadModule(nv[0], nv[1], makeExtensionArtifact(System.getProperty("user.home") +"/.ceylon/repo", nv[0], nv[1], new String[] {}), onePlugin.getClassLoader());
			}
            
			// Metamodel.resetModuleManager();
			
/*			
			final Field field = onePlugin.getClass().getDeclaredField(
					"mainClassName");
			field.setAccessible(true);
			field.set(onePlugin, name + ".run_");

			java.lang.Class<?> clazz = java.lang.Class.forName(name + ".run_",
					true, onePlugin.getClassLoader());
			
			Method[] ms = clazz.getDeclaredMethods(); // String[].class);
			Method m1 = null;
			for (Method m : ms) {
				if (m.getName().startsWith("run")) {
					m1 = m;
				}
			}
			
			if (!m1.isAccessible()) {
				m1.setAccessible(true);
			}
			m1.invoke(null, null); // new Object[] {});
*/
		} catch (Exception e) {
			System.err.println("Manager: Error loading plugins - is the plugin interface fully implemented? ': " + e.getMessage());
			e.printStackTrace();
			System.exit(1);
		}
	}
	
    private ArtifactResult makeExtensionArtifact(final String repo, final String name, final String version, final String[] extensions) {
        return new ArtifactResult(){

            @Override
            public String name() {
            	return name;
            }

            @Override
            public String version() {
            	return version;
            }	

            @Override
            public ImportType importType() {
            	return ImportType.EXPORT;
            }

            @Override
            public ArtifactResultType type() {
            	return ArtifactResultType.CEYLON;
            }

            @Override
            public VisibilityType visibilityType() {
            	return VisibilityType.LOOSE;
            }

            @Override
            public File artifact() throws RepositoryException {
                try {
                	String fileName = repo + "/" + name.replace(".","/") + "/" + version + "/" + name + "-" + version + ".car"; 
					return new File(fileName);
				} catch (Exception e) {
					return null;
				}
            }

            @Override
            public List<ArtifactResult> dependencies() throws RepositoryException {
                List<ArtifactResult> ret = new ArrayList<ArtifactResult>();
                for (String ex : extensions) {
					String[] nv = ex.split("/");
					ret.add(makeExtensionArtifact(repo, nv[0], nv[1], new String[] {}));
				}
                return ret;
            }};
    }
}
