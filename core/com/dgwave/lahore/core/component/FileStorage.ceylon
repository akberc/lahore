import ceylon.file { ... }
import ceylon.language.meta.declaration { Module }
import com.dgwave.lahore.api { Storage, Locator, fileScheme, Config, Document, Preference, Store }

shared class FileStorage(localDir) satisfies Storage {
    Directory localDir;
    shared actual Locator base = Locator(fileScheme, localDir.path.uriString);
    
    shared actual Store<Config> configStore(String context, Module mod) {
        return FileConfigStore(localDir.path.childPath("config").childPath(context), context, mod);
    }
    
    shared actual Store<Document> dataStore(String context) {
        return FileDataStore(localDir.path.childPath("data").childPath(context));
    }
    
    shared actual Store<Preference> preferenceStore() {
        return FilePreferenceStore(localDir.path.childPath("prefs")); 
    }
}

abstract class FileStore(Path basePath) {
    shared Locator baseLocator = Locator(fileScheme, basePath.uriString);
    
    shared Boolean appendEntriesToExistingFile(Path fullPath, {Entry<String,String>+} entries) {
        Resource r = fullPath.resource;
        switch(r)
        case (is Directory | Link | Nil) {
            log.error("Filestore trying to append entries: ``fullPath`` is not a file");
            return false;
        }
        case (is File) {
            File.Appender appender = r.Appender("UTF-8");
            for (entry in entries) {
                if (entry.key.contains('=') || entry.item.contains('=')) {
                    log.error("Filestore key or value should not contain '='");
                    return false;
                }
            }
            
            for (entry in entries) {
                appender.writeLine(entry.key + "=" + entry.item);
            }
            appender.close();
            return true;
        }
    }
}

