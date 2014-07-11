import com.dgwave.lahore.api { Locator, Config, Primitive, Data, Preference, Store }
import ceylon.file { Path, Directory, Link, Nil, Resource, File }
import ceylon.language.meta.declaration { Module }
import ceylon.collection { StringBuilder }

class FileDataStore(Path path) extends FileStore(path) satisfies Store<Data> {
    shared actual Locator base => baseLocator;
    shared actual Boolean append(Data storable) => nothing;
    
    shared actual {Data*} find(String query) => nothing;
    
    shared actual Data? load({Primitive+} uniqueKey, Integer version) => nothing;
    
    shared actual {Data*} loadAll({Primitive+} uniqueKey) => nothing;
    
    shared actual String relativePath => nothing;
    
    shared actual Data? remove({Primitive+} uniqueKey, Integer version) => nothing;
    
    shared actual Boolean save(Data storable) => nothing;
    
}

class FilePreferenceStore(Path path) extends FileStore(path) satisfies Store<Preference> {
    shared actual Locator base => baseLocator;
    shared actual Boolean append(Preference storable) => nothing;
    
    shared actual {Preference*} find(String query) => nothing;
    
    shared actual Preference? load({Primitive+} uniqueKey, Integer version) => nothing;
    
    shared actual {Preference*} loadAll({Primitive+} uniqueKey) => nothing;
    
    shared actual String relativePath => nothing;
    
    shared actual Preference? remove({Primitive+} uniqueKey, Integer version) => nothing;
    
    shared actual Boolean save(Preference storable) => nothing;
        
}

class FileConfigStore(Path path, relativePath, Module mod) 
        extends FileStore(path) satisfies Store<Config> {
    shared actual String relativePath;
    
    shared actual Locator base => baseLocator;
    
    shared actual Boolean append(Config storable){
        return false;
    }
    
    doc("Think of path as a table and keys of a row in the table")
    shared actual Config? load({Primitive+} uniqueKey, Integer version)  {
        Resource r = path.childPath(relativePath).resource;
        switch(r)
        case (is File) {
            if (relativePath.endsWith("json")) {
                return parseJsonAsConfig(relativePath, readFileAsString(r));	
            } else if (relativePath.endsWith("yml") || relativePath.endsWith("yaml")) {
                // TODO return parseYamlAsConfig(readFileAsString(r));
                return null;	
            } else {
                log.error("Configuration file ``relativePath`` is not supported");
                return null;
            }
        } else {
            log.error("Configuration file ``relativePath`` does not exist!");
            return null;
        }		
    }
    
    shared actual {Config*} loadAll({Primitive+} uniqueKey) {
        return {};
    }
    
    shared actual {Config*} find (String relativePath) {
        return {};
    }
    
    shared actual Config? remove({Primitive+} uniqueKey, Integer version) {
        return null;
    }
    
    shared actual Boolean save(Config storable) {
        return false;
    }
    
    shared String readFileAsString(File file) {  
        value sb = StringBuilder();
        value reader = file.Reader();
        try {
            while(exists line = reader.readLine()) {
                sb.append(line);
                sb.append("\n");
            }
        } finally {
            reader.close();
        }
        return sb.string;
    }  	
}

doc("This is a convenience method. Responsibility of the client to keep or discard the storage")
throws(`class Exception`)
shared FileStorage fileStorage(Path path) {
    Resource dir = path.resource;
    try {
        switch(dir)
        case (is Nil) {
            dir.createDirectory();
            return fileStorage(dir.path);
        }
        case(is Directory) {
            return FileStorage(dir);
        }
        case (is File) {
            throw Exception("File exists at location ``path.string``. It should be a directory");
        }
        case (is Link) {
            return fileStorage(dir.linkedPath);
        }
    } catch (Exception ex) {
        throw ex;
    }
}
